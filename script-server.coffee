fs               = require 'fs'
path             = require 'path'
cluster          = require 'cluster'
assert           = require 'assert'
logger           = require('morgan') 'dev'
urlparse         = require('url').parse
{ createServer } = require 'http'

# meow
{ CAT, HOST, PORT, WEBROOT, WORKERS } = process.env

HOST    ?= 'localhost'
PORT    ?= 9999
WORKERS ?= require('os').cpus().length + 1

# I want coercion here
assert WEBROOT

onInterval = (t, f) -> setInterval f, t # swap args for coffeescript
isIterator = (x) -> x? and x[Symbol.iterator]? and x.next instanceof Function
log        = (s) ->
	now  = (new Date).toLocaleTimeString()
	from = cluster.isMaster and 'master' or 'worker'
	console.log "#{now}  #{from}(#{process.pid}): #{s}"

new_slave = ->
	w = cluster.fork()
	w.on 'message', (msg) -> conns++ if msg is 'request'
	log "forked new worker(#{w.process.pid})"

isolate = (root, what) ->
	root = path.join root, '/'
	tmp  = path.join root, what
	return tmp if tmp.startsWith root

if cluster.isMaster
	conns = 0
	prev  = 0

	onInterval 30000, ->
		if prev isnt conns
			prev = conns
			log "watch(30s): connections = #{conns}"

	log "creating #{WORKERS} workers; reincarnation: #{CAT?}; WEBROOT=#{WEBROOT}"
	new_slave() for i in [ 1 .. WORKERS ]

	cluster.on 'exit', (w, code, signal) ->
		log "worker(#{w.process.pid}) exited (#{code or signal})"
		if CAT
			log "reincarnating worker(#{w.process.pid})"
			new_slave()

	return

s = createServer (req, res) ->
	process.send 'request'

	logger req, res, (->)

	try
		where = isolate WEBROOT, urlparse(req.url).pathname

		unless where?
			res.statusCode = 403
			res.end()
			return

		script = null

		try
			script = require where
		catch
			res.statusCode = 404
			res.end()
			return

		script = script.run?(req, res) or script?(req, res)

		if isIterator script
			loop
				tmp = script.next()
				break if tmp.done
				res.write tmp.value.toString()

		require.cache[where].watcher ?=
			fs.watch where, { persistent: false }, ->
				log "#{where} changed; deleting cached copy"
				delete require.cache[where]
				@close()
	catch e
		res.statusCode = 503
		res.write e.stack
		delete require.cache[where]
		fs.unwatchFile where

	res.end()

s.listen PORT, HOST
log "listening on #{HOST}:#{PORT}"

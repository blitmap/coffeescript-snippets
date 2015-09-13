fs                                = require 'fs'
cluster                           = require 'cluster'
logger                            = require('morgan') 'combined'
{ createServer }                  = require 'http'
{ isNullOrUndefined, isFunction } = require 'util'

cat     = process.env.ILIVEIDIEILIVEAGAIN
port    = process.argv[2] or process.env.PORT or 9999
host    = null
workers = null

# coffee --nodejs --harmony appserver [, port][, host][, workers]
if process.argv[4]?
	workers = process.argv[4]
	host    = process.argv[3]
else
	workers = process.argv[3]

host    ?= process.env.HOST    or 'localhost'
workers ?= process.env.WORKERS or require('os').cpus().length + 1

onInterval = (t, f) -> setInterval f, t # swap args for coffeescript
isIterator = (x) -> (not isNullOrUndefined(x)) and isFunction(x.next) and x[Symbol.iterator]?
log        = (s) ->
	now  = (new Date).toLocaleTimeString()
	from = cluster.isMaster and 'master' or 'worker'
	console.log "#{now}  #{from}(#{process.pid}): #{s}"

new_slave = ->
	w    = cluster.fork()
	wpid = w.process.pid # saved for .on('exit')
	w.on 'message', (msg) -> conns++ if msg is 'request'
	w.on 'exit', (w, code, signal) ->
		log "worker(#{wpid}) died (#{code or signal})"
		if cat
			log 'spawning replacement worker'
			new_slave()

if cluster.isMaster
	conns = 0
	prev  = 0

	onInterval 30000, ->
		if prev isnt conns
			prev = conns
			log "timer(every 30s if different): connections = #{conns}"

	log "spawning #{workers} workers"
	new_slave() for i in [ 1 .. workers ]
	return

s = createServer (req, res) ->
	process.send 'request'

	logger req, res, (->) # I don't know why this is necessary.

	# XXX: support not having PATH_TRANSLATED available
	# nginx reverse-proxy also guarantees it's in document root + exists
	path = req.headers.path_translated

	try
		script = require path
		script = script.run?(req, res) or script?(req, res)

		if isIterator script
			loop
				tmp = script.next()
				break if tmp.done
				res.write tmp.value.toString()

		require.cache[path].watcher ?=
			fs.watch path, { persistent: false }, (event, filename) ->
				fs.unwatchFile path
				log "#{filename} changed; deleting cached copy"
				delete require.cache[path]
	catch e
		res.write e.stack
		delete require.cache[path]
		fs.unwatchFile path

	res.end()
		
s.listen port, host
log "listening on #{host}:#{port}"

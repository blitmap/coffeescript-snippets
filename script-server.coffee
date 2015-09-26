fs                                = require 'fs'
path                              = require 'path'
cluster                           = require 'cluster'
logger                            = require('morgan') 'combined'
urlparse                          = require('url').parse
{ createServer }                  = require 'http'
{ isNullOrUndefined, isFunction } = require 'util'

cat        = process.env.ILIVEIDIEILIVEAGAIN
port       = process.argv[2] or process.env.PORT or 9999
host       = null
workers    = null
webroot    = '/srv/http'
scriptroot = 'exe/node'

# coffee --nodejs --harmony appserver [, port][, host][, workers]
if process.argv[4]?
	workers = process.argv[4]
	host    = process.argv[3]
else
	workers = process.argv[3]

host    ?= process.env.HOST    or 'localhost'
workers ?= process.env.WORKERS or require('os').cpus().length + 1

scriptroot = path.join webroot, scriptroot, '/'

onInterval = (t, f) -> setInterval f, t # swap args for coffeescript
isIterator = (x) -> (not isNullOrUndefined(x)) and isFunction(x.next) and x[Symbol.iterator]?
log        = (s) ->
	now  = (new Date).toLocaleTimeString()
	from = cluster.isMaster and 'master' or 'worker'
	console.log "#{now}  #{from}(#{process.pid}): #{s}"

new_slave = ->
	w = cluster.fork()
	w.on 'message', (msg) -> conns++ if msg is 'request'
	log "forked new worker(#{w.process.pid})"

if cluster.isMaster
	conns = 0
	prev  = 0

	onInterval 30000, ->
		if prev isnt conns
			prev = conns
			log "timer(every 30s if different): connections = #{conns}"

	log "creating #{workers} workers"
	new_slave() for i in [ 1 .. workers ]

	cluster.on 'exit', (w, code, signal) ->
		log "worker(#{w.process.pid}) exited (#{code or signal})"
		if cat
			log "reincarnating worker(#{w.process.pid})"
			new_slave()

	return

s = createServer (req, res) ->
	process.send 'request'

	logger req, res, (->) # middleware outside express, lulz

	try
		reqpath  = req.headers.path_translated
		reqpath ?= path.join webroot, urlparse(req.url).pathname

		unless reqpath.startsWith scriptroot
			res.statusCode = 403
			res.end()
			return

		script = require reqpath
		script = script.run?(req, res) or script?(req, res)

		if isIterator script
			loop
				tmp = script.next()
				break if tmp.done
				res.write tmp.value.toString()

		require.cache[reqpath].watcher ?=
			fs.watch reqpath, { persistent: false }, (event, filename) ->
				fs.unwatchFile reqpath
				log "#{filename} changed; deleting cached copy"
				delete require.cache[reqpath]
	catch e
		res.write e.stack
		delete require.cache[reqpath]
		fs.unwatchFile reqpath

	res.end()

s.listen port, host
log "listening on #{host}:#{port}"

{ createHmac } = require 'crypto'
express        = require 'express'
logger         = require('morgan') 'combined'

# [ 'coffee', 'thiss.coffee', 'arg1', 'arg2' ]
rport = process.env.RPORT or '5000'
sport = process.env.SPORT or +rport + 1

sigcheck = (req, res, next) ->
	for t in process.env.GITHUB_SECRET_TOKEN.split ','
		hmac = createHmac 'sha1', t
		hmac.setEncoding 'hex'
		hmac.write req.body
		hmac.end()

		if req.headers['x-hub-signature'] is "sha1=#{hmac.read()}"
			next()
			break

posts = []

receiver = express()
receiver.disable 'x-powered-by'
receiver.use logger

receiver.post '/',
	require('body-parser').text( type: '*/*' ),
	sigcheck,
	(req, res) ->
		posts.push req.body
		res.sendStatus 202

sender = express()
sender.disable 'x-powered-by'
sender.use logger
sender.enable 'etag'

sender.get '/:n?', (req, res) ->
	n = -(req.params.n or Infinity)

	if isNaN n
		res.json []
		return
		
	res.send "[#{posts.join ','}]"

receiver.listen rport,              -> console.log "receiver listening on: *:#{rport}"
sender  .listen sport, 'localhost', -> console.log "sender listening on: localhost:#{sport}"

tee = ->

wrapHandler = (handler) ->
	(module, filename) ->
		run = module._compile
		module._compile = (content, filename) -> tee.call this, content, run(content, filename)
		handler module, filename

cf = (m.exports for path, m of require.cache when path.match /coffee-script\./)[0]

if cf
	{ readFileSync } = require 'fs'

	loadFile = (module, filename) ->
		content = readFileSync filename, 'utf8'

		if content.charCodeAt() is 0xFEFF
			content = content.slice 1

		try
			js = cf.compile content, { filename, bare: true, literate: cf.helpers.isLiterate filename }
		catch err
			throw cf.helpers.updateSyntaxError err, content, filename

		module._compile js, filename

	require.extensions[ext] = loadFile for ext in cf.FILE_EXTENSIONS

require.extensions[ext] = wrapHandler handler for ext, handler of require.extensions

module.exports = (f) -> tee = f if f? # shutup.

###
example:

hijack = require 'require-hijack'
hijack console.log

# console.log receives contents of script and return value (not module.exports)
script = require './script'

###

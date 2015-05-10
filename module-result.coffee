# wraps require('module').Module::_compile so we can collect
# a return value from require()'d scripts (not module.exports)
{ Module } = require 'module'

real_compile = Module::_compile

Module::_compile = (_, filepath) -> require.cache[filepath].result = real_compile.apply this, arguments

###
This section is coffeescript-specific.
Coffeescript [annoyingly] compiles require()'d files
wrapped in a function ((function (){})()).  This redefines
the extension handler to compile with `bare` enabled.
###

cf = (m.exports for path, m of require.cache when path.match /coffee-script\./)[0]

if cf
	{ readFileSync } = require 'fs'

	loadFile = (module, filename) ->
		content = readFileSync filename, 'utf8'

		# strip possible byte-order mark
		if content.charCodeAt() is 0xFEFF
			content = content.slice 1

		try
			js = cf.compile content, { filename, bare: true, literate: cf.helpers.isLiterate filename }
		catch err
			throw cf.helpers.updateSyntaxError err, content, filename

		module._compile js, filename

	require.extensions[ext] = loadFile for ext in cf.FILE_EXTENSIONS

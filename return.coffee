# adds a `return ` to precede js wrapped in a (function ()) so
# we can get the return value -- coffeescript, looking at you

{ Module } = require 'module'

compile = Module::_compile

Module::_compile = (args...) ->
	args[0] = args[0].replace /^\(function\s*\(\)\s*{/, 'return $&'

	compile args...

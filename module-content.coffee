# wraps require('module').Module::_compile so we can save the JS passed to it
{ Module } = require 'module'

old_compile = Module::_compile

Module::_compile = (content, filepath) ->
	require.cache[filepath].js = content
	old_compile.apply this, arguments

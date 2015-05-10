# wraps require('module').Module::_compile so we can collect
# a return value from require()'d scripts (not module.exports)
# note: coffeescript needs to be compiled with `bare` for this to work (no (function (){})())
{ Module } = require 'module'

old_compile = Module::_compile

Module::_compile = (_, filepath) -> require.cache[filepath].result = old_compile.apply this, arguments

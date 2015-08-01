# wraps require('module').Module::_compile so we can collect
# a return value from require()'d scripts (not module.exports)
# note: coffeescript needs to be compiled with `bare` for this to work (no (function (){})())
{ Module } = require 'module'

compile = Module::_compile

Module::_compile = (_, path) -> require.cache[path].result = compile arguments...

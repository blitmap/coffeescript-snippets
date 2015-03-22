# NOTE: this is for binding/loading C functions, it would not well for C++ prototypes
function_prototype = /\s*(\S+)\s*\((.*)\)\s*(?:->)?\s*(\S*)?\s*/

# 'atoi(string) -> int' -> { name: 'atoi', args: [ 'string' ], ret: 'int' }
unproto = (desc) ->
	stat = desc.match function_prototype

	throw new Error 'invalid prototype: #{desc}' unless stat

	args = (a.trim() or '...' for a in stat[3].split ',')

	{ args, name: stat[1], ret: stat[3] }

load_from_lib = (lib, funcs...) ->
	ffi = require 'ffi'
	tmp = {}

	for f in funcs
		f = unproto f

		tmp[f.name] = [ f.ret, f.args ]

	return ffi.Library lib, tmp

module.exports = { unproto, load_from_lib }

# simple test exec?
return unless require.main is module

libm = load_from_lib 'libm', 'ceil  (   double   ) -> double', 'floor(double) double'

console.log "libm::ceil(3.14159) -> #{libm.ceil 3.14159}"
console.log "libm::floor(3.14159) -> #{libm.floor 3.14159}"

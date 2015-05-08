{ Readable, Transform } = require 'stream'

class MapStream extends Transform
	constructor: (@f, opts = objectMode: true) -> super opts

	_transform: (chunk, enc, next) ->
		@push @f.apply chunk
		next()

String::toRot13 ?= -> (String.fromCharCode c.charCodeAt() + (c.toLowerCase() < 'n' and 13 or -13) for c in @).join ''

Array::toStream = (opts = { objectMode: true }) ->
	r = new Readable opts
	r.push v for v in @
	r.push null
	r._read = ->
	return r

# idon'tlikerepeatingmyself..
Object::toStream = -> [ @ ].toStream()

class IterStream extends Readable
	constructor: (@iter, opts = { objectMode: true }) -> super opts

	_read: ->
		tmp = @iter.next()
		@push not tmp.done and tmp.value or null

# WHERE IS YOUR GOD
'cat'.toStream(objectMode: false).pipe(new MapStream -> @toString().toRot13()).pipe process.stdout
process.nextTick console.log

CountTo = (x) -> yield i for i in [ 1 .. x ]

new IterStream(CountTo 5).pipe(new MapStream -> @toString()).pipe process.stdout
process.nextTick console.log

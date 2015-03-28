Array::first      ?= -> @[0]
Array::last_index ?= -> @length - 1
Array::last       ?= -> @[@last_index()]

Array::equal ?= (o, deep = true) ->
	return true  if o is @
	return false unless o instanceof Array
	return false unless @length is o.length
	return false for v, i in @ when not (v instanceof Array and deep and v.equal(o[i], deep) or v is o[i])
	return true

Array::strict_equal ?= (o) -> @equal o, false

Array::repeat ?= (n = 1) ->
	tmp = []
	tmp.push @... while n-- > 0
	return tmp

String::repeat ?= (n = 1) -> new Array(Math.max(n, 0) + 1).join @

String::lpad ?= (n = 0, p = ' ') ->
	return @toString() unless n > @length
	return p[0].repeat(n - @length) + @

String::rpad ?= (n = 0, p = ' ') ->
	return @toString() unless n > @length
	return @ + p[0].repeat(n - @length)

String::pad ?= (n = 0, p = ' ') ->
	return @toString() unless n > @length
	return @lpad(Math.floor((n + @length) / 2), p).rpad(n, p)

return unless require.main is module

{strictEqual} = require 'assert'

x = [ 'a', 'b', 'c' ]

strictEqual x.first(),      x[0],            'Array::first()'
strictEqual x.last_index(), x.length - 1,    'Array::last_index()'
strictEqual x.last(),       x[x.length - 1], 'Array::last()'

strictEqual ['a']       .equal(['a']),            true,  'Array::equal()'
strictEqual ['a']       .equal(['b']),            false, 'Array::equal()'
strictEqual ['a', []]   .equal(['a', []]),        true,  'Array::equal()'
strictEqual ['a', []]   .equal(['a', []], false), false, 'Array::equal()'
strictEqual ['a', ['b']].equal(['a', ['b']]),     true,  'Array::equal()'

strictEqual [[]].strict_equal([[]]), false, 'Array::strict_equal()'

strictEqual ['a', 'b'].repeat( 0).equal([]), true, 'Array::repeat()'
strictEqual ['a', 'b'].repeat(-1).equal([]), true, 'Array::repeat()'
strictEqual ['a', 'b'].repeat( 3).equal(['a', 'b', 'a', 'b', 'a', 'b']), true, 'Array::repeat()'

strictEqual 'ab'.repeat( 3), 'ababab', 'String::repeat()'
strictEqual 'ab'.repeat( 0),       '', 'String::repeat()'
strictEqual 'ab'.repeat(-3),       '', 'String::repeat()'

strictEqual 'cat'.lpad( 5     ), '  cat', 'String::lpad()'
strictEqual 'cat'.lpad( 0     ),   'cat', 'String::lpad()'
strictEqual 'cat'.lpad(-5     ),   'cat', 'String::lpad()'
strictEqual 'cat'.lpad( 5, '#'), '##cat', 'String::lpad()'

strictEqual 'cat'.rpad( 5     ), 'cat  ', 'String::rpad()'
strictEqual 'cat'.rpad( 0     ),   'cat', 'String::rpad()'
strictEqual 'cat'.rpad(-5     ),   'cat', 'String::rpad()'
strictEqual 'cat'.rpad( 5, '#'), 'cat##', 'String::rpad()'

strictEqual 'cat'.pad( 7     ), '  cat  ', 'String::pad()'
strictEqual 'cat'.pad( 0     ),     'cat', 'String::pad()'
strictEqual 'cat'.pad(-7     ),     'cat', 'String::pad()'
strictEqual 'cat'.pad( 7, '#'), '##cat##', 'String::pad()'

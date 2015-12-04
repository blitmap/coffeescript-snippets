Array::first      ?= -> @[0]
Array::last_index ?= -> @length - 1
Array::last       ?= -> @[@last_index()]

Array::equivalent ?= (o) ->
	return true  if o is @
	return false unless o instanceof Array
	return false unless @length is o.length
	return false for v, i in @ when not (v instanceof Array and v.equivalent(o[i]) or v is o[i])
	return true

Array::repeat ?= (n = 1) ->
	tmp = []
	tmp.push @... while n-- > 0
	return tmp

Array::isEmpty ?= -> @length is 0

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

String::reverse ?= -> @toString().split('').reverse().join('')

Number::bit ?= (i, b) ->
	n = @valueOf()
	return n ^ (-b ^ n) & (1 << i) if b?
	return !!(n >> i & 1)

Object::values ?= (o) -> (v for own _, v of o)

return unless require.main is module

{ strictEqual } = require 'assert'

x = [ 'a', 'b', 'c' ]

strictEqual x.first(),      x[0],            'Array::first()'
strictEqual x.last_index(), x.length - 1,    'Array::last_index()'
strictEqual x.last(),       x[x.length - 1], 'Array::last()'

strictEqual ['a']       .equivalent(['a']),            true,  'Array::equivalent()'
strictEqual ['a']       .equivalent(['b']),            false, 'Array::equivalent()'
strictEqual ['a', []]   .equivalent(['a', []]),        true,  'Array::equivalent()'
strictEqual ['a', ['b']].equivalent(['a', ['b']]),     true,  'Array::equivalent()'

strictEqual [].isEmpty(),    true,  'Array::isEmpty()'
strictEqual ['x'].isEmpty(), false, 'Array::isEmpty()'

strictEqual ['a', 'b'].repeat( 0).equivalent([]), true, 'Array::repeat()'
strictEqual ['a', 'b'].repeat(-1).equivalent([]), true, 'Array::repeat()'
strictEqual ['a', 'b'].repeat( 3).equivalent(['a', 'b', 'a', 'b', 'a', 'b']), true, 'Array::repeat()'

strictEqual 'ab'.repeat( 3), 'ababab', 'String::repeat()'
strictEqual 'ab'.repeat( 0),       '', 'String::repeat()'

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

strictEqual 'cat'.reverse(), 'tac', 'String::reverse()'

strictEqual (2).bit(1), true, 'Number::bit()'
strictEqual (4).bit(2), true, 'Number::bit()'
strictEqual (8).bit(3), true, 'Number::bit()'

strictEqual (2).bit(1, false), 0, 'Number::bit()'
strictEqual (0).bit(1, true ), 2, 'Number::bit()'

strictEqual Object.values({ a: 'cat', b: 'dog', c: 'rat', d: 'horse' })[2], 'rat', 'Object::values()'

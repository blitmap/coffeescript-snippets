# https://jsperf.com/assignment-once-vs-boolean-once
once = (f) ->
	->
		tmp = f
		f = ->
		tmp.apply this, arguments

f = once -> console.log 'cat'

f()
f()
f()
f()
f()

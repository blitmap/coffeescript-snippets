range = (start, end, step) ->
	if step?
		yield i for i in [ start .. end ] by step
	else
		yield i for i in [ start .. end ]

module.exports = range

return unless require.main is module

# CS can't [yet] do for-in/for-of on generators :'(
iter = range 0, -30, -5
v    = iter.next()

while not v.done
	console.log v.value
	v = iter.next()

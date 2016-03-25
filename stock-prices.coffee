# Triplebyte interview exercise (3/17/2016)
# find the longest strictly increasing/decreasing run in an array
tests =
[
	[ 3, [ 1, 2, 3          ] ]
	[ 4, [ 2, 3, 4, 3, 2, 1 ] ]
	[ 2, [ 3, 2, 2, 1       ] ]
]

# strictly increasing/decreasing
gt = (x, y) -> x > y
lt = (x, y) -> x < y

stock_runs = (prices) ->
	toggle  = true
	longest = 0
	run     = 0

	# Array::reduce() as fold(), not reduction
	prices.reduce (prev, curr) ->
		keepGoing = (toggle and gt or lt) curr, prev

		if keepGoing
			run++

		longest = Math.max longest, run + 1

		unless keepGoing
			# we flip on a number, it's the first in the new run
			run    = 1
			toggle = not toggle

		# used as the next prev
		return curr
		
	return longest

for t, i in tests
	[ run, input ] = t
	console.log "test #{i + 1} -- expected: #{run}, got: #{stock_runs input}"

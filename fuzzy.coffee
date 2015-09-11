C = {}
C.second = 1
C.minute = C.second * 60
C.hour   = C.minute * 60
C.day    = C.hour   * 24
C.week   = C.day    * 7
C.year   = C.day    * 365
C.month  = C.year   / 12  # imo, best approx.

fuzzy = (time) ->
	time = Math.abs time

	o = []

	for unit in 'year month week day hour minute second'.split ' '
		secs = C[unit]

		continue if time < secs

		i = Math.trunc time / secs
		time %= secs

		o.push "#{i} #{unit}#{i > 1 and 's' or ''}"

	return o.join ', '

module.exports = fuzzy

return unless require.main is module

{ strictEqual } = require 'assert'

strictEqual fuzzy(C.year + C.month + C.week + C.day + C.hour + C.minute + C.second),
	'1 year, 1 month, 1 week, 1 day, 1 hour, 1 minute, 1 second'

strictEqual fuzzy(C.year + 2 * C.month + 37 * C.second),
	'1 year, 2 months, 37 seconds'

strictEqual fuzzy(-3), '3 seconds'

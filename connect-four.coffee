# This was a programming exercise I wrote for Triplebyte (3/17/2016)
# (I was given an hour, I obsessed over it after the interview)
# updated 3/10/2017; coffeescript has for-from for generators now! :D

require 'colors'
prompt = require('prompt-sync')()

# (don't judge me)
Array::last_index   ?= -> @length - 1
String::indentLines ?= (n = 1) ->
	indent = '\t'.repeat n
	return indent + @replace /\r?\n/g, "$&#{indent}"

CRLF = '\r\n'

DIRECTION =
	UP:         [  0, -1 ]
	DOWN:       [  0, +1 ]
	LEFT:       [ -1 , 0 ]
	RIGHT:      [ +1 , 0 ]
	UP_LEFT:    [ -1, -1 ]
	UP_RIGHT:   [ -1, +1 ]
	DOWN_LEFT:  [ +1, -1 ]
	DOWN_RIGHT: [ +1, +1 ]

class Coord
	constructor: (@x, @y) ->
		# Coord constructed from index in @board, not (x, y)
		unless @y?
			[ @x, @y ] = Coord.fromIndex @x

	inDirection: ([ xdiff, ydiff ]) -> new Coord @x + xdiff, @y + ydiff

	toIndex: -> @y * Board.COLUMNS + @x

	@fromIndex: (i) -> [ i % Board.COLUMNS, i // Board.COLUMNS ]

class Board
	@COLUMNS: 7
	@ROWS:    6
	@SIZE:    Board.COLUMNS * Board.ROWS

	constructor: ->
		@board = new Array Board.SIZE
		@board.fill ' '

	toString: ->
		lines = []

		for i in [ 0 ... @board.length ] by Board.COLUMNS
			lines.push @board[ i ... i + Board.COLUMNS ].join ' | '

		separator = (new Array Board.COLUMNS).fill('---').join('+')
		separator = separator[1 ... -1] # take off a '-' from both ends
		numLine   = (i + 1 for i in [ 0 ... Board.COLUMNS ]).join '   '

		return numLine + CRLF + lines.join CRLF + separator + CRLF

	dropPieceInColumn: (x, symbol) ->
		c = @nextVacantInColumn x

		return unless c?

		@mark c, symbol
		return c

	validColumn: (x) -> 0 <= x <= @board.length // Board.COLUMNS
	validCoord:  (c) -> @validColumn(c.x) and 0 <= c.y <= @board.length // Board.ROWS

	# getter + setter
	at: (c) -> @board[c.toIndex()]
	mark: (c, symbol) -> @board[c.toIndex()] = symbol

	isVacant: (c) -> @at(c) is ' '

	# find a vacant coordinate from bottom up in column `x`
	nextVacantInColumn: (x) -> return c for c from @coordsInColumn x when @isVacant c
			
	# yield all coordinates on the board from bottom-up, right-to-left
	coords: -> yield new Coord i for i in  [ @board.last_index() .. 0 ]

	# yield all coordinates in a column `x`, bottom-up
	coordsInColumn: (x) -> yield new Coord x, y for y in [ @board.length // Board.ROWS .. 0 ]

	isComplete: -> ' ' not in @board

	isWon: ->
		# avoid matching 4 empty spaces
		for origin from @coords() when not @isVacant origin
			for _, d of DIRECTION when @matchFour origin, d
				@markWinningFour origin, d
				return true
				
		return false

	# c is a non-vacant starting coordinate
	matchFour: (c, direction) ->
		# XXX: matchFour() is called in a loop
		# we might want to pass symbol in, instead
		symbol = @at c

		for [ 0 ... 3 ]
			c = c.inDirection direction
			return false unless @validCoord c
			return false unless symbol is @at c

		return true

	markWinningFour: (c, dir) ->
		for [ 0 ... 4]
			@mark c, @at(c).bold.green
			c = c.inDirection dir

	markDrawGame: ->
		iter = @coords()
		until (c = iter.next()).done
			c = c.value
			@mark c, @at(c).orange
			

class ConnectFour
	constructor: ->
		@board   = new Board
		@player1 = true

	toString: -> CRLF + @board.toString().indentLines() + CRLF

	show: (msg) ->
		console.log """
			#{@}
			#{msg}
		"""

	start: ->
		loop
			name = "Player ##{@player1 and '1' or '2'}"
			@show "#{name}, your turn!"

			loop
				x = prompt "Please enter a column number [1, #{Board.COLUMNS}]: "
				c = null
				x-- # 1-indexed columns

				unless @board.validColumn x
					console.log 'Invalid column number!'
					continue
				else
					c = @board.dropPieceInColumn x, (@player1 and 'X' or 'O').bold

				if c?
					console.log "Piece added to column #{x}"
					break

				console.log 'Column is full! Choose another!'

			if @board.isWon()
				@show "#{name} has won the game!"
				break

			if @board.isComplete()
				@board.markDrawGame()
				@show 'This game is a draw!  You are both worthy opponents.'
				break

			@player1 = not @player1

game = new ConnectFour
game.start()

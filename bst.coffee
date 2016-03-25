# Code written for Twitch interview
# binary-search tree (BST) - insertion + existence checking

isType     = (ctor, tname) -> (x) -> x instanceof ctor or typeof(x) is tname
isFunction = isType Function, 'function'

class Node
	constructor: (@value = null, @left = null, @right = null) ->
		Object.seal @

# Binary-Search Tree
class BST
	constructor: ->
		@root = null
		@compare = (x, y) -> x < y

		Object.seal @

	add: (v) ->
		return unless v?

		unless @root?
			@root = new Node v
			return

		current = @root

		while current?
			side = @compare(v, current.value) and 'left' or 'right'

			unless current[side]?
				current[side] = new Node v
				break

			current = current[side]

	contains: (v) ->
		current = @root

		while current?
			return true if v is current.value
			side    = @compare(v, current.value) and 'left' or 'right'
			current = current[side]

		return false

TAB_WIDTH = 4
pretty = (x) -> JSON.stringify x, null, TAB_WIDTH

# Question 1:
# In JavaScript, write code to create a binary tree where each node can hold a string. Style counts.
tree = new BST

console.log pretty tree

tree.add 'cat'
tree.add 'dog'
tree.add 'horse'
tree.add 'mouse'
tree.add 'canary'

# Question 2:
# In JavaScript, write code to do a breadth-first search on this tree for a string. 
if tree.contains 'mouse'
	console.log 'we have a rodent problem'

unless tree.contains 'vampires'
	console.log 'we are safe tonight'

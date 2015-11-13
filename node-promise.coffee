###

fs.readFilePromise = require('node-promise')(fs.readFile)

fs.readFilePromise('/path/to/file', 'utf8')
	.then console.log

###

# promise-ify's node functions of the form: (..., callback)
module.exports = (f) ->
	->
		args = Array::slice.call arguments
		return new Promise (resolve, reject) ->
			args.push (err, data) -> err? and reject(err) or resolve(data)
			f.apply this, args

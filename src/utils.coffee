# utils.coffee

export doHaltOnError = false

# ---------------------------------------------------------------------------

export haltOnError = () ->

	doHaltOnError = true

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	if doHaltOnError
		console.trace("ERROR: #{message}")
		process.exit()
	throw new Error(message)

# ---------------------------------------------------------------------------

getCallers = (stackTrace, lExclude=[]) ->

	iter = stackTrace.matchAll(///
			at
			\s+
			(?:
				async
				\s+
				)?
			([^\s(]+)
			///g)
	if !iter
		return ["<unknown>"]

	lCallers = []
	for lMatches from iter
		[_, caller] = lMatches
		if (caller.indexOf('file://') == 0)
			break
		if caller not in lExclude
			lCallers.push caller

	return lCallers

# ---------------------------------------------------------------------------
#   assert - mimic nodejs's assert
#   return true so we can use it in boolean expressions

export assert = (cond, msg) ->

	if ! cond
		stackTrace = new Error().stack
		lCallers = getCallers(stackTrace, ['assert'])

		console.log '--------------------'
		console.log 'JavaScript CALL STACK:'
		for caller in lCallers
			console.log "   #{caller}"
		console.log '--------------------'
		console.log "ERROR: #{msg} (in #{lCallers[0]}())"
		if doHaltOnError
			process.exit()
		error msg
	return true

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info

export croak = (err, label, obj) ->

	if (typeof err == 'string') || (err instanceof String)
		curmsg = err
	else
		curmsg = err.message
	newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{JSON.stringify(obj)}
			"""

	# --- re-throw the error
	throw new Error(newmsg)

# ---------------------------------------------------------------------------

export normalize = (block) ->

	if (typeof block != 'string')
		return block

	# --- Remove leading and trailing whitespace
	#     Convert all whitespace to single space character
	#     Remove empty lines

	lLines = []
	for line in block.split(/\r?\n/)
		line = line.trim()
		line = line.replace(/\s+/g, ' ')
		if ! line.match(/^\s*$/)
			lLines.push line
	return lLines.join('\n')

# ---------------------------------------------------------------------------

export super_normalize = (block) ->

	if (typeof block != 'string')
		return block

	# --- Collapse ALL whitespace, including newlines, to space char
	#     Remove whitespace around =+*()<>[]

	block = block.replace(/\s+/sg, ' ')

	func = (match, ch) => return ch

	block = block.replace(/\s*([=+*()<>\[\]])\s*/g, func)
	return block


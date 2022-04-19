# utils.coffee

import assert from 'assert'

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


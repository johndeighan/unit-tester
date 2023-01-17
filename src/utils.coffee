# utils.coffee

import {toArray, nonEmpty} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export normalize = (block) ->

	if (typeof block != 'string')
		return block

	# --- Remove blank lines
	#     In remaining lines:
	#        - Remove leading and trailing whitespace
	#        - Convert all whitespace to single space character

	lLines = []
	for line in toArray(block)
		line = line.trim()  # remove leading/trailing whitespace
		if nonEmpty(line)
			lLines.push line.replace(/\s+/g, ' ')
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

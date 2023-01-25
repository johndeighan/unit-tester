# JSTester.coffee

import test from 'ava'
import prettier from 'prettier'

import {
	undef, defined, notdefined, DUMP,
	} from '@jdeighan/base-utils'
import {assert} from '@jdeighan/base-utils/exceptions'
import {
	getTestName,
	} from '@jdeighan/unit-tester/utils'

# ---------------------------------------------------------------------------

export class JSTester

	transformValue: (input) ->

		return input

	# ........................................................................

	transformExpected: (input) ->

		return input

	# ........................................................................

	normalize: (js) ->

		try
			result = prettier.format(js, {parser: 'flow'})
			return result
		catch err
			console.log "prettier failed"
			DUMP 'JavaScript', js
			throw err

	# ........................................................................

	equal: (lineNum, js1, js2) ->

		js1 = @transformValue(js1)
		js2 = @transformExpected(js2)

		# --- normalize js1
		try
			norm1 = @normalize(js1)
		catch err
			DUMP 'JavaScript 1', js1
			console.log "ERROR in JSTester 1: #{err.message}"
			throw err

		# --- normalize js2
		try
			norm2 = @normalize(js2)
		catch err
			DUMP 'JavaScript 2', js2
			console.log "ERROR in JSTester 2: #{err.message}"
			throw err

		test getTestName(lineNum), (t) -> t.is(norm1, norm2)
		return

# ---------------------------------------------------------------------------

export jstester = new JSTester()

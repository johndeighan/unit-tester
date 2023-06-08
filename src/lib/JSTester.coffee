# JSTester.coffee

import test from 'ava'
import prettier from 'prettier'

import {
	undef, defined, notdefined, DUMP,
	} from '@jdeighan/base-utils'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'
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
			result = prettier.format(js, {
				parser: 'flow'
				useTabs: true
				})
			return result.replace(/\n\n+/sg, "\n")
		catch err
			console.log "prettier failed"
			DUMP 'JavaScript', js
			throw err

	# ........................................................................

	equal: (lineNum, js1, js2) ->

		dbgEnter 'equal', lineNum, js1, js2

		js1_trans = @transformValue(js1)
		if (js1_trans != js1)
			dbg "js1 transformed", js1_trans

		js2_trans = @transformExpected(js2)
		if (js2_trans != js2)
			dbg "js2 transformed", js2_trans

		# --- normalize js1
		try
			norm1 = @normalize(js1_trans)
			if (norm1 != js1_trans)
				dbg "js1 normalized", norm1
		catch err
			DUMP 'JavaScript 1', js1
			console.log "ERROR in JSTester 1: #{err.message}"
			throw err

		# --- normalize js2
		try
			norm2 = @normalize(js2_trans)
			if (norm2 != js2_trans)
				dbg "js2 normalized", norm2
		catch err
			DUMP 'JavaScript 2', js2
			console.log "ERROR in JSTester 2: #{err.message}"
			throw err

		test getTestName(lineNum), (t) -> t.is(norm1, norm2)
		dbgReturn 'equal'
		return

# ---------------------------------------------------------------------------

export jstester = new JSTester()

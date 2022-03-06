# UnitTester.coffee

import test from 'ava'

import {
	assert, undef, pass, error, croak,
	isString, isFunction, isInteger, isArray,
	} from '@jdeighan/coffee-utils'
import {log, currentLogger, setLogger} from '@jdeighan/coffee-utils/log'
import {debug, debugging, setDebugging} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

export class UnitTester

	constructor: (@source=undef) ->
		@hFound = {}   # used line numbers
		@whichTest = 'deepEqual'

		# --- We already have tests named:
		#        'equal', 'notequal', 'fails', 'succeeds'
		#     Add 4 more:
		for testDesc in [
				'truthy',
				'falsy',
				['same', 'is'],
				['different', 'not'],
				]
			if isArray(testDesc)
				[myName, avaName] = testDesc
			else
				myName = avaName = testDesc
			@addTest myName, (lineNum, input, expected=undef) ->
				@whichTest = avaName
				@test lineNum, input, expected
				return

	# ........................................................................

	addTest: (name, func) ->
		this[name] = func
		return

	# ........................................................................

	test: (lineNum, input, expected) ->

		assert isInteger(lineNum) && (lineNum > 0),
			"UnitTester.test(): arg 1 must be a positive integer"

		testLineNum = process.env.UNIT_TEST_LINENUM
		doDebug = process.env.UNIT_TEST_DEBUG
		if doDebug
			console.log "UNIT_TEST_LINENUM = #{testLineNum}"
		if testLineNum
			if (lineNum == testLineNum)
				if doDebug
					console.log "CUR_LINE_NUM = #{lineNum} - testing"
			else
				if doDebug
					console.log "CUR_LINE_NUM = #{lineNum} - skipping"
				return

		@initialize()
		@lineNum = lineNum  # set an property, for error reporting

		errMsg = undef
		try
			got = @normalize(@transformValue(input))
		catch err
			errMsg = err.message || 'UNKNOWN ERROR'
			log "got ERROR in unit test: #{errMsg}"

		expected = @normalize(@transformExpected(expected))

		if process.env.UNIT_TEST_JUST_SHOW
			log "line #{@lineNum}"
			if errMsg
				log "GOT ERROR #{errMsg}"
			else
				log got, "GOT:"
			log expected, "EXPECTED:"
			return

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichTest = @whichTest

		# --- test names must be unique, getLineNum() ensures that
		lineNum = @getLineNum(lineNum)
		ident = "line #{lineNum}"
		if @source
			ident += " in #{@source}"
		test ident, (t) -> t[whichTest](got, expected)
		return

	# ........................................................................

	initialize: () ->     # override to do any initialization

		pass

	# ........................................................................

	getLineNum: (lineNum) ->

		# --- patch lineNum to avoid duplicates
		while @hFound[lineNum]
			lineNum += 1000
		@hFound[lineNum] = true
		return lineNum

	# ........................................................................

	transformValue: (input) ->
		return input

	# ........................................................................

	transformExpected: (input) ->
		return input

	# ........................................................................
	# may override, e.g. to remove comments

	isEmptyLine: (line) ->
		return (line == '')

	# ........................................................................

	normalize: (input) ->

		if ! isString(input)
			return input

		# --- Remove leading and trailing whitespace
		#     Convert all whitespace to single space character
		#     Remove empty lines

		lLines = []
		for line in input.split(/\r?\n/)
			line = line.trim()
			line = line.replace(/\s+/g, ' ')
			if ! @isEmptyLine(line)
				lLines.push line
		return lLines.join('\n')

	# ........................................................................

	equal: (lineNum, input, expected) ->
		@whichTest = 'deepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	notequal: (lineNum, input, expected) ->
		@whichTest = 'notDeepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	fails: (lineNum, func, expected) ->

		assert ! expected?, "UnitTester: fails doesn't allow expected"
		assert isFunction(func), "UnitTester: fails requires a function"

		# --- disable logging
		logger = currentLogger()
		setLogger (x) -> pass
		try
			func()
			ok = true
		catch err
			ok = false
		setLogger logger
		@whichTest = 'falsy'
		@test lineNum, ok, expected
		return

	# ........................................................................

	succeeds: (lineNum, func, expected) ->

		assert ! expected?, "UnitTester: succeeds doesn't allow expected"
		assert isFunction(func), "UnitTester: succeeds requires a function"
		try
			func()
			ok = true
		catch err
			ok = false
		@whichTest = 'truthy'
		@test lineNum, ok, expected
		return

# ---------------------------------------------------------------------------

export class UnitTesterNoNorm extends UnitTester

	normalize: (input) ->
		return input


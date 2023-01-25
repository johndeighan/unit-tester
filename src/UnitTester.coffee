# UnitTester.coffee

import test from 'ava'

import {
	undef, pass, isString, isFunction, isInteger, removeKeys, DUMP,
	isEmpty, nonEmpty,
	} from '@jdeighan/base-utils'
import {
	assert, haltOnError, suppressExceptionLogging,
	} from '@jdeighan/base-utils/exceptions'

import {
	getTestName, normalize, super_normalize,
	} from '@jdeighan/unit-tester/utils'

# --- Test methods:
#        equal     - checks for deep equality
#        notequal  - not deeply equal
#        fails     - pass in a function
#        succeeds  - pass in a function
#        truthy
#        falsy
#        is        - strict equality
#        not       - not strictly equal
#        like      - same value for matching keys, unmatched keys ignored
#        unlike

# --- These are currently part of coffee-utils
#     But should probably be moved to a lower level library
#     We don't want to import coffee-utils anymore, so for now
#        we just define them here

epsilon = 0.0001
haltOnError false

# ---------------------------------------------------------------------------

export setEpsilon = (ep=0.0001) ->

	epsilon = ep
	return

# ---------------------------------------------------------------------------

export class UnitTester

	constructor: (@source=undef) ->

		@hFound = {}   # used line numbers
		@whichAvaTest = 'deepEqual'
		@whichTest = undef    # should be set by each test method
		@label = 'unknown'

		# --- We already have tests named:
		#        'equal', 'notequal', 'fails', 'succeeds'
		#     Add 4 more:
		for testDesc in [
				['truthy', 'truthy']
				['falsy', 'falsy']
				['is', 'is']
				['not', 'not']
				['same', 'is']
				['different', 'not']
				]
			[myName, avaName] = testDesc
			@addTest myName, (lineNum, input, expected=undef) ->
				@whichAvaTest = avaName
				@test lineNum, input, expected
				return

	# ........................................................................

	addTest: (name, func) ->

		this[name] = func
		return

	# ........................................................................

	test: (lineNum, input, expected) ->

		if isString(lineNum)
			if lMatches = lineNum.match(///^ (.*) (\d+) $///)
				[_, prefix, lineNumStr] = lMatches
				lineNum = @getLineNum(parseInt(lineNumStr, 10))
			else
				throw new Error("test(): Invalid line number: #{lineNum}")
		else if isInteger(lineNum)
			# --- test names must be unique, getLineNum() ensures that
			lineNum = @getLineNum(lineNum)
		else
			throw new Error("test(): Invalid line number: #{lineNum}")

		@label = "line #{lineNum}"

		assert isInteger(lineNum) && (lineNum > 0),
			"UnitTester.test(): arg 1 #{lineNum} should be a positive integer"

		if process.env.UNIT_TEST_LINENUM
			testLineNum = parseInt(process.env.UNIT_TEST_LINENUM, 10)
		doDebug = process.env.UNIT_TEST_DEBUG
		if doDebug
			console.log "UNIT_TEST_DEBUG = #{doDebug}"
			if testLineNum
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
			console.log "got ERROR in unit test #{lineNum}: #{errMsg}"

			# --- print a stack trace
			stackTrace = new Error().stack
			lCallers = getCallers(stackTrace, ['test'])

			console.log '--------------------'
			console.log 'JavaScript CALL STACK:'
			for caller in lCallers
				console.log "   #{caller}"
			console.log '--------------------'
			console.log "ERROR: #{errMsg} (in #{lCallers[0]}())"
			throw err

		expected = @normalize(@transformExpected(expected))

		if (@whichTest == 'like') || (@whichTest == 'unlike')
			got = mapInput(got, expected)

		if process.env.UNIT_TEST_JUST_SHOW
			console.log @label
			if errMsg
				console.log "GOT ERROR in unit test #{lineNum}: #{errMsg}"
			else
				console.log got, "GOT:"
			console.log expected, "EXPECTED:"
			return

		# --- We need to save this here because in the tests themselves,
		#     'this' won't be correct
		whichAvaTest = @whichAvaTest

		ident = @label
		if @source
			ident += " in #{@source}"

		test ident, (t) -> t[whichAvaTest](got, expected)

		if doDebug
			console.log "Unit test #{lineNum} completed"
		return

	# ........................................................................

	initialize: () ->     # override to do any initialization

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

	normalize: (text) ->

		return text

	# ........................................................................
	#          Tests
	# ........................................................................

	like: (lineNum, input, expected) ->

		@whichTest = 'like'
		@whichAvaTest = 'deepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	unlike: (lineNum, input, expected) ->

		@whichTest = 'unlike'
		@whichAvaTest = 'notDeepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	equal: (lineNum, input, expected) ->

		@whichTest = 'equal'
		@whichAvaTest = 'deepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	notequal: (lineNum, input, expected) ->

		@whichTest = 'notequal'
		@whichAvaTest = 'notDeepEqual'
		@test lineNum, input, expected
		return

	# ........................................................................

	about: (lineNum, input, expected) ->

		@whichTest = 'about'
		@whichAvaTest = 'truthy'
		@test lineNum, (Math.abs(input - expected) <= epsilon)
		return

	# ........................................................................

	notabout: (lineNum, input, expected) ->

		@whichTest = 'notabout'
		@whichAvaTest = 'truthy'
		@test lineNum, (Math.abs(input - expected) > epsilon)
		return

	# ........................................................................

	defined: (lineNum, input) ->

		if (input == null)
			input = undef
		@whichTest = 'defined'
		@whichAvaTest = 'not'
		@test lineNum, input, undef
		return

	# ........................................................................

	notdefined: (lineNum, input) ->

		if (input == null)
			input = undef
		@whichTest = 'notdefined'
		@whichAvaTest = 'is'
		@test lineNum, input, undef
		return

	# ........................................................................

	fails: (lineNum, func, expected) ->

		assert ! expected?, "UnitTester: fails doesn't allow expected"
		assert isFunction(func), "UnitTester: fails requires a function"

		# --- Turn off logging errors while checking for failure
		saveHalt = haltOnError false    # turn off halting on error
		suppressExceptionLogging()      # turn off exception logging
		try
			func()
			ok = true
		catch err
			ok = false
		haltOnError saveHalt

		@whichTest = 'fails'
		@whichAvaTest = 'falsy'
		@test lineNum, ok
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

		@whichTest = 'succeeds'
		@whichAvaTest = 'truthy'
		@test lineNum, ok
		return

# ---------------------------------------------------------------------------
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

export class UnitTesterNorm extends UnitTester

	normalize: (text) ->
		return normalize(text)

# ---------------------------------------------------------------------------

export class UnitTesterSuperNorm extends UnitTester

	normalize: (text) ->
		return super_normalize(text)

# ---------------------------------------------------------------------------

export mapInput =(input, expected) ->

	if Array.isArray(input) && Array.isArray(expected)
		lNewInput = []
		for item,i in input
			if expected[i] != undef
				mapped = mapInput(item, expected[i])
			else
				mapped = item
			lNewInput.push mapped
		return lNewInput
	else if (input instanceof Object) && (expected instanceof Object)
		hNewInput = {}
		for own key,value of expected
			hNewInput[key] = input[key]
		return hNewInput
	else
		return input

# ---------------------------------------------------------------------------

export utest = new UnitTester()

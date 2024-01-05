# UnitTester.coffee

import test from 'ava'

import {
	undef, defined, notdefined, pass, oneof,
	isString, isFunction, isNumber, isInteger,
	isEmpty, nonEmpty, removeKeys, DUMP, OL, LOG,
	} from '@jdeighan/base-utils'
import {
	assert, croak, haltOnError, suppressExceptionLogging,
	} from '@jdeighan/base-utils/exceptions'
import {getMyOutsideCaller} from '@jdeighan/base-utils/v8-stack'
import {dbgEnter, dbgReturn, dbg} from '@jdeighan/base-utils/debug'

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
hUsedLineNumbers = {}    # { <num> => 1, ... }

# ---------------------------------------------------------------------------

export setEpsilon = (ep=0.0001) ->

	epsilon = ep
	return

# ---------------------------------------------------------------------------

export class UnitTester

	constructor: (@hOptions={}) ->
		# --- Valid options:
		#        source - will be printed in error messages
		#        debug - turn on debugging

		@source = @hOptions.source
		@debug = @hOptions.debug

		if @debug
			LOG "DEBUGGING ON"

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
			@addTest myName, (lArgs...) ->
				@whichAvaTest = avaName
				@test lArgs...
				return

	# ........................................................................

	addTest: (name, func) ->

		this[name] = func
		return

	# ........................................................................

	getCallerLineNum: () ->

		hNode = getMyOutsideCaller()
		return hNode.line

	# ........................................................................

	test: (lArgs...) ->

		dbgEnter 'test', lArgs
		dbg 'whichTest', @whichTest

		if @debug
			LOG "whichTest = @whichTest"

		# --- NEW: lineNum can be omitted
		#          It's missing and must be calculated if
		#             @whichTest is 'truthy','falsy','succeeds' or 'fails'
		#                AND #args is 1
		#             else #args is 2
		lineNum = input = expected = undef
		if oneof(@whichAvaTest, 'truthy','falsy','succeeds','fails')
			if (lArgs.length == 2)
				[lineNum, input] = lArgs
			else if (lArgs.length == 1)
				[input] = lArgs
			else
				croak "whichTest = #{@whichTest}, lArgs = #{OL(lArgs)}"
		else
			if (lArgs.length == 3)
				[lineNum, input, expected] = lArgs
			else if (lArgs.length == 2)
				[input, expected] = lArgs
			else
				croak "whichTest = #{@whichTest}, lArgs = #{OL(lArgs)}"

		if notdefined(lineNum)
			lineNum = @getCallerLineNum()
			if notdefined(lineNum)
				croak "getCallerLineNum() returned undef"

		assert isInteger(lineNum), "lineNum must be an integer, got #{lineNum}"

		# --- If lineNum has already been used, fix it
		while hUsedLineNumbers[lineNum]
			lineNum += 1000
		hUsedLineNumbers[lineNum] = 1

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
		dbgReturn 'test'
		return

	# ........................................................................

	initialize: () ->     # override to do any initialization

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

	getArgs: (lArgs, expectNum) ->

		dbgEnter 'getArgs', lArgs, expectNum
		if (lArgs.length == expectNum)
			result = lArgs
		else if (lArgs.length == expectNum - 1)
			lineNum = @getCallerLineNum()
			result = [lineNum, lArgs...]
		else
			croak "Invalid # args: #{OL(lArgs)}, #{expectNum} expected"
		dbgReturn 'getArgs', result
		return result

	# ........................................................................

	about: (lArgs...) ->

		dbgEnter 'about', lArgs
		[lineNum, input, expected] = @getArgs(lArgs, 3)

		@whichTest = 'about'
		@whichAvaTest = 'truthy'
		@test lineNum, (Math.abs(input - expected) <= epsilon)
		dbgReturn 'about'
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

	succeeds: (lArgs...) ->

		if (lArgs.length == 1)
			lineNum = @getCallerLineNum()
			func = lArgs[0]
		else if (lArgs.length == 2)
			[lineNum, func] = lArgs

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

	# ........................................................................

	fails: (lArgs...) ->

		if (lArgs.length == 1)
			lineNum = @getCallerLineNum()
			func = lArgs[0]
		else if (lArgs.length == 2)
			[lineNum, func] = lArgs

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

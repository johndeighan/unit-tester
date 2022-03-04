# UnitTester.test.coffee

import {UnitTester, UnitTesterNoNorm} from '@jdeighan/unit-tester'

simple = new UnitTester()
nonorm = new UnitTesterNoNorm()

simple.equal 8, 42, 42
simple.equal 9, 40 + 2, 42
simple.notequal 10, 40 + 3, 42

simple.equal 12, [2,3], [2,3]
simple.notequal 13, [2,3], [2,4]
simple.equal 14, {a:1, b:2}, {a:1, b:2}
simple.notequal 15, {a:1, b:2}, {a:1, b:3}

simple.different 18, [2,3], [2,3]

simple.fails 20, () -> throw "not OK"
simple.succeeds 21, () -> return 42

simple.truthy 23, 99
simple.falsy 24, 0
simple.truthy 25, 'abc'
simple.falsy 26, ''

# --- Normalization:
simple.equal 29, "  abc   xyz   ", "abc xyz"
nonorm.notequal 30, "  abc   xyz   ", "abc xyz"
nonorm.notequal 31, "  abc xyz   ", "abc xyz"
nonorm.notequal 32, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
simple.truthy 23, 9999

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTester
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 47, 'abc', 'ABC'
	custom.equal 48, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTester
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 58, 2, 6
	custom.equal 59, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTester
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 71, " 3.14159 ", "3.9"
	)()

(() ->
	# --- override initialize()

	class CustomTester extends UnitTester
		initialize: () ->
			@h = {
				x: 0
				y: 1
				meaningOfLife: 42
				}
		transformValue: (str) -> return @h[str]

	custom = new CustomTester()
	custom.equal 87, 'meaningOfLife', 42
	)()

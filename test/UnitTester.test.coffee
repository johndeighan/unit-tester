# UnitTester.test.coffee

import {UnitTester, UnitTesterNorm} from '@jdeighan/unit-tester'

simple = new UnitTesterNorm()
nonorm = new UnitTester()

simple.equal 8, 42, 42
simple.equal 9, 40 + 2, 42
simple.notequal 10, 40 + 3, 42

simple.equal 12, [2,3], [2,3]
simple.notequal 13, [2,3], [2,4]
simple.equal 14, {a:1, b:2}, {a:1, b:2}
simple.notequal 15, {a:1, b:2}, {a:1, b:3}

simple.different 17, [2,3], [2,3]

simple.truthy 19, true
simple.falsy 20, false

simple.fails 22, () -> throw "not OK"
simple.succeeds 23, () -> return 42

simple.succeeds 25, () -> simple.truthy(999, false)
simple.succeeds 26, () -> simple.truthy(999, true)
simple.succeeds 27, () -> simple.falsy(999, false)

simple.truthy 29, 99
simple.falsy 30, 0
simple.truthy 31, 'abc'
simple.falsy 32, ''

# --- Normalization:
simple.equal 35, "  abc   xyz   ", "abc xyz"
nonorm.notequal 36, "  abc   xyz   ", "abc xyz"
nonorm.notequal 37, "  abc xyz   ", "abc xyz"
nonorm.notequal 38, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
simple.truthy 41, 9999

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 53, 'abc', 'ABC'
	custom.equal 54, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 64, 2, 6
	custom.equal 65, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 77, " 3.14159 ", "3.9"
	)()

(() ->
	# --- override initialize()

	class CustomTester extends UnitTesterNorm
		initialize: () ->
			@h = {
				x: 0
				y: 1
				meaningOfLife: 42
				}
		transformValue: (str) -> return @h[str]

	custom = new CustomTester()
	custom.equal 93, 'meaningOfLife', 42
	)()

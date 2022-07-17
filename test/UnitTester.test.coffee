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

simple.fails 19, () -> throw "not OK"
simple.succeeds 20, () -> return 42

simple.succeeds 22, () -> simple.truthy(999, false)
simple.succeeds 23, () -> simple.truthy(999, true)
simple.succeeds 24, () -> simple.falsy(999, false)

simple.truthy 26, true
simple.falsy 27, false

result = true
simple.truthy 30, result

result = false
simple.falsy 33, result

simple.truthy 35, 99
simple.falsy 36, 0
simple.truthy 37, 'abc'
simple.falsy 38, ''

# --- with nonorm

nonorm.truthy 42, true
nonorm.falsy 43, false

result = true
nonorm.truthy 46, result

result = false
nonorm.falsy 49, result

nonorm.truthy 51, 99
nonorm.falsy 52, 0
nonorm.truthy 53, 'abc'
nonorm.falsy 54, ''

# --- Normalization:
simple.equal 57, "  abc   xyz   ", "abc xyz"
nonorm.notequal 58, "  abc   xyz   ", "abc xyz"
nonorm.notequal 59, "  abc xyz   ", "abc xyz"
nonorm.notequal 60, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
simple.truthy 63, 9999

# --- Test new testing method hashwith()
simple.hashwith 66, {a:1, b:2}, {a:1}
simple.nothashwith 67, {a:1, b:2}, {c:3}
simple.nothashwith 68, {a:1, b:2}, {a:2}

simple.hashwith 70, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
simple.nothashwith 71, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
simple.nothashwith 72, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 84, 'abc', 'ABC'
	custom.equal 85, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 95, 2, 6
	custom.equal 96, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 108, " 3.14159 ", "3.9"
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
	custom.equal 124, 'meaningOfLife', 42
	)()

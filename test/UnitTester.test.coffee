# UnitTester.test.coffee

import {UnitTester, UnitTesterNorm, simple} from '@jdeighan/unit-tester'

nonorm = new UnitTester()
norm = new UnitTesterNorm()

simple.equal 7, 42, 42
simple.equal 8, 40 + 2, 42
simple.notequal 9, 40 + 3, 42

simple.equal 11, [2,3], [2,3]
simple.notequal 12, [2,3], [2,4]
simple.equal 13, {a:1, b:2}, {a:1, b:2}
simple.notequal 14, {a:1, b:2}, {a:1, b:3}

simple.different 16, [2,3], [2,3]

simple.fails 18,    () -> throw "not OK"
simple.succeeds 19, () -> return 42

simple.succeeds 21, () -> simple.truthy(997, false)
simple.succeeds 22, () -> simple.truthy(998, true)
simple.succeeds 23, () -> simple.falsy(999, false)

simple.truthy 25, true
simple.falsy 26, false

result = true
simple.truthy 29, result

result = false
simple.falsy 32, result

simple.truthy 34, 99
simple.falsy 35, 0
simple.truthy 36, 'abc'
simple.falsy 37, ''

# --- with nonorm

nonorm.truthy 41, true
nonorm.falsy 42, false

result = true
nonorm.truthy 45, result

result = false
nonorm.falsy 48, result

nonorm.truthy 50, 99
nonorm.falsy 51, 0
nonorm.truthy 52, 'abc'
nonorm.falsy 53, ''

# --- Normalization:
norm.equal 56, "  abc   xyz   ", "abc xyz"
nonorm.notequal 57, "  abc   xyz   ", "abc xyz"
nonorm.notequal 58, "  abc xyz   ", "abc xyz"
nonorm.notequal 59, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
simple.truthy 62, 9999

# --- Test new testing method hashwith()
simple.hashwith 65, {a:1, b:2}, {a:1}
simple.nothashwith 66, {a:1, b:2}, {c:3}
simple.nothashwith 67, {a:1, b:2}, {a:2}

simple.hashwith 69, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
simple.nothashwith 70, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
simple.nothashwith 71, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 83, 'abc', 'ABC'
	custom.equal 84, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 94, 2, 6
	custom.equal 95, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 107, " 3.14159 ", "3.9"
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
	custom.equal 123, 'meaningOfLife', 42
	)()

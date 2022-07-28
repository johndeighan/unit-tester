# UnitTester.test.coffee

import {UnitTester, UnitTesterNorm, simple} from '@jdeighan/unit-tester'

nonorm = new UnitTester()
norm = new UnitTesterNorm()

simple.equal 8, 42, 42
simple.equal 9, 40 + 2, 42
simple.notequal 10, 40 + 3, 42

simple.equal "line 12", 42, 42
simple.equal "line 13", 40 + 2, 42
simple.notequal "line 14", 40 + 3, 42

simple.equal 16, [2,3], [2,3]
simple.notequal 17, [2,3], [2,4]
simple.equal 18, {a:1, b:2}, {a:1, b:2}
simple.notequal 19, {a:1, b:2}, {a:1, b:3}

simple.different 21, [2,3], [2,3]

simple.fails 23,    () -> throw "not OK"
simple.succeeds 24, () -> return 42

simple.succeeds 26, () -> simple.truthy(997, false)
simple.succeeds 27, () -> simple.truthy(998, true)
simple.succeeds 28, () -> simple.falsy(999, false)

simple.truthy 30, true
simple.falsy 31, false

result = true
simple.truthy 34, result

result = false
simple.falsy 37, result

simple.truthy 39, 99
simple.falsy 40, 0
simple.truthy 41, 'abc'
simple.falsy 42, ''

# --- with nonorm

nonorm.truthy 46, true
nonorm.falsy 47, false

result = true
nonorm.truthy 50, result

result = false
nonorm.falsy 53, result

nonorm.truthy 55, 99
nonorm.falsy 56, 0
nonorm.truthy 57, 'abc'
nonorm.falsy 58, ''

# --- Normalization:
norm.equal 61, "  abc   xyz   ", "abc xyz"
nonorm.notequal 62, "  abc   xyz   ", "abc xyz"
nonorm.notequal 63, "  abc xyz   ", "abc xyz"
nonorm.notequal 64, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
simple.truthy 67, 9999

# ---------------------------------------------------------------------------
# test like, unlike

simple.like 72, {a:1, b:2}, {a:1}
simple.unlike 73, {a:1, b:2}, {c:3}
simple.unlike 74, {a:1, b:2}, {a:2}

simple.like 76, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
simple.unlike 77, [{a:1, b:2}], [{a:1}, {a:3}]
simple.unlike 78, [{a:1, b:2}, {a:3, c:5}], [{a:1}]
simple.unlike 79, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
simple.unlike 80, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

simple.like 82, {a:1, b:2}, {a:1, b:2}
simple.like 83, {a:1, b:2}, {a:1}
simple.unlike 84, {a:1}, {a:1, b:2}

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 96, 'abc', 'ABC'
	custom.equal 97, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 107, 2, 6
	custom.equal 108, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 120, " 3.14159 ", "3.9"
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
	custom.equal 136, 'meaningOfLife', 42
	)()

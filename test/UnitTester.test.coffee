# UnitTester.test.coffee

import {UnitTester, UnitTesterNorm, utest} from '@jdeighan/unit-tester'

`const undef = undefined`

nonorm = new UnitTester()
norm = new UnitTesterNorm()

utest.equal 10, 42, 42
utest.equal 11, 40 + 2, 42
utest.notequal 12, 40 + 3, 42

# --- allow custom labels
utest.equal "line 997", 42, 42
utest.equal "line 998", 40 + 2, 42
utest.notequal "line 999", 40 + 3, 42

utest.equal 19, [2,3], [2,3]
utest.notequal 20, [2,3], [2,4]
utest.equal 21, {a:1, b:2}, {a:1, b:2}
utest.notequal 22, {a:1, b:2}, {a:1, b:3}

utest.different 24, [2,3], [2,3]

utest.fails 26,    () -> throw "not OK"
utest.succeeds 27, () -> return 42

utest.succeeds 29, () -> utest.truthy(9997, false)
utest.succeeds 30, () -> utest.truthy(9998, true)
utest.succeeds 31, () -> utest.falsy(9999, false)

utest.truthy 33, true
utest.falsy 34, false

result = true
utest.truthy 37, result

result = false
utest.falsy 40, result

utest.truthy 42, 99
utest.falsy 43, 0
utest.truthy 44, 'abc'
utest.falsy 45, ''

# --- with nonorm

nonorm.truthy 49, true
nonorm.falsy 50, false

result = true
nonorm.truthy 53, result

result = false
nonorm.falsy 56, result

nonorm.truthy 58, 99
nonorm.falsy 59, 0
nonorm.truthy 60, 'abc'
nonorm.falsy 61, ''

# --- Normalization:
norm.equal 64, "  abc   xyz   ", "abc xyz"
nonorm.notequal 65, "  abc   xyz   ", "abc xyz"
nonorm.notequal 66, "  abc xyz   ", "abc xyz"
nonorm.notequal 67, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
utest.truthy 70, 9999

# ---------------------------------------------------------------------------
# test like, unlike

utest.like 75, {a:1, b:2}, {a:1}
utest.unlike 76, {a:1, b:2}, {c:3}
utest.unlike 77, {a:1, b:2}, {a:2}

utest.like 79, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
utest.unlike 80, [{a:1, b:2}], [{a:1}, {a:3}]
utest.unlike 81, [{a:1, b:2}, {a:3, c:5}], [{a:1}]
utest.unlike 82, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
utest.unlike 83, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

utest.like 85, {a:1, b:2}, {a:1, b:2}
utest.like 86, {a:1, b:2}, {a:1}
utest.unlike 87, {a:1}, {a:1, b:2}

# ---------------------------------------------------------------------------

# test defined, notdefined

utest.defined 93, 23
utest.defined 94, 'abc'
utest.notdefined 95, undef
utest.notdefined 96, null

# ---------------------------------------------------------------------------

# test about, notabout

utest.about 102, 3.14159, 3.14158
utest.notabout 103, 3.14159, 42

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 115, 'abc', 'ABC'
	custom.equal 116, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 126, 2, 6
	custom.equal 127, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 139, " 3.14159 ", "3.9"
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
	custom.equal 155, 'meaningOfLife', 42
	)()

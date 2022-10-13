# UnitTester.test.coffee

import {UnitTester, UnitTesterNorm, tester} from '@jdeighan/unit-tester'

`const undef = undefined`

nonorm = new UnitTester()
norm = new UnitTesterNorm()

tester.equal 10, 42, 42
tester.equal 11, 40 + 2, 42
tester.notequal 12, 40 + 3, 42

# --- allow custom labels
tester.equal "line 997", 42, 42
tester.equal "line 998", 40 + 2, 42
tester.notequal "line 999", 40 + 3, 42

tester.equal 19, [2,3], [2,3]
tester.notequal 20, [2,3], [2,4]
tester.equal 21, {a:1, b:2}, {a:1, b:2}
tester.notequal 22, {a:1, b:2}, {a:1, b:3}

tester.different 24, [2,3], [2,3]

tester.fails 26,    () -> throw "not OK"
tester.succeeds 27, () -> return 42

tester.succeeds 29, () -> tester.truthy(9997, false)
tester.succeeds 30, () -> tester.truthy(9998, true)
tester.succeeds 31, () -> tester.falsy(9999, false)

tester.truthy 33, true
tester.falsy 34, false

result = true
tester.truthy 37, result

result = false
tester.falsy 40, result

tester.truthy 42, 99
tester.falsy 43, 0
tester.truthy 44, 'abc'
tester.falsy 45, ''

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
tester.truthy 70, 9999

# ---------------------------------------------------------------------------
# test like, unlike

tester.like 75, {a:1, b:2}, {a:1}
tester.unlike 76, {a:1, b:2}, {c:3}
tester.unlike 77, {a:1, b:2}, {a:2}

tester.like 79, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
tester.unlike 80, [{a:1, b:2}], [{a:1}, {a:3}]
tester.unlike 81, [{a:1, b:2}, {a:3, c:5}], [{a:1}]
tester.unlike 82, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
tester.unlike 83, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

tester.like 85, {a:1, b:2}, {a:1, b:2}
tester.like 86, {a:1, b:2}, {a:1}
tester.unlike 87, {a:1}, {a:1, b:2}

# ---------------------------------------------------------------------------

# test defined, notdefined

tester.defined 93, 23
tester.defined 94, 'abc'
tester.notdefined 95, undef
tester.notdefined 96, null

# ---------------------------------------------------------------------------

# test about, notabout

tester.about 102, 3.14159, 3.14158
tester.notabout 103, 3.14159, 42

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

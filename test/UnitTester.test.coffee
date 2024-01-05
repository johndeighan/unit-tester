# UnitTester.test.coffee

import {undef} from '@jdeighan/base-utils'
import {
	UnitTester, UnitTesterNorm, utest,
	} from '@jdeighan/unit-tester'

nonorm = new UnitTester()
norm = new UnitTesterNorm()

utest.equal 11, 42, 42
utest.equal 12, 40 + 2, 42
utest.notequal 13, 40 + 3, 42

utest.equal 15, [2,3], [2,3]
utest.notequal 16, [2,3], [2,4]
utest.equal 17, {a:1, b:2}, {a:1, b:2}
utest.notequal 18, {a:1, b:2}, {a:1, b:3}

utest.different 20, [2,3], [2,3]

utest.fails 22,    () -> throw "not OK"
utest.succeeds 23, () -> return 42

utest.fails 25,    () -> throw new Error('bad')
utest.succeeds 26, () -> return 'abc'
utest.succeeds 27, () -> return 42

utest.truthy 29, true
utest.truthy 30, 1
utest.truthy 31, 'abc'
utest.truthy 32, ['abc']

utest.falsy 34, false
utest.falsy 35, 0
utest.falsy 36, ''
utest.falsy 37, undef

(() =>
	result = true
	utest.truthy 41, result
	)()

(() =>
	result = false
	utest.falsy 46, result
	)()

utest.truthy 49, 99
utest.falsy 50, 0
utest.truthy 51, 'abc'
utest.falsy 52, ''

# --- with nonorm

nonorm.truthy 56, true
nonorm.falsy 57, false

(() =>
	result = true
	nonorm.truthy 61, result
	)()

(() =>
	result = false
	nonorm.falsy 66, result
	)()

nonorm.truthy 69, 99
nonorm.falsy 70, 0
nonorm.truthy 71, 'abc'
nonorm.falsy 72, ''

# --- Normalization:
norm.equal 75, "  abc   xyz   ", "abc xyz"
nonorm.notequal 76, "  abc   xyz   ", "abc xyz"
nonorm.notequal 77, "  abc xyz   ", "abc xyz"
nonorm.notequal 78, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
utest.truthy 81, 9999

# ---------------------------------------------------------------------------
# test like, unlike

utest.like 86, {a:1, b:2}, {a:1}
utest.unlike 87, {a:1, b:2}, {c:3}
utest.unlike 88, {a:1, b:2}, {a:2}

utest.like 90, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
utest.unlike 91, [{a:1, b:2}], [{a:1}, {a:3}]
utest.unlike 92, [{a:1, b:2}, {a:3, c:5}], [{a:1}]
utest.unlike 93, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
utest.unlike 94, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

utest.like 96, {a:1, b:2}, {a:1, b:2}
utest.like 97, {a:1, b:2}, {a:1}
utest.unlike 98, {a:1}, {a:1, b:2}

# ---------------------------------------------------------------------------

# test defined, notdefined

utest.defined 104, 23
utest.defined 105, 'abc'
utest.notdefined 106, undef
utest.notdefined 107, null

# ---------------------------------------------------------------------------

# test about, notabout

utest.about 113, 3.14159, 3.14158
utest.notabout 114, 3.14159, 42

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 126, 'abc', 'ABC'
	custom.equal 127, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 137, 2, 6
	custom.equal 138, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 150, " 3.14159 ", "3.9"
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
	custom.equal 166, 'meaningOfLife', 42
	)()

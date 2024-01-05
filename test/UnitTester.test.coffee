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

lAllWords = [{en: 'a'}, {en: 'b'}, {en: 'c'}]
utest.truthy 40, (lAllWords.length == 3)
utest.falsy  41, (lAllWords.length == 2)

(() =>
	result = true
	utest.truthy 45, result
	)()

(() =>
	result = false
	utest.falsy 50, result
	)()

utest.truthy 53, 99
utest.falsy 54, 0
utest.truthy 55, 'abc'
utest.falsy 56, ''

# --- with nonorm

nonorm.truthy 60, true
nonorm.falsy 61, false

(() =>
	result = true
	nonorm.truthy 65, result
	)()

(() =>
	result = false
	nonorm.falsy 70, result
	)()

nonorm.truthy 73, 99
nonorm.falsy 74, 0
nonorm.truthy 75, 'abc'
nonorm.falsy 76, ''

# --- Normalization:
norm.equal 79, "  abc   xyz   ", "abc xyz"
nonorm.notequal 80, "  abc   xyz   ", "abc xyz"
nonorm.notequal 81, "  abc xyz   ", "abc xyz"
nonorm.notequal 82, "abc   xyz", "abc xyz"

# --- Duplicate line numbers are not a problem
utest.truthy 85, 9999

# ---------------------------------------------------------------------------
# test like, unlike

utest.like 90, {a:1, b:2}, {a:1}
utest.unlike 91, {a:1, b:2}, {c:3}
utest.unlike 92, {a:1, b:2}, {a:2}

utest.like 94, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:3}]
utest.unlike 95, [{a:1, b:2}], [{a:1}, {a:3}]
utest.unlike 96, [{a:1, b:2}, {a:3, c:5}], [{a:1}]
utest.unlike 97, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {a:4}]
utest.unlike 98, [{a:1, b:2}, {a:3, c:5}], [{a:1}, {b:3}]

utest.like 100, {a:1, b:2}, {a:1, b:2}
utest.like 101, {a:1, b:2}, {a:1}
utest.unlike 102, {a:1}, {a:1, b:2}

# ---------------------------------------------------------------------------

# test defined, notdefined

utest.defined 108, 23
utest.defined 109, 'abc'
utest.notdefined 110, undef
utest.notdefined 111, null

# ---------------------------------------------------------------------------

# test about, notabout

utest.about 117, 3.14159, 3.14158
utest.notabout 118, 3.14159, 42

# ---------------------------------------------------------------------------
# --- Create custom unit testers

(() ->
	# --- Value is transformed by converting to upper case

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return input.toUpperCase()

	custom = new CustomTester()
	custom.equal 130, 'abc', 'ABC'
	custom.equal 131, '  abc  ', 'ABC'
	)()

(() ->
	# --- Value is tripled

	class CustomTester extends UnitTesterNorm
		transformValue: (input) -> return 3 * input

	custom = new CustomTester()
	custom.equal 141, 2, 6
	custom.equal 142, 5, 15
	)()

(() ->
	# --- Transform both value and expected
	#     Parse string as a number, then floor() number

	class CustomTester extends UnitTesterNorm
		transformValue: (str) -> return Math.floor(parseFloat(str))
		transformExpected: (str) -> return Math.floor(parseFloat(str))

	custom = new CustomTester()
	custom.equal 154, " 3.14159 ", "3.9"
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
	custom.equal 170, 'meaningOfLife', 42
	)()

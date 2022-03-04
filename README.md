Using class UnitTester
======================

Every test in your file must have a positive integer to identify it.
The intention is to have these test numbers be line numbers, but that
is not required. In addition, 2 distinct tests may be identified by
the same integer, though that will make it more difficult for you to
find failing tests.

Simple usage
------------

methods generally expect 3 arguments:

- the test number
- a value
- an expected value

in the case of methods **fails, succeeds, truthy, falsy**, there
should be no expected value

```coffeescript
simple = new UnitTester()

# --- test for equality NOTE: 99 is the test number
x = 23
simple.equal 99, x, 23
```

Available methods
-----------------

- **equal** - tests for deep equality
- **notequal** - not **equal**
- **fails** - value should be a function
- **succeeds** - not **fails**
- **truthy** - tests if value is true using JavaScript rules
- **falsy** - not **truthy**
- **same** - tests if value and expected are the same object
- **different** - not **same**

Testing string values
---------------------

Instances of class **UnitTester** instances will normalize string values,
including expected values, by viewing the string as a sequence of
lines, separated by /\r?\n/ and:

1. Removing all leading and trailing whitespace from each line
2. Collapsing internal runs of whitespace on each line
	to a single space character
3. Removing empty lines

I.e. the following tests will all pass:

```coffeescript
simple = new UnitTester()

simple.equal 99, 'a string', '  a    string   '
simple.equal 99, '  a   string  ', 'a string'
simple.equal 99, "A\n\n\nB", "A\nB"
simple.equal 99, "  A  \n\n\nB", "A\nB"
```
This makes it easy to test things like generating HTML,
JavaScript and CSS without regard to indentation, etc.
(though line breaks must still match).
If you don't want this behavior, you can use the class
**UnitTestNoNorm**, which does no normalization - unless you
specifically override methods **transformValue()** and/or
**transformExpected()**.

Subclassing
-----------

You may subclass **UnitTester** or **UnitTesterNoNorm**,
in which case you can override the following methods:

- **initialize()** - will be executed before any tests are run
- **transformValue()** - transform the value in any way desired
- **transformExpected()** - transform the expected value in any way desired
- **isEmptyLine()** - define what an empty line is, e.g. allowing you
	to have comments removed from values and expected values.

For example, this test will pass:

```coffeescript
# --- Transform both value and expected
#     Parse string as a number, then floor() number

class CustomTester extends UnitTester
	transformValue: (str) -> return Math.floor(parseFloat(str))
	transformExpected: (str) -> return Math.floor(parseFloat(str))

custom = new CustomTester()
custom.equal 99, " 3.14159 ", "3.9"
```

Installing ava
--------------
Because I had problems with version 4, I specifically installed
version 3 here via:

```bash
$ npm install ava@^3.x.x
```

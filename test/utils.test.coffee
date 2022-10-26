# utils.test.coffee

import {UnitTester, utest} from '@jdeighan/unit-tester'
import {normalize, super_normalize} from '@jdeighan/unit-tester/utils'

# ---------------------------------------------------------------------------
# normalize() should:
#    1. remove any indentation
#    2. remove blank lines

utest.equal 13, normalize("""
		this is
		some text
			that includes
				indented lines
		"""), """
		this is
		some text
		that includes
		indented lines
		"""

utest.equal 25, normalize("""
		this is

		some text
			that includes

				indented lines
		"""), """
		this is
		some text
		that includes
		indented lines
		"""

utest.equal 39, normalize("""
		y = func (y) + 3
		"""), """
		y = func (y) + 3
		"""

# ---------------------------------------------------------------------------
# super_normalize() should:
#    1. collapse runs of whitespace to single space
#    2. remove whitespace around '=', '(', ')', '<', '>', '[', ']'

utest.equal 50, super_normalize("""
		this is

		some text
			that includes

				indented lines
		"""), """
		this is some text that includes indented lines
		"""

utest.equal 61, super_normalize("""
		<html>
			<h1> a title </h1>
		</html>
		"""), """
		<html><h1>a title</h1></html>
		"""

utest.equal 69, super_normalize("""
		x = 23
		"""), """
		x=23
		"""

utest.equal 75, super_normalize("""
		y = func (y) + 3
		"""), """
		y=func(y)+3
		"""

block = """
	abc\tdef
	\tabc     def
	"""

norm = normalize(block)
snorm = super_normalize(block)

utest.equal 89, norm, "abc def\nabc def"
utest.equal 90, snorm, "abc def abc def"

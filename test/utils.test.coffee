# utils.test.coffee

import {UnitTester} from '@jdeighan/unit-tester'
import {normalize, super_normalize} from '@jdeighan/unit-tester/utils'

tester = new UnitTester()

# ---------------------------------------------------------------------------
# normalize() should:
#    1. remove any indentation
#    2. remove blank lines

tester.equal 13, normalize("""
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

tester.equal 25, normalize("""
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

tester.equal 39, normalize("""
		y = func (y) + 3
		"""), """
		y = func (y) + 3
		"""

# ---------------------------------------------------------------------------
# super_normalize() should:
#    1. collapse runs of whitespace to single space
#    2. remove whitespace around '=', '(', ')', '<', '>', '[', ']'

tester.equal 50, super_normalize("""
		this is

		some text
			that includes

				indented lines
		"""), """
		this is some text that includes indented lines
		"""

tester.equal 61, super_normalize("""
		<html>
			<h1> a title </h1>
		</html>
		"""), """
		<html><h1>a title</h1></html>
		"""

tester.equal 69, super_normalize("""
		x = 23
		"""), """
		x=23
		"""

tester.equal 75, super_normalize("""
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

tester.equal 89, norm, "abc def\nabc def"
tester.equal 90, snorm, "abc def abc def"

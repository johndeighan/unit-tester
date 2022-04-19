# utils.test.coffee

import {UnitTester} from '@jdeighan/unit-tester'
import {normalize, super_normalize} from '@jdeighan/unit-tester/utils'

simple = new UnitTester()

# ---------------------------------------------------------------------------
# normalize() should:
#    1. remove any indentation
#    2. remove blank lines

simple.equal 13, normalize("""
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

simple.equal 25, normalize("""
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

simple.equal 39, normalize("""
		y = func (y) + 3
		"""), """
		y = func (y) + 3
		"""

# ---------------------------------------------------------------------------
# super_normalize() should:
#    1. collapse runs of whitespace to single space
#    2. remove whitespace around '=', '(', ')', '<', '>', '[', ']'

simple.equal 50, super_normalize("""
		this is

		some text
			that includes

				indented lines
		"""), """
		this is some text that includes indented lines
		"""

simple.equal 61, super_normalize("""
		<html>
			<h1> a title </h1>
		</html>
		"""), """
		<html><h1>a title</h1></html>
		"""

simple.equal 69, super_normalize("""
		x = 23
		"""), """
		x=23
		"""

simple.equal 75, super_normalize("""
		y = func (y) + 3
		"""), """
		y=func(y)+3
		"""

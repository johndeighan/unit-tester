# temp.test.coffee - from jstester.test.coffee

import {undef} from '@jdeighan/base-utils'
import {jstester, JSTester} from '@jdeighan/unit-tester'

# ---------------------------------------------------------------------------

jstester.equal 14, """
	let x = 42;
	""", """
	let
	x
	=
	42
	;
	"""


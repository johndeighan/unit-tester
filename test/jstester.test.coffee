# jstester.test.coffee

import {undef} from '@jdeighan/base-utils'
import {jstester, JSTester} from '@jdeighan/unit-tester/js'

# ---------------------------------------------------------------------------

jstester.equal 8, """
	let x = 42;
	""", """
	let x = 42;
	"""

jstester.equal 14, """
	let x = 42;
	""", """
	let
	x
	=
	42
	;
	"""

# --- Things we want to ignore:
#        1. The line number something is on
#        2. missing semicolons
#        3. trailing commas
#        4. the type of quote mark used for strings
#        5. extra parentheses
#        6. indent level

jstester.equal 32, """
	let x = 42;
	if ((x == 42)) {
		console.log('this', undef);
		}
	""", """
	let x = 42
		if (x == 42) {
			console.log(
				"this",
				undef,
				);
			}
	"""

jstester.equal 47, """
	let x = 42;
	if ((x == 42)) {
		console.log('this', undef);
		}
	""", """
	let x=42;if(x==42){console.log("this",undef);}
	"""

jstester.equal 56, """
	var a, b, c;

	a = 42;

	b = 99;
	""", """
	var a, b, c;
	a = 42;
	b = 99;
	"""

# ---------------------------------------------------------------------------
# Test subclassing JSTester

(() ->

	class MyTester extends JSTester
		transformValue: (js) ->
			return js.replace('AUTHOR', 'John Deighan')

	tester = new MyTester()

	# ..........................................................

	tester.equal 81, """
		let x = 42;
		if ((x == 42)) {
			console.log('this', 'AUTHOR');
			}
		""", """
		let x=42;if(x==42){console.log("this","John Deighan");}
		"""

	)()

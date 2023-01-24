# temp.coffee

import prettier from 'prettier'

import {DUMP} from '@jdeighan/base-utils'

js = """
	let
	x
	=
	42
	;
	"""

result = prettier.format(js, {parser: 'flow'})
DUMP 'result', result

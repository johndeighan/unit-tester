# mapInput.test.coffee

import {UnitTester, simple, mapInput} from '@jdeighan/unit-tester'

simple.equal 5, mapInput({a:1,b:2}, {a:1}), {a:1}
simple.equal 6, mapInput({a:1,b:2}, {a:3}), {a:1}
simple.equal 7, mapInput({a:1,b:2,c:3,d:4}, {a:'a', c:'c'}), {a:1, c:3}
simple.equal 8, mapInput([{a:1, b:2}], [{b:9}]), [{b:2}]
simple.equal 9, mapInput([{c:3,d:4}], [{c:9}]), [{c:3}]
simple.equal 10, mapInput([{a:1,b:2}, {c:3,d:4}], [{b:9}, {c:9}]), [{b:2}, {c:3}]

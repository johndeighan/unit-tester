// Generated by CoffeeScript 2.7.0
  // UnitTester.coffee
var getCallers, isFunction, isInteger, isString,
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf;

import test from 'ava';

import assert from 'assert';

import {
  normalize,
  super_normalize
} from '@jdeighan/unit-tester/utils';

// --- These are currently part of coffee-utils
//     But should probably be moved to a lower level library
//     We don't want to import coffee-utils anymore, so for now
//        we just define them here
const undef = undefined;

isString = function(x) {
  return typeof x === 'string' || x instanceof String;
};

isFunction = function(x) {
  return typeof x === 'function';
};

isInteger = function(x) {
  if (typeof x === 'number') {
    return Number.isInteger(x);
  } else if (getClassName(x) === 'Number') {
    return Number.isInteger(x.valueOf());
  } else {
    return false;
  }
};

// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor(source = undef) {
    var avaName, j, len, myName, ref, testDesc;
    this.source = source;
    this.hFound = {}; // used line numbers
    this.whichTest = 'deepEqual';
    ref = [['truthy', 'truthy'], ['falsy', 'falsy'], ['like', 'like'], ['same', 'is'], ['different', 'not']];
    // --- We already have tests named:
    //        'equal', 'notequal', 'fails', 'succeeds'
    //     Add 4 more:
    for (j = 0, len = ref.length; j < len; j++) {
      testDesc = ref[j];
      [myName, avaName] = testDesc;
      this.addTest(myName, function(lineNum, input, expected = undef) {
        this.whichTest = avaName;
        this.test(lineNum, input, expected);
      });
    }
  }

  // ........................................................................
  addTest(name, func) {
    this[name] = func;
  }

  // ........................................................................
  test(lineNum, input, expected) {
    var caller, doDebug, err, errMsg, got, ident, j, lCallers, len, stackTrace, testLineNum, whichTest;
    if (isString(lineNum)) {
      lineNum = parseInt(lineNum, 10);
    }
    assert(isInteger(lineNum) && (lineNum > 0), `UnitTester.test(): arg 1 ${lineNum} should be a positive integer`);
    if (process.env.UNIT_TEST_LINENUM) {
      testLineNum = parseInt(process.env.UNIT_TEST_LINENUM, 10);
    }
    doDebug = process.env.UNIT_TEST_DEBUG;
    if (doDebug) {
      console.log(`UNIT_TEST_DEBUG = ${doDebug}`);
      if (testLineNum) {
        console.log(`UNIT_TEST_LINENUM = ${testLineNum}`);
      }
    }
    if (testLineNum) {
      if (lineNum === testLineNum) {
        if (doDebug) {
          console.log(`CUR_LINE_NUM = ${lineNum} - testing`);
        }
      } else {
        if (doDebug) {
          console.log(`CUR_LINE_NUM = ${lineNum} - skipping`);
        }
        return;
      }
    }
    this.initialize();
    this.lineNum = lineNum; // set an property, for error reporting
    errMsg = undef;
    try {
      got = this.normalize(this.transformValue(input));
    } catch (error) {
      err = error;
      errMsg = err.message || 'UNKNOWN ERROR';
      console.log(`got ERROR in unit test: ${errMsg}`);
      // --- print a stack trace
      stackTrace = new Error().stack;
      lCallers = getCallers(stackTrace, ['test']);
      console.log('--------------------');
      console.log('JavaScript CALL STACK:');
      for (j = 0, len = lCallers.length; j < len; j++) {
        caller = lCallers[j];
        console.log(`   ${caller}`);
      }
      console.log('--------------------');
      console.log(`ERROR: ${errMsg} (in ${lCallers[0]}())`);
      throw err;
    }
    expected = this.normalize(this.transformExpected(expected));
    if (process.env.UNIT_TEST_JUST_SHOW) {
      console.log(`line ${this.lineNum}`);
      if (errMsg) {
        console.log(`GOT ERROR ${errMsg}`);
      } else {
        console.log(got, "GOT:");
      }
      console.log(expected, "EXPECTED:");
      return;
    }
    // --- We need to save this here because in the tests themselves,
    //     'this' won't be correct
    whichTest = this.whichTest;
    // --- test names must be unique, getLineNum() ensures that
    lineNum = this.getLineNum(lineNum);
    ident = `line ${lineNum}`;
    if (this.source) {
      ident += ` in ${this.source}`;
    }
    test(ident, function(t) {
      return t[whichTest](got, expected);
    });
    if (doDebug) {
      console.log(`Unit test ${lineNum} completed`);
    }
  }

  // ........................................................................
  initialize() {} // override to do any initialization

  
    // ........................................................................
  getLineNum(lineNum) {
    // --- patch lineNum to avoid duplicates
    while (this.hFound[lineNum]) {
      lineNum += 1000;
    }
    this.hFound[lineNum] = true;
    return lineNum;
  }

  // ........................................................................
  transformValue(input) {
    return input;
  }

  // ........................................................................
  transformExpected(input) {
    return input;
  }

  // ........................................................................
  // may override, e.g. to remove comments
  isEmptyLine(line) {
    return line === '';
  }

  // ........................................................................
  normalize(text) {
    return text;
  }

  // ........................................................................
  getBasicHash(input, expected) {
    var hNew, key, value;
    assert(input instanceof Object, "input not a hash");
    assert(expected instanceof Object, "expected not a hash");
    hNew = {};
    for (key in expected) {
      if (!hasProp.call(expected, key)) continue;
      value = expected[key];
      hNew[key] = input[key];
    }
    return hNew;
  }

  // ........................................................................
  getBasicArray(input, expected) {
    var h, hCompare, i, j, lNew, len;
    assert(Array.isArray(input), "input not an array");
    assert(Array.isArray(expected), "expected not an array");
    hCompare = expected[0];
    lNew = [];
    for (i = j = 0, len = input.length; j < len; i = ++j) {
      h = input[i];
      lNew.push(this.getBasicHash(h, hCompare));
    }
    return lNew;
  }

  // ........................................................................
  hashwith(lineNum, input, expected) {
    this.whichTest = 'deepEqual';
    if (Array.isArray(input) && Array.isArray(expected)) {
      return this.test(lineNum, this.getBasicArray(input, expected), expected);
    } else if ((input instanceof Object) && (expected instanceof Object)) {
      return this.test(lineNum, this.getBasicHash(input, expected), expected);
    } else {
      throw new Error("Bad args");
    }
  }

  // ........................................................................
  nothashwith(lineNum, input, expected) {
    this.whichTest = 'notDeepEqual';
    if (Array.isArray(input) && Array.isArray(expected)) {
      return this.test(lineNum, this.getBasicArray(input, expected), expected);
    } else if ((input instanceof Object) && (expected instanceof Object)) {
      return this.test(lineNum, this.getBasicHash(input, expected), expected);
    } else {
      throw new Error("Bad args");
    }
  }

  // ........................................................................
  equal(lineNum, input, expected) {
    this.whichTest = 'deepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  notequal(lineNum, input, expected) {
    this.whichTest = 'notDeepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  fails(lineNum, func, expected) {
    var err, ok;
    assert(expected == null, "UnitTester: fails doesn't allow expected");
    assert(isFunction(func), "UnitTester: fails requires a function");
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    this.whichTest = 'falsy';
    this.test(lineNum, ok);
  }

  // ........................................................................
  succeeds(lineNum, func, expected) {
    var err, ok;
    assert(expected == null, "UnitTester: succeeds doesn't allow expected");
    assert(isFunction(func), "UnitTester: succeeds requires a function");
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    this.whichTest = 'truthy';
    this.test(lineNum, ok);
  }

};

// ---------------------------------------------------------------------------
getCallers = function(stackTrace, lExclude = []) {
  var _, caller, iter, lCallers, lMatches;
  iter = stackTrace.matchAll(/at\s+(?:async\s+)?([^\s(]+)/g);
  if (!iter) {
    return ["<unknown>"];
  }
  lCallers = [];
  for (lMatches of iter) {
    [_, caller] = lMatches;
    if (caller.indexOf('file://') === 0) {
      break;
    }
    if (indexOf.call(lExclude, caller) < 0) {
      lCallers.push(caller);
    }
  }
  return lCallers;
};

// ---------------------------------------------------------------------------
export var UnitTesterNorm = class UnitTesterNorm extends UnitTester {
  normalize(text) {
    return normalize(text);
  }

};

// ---------------------------------------------------------------------------
export var UnitTesterSuperNorm = class UnitTesterSuperNorm extends UnitTester {
  normalize(text) {
    return super_normalize(text);
  }

};

// ---------------------------------------------------------------------------
export var simple = new UnitTester();

// Generated by CoffeeScript 2.7.0
  // UnitTester.coffee
var epsilon, getCallers, hUsedLineNumbers,
  indexOf = [].indexOf,
  hasProp = {}.hasOwnProperty;

import test from 'ava';

import {
  undef,
  defined,
  notdefined,
  pass,
  oneof,
  isString,
  isFunction,
  isNumber,
  isInteger,
  isEmpty,
  nonEmpty,
  removeKeys,
  DUMP,
  OL,
  LOG
} from '@jdeighan/base-utils';

import {
  assert,
  croak,
  haltOnError,
  suppressExceptionLogging
} from '@jdeighan/base-utils/exceptions';

import {
  getMyOutsideCaller
} from '@jdeighan/base-utils/v8-stack';

import {
  dbgEnter,
  dbgReturn,
  dbg
} from '@jdeighan/base-utils/debug';

import {
  getTestName,
  normalize,
  super_normalize
} from '@jdeighan/unit-tester/utils';

// --- Test methods:
//        equal     - checks for deep equality
//        notequal  - not deeply equal
//        fails     - pass in a function
//        succeeds  - pass in a function
//        truthy
//        falsy
//        is        - strict equality
//        not       - not strictly equal
//        like      - same value for matching keys, unmatched keys ignored
//        unlike

// --- These are currently part of coffee-utils
//     But should probably be moved to a lower level library
//     We don't want to import coffee-utils anymore, so for now
//        we just define them here
epsilon = 0.0001;

haltOnError(false);

hUsedLineNumbers = {}; // { <num> => 1, ... }


// ---------------------------------------------------------------------------
export var setEpsilon = function(ep = 0.0001) {
  epsilon = ep;
};

// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor(hOptions = {}) {
    this.hOptions = hOptions;
    // --- Valid options:
    //        source - will be printed in error messages
    //        debug - turn on debugging
    this.source = this.hOptions.source;
    this.debug = !!this.hOptions.debug;
    if (this.debug) {
      LOG("DEBUGGING ON");
    }
    this.whichAvaTest = 'deepEqual';
    this.whichTest = undef; // should be set by each test method
    this.label = 'unknown';
  }

  // --- We already have tests named:
  //        'equal', 'notequal', 'fails', 'succeeds'
  //     Add 4 more:

    // ........................................................................
  getCallerLineNum() {
    var hNode;
    hNode = getMyOutsideCaller();
    return hNode.line;
  }

  // ........................................................................
  test(...lArgs) {
    var caller, doDebug, err, errMsg, expected, got, ident, input, j, lCallers, len, lineNum, stackTrace, testLineNum, whichAvaTest;
    dbgEnter('test', lArgs);
    dbg('whichTest', this.whichTest);
    if (this.debug) {
      LOG(`whichTest = ${this.whichTest}`);
    }
    // --- NEW: lineNum can be omitted
    //          It's missing and must be calculated if
    //             @whichTest is 'truthy','falsy','succeeds' or 'fails'
    //                AND #args is 1
    //             else #args is 2
    lineNum = input = expected = undef;
    if (oneof(this.whichAvaTest, 'truthy', 'falsy', 'succeeds', 'fails')) {
      if (lArgs.length === 2) {
        [lineNum, input] = lArgs;
      } else if (lArgs.length === 1) {
        [input] = lArgs;
      } else {
        croak(`whichTest = ${this.whichTest}, lArgs = ${OL(lArgs)}`);
      }
    } else {
      if (lArgs.length === 3) {
        [lineNum, input, expected] = lArgs;
      } else if (lArgs.length === 2) {
        [input, expected] = lArgs;
      } else {
        croak(`whichTest = ${this.whichTest}, lArgs = ${OL(lArgs)}`);
      }
    }
    if (notdefined(lineNum)) {
      lineNum = this.getCallerLineNum();
      if (notdefined(lineNum)) {
        croak("getCallerLineNum() returned undef");
      }
    }
    assert(isInteger(lineNum), `lineNum must be an integer, got ${lineNum}`);
    // --- If lineNum has already been used, fix it
    while (hUsedLineNumbers[lineNum]) {
      lineNum += 1000;
    }
    hUsedLineNumbers[lineNum] = 1;
    this.label = `line ${lineNum}`;
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
      console.log(`got ERROR in unit test ${lineNum}: ${errMsg}`);
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
    if ((this.whichTest === 'like') || (this.whichTest === 'unlike')) {
      got = mapInput(got, expected);
    }
    if (process.env.UNIT_TEST_JUST_SHOW) {
      console.log(this.label);
      if (errMsg) {
        console.log(`GOT ERROR in unit test ${lineNum}: ${errMsg}`);
      } else {
        console.log(got, "GOT:");
      }
      console.log(expected, "EXPECTED:");
      return;
    }
    // --- We need to save this here because in the tests themselves,
    //     'this' won't be correct
    whichAvaTest = this.whichAvaTest;
    ident = this.label;
    if (this.source) {
      ident += ` in ${this.source}`;
    }
    test(ident, function(t) {
      return t[whichAvaTest](got, expected);
    });
    if (doDebug) {
      console.log(`Unit test ${lineNum} completed`);
    }
    dbgReturn('test');
  }

  // ........................................................................
  initialize() {} // override to do any initialization

  
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
  //          Tests
  // ........................................................................
  truthy(lineNum, input) {
    this.whichTest = 'truthy';
    this.whichAvaTest = 'truthy';
    this.test(lineNum, input);
  }

  // ........................................................................
  falsy(lineNum, input) {
    this.whichTest = 'falsy';
    this.whichAvaTest = 'falsy';
    this.test(lineNum, input);
  }

  // ........................................................................
  is(lineNum, input) {
    this.whichTest = 'is';
    this.whichAvaTest = 'is';
    this.test(lineNum, input);
  }

  // ........................................................................
  not(lineNum, input) {
    this.whichTest = 'not';
    this.whichAvaTest = 'not';
    this.test(lineNum, input);
  }

  // ........................................................................
  same(lineNum, input) {
    this.whichTest = 'same';
    this.whichAvaTest = 'is';
    this.test(lineNum, input);
  }

  // ........................................................................
  different(lineNum, input) {
    this.whichTest = 'different';
    this.whichAvaTest = 'not';
    this.test(lineNum, input);
  }

  // ........................................................................
  like(lineNum, input, expected) {
    this.whichTest = 'like';
    this.whichAvaTest = 'deepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  unlike(lineNum, input, expected) {
    this.whichTest = 'unlike';
    this.whichAvaTest = 'notDeepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  equal(lineNum, input, expected) {
    this.whichTest = 'equal';
    this.whichAvaTest = 'deepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  notequal(lineNum, input, expected) {
    this.whichTest = 'notequal';
    this.whichAvaTest = 'notDeepEqual';
    this.test(lineNum, input, expected);
  }

  // ........................................................................
  getArgs(lArgs, expectNum) {
    var lineNum, result;
    dbgEnter('getArgs', lArgs, expectNum);
    if (lArgs.length === expectNum) {
      result = lArgs;
    } else if (lArgs.length === expectNum - 1) {
      lineNum = this.getCallerLineNum();
      result = [lineNum, ...lArgs];
    } else {
      croak(`Invalid # args: ${OL(lArgs)}, ${expectNum} expected`);
    }
    dbgReturn('getArgs', result);
    return result;
  }

  // ........................................................................
  about(...lArgs) {
    var expected, input, lineNum;
    dbgEnter('about', lArgs);
    [lineNum, input, expected] = this.getArgs(lArgs, 3);
    this.whichTest = 'about';
    this.whichAvaTest = 'truthy';
    this.test(lineNum, Math.abs(input - expected) <= epsilon);
    dbgReturn('about');
  }

  // ........................................................................
  notabout(lineNum, input, expected) {
    this.whichTest = 'notabout';
    this.whichAvaTest = 'truthy';
    this.test(lineNum, Math.abs(input - expected) > epsilon);
  }

  // ........................................................................
  defined(lineNum, input) {
    if (input === null) {
      input = undef;
    }
    this.whichTest = 'defined';
    this.whichAvaTest = 'not';
    this.test(lineNum, input, undef);
  }

  // ........................................................................
  notdefined(lineNum, input) {
    if (input === null) {
      input = undef;
    }
    this.whichTest = 'notdefined';
    this.whichAvaTest = 'is';
    this.test(lineNum, input, undef);
  }

  // ........................................................................
  succeeds(...lArgs) {
    var err, func, lineNum, ok;
    if (lArgs.length === 1) {
      lineNum = this.getCallerLineNum();
      func = lArgs[0];
    } else if (lArgs.length === 2) {
      [lineNum, func] = lArgs;
    }
    assert(isFunction(func), "UnitTester: succeeds requires a function");
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    this.whichTest = 'succeeds';
    this.whichAvaTest = 'truthy';
    this.test(lineNum, ok);
  }

  // ........................................................................
  fails(...lArgs) {
    var err, func, lineNum, ok, saveHalt;
    if (lArgs.length === 1) {
      lineNum = this.getCallerLineNum();
      func = lArgs[0];
    } else if (lArgs.length === 2) {
      [lineNum, func] = lArgs;
    }
    assert(isFunction(func), "UnitTester: fails requires a function");
    // --- Turn off logging errors while checking for failure
    saveHalt = haltOnError(false); // turn off halting on error
    suppressExceptionLogging(); // turn off exception logging
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    haltOnError(saveHalt);
    this.whichTest = 'fails';
    this.whichAvaTest = 'falsy';
    this.test(lineNum, ok);
  }

};

// ---------------------------------------------------------------------------
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
export var mapInput = function(input, expected) {
  var hNewInput, i, item, j, key, lNewInput, len, mapped, value;
  if (Array.isArray(input) && Array.isArray(expected)) {
    lNewInput = [];
    for (i = j = 0, len = input.length; j < len; i = ++j) {
      item = input[i];
      if (expected[i] !== undef) {
        mapped = mapInput(item, expected[i]);
      } else {
        mapped = item;
      }
      lNewInput.push(mapped);
    }
    return lNewInput;
  } else if ((input instanceof Object) && (expected instanceof Object)) {
    hNewInput = {};
    for (key in expected) {
      if (!hasProp.call(expected, key)) continue;
      value = expected[key];
      hNewInput[key] = input[key];
    }
    return hNewInput;
  } else {
    return input;
  }
};

// ---------------------------------------------------------------------------
export var utest = new UnitTester({
  source: 'unit test',
  debug: false
});

// Generated by CoffeeScript 2.7.0
  // UnitTester.coffee
var epsilon, getCallers,
  indexOf = [].indexOf,
  hasProp = {}.hasOwnProperty;

import test from 'ava';

import {
  undef,
  pass,
  isString,
  isFunction,
  isInteger
} from '@jdeighan/base-utils/utils';

import {
  assert,
  haltOnError
} from '@jdeighan/base-utils';

import {
  setLogger
} from '@jdeighan/base-utils/log';

import {
  normalize,
  super_normalize
} from '@jdeighan/unit-tester/utils';

// --- These are currently part of coffee-utils
//     But should probably be moved to a lower level library
//     We don't want to import coffee-utils anymore, so for now
//        we just define them here
epsilon = 0.0001;

haltOnError(false);

// ---------------------------------------------------------------------------
export var setEpsilon = function(ep = 0.0001) {
  epsilon = ep;
};

// ---------------------------------------------------------------------------
export var UnitTester = class UnitTester {
  constructor(source = undef) {
    var avaName, j, len, myName, ref, testDesc;
    this.source = source;
    this.hFound = {}; // used line numbers
    this.whichAvaTest = 'deepEqual';
    this.whichTest = undef; // should be set by each test method
    this.label = 'unknown';
    ref = [['truthy', 'truthy'], ['falsy', 'falsy'], ['is', 'is'], ['not', 'not'], ['same', 'is'], ['different', 'not']];
    // --- We already have tests named:
    //        'equal', 'notequal', 'fails', 'succeeds'
    //     Add 4 more:
    for (j = 0, len = ref.length; j < len; j++) {
      testDesc = ref[j];
      [myName, avaName] = testDesc;
      this.addTest(myName, function(lineNum, input, expected = undef) {
        this.whichAvaTest = avaName;
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
    var _, caller, doDebug, err, errMsg, got, ident, j, lCallers, lMatches, len, lineNumStr, prefix, stackTrace, testLineNum, whichAvaTest;
    if (isString(lineNum)) {
      if (lMatches = lineNum.match(/^(.*)(\d+)$/)) {
        [_, prefix, lineNumStr] = lMatches;
        lineNum = this.getLineNum(parseInt(lineNumStr, 10));
      } else {
        throw new Error(`test(): Invalid line number: ${lineNum}`);
      }
    } else if (isInteger(lineNum)) {
      // --- test names must be unique, getLineNum() ensures that
      lineNum = this.getLineNum(lineNum);
    } else {
      throw new Error(`test(): Invalid line number: ${lineNum}`);
    }
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
  //          Tests
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
  about(lineNum, input, expected) {
    this.whichTest = 'about';
    this.whichAvaTest = 'truthy';
    this.test(lineNum, Math.abs(input - expected) <= epsilon);
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
  fails(lineNum, func, expected) {
    var err, ok, saveHalt, saveLogger;
    assert(expected == null, "UnitTester: fails doesn't allow expected");
    assert(isFunction(func), "UnitTester: fails requires a function");
    // --- Turn off logging errors while checking for failure
    saveHalt = haltOnError(false); // turn off halting on error
    saveLogger = setLogger((x) => {
      return pass(); // turn off logging
    });
    try {
      func();
      ok = true;
    } catch (error) {
      err = error;
      ok = false;
    }
    haltOnError(saveHalt);
    setLogger(saveLogger);
    this.whichTest = 'fails';
    this.whichAvaTest = 'falsy';
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
    this.whichTest = 'succeeds';
    this.whichAvaTest = 'truthy';
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
export var utest = new UnitTester();

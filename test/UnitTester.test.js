// Generated by CoffeeScript 2.7.0
// UnitTester.test.coffee
var nonorm, norm, result;

import {
  UnitTester,
  UnitTesterNorm,
  simple
} from '@jdeighan/unit-tester';

const undef = undefined;

nonorm = new UnitTester();

norm = new UnitTesterNorm();

simple.equal(10, 42, 42);

simple.equal(11, 40 + 2, 42);

simple.notequal(12, 40 + 3, 42);

// --- allow custom labels
simple.equal("line 997", 42, 42);

simple.equal("line 998", 40 + 2, 42);

simple.notequal("line 999", 40 + 3, 42);

simple.equal(19, [2, 3], [2, 3]);

simple.notequal(20, [2, 3], [2, 4]);

simple.equal(21, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

simple.notequal(22, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 3
});

simple.different(24, [2, 3], [2, 3]);

simple.fails(26, function() {
  throw "not OK";
});

simple.succeeds(27, function() {
  return 42;
});

simple.succeeds(29, function() {
  return simple.truthy(9997, false);
});

simple.succeeds(30, function() {
  return simple.truthy(9998, true);
});

simple.succeeds(31, function() {
  return simple.falsy(9999, false);
});

simple.truthy(33, true);

simple.falsy(34, false);

result = true;

simple.truthy(37, result);

result = false;

simple.falsy(40, result);

simple.truthy(42, 99);

simple.falsy(43, 0);

simple.truthy(44, 'abc');

simple.falsy(45, '');

// --- with nonorm
nonorm.truthy(49, true);

nonorm.falsy(50, false);

result = true;

nonorm.truthy(53, result);

result = false;

nonorm.falsy(56, result);

nonorm.truthy(58, 99);

nonorm.falsy(59, 0);

nonorm.truthy(60, 'abc');

nonorm.falsy(61, '');

// --- Normalization:
norm.equal(64, "  abc   xyz   ", "abc xyz");

nonorm.notequal(65, "  abc   xyz   ", "abc xyz");

nonorm.notequal(66, "  abc xyz   ", "abc xyz");

nonorm.notequal(67, "abc   xyz", "abc xyz");

// --- Duplicate line numbers are not a problem
simple.truthy(70, 9999);

// ---------------------------------------------------------------------------
// test like, unlike
simple.like(75, {
  a: 1,
  b: 2
}, {
  a: 1
});

simple.unlike(76, {
  a: 1,
  b: 2
}, {
  c: 3
});

simple.unlike(77, {
  a: 1,
  b: 2
}, {
  a: 2
});

simple.like(79, [
  {
    a: 1,
    b: 2
  },
  {
    a: 3,
    c: 5
  }
], [
  {
    a: 1
  },
  {
    a: 3
  }
]);

simple.unlike(80, [
  {
    a: 1,
    b: 2
  }
], [
  {
    a: 1
  },
  {
    a: 3
  }
]);

simple.unlike(81, [
  {
    a: 1,
    b: 2
  },
  {
    a: 3,
    c: 5
  }
], [
  {
    a: 1
  }
]);

simple.unlike(82, [
  {
    a: 1,
    b: 2
  },
  {
    a: 3,
    c: 5
  }
], [
  {
    a: 1
  },
  {
    a: 4
  }
]);

simple.unlike(83, [
  {
    a: 1,
    b: 2
  },
  {
    a: 3,
    c: 5
  }
], [
  {
    a: 1
  },
  {
    b: 3
  }
]);

simple.like(85, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

simple.like(86, {
  a: 1,
  b: 2
}, {
  a: 1
});

simple.unlike(87, {
  a: 1
}, {
  a: 1,
  b: 2
});

// ---------------------------------------------------------------------------

// test defined, notdefined
simple.defined(93, 23);

simple.defined(94, 'abc');

simple.notdefined(95, undef);

simple.notdefined(96, null);

// ---------------------------------------------------------------------------
// --- Create custom unit testers
(function() {
  var CustomTester, custom;
  // --- Value is transformed by converting to upper case
  CustomTester = class CustomTester extends UnitTesterNorm {
    transformValue(input) {
      return input.toUpperCase();
    }

  };
  custom = new CustomTester();
  custom.equal(108, 'abc', 'ABC');
  return custom.equal(109, '  abc  ', 'ABC');
})();

(function() {
  var CustomTester, custom;
  // --- Value is tripled
  CustomTester = class CustomTester extends UnitTesterNorm {
    transformValue(input) {
      return 3 * input;
    }

  };
  custom = new CustomTester();
  custom.equal(119, 2, 6);
  return custom.equal(120, 5, 15);
})();

(function() {
  var CustomTester, custom;
  // --- Transform both value and expected
  //     Parse string as a number, then floor() number
  CustomTester = class CustomTester extends UnitTesterNorm {
    transformValue(str) {
      return Math.floor(parseFloat(str));
    }

    transformExpected(str) {
      return Math.floor(parseFloat(str));
    }

  };
  custom = new CustomTester();
  return custom.equal(132, " 3.14159 ", "3.9");
})();

(function() {
  var CustomTester, custom;
  // --- override initialize()
  CustomTester = class CustomTester extends UnitTesterNorm {
    initialize() {
      return this.h = {
        x: 0,
        y: 1,
        meaningOfLife: 42
      };
    }

    transformValue(str) {
      return this.h[str];
    }

  };
  custom = new CustomTester();
  return custom.equal(148, 'meaningOfLife', 42);
})();

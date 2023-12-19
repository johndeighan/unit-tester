// Generated by CoffeeScript 2.7.0
// UnitTester.test.coffee
var nonorm, norm;

import {
  undef
} from '@jdeighan/base-utils';

import {
  UnitTester,
  UnitTesterNorm,
  utest
} from '@jdeighan/unit-tester';

nonorm = new UnitTester();

norm = new UnitTesterNorm();

utest.equal(11, 42, 42);

utest.equal(12, 40 + 2, 42);

utest.notequal(13, 40 + 3, 42);

utest.equal(15, [2, 3], [2, 3]);

utest.notequal(16, [2, 3], [2, 4]);

utest.equal(17, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

utest.notequal(18, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 3
});

utest.different(20, [2, 3], [2, 3]);

utest.fails(22, function() {
  throw "not OK";
});

utest.succeeds(23, function() {
  return 42;
});

utest.succeeds(25, function() {
  return utest.truthy(9997, false);
});

utest.succeeds(26, function() {
  return utest.truthy(9998, true);
});

utest.succeeds(27, function() {
  return utest.falsy(9999, false);
});

utest.truthy(29, true);

utest.falsy(30, false);

(() => {
  var result;
  result = true;
  return utest.truthy(34, result);
})();

(() => {
  var result;
  result = false;
  return utest.falsy(39, result);
})();

utest.truthy(42, 99);

utest.falsy(43, 0);

utest.truthy(44, 'abc');

utest.falsy(45, '');

// --- with nonorm
nonorm.truthy(49, true);

nonorm.falsy(50, false);

(() => {
  var result;
  result = true;
  return nonorm.truthy(54, result);
})();

(() => {
  var result;
  result = false;
  return nonorm.falsy(59, result);
})();

nonorm.truthy(62, 99);

nonorm.falsy(63, 0);

nonorm.truthy(64, 'abc');

nonorm.falsy(65, '');

// --- Normalization:
norm.equal(68, "  abc   xyz   ", "abc xyz");

nonorm.notequal(69, "  abc   xyz   ", "abc xyz");

nonorm.notequal(70, "  abc xyz   ", "abc xyz");

nonorm.notequal(71, "abc   xyz", "abc xyz");

// --- Duplicate line numbers are not a problem
utest.truthy(74, 9999);

// ---------------------------------------------------------------------------
// test like, unlike
utest.like(79, {
  a: 1,
  b: 2
}, {
  a: 1
});

utest.unlike(80, {
  a: 1,
  b: 2
}, {
  c: 3
});

utest.unlike(81, {
  a: 1,
  b: 2
}, {
  a: 2
});

utest.like(83, [
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

utest.unlike(84, [
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

utest.unlike(85, [
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

utest.unlike(86, [
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

utest.unlike(87, [
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

utest.like(89, {
  a: 1,
  b: 2
}, {
  a: 1,
  b: 2
});

utest.like(90, {
  a: 1,
  b: 2
}, {
  a: 1
});

utest.unlike(91, {
  a: 1
}, {
  a: 1,
  b: 2
});

// ---------------------------------------------------------------------------

// test defined, notdefined
utest.defined(97, 23);

utest.defined(98, 'abc');

utest.notdefined(99, undef);

utest.notdefined(100, null);

// ---------------------------------------------------------------------------

// test about, notabout
utest.about(106, 3.14159, 3.14158);

utest.notabout(107, 3.14159, 42);

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
  custom.equal(119, 'abc', 'ABC');
  return custom.equal(120, '  abc  ', 'ABC');
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
  custom.equal(130, 2, 6);
  return custom.equal(131, 5, 15);
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
  return custom.equal(143, " 3.14159 ", "3.9");
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
  return custom.equal(159, 'meaningOfLife', 42);
})();

//# sourceMappingURL=UnitTester.test.js.map

// Generated by CoffeeScript 2.6.1
// utils.coffee
import assert from 'assert';

// ---------------------------------------------------------------------------
export var normalize = function(block) {
  var i, lLines, len, line, ref;
  if (typeof block !== 'string') {
    return block;
  }
  // --- Remove leading and trailing whitespace
  //     Convert all whitespace to single space character
  //     Remove empty lines
  lLines = [];
  ref = block.split(/\r?\n/);
  for (i = 0, len = ref.length; i < len; i++) {
    line = ref[i];
    line = line.trim();
    line = line.replace(/\s+/g, ' ');
    if (!line.match(/^\s*$/)) {
      lLines.push(line);
    }
  }
  return lLines.join('\n');
};

// ---------------------------------------------------------------------------
export var super_normalize = function(block) {
  var func;
  if (typeof block !== 'string') {
    return block;
  }
  // --- Collapse ALL whitespace, including newlines, to space char
  //     Remove whitespace around =+*()<>[]
  block = block.replace(/\s+/sg, ' ');
  func = (match, ch) => {
    return ch;
  };
  block = block.replace(/\s*([=+*()<>\[\]])\s*/g, func);
  return block;
};

(function(e){if("function"==typeof bootstrap)bootstrap("coffeelint",e);else if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else if("undefined"!=typeof ses){if(!ses.ok())return;ses.makeCoffeelint=e}else"undefined"!=typeof window?window.coffeelint=e():global.coffeelint=e()})(function(){var define,ses,bootstrap,module,exports;
return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ASTApi, ASTLinter, BaseLinter,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseLinter = require('./base_linter.coffee');

ASTApi = (function() {
  function ASTApi(config) {
    this.config = config;
  }

  return ASTApi;

})();

module.exports = ASTLinter = (function(_super) {
  __extends(ASTLinter, _super);

  function ASTLinter(source, config, rules, CoffeeScript) {
    this.CoffeeScript = CoffeeScript;
    ASTLinter.__super__.constructor.call(this, source, config, rules);
    this.astApi = new ASTApi(this.config);
  }

  ASTLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintAST === 'function';
  };

  ASTLinter.prototype.lint = function() {
    var coffeeError, errors, rule, v, _i, _len, _ref,
      _this = this;

    errors = [];
    try {
      this.node = this.CoffeeScript.nodes(this.source);
    } catch (_error) {
      coffeeError = _error;
      errors.push(this._parseCoffeeScriptError(coffeeError));
      return errors;
    }
    _ref = this.rules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      rule = _ref[_i];
      this.astApi.createError = function(attrs) {
        if (attrs == null) {
          attrs = {};
        }
        return _this.createError(rule.rule.name, attrs);
      };
      rule.errors = errors;
      v = this.normalizeResult(rule, rule.lintAST(this.node, this.astApi));
      if (v != null) {
        return v;
      }
    }
    return errors;
  };

  ASTLinter.prototype._parseCoffeeScriptError = function(coffeeError) {
    var attrs, lineNumber, match, message, rule;

    rule = this.config['coffeescript_error'];
    message = coffeeError.toString();
    lineNumber = -1;
    if (coffeeError.location != null) {
      lineNumber = coffeeError.location.first_line + 1;
    } else {
      match = /line (\d+)/.exec(message);
      if ((match != null ? match.length : void 0) > 1) {
        lineNumber = parseInt(match[1], 10);
      }
    }
    attrs = {
      message: message,
      level: rule.level,
      lineNumber: lineNumber
    };
    return this.createError('coffeescript_error', attrs);
  };

  return ASTLinter;

})(BaseLinter);


},{"./base_linter.coffee":2}],2:[function(require,module,exports){
var BaseLinter, defaults, extend,
  __slice = [].slice;

extend = function() {
  var destination, k, source, sources, v, _i, _len;

  destination = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  for (_i = 0, _len = sources.length; _i < _len; _i++) {
    source = sources[_i];
    for (k in source) {
      v = source[k];
      destination[k] = v;
    }
  }
  return destination;
};

defaults = function(source, defaults) {
  return extend({}, defaults, source);
};

module.exports = BaseLinter = (function() {
  function BaseLinter(source, config, rules) {
    this.source = source;
    this.config = config;
    this.setupRules(rules);
  }

  BaseLinter.prototype.isObject = function(obj) {
    return obj === Object(obj);
  };

  BaseLinter.prototype.createError = function(ruleName, attrs) {
    var level, _ref;

    if (attrs == null) {
      attrs = {};
    }
    if ((_ref = attrs.level) == null) {
      attrs.level = this.config[ruleName].level;
    }
    level = attrs.level;
    if (level !== 'ignore' && level !== 'warn' && level !== 'error') {
      throw new Error("unknown level " + level);
    }
    if (level === 'error' || level === 'warn') {
      attrs.rule = ruleName;
      return defaults(attrs, this.config[ruleName]);
    } else {
      return null;
    }
  };

  BaseLinter.prototype.acceptRule = function(rule) {
    throw new Error("acceptRule needs to be overridden in the subclass");
  };

  BaseLinter.prototype.setupRules = function(rules) {
    var RuleConstructor, level, name, rule, _results;

    this.rules = [];
    _results = [];
    for (name in rules) {
      RuleConstructor = rules[name];
      level = this.config[name].level;
      if (level === 'error' || level === 'warn') {
        rule = new RuleConstructor(this, this.config);
        if (this.acceptRule(rule)) {
          _results.push(this.rules.push(rule));
        } else {
          _results.push(void 0);
        }
      } else if (level !== 'ignore') {
        throw new Error("unknown level " + level);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  BaseLinter.prototype.normalizeResult = function(p, result) {
    if (result === true) {
      return this.createError(p.rule.name);
    }
    if (this.isObject(result)) {
      return this.createError(p.rule.name, result);
    }
  };

  return BaseLinter;

})();


},{}],3:[function(require,module,exports){
/*
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
*/

var ASTLinter, CoffeeScript, ERROR, IGNORE, LexicalLinter, LineLinter, RULES, WARN, coffeelint, cs, defaults, difference, extend, mergeDefaultConfig, _rules,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

coffeelint = exports;

if (typeof window !== "undefined" && window !== null) {
  CoffeeScript = window.CoffeeScript;
} else {
  cs = 'coffee-script';
  CoffeeScript = require(cs);
}

coffeelint.VERSION = "0.6.0";

ERROR = 'error';

WARN = 'warn';

IGNORE = 'ignore';

coffeelint.RULES = RULES = require('./rules.coffee');

extend = function() {
  var destination, k, source, sources, v, _i, _len;

  destination = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  for (_i = 0, _len = sources.length; _i < _len; _i++) {
    source = sources[_i];
    for (k in source) {
      v = source[k];
      destination[k] = v;
    }
  }
  return destination;
};

defaults = function(source, defaults) {
  return extend({}, defaults, source);
};

difference = function(a, b) {
  var j, _ref, _results;

  j = 0;
  _results = [];
  while (j < a.length) {
    if (_ref = a[j], __indexOf.call(b, _ref) >= 0) {
      _results.push(a.splice(j, 1));
    } else {
      _results.push(j++);
    }
  }
  return _results;
};

LineLinter = require('./line_linter.coffee');

LexicalLinter = require('./lexical_linter.coffee');

ASTLinter = require('./ast_linter.coffee');

mergeDefaultConfig = function(userConfig) {
  var config, rule, ruleConfig;

  config = {};
  for (rule in RULES) {
    ruleConfig = RULES[rule];
    config[rule] = defaults(userConfig[rule], ruleConfig);
  }
  return config;
};

coffeelint.invertLiterate = function(source) {
  var line, newSource, _i, _len, _ref;

  source = CoffeeScript.helpers.invertLiterate(source);
  newSource = "";
  _ref = source.split("\n");
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    line = _ref[_i];
    if (line.match(/^#/)) {
      line = line.replace(/\s*$/, '');
    }
    line = line.replace(/^\s{4}/g, '');
    newSource += "" + line + "\n";
  }
  return newSource;
};

_rules = {};

coffeelint.registerRule = function(RuleConstructor, ruleName) {
  var e, name, p, _ref, _ref1;

  if (ruleName == null) {
    ruleName = void 0;
  }
  p = new RuleConstructor;
  name = (p != null ? (_ref = p.rule) != null ? _ref.name : void 0 : void 0) || "(unknown)";
  e = function(msg) {
    throw new Error("Invalid rule: " + name + " " + msg);
  };
  if (p.rule == null) {
    e("Rules must provide rule attribute with a default configuration.");
  }
  if (p.rule.name == null) {
    e("Rule defaults require a name");
  }
  if ((ruleName != null) && ruleName !== p.rule.name) {
    e("Mismatched rule name: " + ruleName);
  }
  if (p.rule.message == null) {
    e("Rule defaults require a message");
  }
  if (p.rule.description == null) {
    e("Rule defaults require a description");
  }
  if ((_ref1 = p.rule.level) !== 'ignore' && _ref1 !== 'warn' && _ref1 !== 'error') {
    e("Default level must be 'ignore', 'warn', or 'error'");
  }
  if (typeof p.lintToken === 'function') {
    if (!p.tokens) {
      e("'tokens' is required for 'lintToken'");
    }
  } else if (typeof p.lintLine !== 'function' && typeof p.lintAST !== 'function') {
    e("Rules must implement lintToken, lintLine, or lintAST");
  }
  RULES[p.rule.name] = p.rule;
  return _rules[p.rule.name] = RuleConstructor;
};

coffeelint.registerRule(require('./rules/arrow_spacing.coffee'));

coffeelint.registerRule(require('./rules/no_tabs.coffee'));

coffeelint.registerRule(require('./rules/no_trailing_whitespace.coffee'));

coffeelint.registerRule(require('./rules/max_line_length.coffee'));

coffeelint.registerRule(require('./rules/line_endings.coffee'));

coffeelint.registerRule(require('./rules/no_trailing_semicolons.coffee'));

coffeelint.registerRule(require('./rules/indentation.coffee'));

coffeelint.registerRule(require('./rules/camel_case_classes.coffee'));

coffeelint.registerRule(require('./rules/no_implicit_braces.coffee'));

coffeelint.registerRule(require('./rules/no_plusplus.coffee'));

coffeelint.registerRule(require('./rules/no_throwing_strings.coffee'));

coffeelint.registerRule(require('./rules/no_backticks.coffee'));

coffeelint.registerRule(require('./rules/no_implicit_parens.coffee'));

coffeelint.registerRule(require('./rules/no_empty_param_list.coffee'));

coffeelint.registerRule(require('./rules/no_stand_alone_at.coffee'));

coffeelint.registerRule(require('./rules/space_operators.coffee'));

coffeelint.registerRule(require('./rules/duplicate_key.coffee'));

coffeelint.registerRule(require('./rules/empty_constructor_needs_parens.coffee'));

coffeelint.registerRule(require('./rules/cyclomatic_complexity.coffee'));

coffeelint.registerRule(require('./rules/newlines_after_classes.coffee'));

coffeelint.registerRule(require('./rules/non_empty_constructor_needs_parens.coffee'));

coffeelint.lint = function(source, userConfig, literate) {
  var all_errors, astErrors, block_config, cmd, config, disabled, disabled_initially, e, errors, i, l, lexErrors, lexicalLinter, lineErrors, lineLinter, next_line, r, rules, s, tokensByLine, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4;

  if (userConfig == null) {
    userConfig = {};
  }
  if (literate == null) {
    literate = false;
  }
  if (literate) {
    source = this.invertLiterate(source);
  }
  config = mergeDefaultConfig(userConfig);
  disabled_initially = [];
  _ref = source.split('\n');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    l = _ref[_i];
    s = LineLinter.configStatement.exec(l);
    if ((s != null ? s.length : void 0) > 2 && __indexOf.call(s, 'enable') >= 0) {
      _ref1 = s.slice(1);
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        r = _ref1[_j];
        if (r !== 'enable' && r !== 'disable') {
          if (!(r in config && ((_ref2 = config[r].level) === 'warn' || _ref2 === 'error'))) {
            disabled_initially.push(r);
            config[r] = {
              level: 'error'
            };
          }
        }
      }
    }
  }
  astErrors = new ASTLinter(source, config, _rules, CoffeeScript).lint();
  lexicalLinter = new LexicalLinter(source, config, _rules, CoffeeScript);
  lexErrors = lexicalLinter.lint();
  tokensByLine = lexicalLinter.tokensByLine;
  lineLinter = new LineLinter(source, config, _rules, tokensByLine);
  lineErrors = lineLinter.lint();
  errors = lexErrors.concat(lineErrors, astErrors);
  errors.sort(function(a, b) {
    return a.lineNumber - b.lineNumber;
  });
  all_errors = errors;
  errors = [];
  disabled = disabled_initially;
  next_line = 0;
  block_config = lineLinter.block_config;
  for (i = _k = 0, _ref3 = source.split('\n').length; 0 <= _ref3 ? _k < _ref3 : _k > _ref3; i = 0 <= _ref3 ? ++_k : --_k) {
    for (cmd in block_config) {
      rules = block_config[cmd][i];
      if (rules != null) {
        ({
          'disable': function() {
            return disabled = disabled.concat(rules);
          },
          'enable': function() {
            difference(disabled, rules);
            if (rules.length === 0) {
              return disabled = disabled_initially;
            }
          }
        })[cmd]();
      }
    }
    while (next_line === i && all_errors.length > 0) {
      next_line = all_errors[0].lineNumber - 1;
      e = all_errors[0];
      if (e.lineNumber === i + 1 || (e.lineNumber == null)) {
        e = all_errors.shift();
        if (_ref4 = e.rule, __indexOf.call(disabled, _ref4) < 0) {
          errors.push(e);
        }
      }
    }
  }
  return errors;
};


},{"./ast_linter.coffee":1,"./lexical_linter.coffee":4,"./line_linter.coffee":5,"./rules.coffee":6,"./rules/arrow_spacing.coffee":7,"./rules/camel_case_classes.coffee":8,"./rules/cyclomatic_complexity.coffee":9,"./rules/duplicate_key.coffee":10,"./rules/empty_constructor_needs_parens.coffee":11,"./rules/indentation.coffee":12,"./rules/line_endings.coffee":13,"./rules/max_line_length.coffee":14,"./rules/newlines_after_classes.coffee":15,"./rules/no_backticks.coffee":16,"./rules/no_empty_param_list.coffee":17,"./rules/no_implicit_braces.coffee":18,"./rules/no_implicit_parens.coffee":19,"./rules/no_plusplus.coffee":20,"./rules/no_stand_alone_at.coffee":21,"./rules/no_tabs.coffee":22,"./rules/no_throwing_strings.coffee":23,"./rules/no_trailing_semicolons.coffee":24,"./rules/no_trailing_whitespace.coffee":25,"./rules/non_empty_constructor_needs_parens.coffee":26,"./rules/space_operators.coffee":27}],4:[function(require,module,exports){
var BaseLinter, LexicalLinter, TokenApi,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

TokenApi = (function() {
  function TokenApi(CoffeeScript, source, config, tokensByLine) {
    this.config = config;
    this.tokensByLine = tokensByLine;
    this.tokens = CoffeeScript.tokens(source);
    this.lines = source.split('\n');
    this.tokensByLine = {};
  }

  TokenApi.prototype.i = 0;

  TokenApi.prototype.peek = function(n) {
    if (n == null) {
      n = 1;
    }
    return this.tokens[this.i + n] || null;
  };

  return TokenApi;

})();

BaseLinter = require('./base_linter.coffee');

module.exports = LexicalLinter = (function(_super) {
  __extends(LexicalLinter, _super);

  function LexicalLinter(source, config, rules, CoffeeScript) {
    LexicalLinter.__super__.constructor.call(this, source, config, rules);
    this.tokenApi = new TokenApi(CoffeeScript, source, this.config, this.tokensByLine);
    this.tokensByLine = this.tokenApi.tokensByLine;
  }

  LexicalLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintToken === 'function';
  };

  LexicalLinter.prototype.lint = function() {
    var error, errors, i, token, _i, _j, _len, _len1, _ref, _ref1;

    errors = [];
    _ref = this.tokenApi.tokens;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      token = _ref[i];
      this.tokenApi.i = i;
      _ref1 = this.lintToken(token);
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        error = _ref1[_j];
        errors.push(error);
      }
    }
    return errors;
  };

  LexicalLinter.prototype.lintToken = function(token) {
    var errors, lineNumber, rule, type, v, value, _base, _i, _len, _ref, _ref1, _ref2;

    type = token[0], value = token[1], lineNumber = token[2];
    if (typeof lineNumber === "object") {
      if (type === 'OUTDENT' || type === 'INDENT') {
        lineNumber = lineNumber.last_line;
      } else {
        lineNumber = lineNumber.first_line;
      }
    }
    if ((_ref = (_base = this.tokensByLine)[lineNumber]) == null) {
      _base[lineNumber] = [];
    }
    this.tokensByLine[lineNumber].push(token);
    this.lineNumber = lineNumber || this.lineNumber || 0;
    this.tokenApi.lineNumber = this.lineNumber;
    errors = [];
    _ref1 = this.rules;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      rule = _ref1[_i];
      if (!(_ref2 = token[0], __indexOf.call(rule.tokens, _ref2) >= 0)) {
        continue;
      }
      v = this.normalizeResult(rule, rule.lintToken(token, this.tokenApi));
      if (v != null) {
        errors.push(v);
      }
    }
    return errors;
  };

  LexicalLinter.prototype.createError = function(ruleName, attrs) {
    if (attrs == null) {
      attrs = {};
    }
    attrs.lineNumber = this.lineNumber + 1;
    attrs.line = this.tokenApi.lines[this.lineNumber];
    return LexicalLinter.__super__.createError.call(this, ruleName, attrs);
  };

  return LexicalLinter;

})(BaseLinter);


},{"./base_linter.coffee":2}],5:[function(require,module,exports){
var BaseLinter, LineApi, LineLinter, configStatement,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

LineApi = (function() {
  function LineApi(source, config, tokensByLine) {
    this.config = config;
    this.tokensByLine = tokensByLine;
    this.line = null;
    this.lines = source.split('\n');
    this.lineCount = this.lines.length;
    this.context = {
      "class": {
        inClass: false,
        lastUnemptyLineInClass: null,
        classIndents: null
      }
    };
  }

  LineApi.prototype.lineNumber = 0;

  LineApi.prototype.maintainClassContext = function(line) {
    if (this.context["class"].inClass) {
      if (this.lineHasToken('INDENT')) {
        this.context["class"].classIndents++;
      } else if (this.lineHasToken('OUTDENT')) {
        this.context["class"].classIndents--;
        if (this.context["class"].classIndents === 0) {
          this.context["class"].inClass = false;
          this.context["class"].classIndents = null;
        }
      }
      if (this.context["class"].inClass && !line.match(/^\s*$/)) {
        this.context["class"].lastUnemptyLineInClass = this.lineNumber;
      }
    } else {
      if (!line.match(/\\s*/)) {
        this.context["class"].lastUnemptyLineInClass = null;
      }
      if (this.lineHasToken('CLASS')) {
        this.context["class"].inClass = true;
        this.context["class"].lastUnemptyLineInClass = this.lineNumber;
        this.context["class"].classIndents = 0;
      }
    }
    return null;
  };

  LineApi.prototype.isLastLine = function() {
    return this.lineNumber === this.lineCount - 1;
  };

  LineApi.prototype.lineHasToken = function(tokenType, lineNumber) {
    var token, tokens, _i, _len;

    if (tokenType == null) {
      tokenType = null;
    }
    if (lineNumber == null) {
      lineNumber = null;
    }
    lineNumber = lineNumber != null ? lineNumber : this.lineNumber;
    if (tokenType == null) {
      return this.tokensByLine[lineNumber] != null;
    } else {
      tokens = this.tokensByLine[lineNumber];
      if (tokens == null) {
        return null;
      }
      for (_i = 0, _len = tokens.length; _i < _len; _i++) {
        token = tokens[_i];
        if (token[0] === tokenType) {
          return true;
        }
      }
      return false;
    }
  };

  LineApi.prototype.getLineTokens = function() {
    return this.tokensByLine[this.lineNumber] || [];
  };

  return LineApi;

})();

BaseLinter = require('./base_linter.coffee');

configStatement = /coffeelint:\s*(disable|enable)(?:=([\w\s,]*))?/;

module.exports = LineLinter = (function(_super) {
  __extends(LineLinter, _super);

  LineLinter.configStatement = configStatement;

  function LineLinter(source, config, rules, tokensByLine) {
    LineLinter.__super__.constructor.call(this, source, config, rules);
    this.lineApi = new LineApi(source, config, tokensByLine);
    this.block_config = {
      enable: {},
      disable: {}
    };
  }

  LineLinter.prototype.acceptRule = function(rule) {
    return typeof rule.lintLine === 'function';
  };

  LineLinter.prototype.lint = function() {
    var error, errors, line, lineNumber, _i, _j, _len, _len1, _ref, _ref1;

    errors = [];
    _ref = this.lineApi.lines;
    for (lineNumber = _i = 0, _len = _ref.length; _i < _len; lineNumber = ++_i) {
      line = _ref[lineNumber];
      this.lineApi.lineNumber = this.lineNumber = lineNumber;
      this.lineApi.maintainClassContext(line);
      this.collectInlineConfig(line);
      _ref1 = this.lintLine(line);
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        error = _ref1[_j];
        errors.push(error);
      }
    }
    return errors;
  };

  LineLinter.prototype.lintLine = function(line) {
    var errors, rule, v, _i, _len, _ref;

    errors = [];
    _ref = this.rules;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      rule = _ref[_i];
      v = this.normalizeResult(rule, rule.lintLine(line, this.lineApi));
      if (v != null) {
        errors.push(v);
      }
    }
    return errors;
  };

  LineLinter.prototype.collectInlineConfig = function(line) {
    var cmd, r, result, rules, _i, _len, _ref;

    result = configStatement.exec(line);
    if (result != null) {
      cmd = result[1];
      rules = [];
      if (result[2] != null) {
        _ref = result[2].split(',');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          r = _ref[_i];
          rules.push(r.replace(/^\s+|\s+$/g, ""));
        }
      }
      this.block_config[cmd][this.lineNumber] = rules;
    }
    return null;
  };

  LineLinter.prototype.createError = function(rule, attrs) {
    var _ref;

    if (attrs == null) {
      attrs = {};
    }
    attrs.lineNumber = this.lineNumber + 1;
    attrs.level = (_ref = this.config[rule]) != null ? _ref.level : void 0;
    return LineLinter.__super__.createError.call(this, rule, attrs);
  };

  return LineLinter;

})(BaseLinter);


},{"./base_linter.coffee":2}],6:[function(require,module,exports){
var ERROR, IGNORE, WARN;

ERROR = 'error';

WARN = 'warn';

IGNORE = 'ignore';

module.exports = {
  coffeescript_error: {
    level: ERROR,
    message: ''
  }
};


},{}],7:[function(require,module,exports){
var ArrowSpacing;

module.exports = ArrowSpacing = (function() {
  function ArrowSpacing() {}

  ArrowSpacing.prototype.rule = {
    name: 'arrow_spacing',
    level: 'ignore',
    message: 'Function arrow (->) must be spaced properly',
    description: "<p>This rule checks to see that there is spacing before and after\nthe arrow operator that declares a function. This rule is disabled\nby default.</p> <p>Note that if arrow_spacing is enabled, and you\npass an empty function as a parameter, arrow_spacing will accept\neither a space or no space in-between the arrow operator and the\nparenthesis</p>\n<pre><code># Both of this will not trigger an error,\n# even with arrow_spacing enabled.\nx(-> 3)\nx( -> 3)\n\n# However, this will trigger an error\nx((a,b)-> 3)\n</code>\n</pre>"
  };

  ArrowSpacing.prototype.tokens = ['->'];

  ArrowSpacing.prototype.lintToken = function(token, tokenApi) {
    var pp;

    pp = tokenApi.peek(-1);
    if (!(((token.spaced != null) || (token.newLine != null) || this.atEof(tokenApi)) && (((pp.spaced != null) || pp[0] === 'TERMINATOR') || (pp.generated != null) || pp[0] === "INDENT" || (pp[1] === "(" && (pp.generated == null))))) {
      return true;
    } else {
      return null;
    }
  };

  ArrowSpacing.prototype.atEof = function(tokenApi) {
    var i, token, tokens, _i, _len, _ref, _ref1;

    tokens = tokenApi.tokens, i = tokenApi.i;
    _ref = tokens.slice(i + 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      token = _ref[_i];
      if (!(token.generated || ((_ref1 = token[0]) === 'OUTDENT' || _ref1 === 'TERMINATOR'))) {
        return false;
      }
    }
    return true;
  };

  return ArrowSpacing;

})();


},{}],8:[function(require,module,exports){
var CamelCaseClasses, regexes;

regexes = {
  camelCase: /^[A-Z][a-zA-Z\d]*$/
};

module.exports = CamelCaseClasses = (function() {
  function CamelCaseClasses() {}

  CamelCaseClasses.prototype.rule = {
    name: 'camel_case_classes',
    level: 'error',
    message: 'Class names should be camel cased',
    description: "This rule mandates that all class names are camel cased. Camel\ncasing class names is a generally accepted way of distinguishing\nconstructor functions - which require the 'new' prefix to behave\nproperly - from plain old functions.\n<pre>\n<code># Good!\nclass BoaConstrictor\n\n# Bad!\nclass boaConstrictor\n</code>\n</pre>\nThis rule is enabled by default."
  };

  CamelCaseClasses.prototype.tokens = ['CLASS'];

  CamelCaseClasses.prototype.lintToken = function(token, tokenApi) {
    var className, offset, _ref, _ref1, _ref2;

    if ((token.newLine != null) || ((_ref = tokenApi.peek()[0]) === 'INDENT' || _ref === 'EXTENDS')) {
      return null;
    }
    className = null;
    offset = 1;
    while (!className) {
      if (((_ref1 = tokenApi.peek(offset + 1)) != null ? _ref1[0] : void 0) === '.') {
        offset += 2;
      } else if (((_ref2 = tokenApi.peek(offset)) != null ? _ref2[0] : void 0) === '@') {
        offset += 1;
      } else {
        className = tokenApi.peek(offset)[1];
      }
    }
    if (!regexes.camelCase.test(className)) {
      return {
        context: "class name: " + className
      };
    }
  };

  return CamelCaseClasses;

})();


},{}],9:[function(require,module,exports){
var NoTabs;

module.exports = NoTabs = (function() {
  function NoTabs() {}

  NoTabs.prototype.rule = {
    name: 'cyclomatic_complexity',
    value: 10,
    level: 'ignore',
    message: 'The cyclomatic complexity is too damn high',
    description: 'Examine the complexity of your application.'
  };

  NoTabs.prototype.getComplexity = function(node) {
    var complexity, name, _ref;

    name = node.constructor.name;
    complexity = name === 'If' || name === 'While' || name === 'For' || name === 'Try' ? 1 : name === 'Op' && ((_ref = node.operator) === '&&' || _ref === '||') ? 1 : name === 'Switch' ? node.cases.length : 0;
    return complexity;
  };

  NoTabs.prototype.lintAST = function(node, astApi) {
    this.astApi = astApi;
    this.lintNode(node);
    return void 0;
  };

  NoTabs.prototype.lintNode = function(node, line) {
    var complexity, error, name, rule,
      _this = this;

    name = node.constructor.name;
    complexity = this.getComplexity(node);
    node.eachChild(function(childNode) {
      var nodeLine;

      nodeLine = childNode.locationData.first_line;
      if (childNode) {
        return complexity += _this.lintNode(childNode, nodeLine);
      }
    });
    rule = this.astApi.config[this.rule.name];
    if (name === 'Code' && complexity >= rule.value) {
      error = this.astApi.createError({
        context: complexity + 1,
        lineNumber: line + 1,
        lineNumberEnd: node.locationData.last_line + 1
      });
      if (error) {
        this.errors.push(error);
      }
    }
    return complexity;
  };

  return NoTabs;

})();


},{}],10:[function(require,module,exports){
var DuplicateKey;

module.exports = DuplicateKey = (function() {
  DuplicateKey.prototype.rule = {
    name: 'duplicate_key',
    level: 'error',
    message: 'Duplicate key defined in object or class',
    description: "Prevents defining duplicate keys in object literals and classes"
  };

  DuplicateKey.prototype.tokens = ['IDENTIFIER', "{", "}"];

  function DuplicateKey() {
    this.braceScopes = [];
  }

  DuplicateKey.prototype.lintToken = function(_arg, tokenApi) {
    var type;

    type = _arg[0];
    if (type === "{" || type === "}") {
      this.lintBrace.apply(this, arguments);
      return void 0;
    }
    if (type === "IDENTIFIER") {
      return this.lintIdentifier.apply(this, arguments);
    }
  };

  DuplicateKey.prototype.lintIdentifier = function(token, tokenApi) {
    var key, nextToken, previousToken;

    key = token[1];
    if (this.currentScope == null) {
      return null;
    }
    nextToken = tokenApi.peek(1);
    if (nextToken[1] !== ':') {
      return null;
    }
    previousToken = tokenApi.peek(-1);
    if (previousToken[0] === '@') {
      key = "@" + key;
    }
    key = "identifier-" + key;
    if (this.currentScope[key]) {
      return true;
    } else {
      this.currentScope[key] = token;
      return null;
    }
  };

  DuplicateKey.prototype.lintBrace = function(token) {
    if (token[0] === '{') {
      if (this.currentScope != null) {
        this.braceScopes.push(this.currentScope);
      }
      this.currentScope = {};
    } else {
      this.currentScope = this.braceScopes.pop();
    }
    return null;
  };

  return DuplicateKey;

})();


},{}],11:[function(require,module,exports){
var EmptyConstructorNeedsParens;

module.exports = EmptyConstructorNeedsParens = (function() {
  function EmptyConstructorNeedsParens() {}

  EmptyConstructorNeedsParens.prototype.rule = {
    name: 'empty_constructor_needs_parens',
    level: 'ignore',
    message: 'Invoking a constructor without parens and without arguments',
    description: "Requires constructors with no parameters to include the parens"
  };

  EmptyConstructorNeedsParens.prototype.tokens = ['UNARY'];

  EmptyConstructorNeedsParens.prototype.lintToken = function(token, tokenApi) {
    var expectedCallStart, expectedIdentifier, identifierIndex;

    if (token[1] === 'new') {
      identifierIndex = 1;
      while (true) {
        expectedIdentifier = tokenApi.peek(identifierIndex);
        expectedCallStart = tokenApi.peek(identifierIndex + 1);
        if ((expectedIdentifier != null ? expectedIdentifier[0] : void 0) === 'IDENTIFIER') {
          if ((expectedCallStart != null ? expectedCallStart[0] : void 0) === '.') {
            identifierIndex += 2;
            continue;
          }
        }
        break;
      }
      if ((expectedIdentifier != null ? expectedIdentifier[0] : void 0) === 'IDENTIFIER' && (expectedCallStart != null)) {
        return this.handleExpectedCallStart(expectedCallStart);
      }
    }
  };

  EmptyConstructorNeedsParens.prototype.handleExpectedCallStart = function(expectedCallStart) {
    if (expectedCallStart[0] !== 'CALL_START') {
      return true;
    }
  };

  return EmptyConstructorNeedsParens;

})();


},{}],12:[function(require,module,exports){
var Indentation;

module.exports = Indentation = (function() {
  Indentation.prototype.rule = {
    name: 'indentation',
    value: 2,
    level: 'error',
    message: 'Line contains inconsistent indentation',
    description: "This rule imposes a standard number of spaces to be used for\nindentation. Since whitespace is significant in CoffeeScript, it's\ncritical that a project chooses a standard indentation format and\nstays consistent. Other roads lead to darkness. <pre> <code>#\nEnabling this option will prevent this ugly\n# but otherwise valid CoffeeScript.\ntwoSpaces = () ->\n  fourSpaces = () ->\n      eightSpaces = () ->\n            'this is valid CoffeeScript'\n\n</code>\n</pre>\nTwo space indentation is enabled by default."
  };

  Indentation.prototype.tokens = ['INDENT', "[", "]"];

  function Indentation() {
    this.arrayTokens = [];
  }

  Indentation.prototype.lintToken = function(token, tokenApi) {
    var currentLine, expected, ignoreIndent, isArrayIndent, isInterpIndent, isMultiline, lineNumber, lines, numIndents, prevNum, previous, previousIndentation, previousLine, previousSymbol, type, _ref;

    type = token[0], numIndents = token[1], lineNumber = token[2];
    if (type === "[" || type === "]") {
      this.lintArray(token);
      return void 0;
    }
    if (token.generated != null) {
      return null;
    }
    previous = tokenApi.peek(-2);
    isInterpIndent = previous && previous[0] === '+';
    previous = tokenApi.peek(-1);
    isArrayIndent = this.inArray() && (previous != null ? previous.newLine : void 0);
    previousSymbol = (_ref = tokenApi.peek(-1)) != null ? _ref[0] : void 0;
    isMultiline = previousSymbol === '=' || previousSymbol === ',';
    ignoreIndent = isInterpIndent || isArrayIndent || isMultiline;
    if (this.isChainedCall(tokenApi)) {
      lines = tokenApi.lines, lineNumber = tokenApi.lineNumber;
      currentLine = lines[lineNumber];
      prevNum = 1;
      while (/^\s*(#|$)/.test(lines[lineNumber - prevNum])) {
        prevNum += 1;
      }
      previousLine = lines[lineNumber - prevNum];
      previousIndentation = previousLine.match(/^(\s*)/)[1].length;
      numIndents = currentLine.match(/^(\s*)/)[1].length;
      numIndents -= previousIndentation;
    }
    expected = tokenApi.config[this.rule.name].value;
    if (!ignoreIndent && numIndents !== expected) {
      return {
        context: "Expected " + expected + " got " + numIndents
      };
    }
  };

  Indentation.prototype.inArray = function() {
    return this.arrayTokens.length > 0;
  };

  Indentation.prototype.lintArray = function(token) {
    if (token[0] === '[') {
      this.arrayTokens.push(token);
    } else if (token[0] === ']') {
      this.arrayTokens.pop();
    }
    return null;
  };

  Indentation.prototype.isChainedCall = function(tokenApi) {
    var i, lastNewLineIndex, lines, t, token, tokens;

    tokens = tokenApi.tokens, i = tokenApi.i;
    lines = (function() {
      var _i, _len, _ref, _results;

      _ref = tokens.slice(0, +i + 1 || 9e9);
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        token = _ref[i];
        if (token.newLine != null) {
          _results.push(i);
        }
      }
      return _results;
    })();
    lastNewLineIndex = lines ? lines[lines.length - 2] : null;
    if (lastNewLineIndex == null) {
      return false;
    }
    tokens = [tokens[lastNewLineIndex], tokens[lastNewLineIndex + 1]];
    return !!((function() {
      var _i, _len, _results;

      _results = [];
      for (_i = 0, _len = tokens.length; _i < _len; _i++) {
        t = tokens[_i];
        if (t && t[0] === '.') {
          _results.push(t);
        }
      }
      return _results;
    })()).length;
  };

  return Indentation;

})();


},{}],13:[function(require,module,exports){
var LineEndings;

module.exports = LineEndings = (function() {
  function LineEndings() {}

  LineEndings.prototype.rule = {
    name: 'line_endings',
    level: 'ignore',
    value: 'unix',
    message: 'Line contains incorrect line endings',
    description: "This rule ensures your project uses only <tt>windows</tt> or\n<tt>unix</tt> line endings. This rule is disabled by default."
  };

  LineEndings.prototype.lintLine = function(line, lineApi) {
    var ending, lastChar, valid, _ref;

    ending = (_ref = lineApi.config[this.rule.name]) != null ? _ref.value : void 0;
    if (!ending || lineApi.isLastLine() || !line) {
      return null;
    }
    lastChar = line[line.length - 1];
    valid = (function() {
      if (ending === 'windows') {
        return lastChar === '\r';
      } else if (ending === 'unix') {
        return lastChar !== '\r';
      } else {
        throw new Error("unknown line ending type: " + ending);
      }
    })();
    if (!valid) {
      return {
        context: "Expected " + ending
      };
    } else {
      return null;
    }
  };

  return LineEndings;

})();


},{}],14:[function(require,module,exports){
var MaxLineLength, regexes;

regexes = {
  longUrlComment: /^\s*\#\s*http[^\s]+$/
};

module.exports = MaxLineLength = (function() {
  function MaxLineLength() {}

  MaxLineLength.prototype.rule = {
    name: 'max_line_length',
    value: 80,
    level: 'error',
    message: 'Line exceeds maximum allowed length',
    description: "This rule imposes a maximum line length on your code. <a\nhref=\"http://www.python.org/dev/peps/pep-0008/\">Python's style\nguide</a> does a good job explaining why you might want to limit the\nlength of your lines, though this is a matter of taste.\n\nLines can be no longer than eighty characters by default."
  };

  MaxLineLength.prototype.lintLine = function(line, lineApi) {
    var max, _ref;

    max = (_ref = lineApi.config[this.rule.name]) != null ? _ref.value : void 0;
    if (max && max < line.length && !regexes.longUrlComment.test(line)) {
      return {
        context: "Length is " + line.length + ", max is " + max
      };
    }
  };

  return MaxLineLength;

})();


},{}],15:[function(require,module,exports){
var NewlinesAfterClasses;

module.exports = NewlinesAfterClasses = (function() {
  function NewlinesAfterClasses() {}

  NewlinesAfterClasses.prototype.rule = {
    name: 'newlines_after_classes',
    value: 3,
    level: 'ignore',
    message: 'Wrong count of newlines between a class and other code',
    description: "Checks the number of newlines between classes and other        code"
  };

  NewlinesAfterClasses.prototype.lintLine = function(line, lineApi) {
    var context, ending, got, lineNumber;

    ending = lineApi.config[this.rule.name].value;
    if (!ending || lineApi.isLastLine()) {
      return null;
    }
    lineNumber = lineApi.lineNumber, context = lineApi.context;
    if (!context["class"].inClass && (context["class"].lastUnemptyLineInClass != null) && (lineNumber - context["class"].lastUnemptyLineInClass) !== ending) {
      got = lineNumber - context["class"].lastUnemptyLineInClass;
      return {
        context: "Expected " + ending + " got " + got
      };
    }
    return null;
  };

  return NewlinesAfterClasses;

})();


},{}],16:[function(require,module,exports){
var NoBackticks;

module.exports = NoBackticks = (function() {
  function NoBackticks() {}

  NoBackticks.prototype.rule = {
    name: 'no_backticks',
    level: 'error',
    message: 'Backticks are forbidden',
    description: "Backticks allow snippets of JavaScript to be embedded in\nCoffeeScript. While some folks consider backticks useful in a few\nniche circumstances, they should be avoided because so none of\nJavaScript's \"bad parts\", like <tt>with</tt> and <tt>eval</tt>,\nsneak into CoffeeScript.\nThis rule is enabled by default."
  };

  NoBackticks.prototype.tokens = ["JS"];

  NoBackticks.prototype.lintToken = function(token, tokenApi) {
    return true;
  };

  return NoBackticks;

})();


},{}],17:[function(require,module,exports){
var NoEmptyParamList;

module.exports = NoEmptyParamList = (function() {
  function NoEmptyParamList() {}

  NoEmptyParamList.prototype.rule = {
    name: 'no_empty_param_list',
    level: 'ignore',
    message: 'Empty parameter list is forbidden',
    description: "This rule prohibits empty parameter lists in function definitions.\n<pre>\n<code># The empty parameter list in here is unnecessary:\nmyFunction = () -&gt;\n\n# We might favor this instead:\nmyFunction = -&gt;\n</code>\n</pre>\nEmpty parameter lists are permitted by default."
  };

  NoEmptyParamList.prototype.tokens = ["PARAM_START"];

  NoEmptyParamList.prototype.lintToken = function(token, tokenApi) {
    var nextType;

    nextType = tokenApi.peek()[0];
    return nextType === 'PARAM_END';
  };

  return NoEmptyParamList;

})();


},{}],18:[function(require,module,exports){
var NoImplicitBraces;

module.exports = NoImplicitBraces = (function() {
  function NoImplicitBraces() {}

  NoImplicitBraces.prototype.rule = {
    name: 'no_implicit_braces',
    level: 'ignore',
    message: 'Implicit braces are forbidden',
    description: "This rule prohibits implicit braces when declaring object literals.\nImplicit braces can make code more difficult to understand,\nespecially when used in combination with optional parenthesis.\n<pre>\n<code># Do you find this code ambiguous? Is it a\n# function call with three arguments or four?\nmyFunction a, b, 1:2, 3:4\n\n# While the same code written in a more\n# explicit manner has no ambiguity.\nmyFunction(a, b, {1:2, 3:4})\n</code>\n</pre>\nImplicit braces are permitted by default, since their use is\nidiomatic CoffeeScript."
  };

  NoImplicitBraces.prototype.tokens = ["{"];

  NoImplicitBraces.prototype.lintToken = function(token, tokenApi) {
    var i, t;

    if (token.generated) {
      i = -1;
      while (true) {
        t = tokenApi.peek(i);
        if ((t == null) || t[0] === 'TERMINATOR') {
          return true;
        }
        if (t[0] === 'CLASS') {
          return null;
        }
        i -= 1;
      }
    }
  };

  return NoImplicitBraces;

})();


},{}],19:[function(require,module,exports){
var NoImplicitParens;

module.exports = NoImplicitParens = (function() {
  function NoImplicitParens() {}

  NoImplicitParens.prototype.rule = {
    name: 'no_implicit_parens',
    level: 'ignore',
    message: 'Implicit parens are forbidden',
    description: "This rule prohibits implicit parens on function calls.\n<pre>\n<code># Some folks don't like this style of coding.\nmyFunction a, b, c\n\n# And would rather it always be written like this:\nmyFunction(a, b, c)\n</code>\n</pre>\nImplicit parens are permitted by default, since their use is\nidiomatic CoffeeScript."
  };

  NoImplicitParens.prototype.tokens = ["CALL_START"];

  NoImplicitParens.prototype.lintToken = function(token, tokenApi) {
    return token.generated;
  };

  return NoImplicitParens;

})();


},{}],20:[function(require,module,exports){
var NoPlusPlus;

module.exports = NoPlusPlus = (function() {
  function NoPlusPlus() {}

  NoPlusPlus.prototype.rule = {
    name: 'no_plusplus',
    level: 'ignore',
    message: 'The increment and decrement operators are forbidden',
    description: "This rule forbids the increment and decrement arithmetic operators.\nSome people believe the <tt>++</tt> and <tt>--</tt> to be cryptic\nand the cause of bugs due to misunderstandings of their precedence\nrules.\nThis rule is disabled by default."
  };

  NoPlusPlus.prototype.tokens = ["++", "--"];

  NoPlusPlus.prototype.lintToken = function(token, tokenApi) {
    return {
      context: "found '" + token[0] + "'"
    };
  };

  return NoPlusPlus;

})();


},{}],21:[function(require,module,exports){
var NoStandAloneAt;

module.exports = NoStandAloneAt = (function() {
  function NoStandAloneAt() {}

  NoStandAloneAt.prototype.rule = {
    name: 'no_stand_alone_at',
    level: 'ignore',
    message: '@ must not be used stand alone',
    description: "This rule checks that no stand alone @ are in use, they are\ndiscouraged. Further information in CoffeScript issue <a\nhref=\"https://github.com/jashkenas/coffee-script/issues/1601\">\n#1601</a>"
  };

  NoStandAloneAt.prototype.tokens = ["@"];

  NoStandAloneAt.prototype.lintToken = function(token, tokenApi) {
    var isDot, isIdentifier, isIndexStart, isValidProtoProperty, nextToken, protoProperty, spaced;

    nextToken = tokenApi.peek();
    spaced = token.spaced;
    isIdentifier = nextToken[0] === 'IDENTIFIER';
    isIndexStart = nextToken[0] === 'INDEX_START';
    isDot = nextToken[0] === '.';
    if (nextToken[0] === '::') {
      protoProperty = tokenApi.peek(2);
      isValidProtoProperty = protoProperty[0] === 'IDENTIFIER';
    }
    if (spaced || (!isIdentifier && !isIndexStart && !isDot && !isValidProtoProperty)) {
      return true;
    }
  };

  return NoStandAloneAt;

})();


},{}],22:[function(require,module,exports){
var NoTabs, indentationRegex,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

indentationRegex = /\S/;

module.exports = NoTabs = (function() {
  function NoTabs() {}

  NoTabs.prototype.rule = {
    name: 'no_tabs',
    level: 'error',
    message: 'Line contains tab indentation',
    description: "This rule forbids tabs in indentation. Enough said. It is enabled by\ndefault."
  };

  NoTabs.prototype.lintLine = function(line, lineApi) {
    var indentation;

    indentation = line.split(indentationRegex)[0];
    if (lineApi.lineHasToken() && __indexOf.call(indentation, '\t') >= 0) {
      return true;
    } else {
      return null;
    }
  };

  return NoTabs;

})();


},{}],23:[function(require,module,exports){
var NoThrowingStrings;

module.exports = NoThrowingStrings = (function() {
  function NoThrowingStrings() {}

  NoThrowingStrings.prototype.rule = {
    name: 'no_throwing_strings',
    level: 'error',
    message: 'Throwing strings is forbidden',
    description: "This rule forbids throwing string literals or interpolations. While\nJavaScript (and CoffeeScript by extension) allow any expression to\nbe thrown, it is best to only throw <a\nhref=\"https://developer.mozilla.org\n/en/JavaScript/Reference/Global_Objects/Error\"> Error</a> objects,\nbecause they contain valuable debugging information like the stack\ntrace. Because of JavaScript's dynamic nature, CoffeeLint cannot\nensure you are always throwing instances of <tt>Error</tt>. It will\nonly catch the simple but real case of throwing literal strings.\n<pre>\n<code># CoffeeLint will catch this:\nthrow \"i made a boo boo\"\n\n# ... but not this:\nthrow getSomeString()\n</code>\n</pre>\nThis rule is enabled by default."
  };

  NoThrowingStrings.prototype.tokens = ["THROW"];

  NoThrowingStrings.prototype.lintToken = function(token, tokenApi) {
    var n1, n2, nextIsString, _ref;

    _ref = [tokenApi.peek(), tokenApi.peek(2)], n1 = _ref[0], n2 = _ref[1];
    nextIsString = n1[0] === 'STRING' || (n1[0] === '(' && n2[0] === 'STRING');
    return nextIsString;
  };

  return NoThrowingStrings;

})();


},{}],24:[function(require,module,exports){
var NoTrailingSemicolons, regexes,
  __slice = [].slice;

regexes = {
  trailingSemicolon: /;\r?$/
};

module.exports = NoTrailingSemicolons = (function() {
  function NoTrailingSemicolons() {}

  NoTrailingSemicolons.prototype.rule = {
    name: 'no_trailing_semicolons',
    level: 'error',
    message: 'Line contains a trailing semicolon',
    description: "This rule prohibits trailing semicolons, since they are needless\ncruft in CoffeeScript.\n<pre>\n<code># This semicolon is meaningful.\nx = '1234'; console.log(x)\n\n# This semicolon is redundant.\nalert('end of line');\n</code>\n</pre>\nTrailing semicolons are forbidden by default."
  };

  NoTrailingSemicolons.prototype.lintLine = function(line, lineApi) {
    var first, hasNewLine, hasSemicolon, last, _i, _ref;

    hasSemicolon = regexes.trailingSemicolon.test(line);
    _ref = lineApi.getLineTokens(), first = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), last = _ref[_i++];
    hasNewLine = last && (last.newLine != null);
    if (hasSemicolon && !hasNewLine && lineApi.lineHasToken() && last[0] !== 'STRING') {
      return true;
    }
  };

  return NoTrailingSemicolons;

})();


},{}],25:[function(require,module,exports){
var NoTrailingWhitespace, regexes;

regexes = {
  trailingWhitespace: /[^\s]+[\t ]+\r?$/,
  lineHasComment: /^\s*[^\#]*\#/
};

module.exports = NoTrailingWhitespace = (function() {
  function NoTrailingWhitespace() {}

  NoTrailingWhitespace.prototype.rule = {
    name: 'no_trailing_whitespace',
    level: 'error',
    message: 'Line ends with trailing whitespace',
    allowed_in_comments: false,
    description: "This rule forbids trailing whitespace in your code, since it is\nneedless cruft. It is enabled by default."
  };

  NoTrailingWhitespace.prototype.lintLine = function(line, lineApi) {
    var str, token, tokens, _i, _len, _ref, _ref1;

    if (regexes.trailingWhitespace.test(line)) {
      if (!((_ref = lineApi.config['no_trailing_whitespace']) != null ? _ref.allowed_in_comments : void 0)) {
        return true;
      }
      line = line;
      tokens = lineApi.tokensByLine[lineApi.lineNumber];
      if (!tokens) {
        return null;
      }
      _ref1 = (function() {
        var _j, _len, _results;

        _results = [];
        for (_j = 0, _len = tokens.length; _j < _len; _j++) {
          token = tokens[_j];
          if (token[0] === 'STRING') {
            _results.push(token[1]);
          }
        }
        return _results;
      })();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        str = _ref1[_i];
        line = line.replace(str, 'STRING');
      }
      if (!regexes.lineHasComment.test(line)) {
        return true;
      }
    }
  };

  return NoTrailingWhitespace;

})();


},{}],26:[function(require,module,exports){
var NonEmptyConstructorNeedsParens, ParentClass, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ParentClass = require('./empty_constructor_needs_parens.coffee');

module.exports = NonEmptyConstructorNeedsParens = (function(_super) {
  __extends(NonEmptyConstructorNeedsParens, _super);

  function NonEmptyConstructorNeedsParens() {
    _ref = NonEmptyConstructorNeedsParens.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  NonEmptyConstructorNeedsParens.prototype.rule = {
    name: 'non_empty_constructor_needs_parens',
    level: 'ignore',
    message: 'Invoking a constructor without parens and with arguments',
    description: "Requires constructors with parameters to include the parens"
  };

  NonEmptyConstructorNeedsParens.prototype.handleExpectedCallStart = function(expectedCallStart) {
    if (expectedCallStart[0] === 'CALL_START' && expectedCallStart.generated) {
      return true;
    }
  };

  return NonEmptyConstructorNeedsParens;

})(ParentClass);


},{"./empty_constructor_needs_parens.coffee":11}],27:[function(require,module,exports){
var SpaceOperators,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = SpaceOperators = (function() {
  SpaceOperators.prototype.rule = {
    name: 'space_operators',
    level: 'ignore',
    message: 'Operators must be spaced properly',
    description: "This rule enforces that operators have space around them."
  };

  SpaceOperators.prototype.tokens = ["+", "-", "=", "MATH", "COMPARE", "LOGIC", "COMPOUND_ASSIGN", "(", ")", "CALL_START", "CALL_END"];

  function SpaceOperators() {
    this.callTokens = [];
    this.parenTokens = [];
  }

  SpaceOperators.prototype.lintToken = function(_arg, tokenApi) {
    var type;

    type = _arg[0];
    if (type === "CALL_START" || type === "CALL_END") {
      this.lintCall.apply(this, arguments);
      return void 0;
    }
    if (type === "(" || type === ")") {
      this.lintParens.apply(this, arguments);
      return void 0;
    }
    if (type === "+" || type === "-") {
      return this.lintPlus.apply(this, arguments);
    } else {
      return this.lintMath.apply(this, arguments);
    }
  };

  SpaceOperators.prototype.lintPlus = function(token, tokenApi) {
    var isUnary, p, unaries, _ref;

    if (this.isInInterpolation() || this.isInExtendedRegex()) {
      return null;
    }
    p = tokenApi.peek(-1);
    unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START', 'INDEX_START', '..', '...', 'COMPARE', 'IF', 'THROW', 'LOGIC', 'POST_IF', ':', '[', 'INDENT', 'COMPOUND_ASSIGN', 'RETURN', 'MATH', 'BY'];
    isUnary = !p ? false : (_ref = p[0], __indexOf.call(unaries, _ref) >= 0);
    if ((isUnary && token.spaced) || (!isUnary && !token.spaced && !token.newLine)) {
      return {
        context: token[1]
      };
    } else {
      return null;
    }
  };

  SpaceOperators.prototype.lintMath = function(token, tokenApi) {
    if (!token.spaced && !token.newLine) {
      return {
        context: token[1]
      };
    } else {
      return null;
    }
  };

  SpaceOperators.prototype.isInExtendedRegex = function() {
    var t, _i, _len, _ref;

    _ref = this.callTokens;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      if (t.isRegex) {
        return true;
      }
    }
    return false;
  };

  SpaceOperators.prototype.lintCall = function(token, tokenApi) {
    var p;

    if (token[0] === 'CALL_START') {
      p = tokenApi.peek(-1);
      token.isRegex = p && p[0] === 'IDENTIFIER' && p[1] === 'RegExp';
      this.callTokens.push(token);
    } else {
      this.callTokens.pop();
    }
    return null;
  };

  SpaceOperators.prototype.isInInterpolation = function() {
    var t, _i, _len, _ref;

    _ref = this.parenTokens;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      if (t.isInterpolation) {
        return true;
      }
    }
    return false;
  };

  SpaceOperators.prototype.lintParens = function(token, tokenApi) {
    var i, n1, n2, p1;

    if (token[0] === '(') {
      p1 = tokenApi.peek(-1);
      n1 = tokenApi.peek(1);
      n2 = tokenApi.peek(2);
      i = n1 && n2 && n1[0] === 'STRING' && n2[0] === '+';
      token.isInterpolation = i;
      this.parenTokens.push(token);
    } else {
      this.parenTokens.pop();
    }
    return null;
  };

  return SpaceOperators;

})();


},{}]},{},[3])(3)
});
;
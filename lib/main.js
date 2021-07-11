(function() {
  'use strict';
  var CND, IDLX, IDLX_GRAMMAR, IDL_GRAMMAR, Idl_lexer, NCR, NEARLEY, PATH, badge, debug, diagram, echo, equals, formula, help, info, isa, last_of, log, rpr, tokens, type_of, urge, validate, warn, whisper,
    splice = [].splice;

  //###########################################################################################################
  PATH = require('path');

  //...........................................................................................................
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'NEARlEY';

  log = CND.get_logger('plain', badge);

  debug = CND.get_logger('debug', badge);

  info = CND.get_logger('info', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  NEARLEY = require('nearley');

  IDL_GRAMMAR = require('./idl');

  IDLX_GRAMMAR = require('./idlx');

  last_of = function(x) {
    return x[x.length - 1];
  };

  ({isa, type_of, validate, equals} = require('./types'));

  //===========================================================================================================
  // COMPATIBILITY WITH MKNCR
  //-----------------------------------------------------------------------------------------------------------
  this._NCR = NCR = Object.create(require('ncr'));

  NCR._input_default = 'xncr';

  NCR.jzr_as_uchr = function(glyph) {
    if ((this.as_csg(glyph)) === 'jzr') {
      // return @as_uchr glyph, input: 'xncr' if ( @as_csg glyph, input: 'xncr' ) is 'jzr'
      return this.as_uchr(glyph);
    }
    return glyph;
  };

  //-----------------------------------------------------------------------------------------------------------
  NCR.jzr_as_xncr = function(glyph) {
    var nfo;
    // nfo = @analyze glyph, input: 'xncr'
    nfo = this.analyze(glyph);
    if (!((nfo.rsg === 'u-pua') || (nfo.csg === 'jzr'))) {
      return glyph;
    }
    return this.as_chr(nfo.cid, {
      csg: 'jzr'
    });
  };

  //===========================================================================================================
  // LEXER
  //-----------------------------------------------------------------------------------------------------------
  Idl_lexer = function() {
    this.reset('');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  Idl_lexer.prototype.reset = function(data, state) {
    this.buffer = NCR.chrs_from_text(data, {
      input: 'xncr'
    });
    this.index = 0;
    this.line = state ? state.line : 1;
    this.prv_nl = state ? -state.col : 0;
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  Idl_lexer.prototype.next = function() {
    var chr;
    if (this.index < this.buffer.length) {
      chr = NCR.jzr_as_uchr(this.buffer[this.index]);
      this.index += +1;
      if (chr === '\n') {
        this.line += +1;
        this.prv_nl = this.index;
      }
      return {
        // return { value: chr, line: @line, col: @index - @prv_nl, }
        value: chr
      };
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  Idl_lexer.prototype.save = function() {
    return {
      line: this.line,
      col: this.index - this.prv_nl
    };
  };

  //-----------------------------------------------------------------------------------------------------------
  Idl_lexer.prototype.formatError = function(token, message) {
    var R;
    R = `${message} at index ${this.index - 1} (${this.buffer.join('')})`;
    return R;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.IDL = {};

  //-----------------------------------------------------------------------------------------------------------
  this.IDL.parse = function(source) {
    var R, type;
    if ((type = type_of(source)) !== 'text') {
      throw new Error(`expected a text, got a ${type}`);
    }
    if (source.length === 0) {
      throw new Error("expected a non-empty text, got an empty text");
    }
    /* TAINT should we rewind()? finish()? parser? */
    this._parser = new NEARLEY.Parser(IDL_GRAMMAR.ParserRules, IDL_GRAMMAR.ParserStart, {
      lexer: new Idl_lexer()
    });
    // @_parser.reset()
    this._parser.feed(source);
    if (this._parser.results.length !== 1) {
      throw new Error(`Syntax Error: ${rpr(source)}`);
    }
    R = this._parser.results[0];
    if (R.length === 1) {
      R = R[0];
    }
    return R;
  };

  // #-----------------------------------------------------------------------------------------------------------
  // @IDLX = # Object.assign Object.create @IDL

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX = {};

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.parse = function(source) {
    var R, type;
    if ((type = type_of(source)) !== 'text') {
      throw new Error(`expected a text, got a ${type}`);
    }
    if (source.length === 0) {
      throw new Error("expected a non-empty text, got an empty text");
    }
    /* TAINT should we rewind()? finish()? parser? */
    this._parser = new NEARLEY.Parser(IDLX_GRAMMAR.ParserRules, IDLX_GRAMMAR.ParserStart, {
      lexer: new Idl_lexer()
    });
    // @_parser.reset()
    this._parser.feed(source);
    if (this._parser.results.length !== 1) {
      throw new Error(`Syntax Error: ${rpr(source)}`);
    }
    R = this._parser.results[0];
    if (R.length === 1) {
      // debug '33398', ( rpr R ), R.length
      R = R[0];
    }
    return R;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  /* TAINT methods in this section should be made available for IDL as well */
  // #-----------------------------------------------------------------------------------------------------------
  // @IDLX.get_literals_and_types = => @_get_literals_and_types IDLX_GRAMMAR

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._get_literals_and_types = (grammar) => {
    var paths;
    paths = this.IDLX._paths_from_grammar(grammar);
    return this.IDLX._literals_and_types_from_paths(paths);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._literals_and_types_from_paths = (paths) => {
    /* TAINT pattern should allow literal double quotes */
    var R, _, i, len, literal, match, path, type;
    R = {};
    for (i = 0, len = paths.length; i < len; i++) {
      path = paths[i];
      if (!(match = path.match(/\+([^\/+]+)\+.*"([^"])"$/))) {
        throw new Error(`illegal path ${rpr(path)}`);
      }
      [_, type, literal] = match;
      R[literal] = type;
    }
    // ( R[ type ] ?= [] ).push literal
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._paths_from_grammar = (grammar) => {
    var paths, registry;
    registry = this.IDLX._registry_from_grammar(grammar);
    paths = new Set();
    this.IDLX._condense(registry, new Set(), paths, grammar.ParserStart);
    return Array.from(paths);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._registry_from_grammar = (grammar) => {
    var R, entry, i, j, len, len1, name, ref, rule, symbol, symbols, target;
    R = {};
    ref = grammar.ParserRules;
    for (i = 0, len = ref.length; i < len; i++) {
      rule = ref[i];
      ({name, symbols} = rule);
      for (j = 0, len1 = symbols.length; j < len1; j++) {
        symbol = symbols[j];
        if (isa.object(symbol)) {
          symbol = '"' + symbol.literal + '"';
        }
        entry = R[symbol] != null ? R[symbol] : R[symbol] = [];
        target = R[name] != null ? R[name] : R[name] = [];
        target.push(symbol);
      }
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._condense = (registry, seen, paths, name, route = []) => {
    var entry, i, is_public_name, len, path, symbol, symbols;
    if (seen.has(name)) {
      return;
    }
    seen.add(name);
    symbols = registry[name];
    is_public_name = !/\$/.test(name);
    if (is_public_name) {
      route.push(name);
    }
    for (i = 0, len = symbols.length; i < len; i++) {
      symbol = symbols[i];
      entry = registry[symbol];
      if (entry.length === 0) {
        route.push(symbol);
        if (!/(?:\/\/)|(?:\/$)/.test((path = route.join('/')))) {
          paths.add(path);
        }
        route.pop();
      } else {
        this.IDLX._condense(registry, seen, paths, symbol, route);
      }
    }
    if (is_public_name) {
      route.pop();
    }
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.type_from_literal = (literal) => {
    var ref;
    return (ref = this.IDLX.literals_and_types[literal]) != null ? ref : 'component';
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.list_tokens = (diagram_or_formula, settings) => {
    var R, diagram, type;
    switch (type = type_of(diagram_or_formula)) {
      case 'text':
        diagram = this.IDLX.parse(diagram_or_formula);
        break;
      case 'list':
        diagram = diagram_or_formula;
        break;
      default:
        throw new Error(`expected a text or a list, got a ${type} in ${rpr(diagram_or_formula)}`);
    }
    R = [];
    R.i_base = -1;
    R = this.IDLX._list_tokens(diagram, R, settings != null ? settings : {});
    delete R.i_base;
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._list_tokens = (diagram, R, settings) => {
    var element, i, is_bracketed, is_epenthetical, is_first, len, ref, token_type, type;
    /* `settings.all_brackets` is needed by `ngrams.get_relational_bigrams_as_tokens` to get brackets
     around all operators. Brackets that are added for binary operators with two arguments and unary
     operators are here called 'epenthetical'; they get no index (`token.i`) and the indices on the
     other tokens are the same as the ones for a formula without epenthetical brackets. */
    if ((ref = settings.all_brackets) != null ? ref : false) {
      is_bracketed = true;
      is_epenthetical = diagram.length <= 3;
    } else {
      //.........................................................................................................
      is_bracketed = diagram.length > 3;
      is_epenthetical = false;
    }
    //.........................................................................................................
    if (is_bracketed) {
      if (is_epenthetical) {
        R.push({
          t: 'lbracket',
          s: '(',
          i: null
        });
      } else {
        R.i_base += +1;
        R.push({
          t: 'lbracket',
          s: '(',
          i: R.i_base
        });
      }
    }
    //.........................................................................................................
    is_first = true;
    for (i = 0, len = diagram.length; i < len; i++) {
      element = diagram[i];
      switch (type = type_of(element)) {
        case 'text':
          token_type = this.IDLX.type_from_literal(element);
          // i           = if is_epenthetical
          R.i_base += +1;
          R.push({
            t: token_type,
            s: element,
            i: R.i_base
          });
          break;
        case 'list':
          if (is_first) {
            throw new Error(`expected a text as first element of diagram, got a ${type} in ${rpr(diagram)}`);
          }
          this.IDLX._list_tokens(element, R, settings);
          break;
        default:
          throw new Error(`expected a text or a list, got a ${type} in ${rpr(diagram)}`);
      }
      is_first = false;
    }
    //.........................................................................................................
    if (is_bracketed) {
      if (is_epenthetical) {
        R.push({
          t: 'rbracket',
          s: ')',
          i: null
        });
      } else {
        R.i_base += +1;
        R.push({
          t: 'rbracket',
          s: ')',
          i: R.i_base
        });
      }
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.get_formula = (diagram_or_formula) => {
    var literal;
    return ((function() {
      var i, len, ref, results;
      ref = this.IDLX.list_tokens(diagram_or_formula);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ({
          s: literal
        } = ref[i]);
        /* TAINT possible inputs should be formula, diagram, or tokenlist */
        results.push(literal);
      }
      return results;
    }).call(this)).join('');
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._text_with_jzr_glyphs_as_uchrs = (text) => {
    var glyph;
    return ((function() {
      var i, len, ref, results;
      ref = NCR.chrs_from_text(text);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        glyph = ref[i];
        results.push(NCR.jzr_as_uchr(glyph));
      }
      return results;
    })()).join('');
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._text_with_jzr_glyphs_as_xncrs = (text) => {
    var glyph;
    return ((function() {
      var i, len, ref, results;
      ref = NCR.chrs_from_text(text);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        glyph = ref[i];
        results.push(NCR.jzr_as_xncr(glyph));
      }
      return results;
    })()).join('');
  };

  //===========================================================================================================
  // TREE-SHAKING
  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.formula_may_be_nonminimal = (formula) => {
    var type;
    if ((type = type_of(formula)) !== 'text') {
      throw new Error(`expected a text, got a ${type}`);
    }
    return this.IDLX._get_treeshaker_litmus().test(formula);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.minimize_diagram = (diagram) => {
    var type;
    if ((type = type_of(diagram)) !== 'list') {
      throw new Error(`expected a list, got a ${type} in ${rpr(diagram)}`);
    }
    return this.IDLX._shake_tree(JSON.parse(JSON.stringify(diagram)));
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX.minimize_formula = (formula) => {
    var type;
    if ((type = type_of(formula)) !== 'text') {
      throw new Error(`expected a text, got a ${type} in ${rpr(formula)}`);
    }
    return this.IDLX.get_formula(this.IDLX._shake_tree(this.IDLX.parse(formula)));
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._shake_tree = (diagram) => {
    var argument_idx, operator, ref, sub_operator, sub_tree, type;
    if ((type = type_of(diagram)) !== 'list') {
      throw new Error(`expected a list, got a ${type}`);
    }
    //.........................................................................................................
    operator = diagram[0];
    // #.........................................................................................................
    // unless ( type = operator_token.t ) is 'operator'
    //   throw new Error "expected an operator, got a #{type}"
    //.........................................................................................................
    argument_idx = 0;
    while (true) {
      //.........................................................................................................
      argument_idx += +1;
      if (argument_idx > diagram.length - 1) {
        break;
      }
      sub_tree = diagram[argument_idx];
      if ((type_of(sub_tree)) !== 'list') {
        continue;
      }
      sub_operator = sub_tree[0];
      //.......................................................................................................
      // unless ( type = type_of sub_operator_token ) is 'MOJIKURA-IDL/token'
      //   throw new Error "expected a MOJIKURA-IDL/token, got a #{type}"
      // #.......................................................................................................
      // unless ( type = sub_operator_token.t ) is 'operator'
      //   throw new Error "expected an operator, got a #{type}"
      //.......................................................................................................
      if (operator === sub_operator) {
        splice.apply(diagram, [argument_idx, argument_idx - argument_idx + 1].concat(ref = sub_tree.slice(1))), ref;
        argument_idx += -1;
      } else {
        this.IDLX._shake_tree(sub_tree);
      }
    }
    return diagram;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.IDLX._get_treeshaker_litmus = () => {
    var R, binary_operators, i, j, len, len1, operator, pattern, ref, sub_operator, sub_pattern, symbol, token_type;
    if ((R = this.IDLX._get_treeshaker_litmus.pattern) != null) {
      /* When `@IDLX._get_treeshaker_litmus.pattern` matches a formula, it *may* be non-minimal; if the pattern
       does *not* match a formula, there are certainly no opportunities for optimization. The pattern works by
       trying to match sequences like `/...|(?:O[^MNPQ]*O)|(?:P[^MNOQ]*P)|.../`, where `MNOPQ` are the binary
       operators. */
      return R;
    }
    //.........................................................................................................
    binary_operators = [];
    ref = this.IDLX.literals_and_types;
    for (symbol in ref) {
      token_type = ref[symbol];
      if (token_type === 'binary_operator') {
        binary_operators.push(symbol);
      }
    }
    // binary_operators = binary_operators[ .. 3 ]
    // debug '52998', binary_operators
    pattern = [];
    for (i = 0, len = binary_operators.length; i < len; i++) {
      operator = binary_operators[i];
      sub_pattern = [];
      sub_pattern.push('[^');
      for (j = 0, len1 = binary_operators.length; j < len1; j++) {
        sub_operator = binary_operators[j];
        if (sub_operator === operator) {
          continue;
        }
        sub_pattern.push(sub_operator);
      }
      sub_pattern.push(']*');
      pattern.push('(?:' + operator + (sub_pattern.join('')) + operator + ')');
    }
    //.........................................................................................................
    return this.IDLX._get_treeshaker_litmus.pattern = new RegExp(pattern.join('|'));
  };

  //###########################################################################################################
  this.IDLX._get_treeshaker_litmus.pattern = null;

  this.IDLX.literals_and_types = this.IDLX._get_literals_and_types(IDLX_GRAMMAR);

  //===========================================================================================================
  // SILHOUTTES, NGRAMS
  //-----------------------------------------------------------------------------------------------------------
  IDLX = this.IDLX;

  (function() {
    var i, len, module_name, name, ref, results, value;
    ref = ['./silhouettes', './ngrams'];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      module_name = ref[i];
      results.push((function() {
        var ref1, results1;
        ref1 = require(module_name);
        results1 = [];
        for (name in ref1) {
          value = ref1[name];
          results1.push(IDLX[name] = value);
        }
        return results1;
      })());
    }
    return results;
  })();

  //###########################################################################################################
  if (module.parent == null) {
    //.........................................................................................................
    info(this.IDLX._get_literals_and_types(IDLX_GRAMMAR));
    info(this.IDLX.type_from_literal(IDLX_GRAMMAR));
    help('↻', this.IDLX.type_from_literal('↻')); // 'operator',
    help('〓', this.IDLX.type_from_literal('〓')); // 'proxy',
    help('§', this.IDLX.type_from_literal('§')); // 'proxy',
    help('⿰', this.IDLX.type_from_literal('⿰')); // 'operator',
    help('⿻', this.IDLX.type_from_literal('⿻')); // 'operator',
    help('◰', this.IDLX.type_from_literal('◰')); // 'operator',
    help('(', this.IDLX.type_from_literal('(')); // 'bracket',
    help('x', this.IDLX.type_from_literal('x')); // 'other',
    formula = '⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))';
    whisper(formula);
    help(diagram = this.IDLX.parse(formula));
    whisper(formula);
    help(tokens = this.IDLX.list_tokens(diagram));
    urge(this.IDLX.get_formula(formula));
    urge(this.IDLX.get_formula(diagram));
    urge(this.IDLX._get_treeshaker_litmus());
    urge(CND.yellow(formula), CND.blue(CND.truth(this.IDLX.formula_may_be_nonminimal(formula))));
    urge(CND.yellow('⿱⿱𫝀口㐄'), CND.blue(CND.truth(this.IDLX.formula_may_be_nonminimal('⿱⿱𫝀口㐄'))));
    urge(CND.yellow('⿱𫝀⿱口㐄'), CND.blue(CND.truth(this.IDLX.formula_may_be_nonminimal('⿱𫝀⿱口㐄'))));
    urge(CND.yellow('⿰韋(⿱白大十)'), CND.blue(CND.truth(this.IDLX.formula_may_be_nonminimal('⿰韋(⿱白大十)'))));
    info(CND.yellow(formula), CND.blue(this.IDLX.minimize_formula(formula)));
    info(CND.yellow('⿱⿱𫝀口㐄'), CND.blue(this.IDLX.minimize_formula('⿱⿱𫝀口㐄')));
    info(CND.yellow('⿱𫝀⿱口㐄'), CND.blue(this.IDLX.minimize_formula('⿱𫝀⿱口㐄')));
    info(CND.yellow('⿰韋(⿱白大十)'), CND.blue(this.IDLX.minimize_formula('⿰韋(⿱白大十)')));
    process.exit(1);
  }

}).call(this);

//# sourceMappingURL=main.js.map
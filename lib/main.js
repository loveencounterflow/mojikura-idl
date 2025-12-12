(function() {
  'use strict';
  var CND, IDLX, IDLX_GRAMMAR, IDL_GRAMMAR, Idl_lexer, NCR, NEARLEY, NGRAMS, PATH, SILHOUETTES, badge, debug, diagram, echo, equals, formula, help, info, isa, last_of, log, rpr, tokens, type_of, urge, validate, warn, whisper,
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
  this._NCR = NCR = Object.create(require('ncr-norangereader'));

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
  /* NOTE: do not use parametric `require()` as this may throw off browserify (and rightly so) */
  IDLX = this.IDLX;

  SILHOUETTES = require('./silhouettes');

  NGRAMS = require('./ngrams');

  (function() {
    var name, value;
    for (name in SILHOUETTES) {
      value = SILHOUETTES[name];
      IDLX[name] = value;
    }
    for (name in NGRAMS) {
      value = NGRAMS[name];
      IDLX[name] = value;
    }
    return null;
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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vc3JjL21haW4uY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUVBO0VBQUE7QUFBQSxNQUFBLEdBQUEsRUFBQSxJQUFBLEVBQUEsWUFBQSxFQUFBLFdBQUEsRUFBQSxTQUFBLEVBQUEsR0FBQSxFQUFBLE9BQUEsRUFBQSxNQUFBLEVBQUEsSUFBQSxFQUFBLFdBQUEsRUFBQSxLQUFBLEVBQUEsS0FBQSxFQUFBLE9BQUEsRUFBQSxJQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBLEdBQUEsRUFBQSxPQUFBLEVBQUEsR0FBQSxFQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsT0FBQSxFQUFBLElBQUEsRUFBQSxRQUFBLEVBQUEsSUFBQSxFQUFBLE9BQUE7SUFBQSxrQkFBQTs7O0VBSUEsSUFBQSxHQUE0QixPQUFBLENBQVEsTUFBUixFQUo1Qjs7O0VBTUEsR0FBQSxHQUE0QixPQUFBLENBQVEsS0FBUjs7RUFDNUIsR0FBQSxHQUE0QixHQUFHLENBQUM7O0VBQ2hDLEtBQUEsR0FBNEI7O0VBQzVCLEdBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxPQUFmLEVBQTRCLEtBQTVCOztFQUM1QixLQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsT0FBZixFQUE0QixLQUE1Qjs7RUFDNUIsSUFBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLE1BQWYsRUFBNEIsS0FBNUI7O0VBQzVCLElBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxNQUFmLEVBQTRCLEtBQTVCOztFQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1Qjs7RUFDNUIsSUFBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLE1BQWYsRUFBNEIsS0FBNUI7O0VBQzVCLE9BQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxTQUFmLEVBQTRCLEtB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QUcsQ0FBQyxNQUFKLENBQVcsT0FBWCxDQUFQLEVBQWtDLEdBQUcsQ0FBQyxJQUFKLENBQVMsSUFBQyxDQUFBLElBQUksQ0FBQyxnQkFBTixDQUF1QixPQUF2QixDQUFULENBQWxDO0lBQ0EsSUFBQSxDQUFPLEdBQUcsQ0FBQyxNQUFKLENBQVcsUUFBWCxDQUFQLEVBQW1DLEdBQUcsQ0FBQyxJQUFKLENBQVMsSUFBQyxDQUFBLElBQUksQ0FBQyxnQkFBTixDQUF1QixRQUF2QixDQUFULENBQW5DO0lBQ0EsSUFBQSxDQUFPLEdBQUcsQ0FBQyxNQUFKLENBQVcsUUFBWCxDQUFQLEVBQW1DLEdBQUcsQ0FBQyxJQUFKLENBQVMsSUFBQyxDQUFBLElBQUksQ0FBQyxnQkFBTixDQUF1QixRQUF2QixDQUFULENBQW5DO0lBQ0EsSUFBQSxDQUFPLEdBQUcsQ0FBQyxNQUFKLENBQVcsVUFBWCxDQUFQLEVBQWtDLEdBQUcsQ0FBQyxJQUFKLENBQVMsSUFBQyxDQUFBLElBQUksQ0FBQyxnQkFBTixDQUF1QixVQUF2QixDQUFULENBQWxDO0lBQ0EsT0FBTyxDQUFDLElBQVIsQ0FBYSxDQUFiLEVBNUJKOztBQXRXQSIsInNvdXJjZXNDb250ZW50IjpbIlxuXG4ndXNlIHN0cmljdCdcblxuXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblBBVEggICAgICAgICAgICAgICAgICAgICAgPSByZXF1aXJlICdwYXRoJ1xuIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uXG5DTkQgICAgICAgICAgICAgICAgICAgICAgID0gcmVxdWlyZSAnY25kJ1xucnByICAgICAgICAgICAgICAgICAgICAgICA9IENORC5ycHJcbmJhZGdlICAgICAgICAgICAgICAgICAgICAgPSAnTkVBUmxFWSdcbmxvZyAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAncGxhaW4nLCAgICAgYmFkZ2VcbmRlYnVnICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnZGVidWcnLCAgICAgYmFkZ2VcbmluZm8gICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnaW5mbycsICAgICAgYmFkZ2Vcbndhcm4gICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnd2FybicsICAgICAgYmFkZ2VcbmhlbHAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnaGVscCcsICAgICAgYmFkZ2VcbnVyZ2UgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAndXJnZScsICAgICAgYmFkZ2VcbndoaXNwZXIgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnd2hpc3BlcicsICAgYmFkZ2VcbmVjaG8gICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZWNoby5iaW5kIENORFxuTkVBUkxFWSAgICAgICAgICAgICAgICAgICA9IHJlcXVpcmUgJ25lYXJsZXknXG5JRExfR1JBTU1BUiAgICAgICAgICAgICAgID0gcmVxdWlyZSAnLi9pZGwnXG5JRExYX0dSQU1NQVIgICAgICAgICAgICAgID0gcmVxdWlyZSAnLi9pZGx4J1xubGFzdF9vZiAgICAgICAgICAgICAgICAgICA9ICggeCApIC0+IHhbIHgubGVuZ3RoIC0gMSBdXG57IGlzYVxuICB0eXBlX29mXG4gIHZhbGlkYXRlXG4gIGVxdWFscyAgIH0gICAgICAgICAgICAgID0gcmVxdWlyZSAnLi90eXBlcydcblxuXG4jPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cbiMgQ09NUEFUSUJJTElUWSBXSVRIIE1LTkNSXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBfTkNSID0gTkNSID0gT2JqZWN0LmNyZWF0ZSByZXF1aXJlICduY3Itbm9yYW5nZXJlYWRlcidcbk5DUi5faW5wdXRfZGVmYXVsdCA9ICd4bmNyJ1xuTkNSLmp6cl9hc191Y2hyID0gKCBnbHlwaCApIC0+XG4gICMgcmV0dXJuIEBhc191Y2hyIGdseXBoLCBpbnB1dDogJ3huY3InIGlmICggQGFzX2NzZyBnbHlwaCwgaW5wdXQ6ICd4bmNyJyApIGlzICdqenInXG4gIHJldHVybiBAYXNfdWNociBnbHlwaCBpZiAoIEBhc19jc2cgZ2x5cGggKSBpcyAnanpyJ1xuICByZXR1cm4gZ2x5cGhcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5OQ1IuanpyX2FzX3huY3IgPSAoIGdseXBoICkgLT5cbiAgIyBuZm8gPSBAYW5hbHl6ZSBnbHlwaCwgaW5wdXQ6ICd4bmNyJ1xuICBuZm8gPSBAYW5hbHl6ZSBnbHlwaFxuICByZXR1cm4gZ2x5cGggdW5sZXNzICggbmZvLnJzZyBpcyAndS1wdWEnICkgb3IgKCBuZm8uY3NnIGlzICdqenInIClcbiAgcmV0dXJuIEBhc19jaHIgbmZvLmNpZCwgeyBjc2c6ICdqenInLCB9XG5cblxuIz09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG4jIExFWEVSXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbklkbF9sZXhlciA9IC0+XG4gIEByZXNldCAnJ1xuICByZXR1cm4gbnVsbFxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbklkbF9sZXhlcjo6cmVzZXQgPSAoIGRhdGEsIHN0YXRlICkgLT5cbiAgQGJ1ZmZlciA9IE5DUi5jaHJzX2Zyb21fdGV4dCBkYXRhLCBpbnB1dDogJ3huY3InXG4gIEBpbmRleCAgPSAwXG4gIEBsaW5lICAgPSBpZiBzdGF0ZSB0aGVuIHN0YXRlLmxpbmUgZWxzZSAxXG4gIEBwcnZfbmwgPSBpZiBzdGF0ZSB0aGVuIC1zdGF0ZS5jb2wgZWxzZSAwXG4gIHJldHVybiBudWxsXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuSWRsX2xleGVyOjpuZXh0ID0gLT5cbiAgaWYgQGluZGV4IDwgQGJ1ZmZlci5sZW5ndGhcbiAgICBjaHIgICAgID0gTkNSLmp6cl9hc191Y2hyIEBidWZmZXJbIEBpbmRleCBdXG4gICAgQGluZGV4ICs9ICsxXG4gICAgaWYgY2hyIGlzICdcXG4nXG4gICAgICBAbGluZSAgKz0gKzFcbiAgICAgIEBwcnZfbmwgPSBAaW5kZXhcbiAgICAjIHJldHVybiB7IHZhbHVlOiBjaHIsIGxpbmU6IEBsaW5lLCBjb2w6IEBpbmRleCAtIEBwcnZfbmwsIH1cbiAgICByZXR1cm4geyB2YWx1ZTogY2hyLCB9XG4gIHJldHVybiBudWxsXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuSWRsX2xleGVyOjpzYXZlID0gLT5cbiAgcmV0dXJuIHsgbGluZTogQGxpbmUsIGNvbDogQGluZGV4IC0gQHBydl9ubCwgfVxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbklkbF9sZXhlcjo6Zm9ybWF0RXJyb3IgPSAoIHRva2VuLCBtZXNzYWdlICkgLT5cbiAgUiA9IFwiI3ttZXNzYWdlfSBhdCBpbmRleCAje0BpbmRleCAtIDF9ICgje0BidWZmZXIuam9pbiAnJ30pXCJcbiAgcmV0dXJuIFJcblxuXG4jPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cbiNcbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETCA9IHt9XG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETC5wYXJzZSA9ICggc291cmNlICkgLT5cbiAgdGhyb3cgbmV3IEVycm9yIFwiZXhwZWN0ZWQgYSB0ZXh0LCBnb3QgYSAje3R5cGV9XCIgdW5sZXNzICggdHlwZSA9IHR5cGVfb2Ygc291cmNlICkgaXMgJ3RleHQnXG4gIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGEgbm9uLWVtcHR5IHRleHQsIGdvdCBhbiBlbXB0eSB0ZXh0XCIgaWYgc291cmNlLmxlbmd0aCBpcyAwXG4gICMjIyBUQUlOVCBzaG91bGQgd2UgcmV3aW5kKCk/IGZpbmlzaCgpPyBwYXJzZXI/ICMjI1xuICBAX3BhcnNlciA9IG5ldyBORUFSTEVZLlBhcnNlciBJRExfR1JBTU1BUi5QYXJzZXJSdWxlcywgSURMX0dSQU1NQVIuUGFyc2VyU3RhcnQsIHsgbGV4ZXI6IG5ldyBJZGxfbGV4ZXIoKSwgfVxuICAjIEBfcGFyc2VyLnJlc2V0KClcbiAgQF9wYXJzZXIuZmVlZCBzb3VyY2VcbiAgdGhyb3cgbmV3IEVycm9yIFwiU3ludGF4IEVycm9yOiAje3JwciBzb3VyY2V9XCIgdW5sZXNzIEBfcGFyc2VyLnJlc3VsdHMubGVuZ3RoIGlzIDFcbiAgUiA9IEBfcGFyc2VyLnJlc3VsdHNbIDAgXVxuICBSID0gUlsgMCBdIGlmIFIubGVuZ3RoIGlzIDFcbiAgcmV0dXJuIFJcblxuIyAjLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbiMgQElETFggPSAjIE9iamVjdC5hc3NpZ24gT2JqZWN0LmNyZWF0ZSBASURMXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFggPSB7fVxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBJRExYLnBhcnNlID0gKCBzb3VyY2UgKSAtPlxuICB0aHJvdyBuZXcgRXJyb3IgXCJleHBlY3RlZCBhIHRleHQsIGdvdCBhICN7dHlwZX1cIiB1bmxlc3MgKCB0eXBlID0gdHlwZV9vZiBzb3VyY2UgKSBpcyAndGV4dCdcbiAgdGhyb3cgbmV3IEVycm9yIFwiZXhwZWN0ZWQgYSBub24tZW1wdHkgdGV4dCwgZ290IGFuIGVtcHR5IHRleHRcIiBpZiBzb3VyY2UubGVuZ3RoIGlzIDBcbiAgIyMjIFRBSU5UIHNob3VsZCB3ZSByZXdpbmQoKT8gZmluaXNoKCk/IHBhcnNlcj8gIyMjXG4gIEBfcGFyc2VyID0gbmV3IE5FQVJMRVkuUGFyc2VyIElETFhfR1JBTU1BUi5QYXJzZXJSdWxlcywgSURMWF9HUkFNTUFSLlBhcnNlclN0YXJ0LCB7IGxleGVyOiBuZXcgSWRsX2xleGVyKCksIH1cbiAgIyBAX3BhcnNlci5yZXNldCgpXG4gIEBfcGFyc2VyLmZlZWQgc291cmNlXG4gIHRocm93IG5ldyBFcnJvciBcIlN5bnRheCBFcnJvcjogI3tycHIgc291cmNlfVwiIHVubGVzcyBAX3BhcnNlci5yZXN1bHRzLmxlbmd0aCBpcyAxXG4gIFIgPSBAX3BhcnNlci5yZXN1bHRzWyAwIF1cbiAgIyBkZWJ1ZyAnMzMzOTgnLCAoIHJwciBSICksIFIubGVuZ3RoXG4gIFIgPSBSWyAwIF0gaWYgUi5sZW5ndGggaXMgMVxuICByZXR1cm4gUlxuXG5cbiM9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuI1xuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG4jIyMgVEFJTlQgbWV0aG9kcyBpbiB0aGlzIHNlY3Rpb24gc2hvdWxkIGJlIG1hZGUgYXZhaWxhYmxlIGZvciBJREwgYXMgd2VsbCAjIyNcblxuIyAjLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbiMgQElETFguZ2V0X2xpdGVyYWxzX2FuZF90eXBlcyA9ID0+IEBfZ2V0X2xpdGVyYWxzX2FuZF90eXBlcyBJRExYX0dSQU1NQVJcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5fZ2V0X2xpdGVyYWxzX2FuZF90eXBlcyA9ICggZ3JhbW1hciApID0+XG4gIHBhdGhzID0gQElETFguX3BhdGhzX2Zyb21fZ3JhbW1hciBncmFtbWFyXG4gIHJldHVybiBASURMWC5fbGl0ZXJhbHNfYW5kX3R5cGVzX2Zyb21fcGF0aHMgcGF0aHNcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5fbGl0ZXJhbHNfYW5kX3R5cGVzX2Zyb21fcGF0aHMgPSAoIHBhdGhzICkgPT5cbiAgUiA9IHt9XG4gIGZvciBwYXRoIGluIHBhdGhzXG4gICAgIyMjIFRBSU5UIHBhdHRlcm4gc2hvdWxkIGFsbG93IGxpdGVyYWwgZG91YmxlIHF1b3RlcyAjIyNcbiAgICB1bmxlc3MgKCBtYXRjaCA9IHBhdGgubWF0Y2ggLy8vIFxcKyAoIFteIFxcLyArIF0rICkgXFwrIC4qIFwiICggW14gXCJdICkgXCIgICQgLy8vIClcbiAgICAgIHRocm93IG5ldyBFcnJvciBcImlsbGVnYWwgcGF0aCAje3JwciBwYXRofVwiXG4gICAgWyBfXG4gICAgICB0eXBlXG4gICAgICBsaXRlcmFsIF0gICA9IG1hdGNoXG4gICAgUlsgbGl0ZXJhbCBdICA9IHR5cGVcbiAgICAjICggUlsgdHlwZSBdID89IFtdICkucHVzaCBsaXRlcmFsXG4gIHJldHVybiBSXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFguX3BhdGhzX2Zyb21fZ3JhbW1hciA9ICggZ3JhbW1hciApID0+XG4gIHJlZ2lzdHJ5ICA9IEBJRExYLl9yZWdpc3RyeV9mcm9tX2dyYW1tYXIgZ3JhbW1hclxuICBwYXRocyAgICAgPSBuZXcgU2V0KClcbiAgQElETFguX2NvbmRlbnNlIHJlZ2lzdHJ5LCAoIG5ldyBTZXQoKSApLCBwYXRocywgZ3JhbW1hci5QYXJzZXJTdGFydFxuICByZXR1cm4gQXJyYXkuZnJvbSBwYXRoc1xuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBJRExYLl9yZWdpc3RyeV9mcm9tX2dyYW1tYXIgPSAoIGdyYW1tYXIgKSA9PlxuICBSID0ge31cbiAgZm9yIHJ1bGUgaW4gZ3JhbW1hci5QYXJzZXJSdWxlc1xuICAgIHsgbmFtZSwgc3ltYm9scywgfSA9IHJ1bGVcbiAgICBmb3Igc3ltYm9sIGluIHN5bWJvbHNcbiAgICAgIGlmIGlzYS5vYmplY3Qgc3ltYm9sXG4gICAgICAgIHN5bWJvbCA9ICdcIicgKyBzeW1ib2wubGl0ZXJhbCArICdcIidcbiAgICAgIGVudHJ5ICAgPSBSWyBzeW1ib2wgXSA/PSBbXVxuICAgICAgdGFyZ2V0ICA9IFJbIG5hbWUgICBdID89IFtdXG4gICAgICB0YXJnZXQucHVzaCBzeW1ib2xcbiAgcmV0dXJuIFJcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5fY29uZGVuc2UgPSAoIHJlZ2lzdHJ5LCBzZWVuLCBwYXRocywgbmFtZSwgcm91dGUgPSBbXSApID0+XG4gIHJldHVybiBpZiBzZWVuLmhhcyBuYW1lXG4gIHNlZW4uIGFkZCBuYW1lXG4gIHN5bWJvbHMgICAgICAgICA9IHJlZ2lzdHJ5WyBuYW1lIF1cbiAgaXNfcHVibGljX25hbWUgID0gbm90IC9cXCQvLnRlc3QgbmFtZVxuICByb3V0ZS5wdXNoIG5hbWUgaWYgaXNfcHVibGljX25hbWVcbiAgZm9yIHN5bWJvbCBpbiBzeW1ib2xzXG4gICAgZW50cnkgPSByZWdpc3RyeVsgc3ltYm9sIF1cbiAgICBpZiAoIGVudHJ5Lmxlbmd0aCBpcyAwIClcbiAgICAgIHJvdXRlLnB1c2ggc3ltYm9sXG4gICAgICBwYXRocy5hZGQgcGF0aCB1bmxlc3MgLy8vICg/OiBcXC9cXC8gKSB8ICg/OiBcXC8gJCApIC8vLy50ZXN0ICggcGF0aCA9IHJvdXRlLmpvaW4gJy8nIClcbiAgICAgIHJvdXRlLnBvcCgpXG4gICAgZWxzZVxuICAgICAgQElETFguX2NvbmRlbnNlIHJlZ2lzdHJ5LCBzZWVuLCBwYXRocywgc3ltYm9sLCByb3V0ZVxuICByb3V0ZS5wb3AoKSBpZiBpc19wdWJsaWNfbmFtZVxuICByZXR1cm4gbnVsbFxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBJRExYLnR5cGVfZnJvbV9saXRlcmFsID0gKCBsaXRlcmFsICkgPT4gQElETFgubGl0ZXJhbHNfYW5kX3R5cGVzWyBsaXRlcmFsIF0gPyAnY29tcG9uZW50J1xuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBJRExYLmxpc3RfdG9rZW5zID0gKCBkaWFncmFtX29yX2Zvcm11bGEsIHNldHRpbmdzICkgPT5cbiAgc3dpdGNoIHR5cGUgPSB0eXBlX29mIGRpYWdyYW1fb3JfZm9ybXVsYVxuICAgIHdoZW4gJ3RleHQnIHRoZW4gZGlhZ3JhbSA9IEBJRExYLnBhcnNlICBkaWFncmFtX29yX2Zvcm11bGFcbiAgICB3aGVuICdsaXN0JyB0aGVuIGRpYWdyYW0gPSAgICAgICAgICAgICAgZGlhZ3JhbV9vcl9mb3JtdWxhXG4gICAgZWxzZSB0aHJvdyBuZXcgRXJyb3IgXCJleHBlY3RlZCBhIHRleHQgb3IgYSBsaXN0LCBnb3QgYSAje3R5cGV9IGluICN7cnByIGRpYWdyYW1fb3JfZm9ybXVsYX1cIlxuICBSICAgICAgICAgPSBbXVxuICBSLmlfYmFzZSAgPSAtMVxuICBSICAgICAgICAgPSBASURMWC5fbGlzdF90b2tlbnMgZGlhZ3JhbSwgUiwgc2V0dGluZ3MgPyB7fVxuICBkZWxldGUgUi5pX2Jhc2VcbiAgcmV0dXJuIFJcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5fbGlzdF90b2tlbnMgPSAoIGRpYWdyYW0sIFIsIHNldHRpbmdzICkgPT5cbiAgIyMjIGBzZXR0aW5ncy5hbGxfYnJhY2tldHNgIGlzIG5lZWRlZCBieSBgbmdyYW1zLmdldF9yZWxhdGlvbmFsX2JpZ3JhbXNfYXNfdG9rZW5zYCB0byBnZXQgYnJhY2tldHNcbiAgYXJvdW5kIGFsbCBvcGVyYXRvcnMuIEJyYWNrZXRzIHRoYXQgYXJlIGFkZGVkIGZvciBiaW5hcnkgb3BlcmF0b3JzIHdpdGggdHdvIGFyZ3VtZW50cyBhbmQgdW5hcnlcbiAgb3BlcmF0b3JzIGFyZSBoZXJlIGNhbGxlZCAnZXBlbnRoZXRpY2FsJzsgdGhleSBnZXQgbm8gaW5kZXggKGB0b2tlbi5pYCkgYW5kIHRoZSBpbmRpY2VzIG9uIHRoZVxuICBvdGhlciB0b2tlbnMgYXJlIHRoZSBzYW1lIGFzIHRoZSBvbmVzIGZvciBhIGZvcm11bGEgd2l0aG91dCBlcGVudGhldGljYWwgYnJhY2tldHMuICMjI1xuICBpZiBzZXR0aW5ncy5hbGxfYnJhY2tldHMgPyBub1xuICAgIGlzX2JyYWNrZXRlZCAgICA9IHllc1xuICAgIGlzX2VwZW50aGV0aWNhbCA9ICggZGlhZ3JhbS5sZW5ndGggPD0gMyApXG4gICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgZWxzZVxuICAgIGlzX2JyYWNrZXRlZCAgICA9ICggZGlhZ3JhbS5sZW5ndGggPiAzIClcbiAgICBpc19lcGVudGhldGljYWwgPSBub1xuICAjLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uXG4gIGlmIGlzX2JyYWNrZXRlZFxuICAgIGlmIGlzX2VwZW50aGV0aWNhbFxuICAgICAgUi5wdXNoIHsgdDogJ2xicmFja2V0JywgczogJygnLCBpOiBudWxsLCB9XG4gICAgZWxzZVxuICAgICAgUi5pX2Jhc2UgKz0gKzFcbiAgICAgIFIucHVzaCB7IHQ6ICdsYnJhY2tldCcsIHM6ICcoJywgaTogUi5pX2Jhc2UsIH1cbiAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICBpc19maXJzdCA9IHllc1xuICBmb3IgZWxlbWVudCBpbiBkaWFncmFtXG4gICAgc3dpdGNoIHR5cGUgPSB0eXBlX29mIGVsZW1lbnRcbiAgICAgIHdoZW4gJ3RleHQnXG4gICAgICAgIHRva2VuX3R5cGUgID0gQElETFgudHlwZV9mcm9tX2xpdGVyYWwgZWxlbWVudFxuICAgICAgICAjIGkgICAgICAgICAgID0gaWYgaXNfZXBlbnRoZXRpY2FsXG4gICAgICAgIFIuaV9iYXNlICs9ICsxXG4gICAgICAgIFIucHVzaCB7IHQ6IHRva2VuX3R5cGUsIHM6IGVsZW1lbnQsIGk6IFIuaV9iYXNlLCB9XG4gICAgICB3aGVuICdsaXN0J1xuICAgICAgICBpZiBpc19maXJzdFxuICAgICAgICAgIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGEgdGV4dCBhcyBmaXJzdCBlbGVtZW50IG9mIGRpYWdyYW0sIGdvdCBhICN7dHlwZX0gaW4gI3tycHIgZGlhZ3JhbX1cIlxuICAgICAgICBASURMWC5fbGlzdF90b2tlbnMgZWxlbWVudCwgUiwgc2V0dGluZ3NcbiAgICAgIGVsc2VcbiAgICAgICAgdGhyb3cgbmV3IEVycm9yIFwiZXhwZWN0ZWQgYSB0ZXh0IG9yIGEgbGlzdCwgZ290IGEgI3t0eXBlfSBpbiAje3JwciBkaWFncmFtfVwiXG4gICAgaXNfZmlyc3QgPSBub1xuICAjLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uXG4gIGlmIGlzX2JyYWNrZXRlZFxuICAgIGlmIGlzX2VwZW50aGV0aWNhbFxuICAgICAgUi5wdXNoIHsgdDogJ3JicmFja2V0JywgczogJyknLCBpOiBudWxsLCB9XG4gICAgZWxzZVxuICAgICAgUi5pX2Jhc2UgKz0gKzFcbiAgICAgIFIucHVzaCB7IHQ6ICdyYnJhY2tldCcsIHM6ICcpJywgaTogUi5pX2Jhc2UsIH1cbiAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICByZXR1cm4gUlxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBJRExYLmdldF9mb3JtdWxhID0gKCBkaWFncmFtX29yX2Zvcm11bGEgKSA9PlxuICAjIyMgVEFJTlQgcG9zc2libGUgaW5wdXRzIHNob3VsZCBiZSBmb3JtdWxhLCBkaWFncmFtLCBvciB0b2tlbmxpc3QgIyMjXG4gIHJldHVybiAoIGxpdGVyYWwgZm9yIHsgczogbGl0ZXJhbCwgfSBpbiBASURMWC5saXN0X3Rva2VucyBkaWFncmFtX29yX2Zvcm11bGEgKS5qb2luICcnXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFguX3RleHRfd2l0aF9qenJfZ2x5cGhzX2FzX3VjaHJzID0gKCB0ZXh0ICkgPT5cbiAgcmV0dXJuICggTkNSLmp6cl9hc191Y2hyIGdseXBoIGZvciBnbHlwaCBpbiBOQ1IuY2hyc19mcm9tX3RleHQgdGV4dCApLmpvaW4gJydcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5fdGV4dF93aXRoX2p6cl9nbHlwaHNfYXNfeG5jcnMgPSAoIHRleHQgKSA9PlxuICByZXR1cm4gKCBOQ1IuanpyX2FzX3huY3IgZ2x5cGggZm9yIGdseXBoIGluIE5DUi5jaHJzX2Zyb21fdGV4dCB0ZXh0ICkuam9pbiAnJ1xuXG5cbiM9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuIyBUUkVFLVNIQUtJTkdcbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFguZm9ybXVsYV9tYXlfYmVfbm9ubWluaW1hbCA9ICggZm9ybXVsYSApID0+XG4gIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGEgdGV4dCwgZ290IGEgI3t0eXBlfVwiIHVubGVzcyAoIHR5cGUgPSB0eXBlX29mIGZvcm11bGEgKSBpcyAndGV4dCdcbiAgcmV0dXJuIEBJRExYLl9nZXRfdHJlZXNoYWtlcl9saXRtdXMoKS50ZXN0IGZvcm11bGFcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5taW5pbWl6ZV9kaWFncmFtID0gKCBkaWFncmFtICkgPT5cbiAgdW5sZXNzICggdHlwZSA9IHR5cGVfb2YgZGlhZ3JhbSApIGlzICdsaXN0J1xuICAgIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGEgbGlzdCwgZ290IGEgI3t0eXBlfSBpbiAje3JwciBkaWFncmFtfVwiXG4gIHJldHVybiBASURMWC5fc2hha2VfdHJlZSBKU09OLnBhcnNlIEpTT04uc3RyaW5naWZ5IGRpYWdyYW1cblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5ASURMWC5taW5pbWl6ZV9mb3JtdWxhID0gKCBmb3JtdWxhICkgPT5cbiAgdW5sZXNzICggdHlwZSA9IHR5cGVfb2YgZm9ybXVsYSApIGlzICd0ZXh0J1xuICAgIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGEgdGV4dCwgZ290IGEgI3t0eXBlfSBpbiAje3JwciBmb3JtdWxhfVwiXG4gIHJldHVybiBASURMWC5nZXRfZm9ybXVsYSBASURMWC5fc2hha2VfdHJlZSBASURMWC5wYXJzZSBmb3JtdWxhXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFguX3NoYWtlX3RyZWUgPSAoIGRpYWdyYW0gKSA9PlxuICB1bmxlc3MgKCB0eXBlID0gdHlwZV9vZiBkaWFncmFtICkgaXMgJ2xpc3QnXG4gICAgdGhyb3cgbmV3IEVycm9yIFwiZXhwZWN0ZWQgYSBsaXN0LCBnb3QgYSAje3R5cGV9XCJcbiAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICBvcGVyYXRvciA9IGRpYWdyYW1bIDAgXVxuICAjICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgIyB1bmxlc3MgKCB0eXBlID0gb3BlcmF0b3JfdG9rZW4udCApIGlzICdvcGVyYXRvcidcbiAgIyAgIHRocm93IG5ldyBFcnJvciBcImV4cGVjdGVkIGFuIG9wZXJhdG9yLCBnb3QgYSAje3R5cGV9XCJcbiAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICBhcmd1bWVudF9pZHggPSAwXG4gICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgbG9vcFxuICAgIGFyZ3VtZW50X2lkeCArPSArMVxuICAgIGJyZWFrIGlmIGFyZ3VtZW50X2lkeCA+IGRpYWdyYW0ubGVuZ3RoIC0gMVxuICAgIHN1Yl90cmVlICAgICAgPSBkaWFncmFtWyBhcmd1bWVudF9pZHggXVxuICAgIGNvbnRpbnVlIHVubGVzcyAoIHR5cGVfb2Ygc3ViX3RyZWUgKSBpcyAnbGlzdCdcbiAgICBzdWJfb3BlcmF0b3IgID0gc3ViX3RyZWVbIDAgXVxuICAgICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uXG4gICAgIyB1bmxlc3MgKCB0eXBlID0gdHlwZV9vZiBzdWJfb3BlcmF0b3JfdG9rZW4gKSBpcyAnTU9KSUtVUkEtSURML3Rva2VuJ1xuICAgICMgICB0aHJvdyBuZXcgRXJyb3IgXCJleHBlY3RlZCBhIE1PSklLVVJBLUlETC90b2tlbiwgZ290IGEgI3t0eXBlfVwiXG4gICAgIyAjLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICAgICMgdW5sZXNzICggdHlwZSA9IHN1Yl9vcGVyYXRvcl90b2tlbi50ICkgaXMgJ29wZXJhdG9yJ1xuICAgICMgICB0aHJvdyBuZXcgRXJyb3IgXCJleHBlY3RlZCBhbiBvcGVyYXRvciwgZ290IGEgI3t0eXBlfVwiXG4gICAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgICBpZiBvcGVyYXRvciBpcyBzdWJfb3BlcmF0b3JcbiAgICAgIGRpYWdyYW1bIGFyZ3VtZW50X2lkeCAuLiBhcmd1bWVudF9pZHggXSA9IHN1Yl90cmVlWyAxIC4uIF1cbiAgICAgIGFyZ3VtZW50X2lkeCArPSAtMVxuICAgIGVsc2VcbiAgICAgIEBJRExYLl9zaGFrZV90cmVlIHN1Yl90cmVlXG4gIHJldHVybiBkaWFncmFtXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuQElETFguX2dldF90cmVlc2hha2VyX2xpdG11cyA9ID0+XG4gICMjIyBXaGVuIGBASURMWC5fZ2V0X3RyZWVzaGFrZXJfbGl0bXVzLnBhdHRlcm5gIG1hdGNoZXMgYSBmb3JtdWxhLCBpdCAqbWF5KiBiZSBub24tbWluaW1hbDsgaWYgdGhlIHBhdHRlcm5cbiAgZG9lcyAqbm90KiBtYXRjaCBhIGZvcm11bGEsIHRoZXJlIGFyZSBjZXJ0YWlubHkgbm8gb3Bwb3J0dW5pdGllcyBmb3Igb3B0aW1pemF0aW9uLiBUaGUgcGF0dGVybiB3b3JrcyBieVxuICB0cnlpbmcgdG8gbWF0Y2ggc2VxdWVuY2VzIGxpa2UgYC8uLi58KD86T1teTU5QUV0qTyl8KD86UFteTU5PUV0qUCl8Li4uL2AsIHdoZXJlIGBNTk9QUWAgYXJlIHRoZSBiaW5hcnlcbiAgb3BlcmF0b3JzLiAjIyNcbiAgcmV0dXJuIFIgaWYgKCBSID0gQElETFguX2dldF90cmVlc2hha2VyX2xpdG11cy5wYXR0ZXJuICk/XG4gICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgYmluYXJ5X29wZXJhdG9ycyA9IFtdXG4gIGZvciBzeW1ib2wsIHRva2VuX3R5cGUgb2YgQElETFgubGl0ZXJhbHNfYW5kX3R5cGVzXG4gICAgYmluYXJ5X29wZXJhdG9ycy5wdXNoIHN5bWJvbCBpZiB0b2tlbl90eXBlIGlzICdiaW5hcnlfb3BlcmF0b3InXG4gICMgYmluYXJ5X29wZXJhdG9ycyA9IGJpbmFyeV9vcGVyYXRvcnNbIC4uIDMgXVxuICAjIGRlYnVnICc1Mjk5OCcsIGJpbmFyeV9vcGVyYXRvcnNcbiAgcGF0dGVybiA9IFtdXG4gIGZvciBvcGVyYXRvciBpbiBiaW5hcnlfb3BlcmF0b3JzXG4gICAgc3ViX3BhdHRlcm4gPSBbXVxuICAgIHN1Yl9wYXR0ZXJuLnB1c2ggJ1teJ1xuICAgIGZvciBzdWJfb3BlcmF0b3IgaW4gYmluYXJ5X29wZXJhdG9yc1xuICAgICAgY29udGludWUgaWYgc3ViX29wZXJhdG9yIGlzIG9wZXJhdG9yXG4gICAgICBzdWJfcGF0dGVybi5wdXNoIHN1Yl9vcGVyYXRvclxuICAgIHN1Yl9wYXR0ZXJuLnB1c2ggJ10qJ1xuICAgIHBhdHRlcm4ucHVzaCAnKD86JyArIG9wZXJhdG9yICsgKCBzdWJfcGF0dGVybi5qb2luICcnICkgKyBvcGVyYXRvciArICcpJ1xuICAjLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uXG4gIHJldHVybiBASURMWC5fZ2V0X3RyZWVzaGFrZXJfbGl0bXVzLnBhdHRlcm4gPSBuZXcgUmVnRXhwIHBhdHRlcm4uam9pbiAnfCdcblxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5ASURMWC5fZ2V0X3RyZWVzaGFrZXJfbGl0bXVzLnBhdHRlcm4gID0gbnVsbFxuQElETFgubGl0ZXJhbHNfYW5kX3R5cGVzICAgICAgICAgICAgICA9IEBJRExYLl9nZXRfbGl0ZXJhbHNfYW5kX3R5cGVzIElETFhfR1JBTU1BUlxuXG5cbiM9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuIyBTSUxIT1VUVEVTLCBOR1JBTVNcbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuIyMjIE5PVEU6IGRvIG5vdCB1c2UgcGFyYW1ldHJpYyBgcmVxdWlyZSgpYCBhcyB0aGlzIG1heSB0aHJvdyBvZmYgYnJvd3NlcmlmeSAoYW5kIHJpZ2h0bHkgc28pICMjI1xuSURMWCAgICAgICAgPSBASURMWFxuU0lMSE9VRVRURVMgPSByZXF1aXJlICcuL3NpbGhvdWV0dGVzJ1xuTkdSQU1TICAgICAgPSByZXF1aXJlICcuL25ncmFtcydcbmRvIC0+XG4gIGZvciBuYW1lLCB2YWx1ZSBvZiBTSUxIT1VFVFRFU1xuICAgIElETFhbIG5hbWUgXSA9IHZhbHVlXG4gIGZvciBuYW1lLCB2YWx1ZSBvZiBOR1JBTVNcbiAgICBJRExYWyBuYW1lIF0gPSB2YWx1ZVxuICByZXR1cm4gbnVsbFxuXG5cbiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjI1xudW5sZXNzIG1vZHVsZS5wYXJlbnQ/XG4gICAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICAgIGluZm8gQElETFguX2dldF9saXRlcmFsc19hbmRfdHlwZXMgSURMWF9HUkFNTUFSXG4gICAgaW5mbyBASURMWC50eXBlX2Zyb21fbGl0ZXJhbCBJRExYX0dSQU1NQVJcbiAgICBoZWxwICfihrsnLCBASURMWC50eXBlX2Zyb21fbGl0ZXJhbCAn4oa7JyAjICdvcGVyYXRvcicsXG4gICAgaGVscCAn44CTJywgQElETFgudHlwZV9mcm9tX2xpdGVyYWwgJ+OAkycgIyAncHJveHknLFxuICAgIGhlbHAgJ8KnJywgQElETFgudHlwZV9mcm9tX2xpdGVyYWwgJ8KnJyAjICdwcm94eScsXG4gICAgaGVscCAn4r+wJywgQElETFgudHlwZV9mcm9tX2xpdGVyYWwgJ+K/sCcgIyAnb3BlcmF0b3InLFxuICAgIGhlbHAgJ+K/uycsIEBJRExYLnR5cGVfZnJvbV9saXRlcmFsICfiv7snICMgJ29wZXJhdG9yJyxcbiAgICBoZWxwICfil7AnLCBASURMWC50eXBlX2Zyb21fbGl0ZXJhbCAn4pewJyAjICdvcGVyYXRvcicsXG4gICAgaGVscCAnKCcsIEBJRExYLnR5cGVfZnJvbV9saXRlcmFsICcoJyAjICdicmFja2V0JyxcbiAgICBoZWxwICd4JywgQElETFgudHlwZV9mcm9tX2xpdGVyYWwgJ3gnICMgJ290aGVyJyxcbiAgICBmb3JtdWxhICAgICAgID0gJ+K/ueW8kyjiv7Ao4r+x5Lq65Lq65LioKSjiv7HkurrkurrkuKgpKOK/seS6uuS6uuS4qCkpJ1xuICAgIHdoaXNwZXIgZm9ybXVsYVxuICAgIGhlbHAgZGlhZ3JhbSAgPSBASURMWC5wYXJzZSBmb3JtdWxhXG4gICAgd2hpc3BlciBmb3JtdWxhXG4gICAgaGVscCB0b2tlbnMgICA9IEBJRExYLmxpc3RfdG9rZW5zIGRpYWdyYW1cbiAgICB1cmdlIEBJRExYLmdldF9mb3JtdWxhIGZvcm11bGFcbiAgICB1cmdlIEBJRExYLmdldF9mb3JtdWxhIGRpYWdyYW1cbiAgICB1cmdlIEBJRExYLl9nZXRfdHJlZXNoYWtlcl9saXRtdXMoKVxuICAgIHVyZ2UgKCBDTkQueWVsbG93IGZvcm11bGEgICAgKSwgKCBDTkQuYmx1ZSBDTkQudHJ1dGggQElETFguZm9ybXVsYV9tYXlfYmVfbm9ubWluaW1hbCBmb3JtdWxhICAgIClcbiAgICB1cmdlICggQ05ELnllbGxvdyAn4r+x4r+x8KudgOWPo+OQhCcgICAgKSwgKCBDTkQuYmx1ZSBDTkQudHJ1dGggQElETFguZm9ybXVsYV9tYXlfYmVfbm9ubWluaW1hbCAn4r+x4r+x8KudgOWPo+OQhCcgICAgKVxuICAgIHVyZ2UgKCBDTkQueWVsbG93ICfiv7Hwq52A4r+x5Y+j45CEJyAgICApLCAoIENORC5ibHVlIENORC50cnV0aCBASURMWC5mb3JtdWxhX21heV9iZV9ub25taW5pbWFsICfiv7Hwq52A4r+x5Y+j45CEJyAgICApXG4gICAgdXJnZSAoIENORC55ZWxsb3cgJ+K/sOmfiyjiv7Hnmb3lpKfljYEpJyApLCAoIENORC5ibHVlIENORC50cnV0aCBASURMWC5mb3JtdWxhX21heV9iZV9ub25taW5pbWFsICfiv7Dpn4so4r+x55m95aSn5Y2BKScgKVxuICAgIGluZm8gKCBDTkQueWVsbG93IGZvcm11bGEgICAgKSwgKCBDTkQuYmx1ZSBASURMWC5taW5pbWl6ZV9mb3JtdWxhIGZvcm11bGEgICAgICAgICAgICAgICAgICAgICAgIClcbiAgICBpbmZvICggQ05ELnllbGxvdyAn4r+x4r+x8KudgOWPo+OQhCcgICAgKSwgKCBDTkQuYmx1ZSBASURMWC5taW5pbWl6ZV9mb3JtdWxhICfiv7Hiv7Hwq52A5Y+j45CEJyAgICAgICAgICAgICAgICAgICAgICAgKVxuICAgIGluZm8gKCBDTkQueWVsbG93ICfiv7Hwq52A4r+x5Y+j45CEJyAgICApLCAoIENORC5ibHVlIEBJRExYLm1pbmltaXplX2Zvcm11bGEgJ+K/sfCrnYDiv7Hlj6PjkIQnICAgICAgICAgICAgICAgICAgICAgICApXG4gICAgaW5mbyAoIENORC55ZWxsb3cgJ+K/sOmfiyjiv7Hnmb3lpKfljYEpJyApLCAoIENORC5ibHVlIEBJRExYLm1pbmltaXplX2Zvcm11bGEgJ+K/sOmfiyjiv7Hnmb3lpKfljYEpJyAgICAgICAgICAgICAgICAgICAgKVxuICAgIHByb2Nlc3MuZXhpdCAxXG5cbiJdfQ==

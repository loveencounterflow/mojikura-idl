(function() {
  //###########################################################################################################
  var CND, IDLX, TAP, alert, badge, conflate, debug, echo, equals, help, info, isa, log, rpr, type_of, urge, validate, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MOJIKURA-IDL/TESTS/NGRAMS';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  TAP = require('tap');

  ({IDLX} = require('../..'));

  ({isa, type_of, validate, equals} = require('../types'));

  /*
  Ngrams with Relations:
  谆:⿰讠(⿱亠口子)
  谆∋⿰讠亠
  谆∋⿱亠口
  谆∋⿱口子
  (谆∋⿱亠...子)
  (谆∋⿰讠⿱亠)
  */
  //-----------------------------------------------------------------------------------------------------------
  conflate = function(bigrams) {
    var R, bigram, i, len, token;
    // bigrams.sort()
    R = [];
    for (i = 0, len = bigrams.length; i < len; i++) {
      bigram = bigrams[i];
      R.push(((function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = bigram.length; j < len1; j++) {
          token = bigram[j];
          results.push(token.s);
        }
        return results;
      })()).join(''));
    }
    return R.join(',');
  };

  //-----------------------------------------------------------------------------------------------------------
  TAP.test("(IDLX) bigrams", function(T) {
    /* !!!!!!!!!!!!!!!!!!!! */
    var bigrams, error, formula, glyph, i, len, matcher, probe, probes_and_matchers/* TAINT not normalized? */, result;
    [/* !!!!!!!!!!!!!!!!!!!! */ '䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田'];
    [/* TAINT not normalized? */ '𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'];
    probes_and_matchers = [["乳:⿰⿱爫子乚", "⿱⊚爫,⿱爫子,⿰子乚,⿰乚⊚"], ["鐓:(⿰金(⿱亠口子)夊)", "⿰⊚金,⿰金亠,⿱亠口,⿱口子,⿰子夊,⿰夊⊚"], ["孔:⿰子乚", "⿰⊚子,⿰子乚,⿰乚⊚"], ["谆:⿰讠(⿱亠口子)", "⿰⊚讠,⿰讠亠,⿱亠口,⿱口子,⿱子⊚"], ["享:(⿱亠口子)", "⿱⊚亠,⿱亠口,⿱口子,⿱子⊚"], ["孫:⿰子系", "⿰⊚子,⿰子系,⿰系⊚"], ["浮:⿰氵⿱爫子", "⿰⊚氵,⿰氵爫,⿱爫子,⿱子⊚"], ["仔:⿰亻子", "⿰⊚亻,⿰亻子,⿰子⊚"], ["郭:⿰(⿱亠口子)阝", "⿱⊚亠,⿱亠口,⿱口子,⿰子阝,⿰阝⊚"], ["孙:⿰子小", "⿰⊚子,⿰子小,⿰小⊚"], ["敦:⿰(⿱亠口子)夊", "⿱⊚亠,⿱亠口,⿱口子,⿰子夊,⿰夊⊚"], ["孕:⿱乃子", "⿱⊚乃,⿱乃子,⿱子⊚"], ["遜:⿺辶⿰子系", "⿺⊚辶,⿺辶子,⿰子系,⿰系⊚"], ["鷻:(⿰鳥(⿱亠口子)夊)", "⿰⊚鳥,⿰鳥亠,⿱亠口,⿱口子,⿰子夊,⿰夊⊚"], ["𤅸:⿰氵⿱⿰臣⿱𠂉⿴占𠂭皿", "⿰⊚氵,⿰氵臣,⿰臣𠂉,⿱𠂉占,⿴占𠂭,⿱𠂭皿,⿱皿⊚"], ["𣟁:⿰木⿱⿰阝⿱⿸𠂇工⺝土", "⿰⊚木,⿰木阝,⿰阝𠂇,⿸𠂇工,⿱工⺝,⿱⺝土,⿱土⊚"], ["𧃚:⿱卄⿰月⿺辶⿱⿸𠂇工⺝", "⿱⊚卄,⿱卄月,⿰月辶,⿺辶𠂇,⿸𠂇工,⿱工⺝,⿱⺝⊚"], ["𥷿:⿱𥫗⿰⿱巛田⿸广⿱廿灬", "⿱⊚𥫗,⿱𥫗巛,⿱巛田,⿰田广,⿸广廿,⿱廿灬,⿱灬⊚"], ["𤬣:⿱⿻⿴乂⿰⿱大亏瓜", "⿻⊚,⿻,⿴乂,⿱乂大,⿱大亏,⿰亏瓜,⿰瓜⊚"], ["䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田", "⿱⊚⻗,⿱⻗田,⿰田⻗,⿱⻗田,⿱田⻗,⿱⻗田,⿰田⻗,⿱⻗田,⿱田⊚"], ["𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝", "⿵⊚𠘨,⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝,⿱䖝𠘨,⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝,⿵䖝⊚"], ["竜:⿱立≈电", "⿱⊚立,⿱立电,⿱电⊚"], ["覽:⿱⿰臣⿱罒見", "⿰⊚臣,⿰臣,⿱罒,⿱罒見,⿱見⊚"], ["龟:⿱𠂊≈电", "⿱⊚𠂊,⿱𠂊电,⿱电⊚"], ["𠗬:⿰冫⿸戶用", "⿰⊚冫,⿰冫戶,⿸戶用,⿸用⊚"], ["𠗭:(⿱⿰冫士寸)", "⿰⊚冫,⿰冫,⿱士,⿱士寸,⿱寸⊚"], ["𠚖:⿶≈凵王", "⿶⊚凵,⿶凵王,⿶王⊚"], ["𠚜:⿶≈凵⿱爫臼", "⿶⊚凵,⿶凵爫,⿱爫臼,⿱臼⊚"], ["𠚡:⿶?凵⿱爫臼", "⿶⊚凵,⿶凵爫,⿱爫臼,⿱臼⊚"], ["繭:⿱卄⿻≈巾⿰糹虫", "⿱⊚卄,⿱卄巾,⿻巾糹,⿰糹虫,⿰虫⊚"], ["𠕄:↻凹", ""], ["孝:⿱耂子", "⿱⊚耂,⿱耂子,⿱子⊚"], ["猛:⿰犭⿱子皿", "⿰⊚犭,⿰犭子,⿱子皿,⿱皿⊚"], ["孟:⿱子皿", "⿱⊚子,⿱子皿,⿱皿⊚"], ["勃:⿰⿱子力", "⿱⊚,⿱子,⿰子力,⿰力⊚"], ["郭:⿰(⿱亠口子)阝", "⿱⊚亠,⿱亠口,⿱口子,⿰子阝,⿰阝⊚"]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher] = probes_and_matchers[i];
      [glyph, formula] = probe.split(':');
      try {
        // debug '27821', IDLX.list_tokens formula, { all_brackets: yes, }
        bigrams = IDLX.get_relational_bigrams_as_tokens(formula);
        // urge  '93209', formula
        // urge  '93209', bigrams
        result = conflate(bigrams);
      } catch (error1) {
        // debug JSON.stringify [ probe, result, ]
        error = error1;
        T.fail(`${probe} failed with ${rpr(error.message)}`);
        continue;
      }
      if (result === matcher) {
        T.ok(true);
      } else {
        T.fail(`expected ${matcher}, got ${result}`);
      }
    }
    return T.end();
  });

  //-----------------------------------------------------------------------------------------------------------
  TAP.test("(IDLX) cached bigrams with indices", function(T) {
    var bigram, bigrams, bigrams_as_indices, formula, glyph, i, len, matcher, parts, probe, probes_and_matchers, result;
    probes_and_matchers = [["乳:⿰⿱爫子乚", "⿱⊚爫,⿱爫子,⿰子乚,⿰乚⊚"], ["鐓:(⿰金(⿱亠口子)夊)", "⿰⊚金,⿰金亠,⿱亠口,⿱口子,⿰子夊,⿰夊⊚"], ["孔:⿰子乚", "⿰⊚子,⿰子乚,⿰乚⊚"], ["𠃨:⿹⺄&cdp#x88c6;", "⿹⊚⺄,⿹⺄&cdp#x88c6;,⿹&cdp#x88c6;⊚"], ["𠄋:⿰(⿱&cdp#x855e;日丂)乞", "⿱⊚&cdp#x855e;,⿱&cdp#x855e;日,⿱日丂,⿰丂乞,⿰乞⊚"], ["𠄋:⿰酉⿱日𤴓", "⿰⊚酉,⿰酉日,⿱日𤴓,⿱𤴓⊚"]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher] = probes_and_matchers[i];
      [glyph, formula] = probe.split(':');
      parts = IDLX.split_formula(formula);
      bigrams_as_indices = IDLX.get_relational_bigrams_as_indices(formula);
      bigrams = IDLX.bigrams_from_parts_and_indices(parts, bigrams_as_indices);
      result = ((function() {
        var j, len1, results;
        results = [];
        for (j = 0, len1 = bigrams.length; j < len1; j++) {
          bigram = bigrams[j];
          results.push(bigram.join(''));
        }
        return results;
      })()).join(',');
      // urge  '93209', glyph, formula
      // help  '93209', result
      // debug '22020', JSON.stringify [ probe, result, ]
      if (result === matcher) {
        T.ok(true);
      } else {
        T.fail(`expected ${matcher}, got ${result}`);
      }
    }
    return T.end();
  });

  //-----------------------------------------------------------------------------------------------------------
  TAP.test("(IDLX) bigrams as lists of texts", function(T) {
    var formula, glyph, i, len, matcher, probe, probes_and_matchers, result;
    probes_and_matchers = [["乳:⿰⿱爫子乚", ["⿱⊚爫", "⿱爫子", "⿰子乚", "⿰乚⊚"]], ["鐓:(⿰金(⿱亠口子)夊)", ["⿰⊚金", "⿰金亠", "⿱亠口", "⿱口子", "⿰子夊", "⿰夊⊚"]], ["孔:⿰子乚", ["⿰⊚子", "⿰子乚", "⿰乚⊚"]], ["𠃨:⿹⺄&cdp#x88c6;", ["⿹⊚⺄", "⿹⺄&cdp#x88c6;", "⿹&cdp#x88c6;⊚"]], ["𠄋:⿰(⿱&cdp#x855e;日丂)乞", ["⿱⊚&cdp#x855e;", "⿱&cdp#x855e;日", "⿱日丂", "⿰丂乞", "⿰乞⊚"]], ["𠄋:⿰酉⿱日𤴓", ["⿰⊚酉", "⿰酉日", "⿱日𤴓", "⿱𤴓⊚"]], ["𠕄:↻凹", []], ["孝:⿱耂子", ["⿱⊚耂", "⿱耂子", "⿱子⊚"]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher] = probes_and_matchers[i];
      [glyph, formula] = probe.split(':');
      result = IDLX.get_relational_bigrams(formula);
      // debug '32321', JSON.stringify [ probe, result, ]
      if (equals(result, matcher)) {
        T.ok(true);
      } else {
        T.fail(`expected ${matcher}, got ${result}`);
      }
    }
    return T.end();
  });

}).call(this);

//# sourceMappingURL=idlx-ngrams.js.map
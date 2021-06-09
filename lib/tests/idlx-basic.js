(function() {
  //###########################################################################################################
  var CND, IDL, IDLX, TAP, alert, badge, debug, echo, equals, help, info, isa, log, rpr, type_of, urge, validate, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'MOJIKURA-IDL/tests';

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

  ({IDL, IDLX} = require('../..'));

  ({isa, type_of, validate, equals} = require('../types'));

  //===========================================================================================================
  // TESTS (IDLX)
  //-----------------------------------------------------------------------------------------------------------
  TAP.test("(IDLX) simple formulas", function(T) {
    var i, len, matcher, probe, probes_and_matchers, result;
    probes_and_matchers = [["⿱刀口", ["⿱", "刀", "口"]], ["⿱癶⿰弓貝", ["⿱", "癶", ["⿰", "弓", "貝"]]], ["⿱⿰亻式貝", ["⿱", ["⿰", "亻", "式"], "貝"]], ["⿱⿰亻式⿱目八", ["⿱", ["⿰", "亻", "式"], ["⿱", "目", "八"]]], ["⿺辶言", ["⿺", "辶", "言"]], ["⿰ab", ["⿰", "a", "b"]], ["⿰⿰abc", ["⿰", ["⿰", "a", "b"], "c"]], ["⿱⿱刀口乙", ["⿱", ["⿱", "刀", "口"], "乙"]], ["⿱⿱刀口乙", ["⿱", ["⿱", "刀", "口"], "乙"]], ["⿱&jzr#xe24a;&jzr#xe11d;", ["⿱", "", ""]], ["⿰𠁣𠃛", ["⿰", "𠁣", "𠃛"]]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher] = probes_and_matchers[i];
      // result = resume_next T, -> IDLX.parse probe
      result = IDLX.parse(probe);
      urge(CND.truth(equals(result, matcher)), JSON.stringify([probe, result]));
      // urge ( rpr probe ), result
      T.ok(equals(result, matcher));
    }
    //.........................................................................................................
    T.end();
    return null;
  });

  //-----------------------------------------------------------------------------------------------------------
  TAP.test("(IDLX) reject bogus formulas", function(T) {
    var error, i, len, matcher, message, probe, probes_and_matchers, result;
    probes_and_matchers = [["⿲木木木", "invalid syntax at index 0 (⿲木木木)\nUnexpected \"⿲\"\n"], ["木", "invalid syntax at index 0 (木)\nUnexpected \"木\"\n"], [42, "expected a text, got a number"], ["", "expected a non-empty text, got an empty text"], ["⿱⿰亻式⿱目八木木木", "invalid syntax at index 7 (⿱⿰亻式⿱目八木木木)\nUnexpected \"木\"\n"], ["⿺廴聿123", "invalid syntax at index 3 (⿺廴聿123)\nUnexpected \"1\"\n"], ["⿺", "Syntax Error: '⿺'"], ["⿺⿺⿺⿺", "Syntax Error: '⿺⿺⿺⿺'"]];
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher] = probes_and_matchers[i];
      try {
        result = IDLX.parse(probe);
        debug(rpr(probe), rpr(result));
        warn(`expected an exception, got result ${rpr(result)}`);
        T.fail(`expected an exception, got result ${rpr(result)}`);
      } catch (error1) {
        error = error1;
        ({message} = error);
        urge(JSON.stringify([probe, message]));
      }
      T.ok(equals(message, matcher));
    }
    //.........................................................................................................
    T.end();
    return null;
  });

}).call(this);

//# sourceMappingURL=idlx-basic.js.map
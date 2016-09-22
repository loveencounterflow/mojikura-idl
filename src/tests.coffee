



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
{ IDL, IDLX, }            = require './main'


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
nice_text_rpr = ( text ) ->
  ### Ad-hoc method to print out text in a readable, CoffeeScript-compatible, triple-quoted way. Line breaks
  (`\\n`) will be shown as line breaks, so texts should not be as spaghettified as they appear with
  JSON.stringify (the last line break of a string is, however, always shown in its symbolic form so it
  won't get swallowed by the CoffeeScript parser). Code points below U+0020 (space) are shown as
  `\\x00`-style escapes, taken up less space than `\u0000` escapes while keeping things explicit. All
  double quotes will be prepended with a backslash. ###
  R = text
  R = R.replace /[\x00-\x09\x0b-\x19]/g, ( $0 ) ->
    cid_hex = ( $0.codePointAt 0 ).toString 16
    cid_hex = '0' + cid_hex if cid_hex.length is 1
    return "\\x#{cid_hex}"
  R = R.replace /"/g, '\\"'
  R = R.replace /\n$/g, '\\n'
  R = '\n"""' + R + '"""'
  return R

#-----------------------------------------------------------------------------------------------------------
@_main = ( handler ) ->
  test @, 'timeout': 2500

#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null


#===========================================================================================================
# TESTS (SANITY CHECKS)
#-----------------------------------------------------------------------------------------------------------
@[ "sanity checks (private methods)" ] = ( T ) ->
  probes_and_matchers = [
    ["木",["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"]]
    ["⿲",["assigned","cjk","idl"]]
    ["a",["assigned"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDL._tags_from_symbol  null, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "sanity checks (grammar data)" ] = ( T ) ->
  T.ok '⿰' of IDL.grammar.operators
  T.ok '⿱' of IDL.grammar.operators
  T.ok '⿴' of IDL.grammar.operators
  T.ok '⿵' of IDL.grammar.operators
  T.ok '⿶' of IDL.grammar.operators
  T.ok '⿷' of IDL.grammar.operators
  T.ok '⿸' of IDL.grammar.operators
  T.ok '⿹' of IDL.grammar.operators
  T.ok '⿺' of IDL.grammar.operators
  T.ok '⿻' of IDL.grammar.operators
  T.ok '⿲' of IDL.grammar.operators
  T.ok '⿳' of IDL.grammar.operators
  #.........................................................................................................
  T.ok '⿰' of IDLX.grammar.operators
  T.ok '⿱' of IDLX.grammar.operators
  T.ok '⿴' of IDLX.grammar.operators
  T.ok '⿵' of IDLX.grammar.operators
  T.ok '⿶' of IDLX.grammar.operators
  T.ok '⿷' of IDLX.grammar.operators
  T.ok '⿸' of IDLX.grammar.operators
  T.ok '⿹' of IDLX.grammar.operators
  T.ok '⿺' of IDLX.grammar.operators
  T.ok '⿻' of IDLX.grammar.operators
  T.ok '⿲' not of IDLX.grammar.operators
  T.ok '⿳' not of IDLX.grammar.operators
  T.ok '◰' of IDLX.grammar.operators
  T.ok '≈' of IDLX.grammar.operators
  T.ok '↻' of IDLX.grammar.operators
  T.ok '↔' of IDLX.grammar.operators
  T.ok '↕' of IDLX.grammar.operators
  T.ok '●' of IDLX.grammar.solitaires
  #.........................................................................................................
  T.ok IDL.grammar           isnt IDLX.grammar
  T.ok IDL.grammar.operators isnt IDLX.grammar.operators
  T.ok not CND.equals IDL.grammar,            IDLX.grammar
  T.ok not CND.equals IDL.grammar.operators,  IDLX.grammar.operators
  #.........................................................................................................
  return null


#===========================================================================================================
# TESTS (IDL)
#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) parse simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["木","木"]
    ["⿲木木木",["⿲","木","木","木"]]
    ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
    ["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
    ["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
    ["⿺辶言",["⿺","辶","言"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDL.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) parse tree of simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["木",{"s":"木","idx":0,"t":"component"}]
    ["⿲木木木",[{"s":"⿲","idx":0,"t":"operator","a":3,"n":"pillars"},{"s":"木","idx":1,"t":"component"},{"s":"木","idx":2,"t":"component"},{"s":"木","idx":3,"t":"component"}]]
    ["⿱癶⿰弓貝",[{"s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},{"s":"癶","idx":1,"t":"component"},[{"s":"⿰","idx":2,"t":"operator","a":2,"n":"left-right"},{"s":"弓","idx":3,"t":"component"},{"s":"貝","idx":4,"t":"component"}]]]
    ["⿱⿰亻式貝",[{"s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"s":"亻","idx":2,"t":"component"},{"s":"式","idx":3,"t":"component"}],{"s":"貝","idx":4,"t":"component"}]]
    ["⿱⿰亻式⿱目八",[{"s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"s":"亻","idx":2,"t":"component"},{"s":"式","idx":3,"t":"component"}],[{"s":"⿱","idx":4,"t":"operator","a":2,"n":"top/down"},{"s":"目","idx":5,"t":"component"},{"s":"八","idx":6,"t":"component"}]]]
    ["⿺辶言",[{"s":"⿺","idx":0,"t":"operator","a":2,"n":"leftbottom"},{"s":"辶","idx":1,"t":"component"},{"s":"言","idx":2,"t":"component"}]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDL.parse_tree probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) reject bogus formulas" ] = ( T ) ->
  probes_and_matchers = [
    [42,"expected a text, got a number"]
    ["","syntax error (empty text)"]
    ["⿱⿰亻式⿱目八木木木","syntax error (token idx 7 of '⿱⿰亻式⿱目八木木木')"]
    ["⿺廴聿123","syntax error (token idx 3 of '⿺廴聿123')"]
    ["⿺","syntax error (premature end of source '⿺')"]
    ["⿺⿺⿺⿺","syntax error (premature end of source '⿺⿺⿺⿺')"]
    ["⿺12","unable to parse token of type other (token idx 2 of '⿺12')"]
    ["(⿰亻聿式)","unable to parse token of type other (token idx 1 of '(⿰亻聿式)')"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDL.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      warn JSON.stringify [ probe, error[ 'message' ], ]
      T.eq error[ 'message' ], matcher
  #.........................................................................................................
  return null


#===========================================================================================================
# TESTS (IDLX)
#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) parse simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["木","木"]
    ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
    ["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
    ["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
    ["⿺辶言",["⿺","辶","言"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDLX.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) reject bogus formulas" ] = ( T ) ->
  probes_and_matchers = [
    [42,"expected a text, got a number"]
    ["","syntax error (empty text)"]
    ["⿱⿰亻式⿱目八木木木","syntax error (token idx 7 of '⿱⿰亻式⿱目八木木木')"]
    ["⿺廴聿123","syntax error (token idx 3 of '⿺廴聿123')"]
    ["⿺","syntax error (premature end of source '⿺')"]
    ["⿺⿺⿺⿺","syntax error (premature end of source '⿺⿺⿺⿺')"]
    ["⿺12","unable to parse token of type other (token idx 2 of '⿺12')"]
    ["(⿰亻聿式)","unable to parse token of type other (token idx 1 of '(⿰亻聿式)')"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      warn JSON.stringify [ probe, error[ 'message' ], ]
      T.eq error[ 'message' ], matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) reject IDL operators with arity 3" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲木木木","syntax error (token idx 1 of '⿲木木木')"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      warn JSON.stringify [ probe, error[ 'message' ], ]
      T.eq error[ 'message' ], matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) parse extended formulas" ] = ( T ) ->
  probes_and_matchers = [
      [ '≈㐀', [ '≈', '㐀', ], ]
      [ '≈𠀎', [ '≈', '𠀎', ], ]
      [ '≈𪜀', [ '≈', '𪜀', ], ]
      [ '≈〇', [ '≈', '〇', ], ]
      [ '●', '●', ]
      #  ['▽', []]
      # [ '↻正', [ '↻', '正', ], ]
      # [ '↔≈匕', [ '↔', [ '≈', '匕' ] ], ]
      # [ '↔正', [ '↔', '正', ], ]
      # [ '⿱丶乂', [ '⿱', '丶', '乂', ], ]
      # [ '⿺走⿹◰口戈日', [ '⿺', '走', [ '⿹', [ '◰', '口', '戈' ], '日' ] ], ]
      # [ '(⿱北㓁允)', [ '⿱', [ '北', '㓁', '允' ] ], ]
      # ['≈匚', [ '≈', '匚' ], ]
      # ['≈&jzr#xe174;', [ '≈', '&jzr#xe174;' ], ]
      # ['≈非', [ '≈', '非' ], ]
      # [ '⿱§&jzr#xe199;', [ '⿱', '§', '&jzr#xe199;' ], ]
      # [ '〓', [ '〓' ], ]
      # [ '⿺走⿹◰口〓日', [ '⿺', '走', [ '⿹', [ '◰', '口', '〓' ], '日' ] ], ]
      # # [ '⿻串⿰立&jzr#x1234;', [ '⿻', '串', [ '⿰', '立', '&jzr#x1234;' ] ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDLX.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null '  '
  include = [
    # "(IDL) demo"
    "sanity checks (private methods)"
    "sanity checks (grammar data)"
    #.......................................................................................................
    "(IDL) parse simple formulas"
    "(IDL) parse tree of simple formulas"
    "(IDL) reject bogus formulas"
    #.......................................................................................................
    "(IDLX) parse simple formulas"
    "(IDLX) reject bogus formulas"
    "(IDLX) reject IDL operators with arity 3"
    "(IDLX) parse extended formulas"
    ]
  @_prune()
  @_main()

  # urge IDL.parse "⿱癶⿰弓貝"
  # help IDL.parse_tree "⿱癶⿰弓貝"
  # IDL.parse    ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]

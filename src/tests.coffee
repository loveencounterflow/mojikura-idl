



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
MKNCR                     = require 'mingkwai-ncr'


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

#-----------------------------------------------------------------------------------------------------------
resume_next = ( T, method ) ->
  try
    R = method()
  catch error
    return Symbol "### ERROR ### " + error[ 'message' ]
  return R


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

#-----------------------------------------------------------------------------------------------------------
@[ "sanity checks (MKNCR)" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲",["u",["assigned","cjk","idl"]]]
    ["木",["u",["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"]]]
    ["&#x1234;",["u",["assigned"]]]
    ["&#xe100;",["u",["assigned","pua","cjk"]]]
    ["&jzr#xe100;",["jzr",["assigned","cjk"]]]
    ["&morohashi#x1234;",["morohashi",["assigned","cjk"]]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    description     = MKNCR.describe probe
    # urge JSON.stringify [ probe, description, ]
    { csg, tag, }   = description
    result          = [ csg, tag, ]
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#===========================================================================================================
# TESTS (IDL)
#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) parse simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲木木木",["⿲","木","木","木"]]
    ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
    ["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
    ["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
    ["⿺辶言",["⿺","辶","言"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = resume_next T, -> IDL.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) parse tree of simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲木木木",[{"~isa":"MOJIKURA-IDL/token","s":"⿲","idx":0,"t":"operator","a":3,"n":"pillars"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":1,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":3,"t":"component"}]]
    ["⿱癶⿰弓貝",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},{"~isa":"MOJIKURA-IDL/token","s":"癶","idx":1,"t":"component"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":2,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"弓","idx":3,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"貝","idx":4,"t":"component"}]]]
    ["⿱⿰亻式貝",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"亻","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"式","idx":3,"t":"component"}],{"~isa":"MOJIKURA-IDL/token","s":"貝","idx":4,"t":"component"}]]
    ["⿱⿰亻式⿱目八",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"亻","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"式","idx":3,"t":"component"}],[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":4,"t":"operator","a":2,"n":"top/down"},{"~isa":"MOJIKURA-IDL/token","s":"目","idx":5,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"八","idx":6,"t":"component"}]]]
    ["⿺辶言",[{"~isa":"MOJIKURA-IDL/token","s":"⿺","idx":0,"t":"operator","a":2,"n":"leftbottom"},{"~isa":"MOJIKURA-IDL/token","s":"辶","idx":1,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"言","idx":2,"t":"component"}]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = resume_next T, -> IDL.parse_tree probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) reject bogus formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["木","syntax error: lone token of type 'component' in [  ✘ 木 ✘  ]"]
    [42,"expected a text, got a number"]
    ["","syntax error: empty text"]
    ["⿱⿰亻式⿱目八木木木","syntax error: extra token(s) in [ ⿱⿰亻式⿱目八 ✘ 木 ✘ 木木 ]"]
    ["⿺廴聿123","syntax error: extra token(s) in [ ⿺廴聿 ✘ 1 ✘ 23 ]"]
    ["⿺","syntax error: premature end of source in [  ✘ ⿺ ✘  ])"]
    ["⿺⿺⿺⿺","syntax error: premature end of source in [ ⿺⿺⿺ ✘ ⿺ ✘  ])"]
    ["⿺12","syntax error: illegal token '1' (type 'other') in [ ⿺ ✘ 1 ✘ 2 ]"]
    ["(⿰亻聿式)","syntax error: illegal token '(' (type 'other') in [  ✘ ( ✘ ⿰亻聿式) ]"]
    ["≈〇","syntax error: illegal token '≈' (type 'other') in [  ✘ ≈ ✘ 〇 ]"]
    ["●","syntax error: illegal token '●' (type 'other') in [  ✘ ● ✘  ]"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDL.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      message = CND.remove_colors error[ 'message' ]
      warn JSON.stringify [ probe, message, ]
      T.eq message, matcher
  #.........................................................................................................
  return null


#===========================================================================================================
# TESTS (IDLX)
#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) parse simple formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
    ["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
    ["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
    ["⿺辶言",["⿺","辶","言"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = resume_next T, -> IDLX.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) reject bogus formulas" ] = ( T ) ->
  probes_and_matchers = [
    ["木","syntax error: lone token of type 'component' in [  ✘ 木 ✘  ]"]
    [42,"expected a text, got a number"]
    ["","syntax error: empty text"]
    ["⿱⿰亻式⿱目八木木木","syntax error: extra token(s) in [ ⿱⿰亻式⿱目八 ✘ 木 ✘ 木木 ]"]
    ["⿺廴聿123","syntax error: extra token(s) in [ ⿺廴聿 ✘ 1 ✘ 23 ]"]
    ["⿺","syntax error: premature end of source in [  ✘ ⿺ ✘  ])"]
    ["⿺⿺⿺⿺","syntax error: premature end of source in [ ⿺⿺⿺ ✘ ⿺ ✘  ])"]
    ["⿺12","syntax error: illegal token '1' (type 'other') in [ ⿺ ✘ 1 ✘ 2 ]"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      message = CND.remove_colors error[ 'message' ]
      warn JSON.stringify [ probe, message, ]
      T.eq message, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) reject IDL operators with arity 3" ] = ( T ) ->
  probes_and_matchers = [
    ["⿲木木木","syntax error: extra token(s) in [ ⿲ ✘ 木 ✘ 木木 ]"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      message = CND.remove_colors error[ 'message' ]
      warn JSON.stringify [ probe, message, ]
      T.eq message, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) parse extended formulas (plain)" ] = ( T ) ->
  probes_and_matchers = [
      [ '≈㐀', [ '≈', '㐀', ], ]
      [ '≈𠀎', [ '≈', '𠀎', ], ]
      [ '≈𪜀', [ '≈', '𪜀', ], ]
      [ '≈〇', [ '≈', '〇', ], ]
      [ '●', '●', ]
      [ '〓', '〓', ]
      [ '⿱〓〓', [ '⿱', '〓', '〓' ]]
      [ '▽', '▽', ]
      [ '↻正', [ '↻', '正', ], ]
      [ '↔≈匕', [ '↔', [ '≈', '匕' ] ], ]
      [ '↔正', [ '↔', '正', ], ]
      [ '⿱丶乂', [ '⿱', '丶', '乂', ], ]
      [ '⿺走⿹◰口戈日', [ '⿺', '走', [ '⿹', [ '◰', '口', '戈' ], '日' ] ], ]
      ['≈匚', [ '≈', '匚' ], ]
      ["≈&jzr#xe174;",["≈",""]]
      ['≈非', [ '≈', '非' ], ]
      [ '⿺走⿹◰口〓日', [ '⿺', '走', [ '⿹', [ '◰', '口', '〓' ], '日' ] ], ]
      ["⿻串⿰立&jzr#x1234;",["⿻","串",["⿰","立","ሴ"]]]
      ["⿱丶⿵𠘨§",["⿱","丶",["⿵","𠘨","§"]]]
      # [ '𡦹:⿱丶⿵𠘨§', [ '⿱', '§', '&jzr#xe199;' ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = resume_next T, -> IDLX.parse probe
    urge JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) parse extended formulas (bracketed)" ] = ( T ) ->
  probes_and_matchers = [
    [ '⿰亻聿', [ '⿰', '亻', '聿', ], ]
    [ '(⿰亻聿式)', [ '⿰', '亻', '聿', '式', ], ]
    # [ '(⿱北㓁允)', [ '⿱', '北', '㓁', '允', ], ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # result = resume_next T, -> IDLX.parse probe
    result = IDLX.parse probe
    urge JSON.stringify [ probe, result, ]
    # T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDLX) reject bogus bracketed formulas" ] = ( T ) ->
  probes_and_matchers = [
    [ '(⿰亻聿)', "", ]
    [ '(⿰亻)', "", ]
    [ '(⿰亻)聿', "", ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      message = CND.remove_colors error[ 'message' ]
      warn JSON.stringify [ probe, message, ]
      # T.eq message, matcher
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null '  '
  include = [
    # # "(IDL) demo"
    # "sanity checks (private methods)"
    # "sanity checks (grammar data)"
    # "sanity checks (MKNCR)"
    # #.......................................................................................................
    # "(IDL) parse simple formulas"
    # "(IDL) reject bogus formulas"
    # "(IDL) parse tree of simple formulas"
    # #.......................................................................................................
    # "(IDLX) reject bogus formulas"
    # "(IDLX) reject IDL operators with arity 3"
    # "(IDLX) parse simple formulas"
    # "(IDLX) parse extended formulas (plain)"
    "(IDLX) parse extended formulas (bracketed)"
    # "(IDLX) reject bogus bracketed formulas"
    ]
  @_prune()
  # @_main()

  info IDLX.parse '⿰亻聿'      # [ '⿰', '亻', '聿', ]
  info IDLX.parse '(⿰亻聿式)'   # [ '⿰', '亻', '聿', '式', ]


  demo_errors = ->
    # urge IDL.parse "⿱癶⿰弓貝"
    # help IDL.parse_tree "貝"
    # d = IDL.parse_tree "⿱癶⿰弓貝"
    # d = IDLX.parse_tree "⿺走⿹◰口戈〓"
    # d = IDLX._tokenize null, "⿺走⿹◰口弓戈〓"
    sources = [
      ""
      "⿺"
      "走"
      "走⿹◰口弓戈〓"
      "⿺走x"
      "⿺走⿹◰口弓戈〓"
      ]
    for source in sources
      try
        d = IDLX.parse_tree source
      catch error
        info error[ 'message' ]
  # demo_errors()
  # prototype = {}
  # prototype.x = 42
  # d = Object.create prototype
  # d.y = 'helo'
  # debug d
  # debug 'x' of d
  # debug 'y' of d
  # debug '30201', IDLX.parse '⿻串⿰立&jzr#x1234;' # [ '⿻', '串', [ '⿰', '立', '&jzr#x1234;' ] ], ]
  # debug '30201', IDLX.parse "⿱丶⿵𠘨§" #,["⿱","丶",["⿵","𠘨","§"]]

###


use PipeDreams tap to implement benchmarks

detect bogus occurrences of solitaires in non-minimal formulas

remove stack and other unused properties of _new_parse

implement brackets

###











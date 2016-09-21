



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
# TESTS (IDL)
#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) demo" ] = ( T ) ->
  sources = [
    '木'
    '⿲木木木'
    '⿱癶⿰弓貝'
    '⿱⿰亻式貝'
    '⿱⿰亻式⿱目八'
    '⿺辶言'
    # '⿱⿰亻式⿱目八木木木'
    # '⿺廴聿123'
    ]
  for source in sources
    help source
    p = IDL.parse source
    urge JSON.stringify p
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(IDL) sanity checks (private methods)" ] = ( T ) ->
  probes_and_matchers = [
    ["木",["assigned","ideograph","cjk","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"]]
    ["⿲",["assigned","cjk","idl"]]
    ["a",["assigned"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDL._tags_from_symbol  null, probe
    help JSON.stringify [ probe, result, ]
    T.eq result, matcher

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
    ["⿲木木木",'']
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


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null '  '
  include = [
    # "(IDL) demo"
    "(IDL) sanity checks (private methods)"
    "(IDL) parse simple formulas"
    "(IDL) reject bogus formulas"
    "(IDLX) parse simple formulas"
    "(IDLX) reject bogus formulas"
    "(IDLX) reject IDL operators with arity 3"
    ]
  @_prune()
  @_main()


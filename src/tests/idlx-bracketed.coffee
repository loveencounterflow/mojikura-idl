



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
TAP                       = require 'tap'
{ IDL, IDLX, }            = require '../..'


#===========================================================================================================
# TESTS (IDLX)
#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) parse bracketed formulas", ( T ) ->
  probes_and_matchers = [
    # ["⿱㽞一",["⿱","㽞","一"]]
    # ["⿱刀口",["⿱","刀","口"]]
    ["(⿱(⿰亻聿式)一口)",["⿱",["⿰","亻","聿","式"],"一","口"]]
    ["(⿱㽞一口)",["⿱","㽞","一","口"]]
    ["(⿰亻聿式刀口乙)",["⿰","亻","聿","式","刀","口","乙"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    # result = resume_next T, -> IDLX.parse probe
    result = IDLX.parse probe
    urge ( CND.truth CND.equals result, matcher ), JSON.stringify [ probe, result, ]
    # urge ( rpr probe ), result
    T.ok CND.equals result, matcher
    # T.ok true
  #.........................................................................................................
  T.end()
  return null

###
#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) reject bogus formulas", ( T ) ->
  probes_and_matchers = [
    ["⿲木木木","invalid syntax at index 0 (⿲木木木)\nUnexpected \"⿲\"\n"]
    ["木","invalid syntax at index 0 (木)\nUnexpected \"木\"\n"]
    [42,"expected a text, got a number"]
    ["","expected a non-empty text, got an empty text"]
    ["⿱⿰亻式⿱目八木木木","invalid syntax at index 7 (⿱⿰亻式⿱目八木木木)\nUnexpected \"木\"\n"]
    ["⿺廴聿123","invalid syntax at index 3 (⿺廴聿123)\nUnexpected \"1\"\n"]
    ["⿺","Syntax Error: '⿺'"]
    ["⿺⿺⿺⿺","Syntax Error: '⿺⿺⿺⿺'"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = IDLX.parse probe
      debug ( rpr probe ), ( rpr result )
      warn "expected an exception, got result #{rpr result}"
      T.fail "expected an exception, got result #{rpr result}"
    catch error
      { message, } = error
      urge JSON.stringify [ probe, message, ]
     T.ok CND.equals message, matcher
  #.........................................................................................................
  T.end()
  return null
###



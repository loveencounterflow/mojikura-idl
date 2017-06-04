



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
TAP.test "(IDLX) bracketed formulas (simple)", ( T ) ->
  probes_and_matchers = [
    ["(⿰亻聿式)",["⿰","亻","聿","式"]]
    ["(⿱北㓁允)",["⿱","北","㓁","允"]]
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

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) bracketed formulas (advanced)", ( T ) ->
  probes_and_matchers = [
    ["(⿱&jzr#xe223;一八⿰(⿱&jzr#xe223;一八)(⿱&jzr#xe223;一八))",["⿱","","一","八",["⿰",["⿱","","一","八"],["⿱","","一","八"]]]]
    ["(⿱(⿰亻聿式)一口)",["⿱",["⿰","亻","聿","式"],"一","口"]]
    ["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))",["⿹","弓",["⿰",["⿱","人","人","丨"],["⿱","人","人","丨"],["⿱","人","人","丨"]]]]
    ["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))",["⿹","弓",["⿰",["⿱","人","人","丨"],["⿱","人","人","丨"],["⿱","人","人","丨"]]]]
    ["⿰臣(⿱𠂉(⿰人人人)(⿰古古古))",["⿰","臣",["⿱","𠂉",["⿰","人","人","人"],["⿰","古","古","古"]]]]
    ["(⿱屮(⿰屮屮屮)一(⿰𠂈屮又))",["⿱","屮",["⿰","屮","屮","屮"],"一",["⿰","𠂈","屮","又"]]]
    ["⿱(⿰車(⿱爫龴⿵冂厶)車)(⿰田⿵冂乂田)",["⿱",["⿰","車",["⿱","爫","龴",["⿵","冂","厶"]],"車"],["⿰","田",["⿵","冂","乂"],"田"]]]
    ["(⿰阝(⿸𠂆虍人)(⿸𠂆虍人))",["⿰","阝",["⿸","𠂆","虍","人"],["⿸","𠂆","虍","人"]]]
    ["⿰阝(⿱山人儿⿰(⿱山人儿)(⿱山人儿))",["⿰","阝",["⿱","山","人","儿",["⿰",["⿱","山","人","儿"],["⿱","山","人","儿"]]]]]
    ["⿰阜(⿱山介⿰(⿱山人几)(⿱山人几))",["⿰","阜",["⿱","山","介",["⿰",["⿱","山","人","几"],["⿱","山","人","几"]]]]]
    ["(⿱厶(⿰刃工刃)一(⿰丶丶丶)口)",["⿱","厶",["⿰","刃","工","刃"],"一",["⿰","丶","丶","丶"],"口"]]
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
#     ["()","IDLX: unexpected right bracket [ ( ✘ ) ✘  ]"]
#     ["(⿰)","IDLX: too few constituents [ (⿰ ✘ ) ✘  ]"]
#     ["(聿)","IDL: extra token(s) [ (聿 ✘ ) ✘  ]"]
#     [")","IDLX: unexpected right bracket [  ✘ ) ✘  ]"]
#     ["⿰)","IDLX: unexpected right bracket [ ⿰ ✘ ) ✘  ]"]
#     ["聿)","IDL: extra token(s) [ 聿 ✘ ) ✘  ]"]
#     ["(⿰亻聿)","IDLX: too few constituents [ (⿰亻聿 ✘ ) ✘  ]"]
#     ["(⿰亻)","IDLX: too few constituents [ (⿰亻 ✘ ) ✘  ]"]
#     ["(⿰亻)聿","IDLX: too few constituents [ (⿰亻 ✘ ) ✘ 聿 ]"]
#     ["(≈北㓁)","IDLX: cannot bracket unary operator [ ( ✘ ≈ ✘ 北㓁) ]"]
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
###



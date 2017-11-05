



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/TESTS/SILHOUETTES'
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
{ IDLX, }                 = require '../..'


#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) silhouettes", ( T ) ->
  probes_and_matchers = [
    ["⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","ooo..o..oo..o.."]
    ["⿱⿰⿵&#123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","ooo..o..oo..o.."]
    ["⿱⿰⿵&#x123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","ooo..o..oo..o.."]
    ["⿱⿰⿵&jzr#123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","ooo..o..oo..o.."]
    ["⿱⿰⿵&jzr#x123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","ooo..o..oo..o.."]
    ["鐓:(⿰金(⿱亠口子)夊)","..(o.(o...).)"]
    ["敦:⿰(⿱亠口子)夊","..o(o...)."]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDLX.silhouette_from_formula probe
    # debug JSON.stringify [ probe, result, ]
    T.ok result == matcher
  T.end()









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


#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) solitaires", ( T ) ->
  probes_and_matchers = [
    [ '↻', 'operator',  ]
    [ '〓', 'proxy',     ]
    [ '§', 'proxy',     ]
    [ '⿰', 'operator',  ]
    [ '⿻', 'operator',  ]
    [ '◰', 'operator',  ]
    [ '(', 'bracket',   ]
    [ 'x', 'other',     ]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    result = IDLX.type_from_literal probe
    urge ( CND.truth CND.equals result, matcher ), JSON.stringify [ probe, result, ]
    T.ok CND.equals result, matcher
  #.........................................................................................................
  T.end()
  return null






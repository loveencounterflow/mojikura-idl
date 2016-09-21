



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL'
badge                     = 'MOJIKURA-IDL/IDLX'
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
MKNCR                     = require 'mingkwai-ncr'
O                         = require './options'
IDL                       = require './idl'

############################################################################################################
module.exports = IDLX = Object.assign {}, ( CND.deep_copy IDL )

# debug '34100', IDL.grammar is IDLX.grammar
# debug '34100', IDL.grammar.operators is IDLX.grammar.operators
# debug '34100', CND.equals IDL.grammar, IDLX.grammar
# debug '34100', CND.equals IDL.grammar.operators, IDLX.grammar.operators
# debug '34100', IDLX.grammar.operators


#===========================================================================================================
# GRAMMAR
#-----------------------------------------------------------------------------------------------------------
@grammar = O.idlx


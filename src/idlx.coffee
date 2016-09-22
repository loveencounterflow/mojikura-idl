



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

#===========================================================================================================
# GRAMMAR
#-----------------------------------------------------------------------------------------------------------
@grammar = O.idlx


#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@_symbol_is_solitaire   = ( me, symbol ) -> symbol of @grammar.solitaires
@_symbol_is_proxy       = ( me, symbol ) -> symbol of @grammar.proxies
# @_symbol_is_lbracket    = ( me, symbol ) -> symbol of @grammar.lbrackets
# @_symbol_is_rbracket    = ( me, symbol ) -> symbol of @grammar.rbrackets

#-----------------------------------------------------------------------------------------------------------
@_type_of_symbol = ( me, symbol ) ->
  R = IDL._type_of_symbol.call IDLX, me, symbol
  return 'solitaire'  if @_symbol_is_solitaire  me, symbol
  return 'proxy'      if @_symbol_is_proxy      me, symbol
  # return 'lbracket'   if @_symbol_is_lbracket   me, symbol
  # return 'rbracket'   if @_symbol_is_rbracket   me, symbol
  return R


#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@_parse_tree = ( me, R = null ) ->
  token     = me.tokens[ me.idx ]
  throw new Error "syntax error (premature end of source #{rpr me.source})" unless token?
  me.idx   += +1
  target    = null
  arity     = null
  #.........................................................................................................
  switch type = token.t
    #.......................................................................................................
    when 'operator'
      arity   = token.a
      target  = [ token, ]
      for count in [ 1 .. arity ] by +1
        @_parse_tree me, target
      if R? then  R.push target
      else        R = target
    #.......................................................................................................
    when 'component', 'solitaire', 'proxy'
      if R? then  R.push token
      else        R = token
    #.......................................................................................................
    else
      throw new Error "unable to parse token of type #{rpr type} (token idx #{me.idx} of #{rpr me.source})"
  #.........................................................................................................
  return R


############################################################################################################
### Poor Man's MultiMix: ###
module.exports = IDLX = Object.assign ( CND.deep_copy IDL ), @

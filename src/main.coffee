


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL'
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


#===========================================================================================================
# PARSE
#-----------------------------------------------------------------------------------------------------------
@_new_parse = ( source ) ->
  R =
   '~isa':    'MOJIKURA/IDL/parse'
   grammar:   O.idl
   source:    source
   stack:     []
   idx:       0
  R.tokens = @_tokenize R, source
  return R


#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@_tokenize = ( me, source ) ->
  R       = []
  chrs    = MKNCR.chrs_from_text source
  cu_idx  = 0
  for symbol in chrs
    R.push @_new_token me, symbol, cu_idx
    ### we're counting JS code units here ###
    cu_idx += symbol.length
  return R

#-----------------------------------------------------------------------------------------------------------
@_new_token = ( me, symbol, cu_idx ) ->
  type  = @_type_of_symbol me, symbol
  ### `t` for 'type' ###
  R     = { s: symbol, idx: cu_idx, t: type, }
  switch type
    when 'operator'
      operator  = @_operator_from_symbol me, symbol
      R.a       = operator.arity
      R.n       = operator.name
  return R

#-----------------------------------------------------------------------------------------------------------
@_operator_from_symbol = ( me, symbol ) ->
  unless ( R = me.grammar.operators[ symbol ] )?
    throw new Error "symbol not known to be an operator: #{rpr symbol}"
  return R

#-----------------------------------------------------------------------------------------------------------
@_symbol_is_operator    = ( me, symbol ) -> symbol of me.grammar.operators
@_symbol_is_component   = ( me, symbol ) -> 'cjk' in ( ( MKNCR.describe symbol ).tag ? [] )
# @_symbol_is_lbracket    = ( me, symbol ) -> symbol of me.lbrackets
# @_symbol_is_rbracket    = ( me, symbol ) -> symbol of me.rbrackets

#-----------------------------------------------------------------------------------------------------------
@_type_of_symbol = ( me, symbol ) ->
  return 'operator'   if @_symbol_is_operator   me, symbol
  return 'component'  if @_symbol_is_component  me, symbol
  # return 'lbracket'   if @_symbol_is_lbracket   me, symbol
  # return 'rbracket'   if @_symbol_is_rbracket   me, symbol
  return 'other'


#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@parse = ( source ) ->
  return @_parse @as_csl source

#-----------------------------------------------------------------------------------------------------------
@_parse = ( csl ) ->
  return csl.s unless CND.isa_list csl
  R = []
  for token in csl
    R.push @_parse token
  return R

#-----------------------------------------------------------------------------------------------------------
@as_csl = ( source ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of source ) is 'text'
  throw new Error "syntax error (empty text)" unless source.length > 0
  me  = @_new_parse source
  R   = @_as_csl    me
  unless me.idx is me.tokens.length
    throw new Error "syntax error (token idx #{me.idx} of #{rpr me.source})"
  return R

#-----------------------------------------------------------------------------------------------------------
@_as_csl = ( me, R = null ) ->
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
        @_as_csl me, target
      if R? then  R.push target
      else        R = target
    #.......................................................................................................
    when 'component'
      if R? then  R.push token
      else        R = token
    #.......................................................................................................
    else
      throw new Error "unable to parse token of type #{type} (token idx #{me.idx} of #{rpr me.source})"
  #.........................................................................................................
  return R



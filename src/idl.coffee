


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/IDL'
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
# GRAMMAR
#-----------------------------------------------------------------------------------------------------------
@grammar = O.idl

#===========================================================================================================
# PARSE
#-----------------------------------------------------------------------------------------------------------
@_new_parse = ( source ) ->
  R =
   '~isa':    'MOJIKURA-IDL/parse'
   source:    source
   stack:     []
   idx:       0
  R.tokens = @_tokenize R, source
  return R

#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@tokenize = ( source ) -> ( @_new_parse source ).tokens

#-----------------------------------------------------------------------------------------------------------
@_tokenize = ( me, source ) ->
  R       = []
  chrs    = MKNCR.chrs_from_text source
  for symbol, idx in chrs
    R.push @_new_token me, symbol, idx
  return R

#-----------------------------------------------------------------------------------------------------------
@_new_token = ( me, symbol, idx ) ->
  type    = @_type_of_symbol me, symbol
  symbol  = MKNCR.jzr_as_uchr symbol
  ### `t` for 'type' ###
  R       = { '~isa': 'MOJIKURA-IDL/token', s: symbol, idx, t: type, }
  #.........................................................................................................
  switch type
    when 'operator'
      operator  = @_operator_from_symbol me, symbol
      R.a       = operator.arity
      R.n       = operator.name
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_isa_token = ( x ) -> CND.isa x, 'MOJIKURA-IDL/token'

#-----------------------------------------------------------------------------------------------------------
@_operator_from_symbol = ( me, symbol ) ->
  unless ( R = @grammar.operators[ symbol ] )?
    throw new Error "unknown operator #{rpr symbol}"
  return R

#-----------------------------------------------------------------------------------------------------------
@_describe_symbol       = ( me, symbol ) -> MKNCR.describe symbol
@_tags_from_symbol      = ( me, symbol ) -> ( @_describe_symbol me, symbol ).tag ? []
@_symbol_is_operator    = ( me, symbol ) -> symbol of @grammar.operators
@_symbol_is_component   = ( me, symbol ) -> 'cjk' in @_tags_from_symbol me, symbol

#-----------------------------------------------------------------------------------------------------------
@_type_of_symbol = ( me, symbol ) ->
  return 'operator'   if @_symbol_is_operator   me, symbol
  return 'component'  if @_symbol_is_component  me, symbol
  return 'other'


#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@parse = ( source ) ->
  return @_parse @parse_tree source

#-----------------------------------------------------------------------------------------------------------
@_parse = ( element ) ->
  return element.s if @_isa_token element
  return ( @_parse token for token in element )

#-----------------------------------------------------------------------------------------------------------
@_rpr_tokens = ( me, error_idx = null ) ->
  error_idx  ?= me.idx
  R           = []
  for token, idx in me.tokens
    R.push if idx is error_idx then CND.red " ✘ #{token.s} ✘ " else CND.white "#{token.s}"
  offending_token.error = yes if ( offending_token = me.tokens[ error_idx ] )?
  return CND.white "[ #{R.join ''} ]"

#-----------------------------------------------------------------------------------------------------------
@parse_tree = ( source ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of source ) is 'text'
  throw new Error "syntax error: empty text" unless source.length > 0
  me  = @_new_parse   source
  R   = @_parse_tree  me
  #.........................................................................................................
  if me.idx isnt me.tokens.length
    tokens_txt = @_rpr_tokens me
    throw new Error "syntax error: extra token(s) in #{tokens_txt}"
  #.........................................................................................................
  if ( me.tokens.length is 1 ) and ( ( type = me.tokens[ 0 ].t ) in [ 'other', 'component', ] )
    tokens_txt = @_rpr_tokens me, 0
    throw new Error "syntax error: lone token of type #{rpr type} in #{tokens_txt}"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_parse_tree = ( me, R = null ) ->
  token     = me.tokens[ me.idx ]
  unless token?
    tokens_txt = @_rpr_tokens me, me.idx - 1
    throw new Error "syntax error: premature end of source in #{tokens_txt})"
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
    when 'component'
      if R? then  R.push token
      else        R = token
    #.......................................................................................................
    else
      tokens_txt = @_rpr_tokens me, me.idx - 1
      throw new Error "syntax error: illegal token #{rpr token.s} (type #{rpr type}) in #{tokens_txt}"
  #.........................................................................................................
  return R


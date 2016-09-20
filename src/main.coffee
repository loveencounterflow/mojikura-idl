


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA/IDL'
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
  me  = @_new_parse source
  R   = @_parse me
  return R

#-----------------------------------------------------------------------------------------------------------
@_parse = ( me, R = null ) ->
  R              ?= []
  token           = me.tokens[ me.idx ]
  me.idx         += +1
  # argument_count  = 0
  operator_count  = 0
  target          = null
  arity           = null
  debug '30211', token
  switch type = token.t
    when 'operator'
      operator_count += +1
      arity           = token.a
      target          = [ token, ]
      R.push target
      for count in [ 1 .. arity ] by +1
        @_parse me, target
    when 'component'
      R.push token
    else
      throw new Error """unable to parse token of type #{type}\n#{me.source}\n#{idx}"""
  return R


#===========================================================================================================
# DEMO
#-----------------------------------------------------------------------------------------------------------
@demo = ->
  sources = [
    '⿲木木木'
    '⿱癶⿰弓貝'
    '⿱⿰亻式貝'
    '⿱⿰亻式⿱目八'
    # '⿺辶言'
    # '⿺廴聿123'
    ]
  for source in sources
    help source
    p = @parse source
    urge '\n' + rpr p
    # break
    # for token in tokens
    #   nfo             = MKNCR.describe token
    #   tags            = nfo.tag ? []
    #   tags_txt        = tags.join ' '
    #   operator_nfo    = O.idl.operators[ token ] ? null
    #   is_cjk          = 'cjk' in tags
    #   is_ideograph    = 'ideograph' in tags
    #   name            = null
    #   arity           = null
    #   if ( is_idl = operator_nfo? )
    #     { name, arity, }  = operator_nfo
    #     color             = CND.grey
    #   if is_cjk         then color = CND.gold
    #   if is_ideograph   then color = CND.lime
    #   if is_idl         then color = CND.pink
    #   help ( color token ), ( CND.white name, arity )


############################################################################################################
unless module.parent?
  @demo()

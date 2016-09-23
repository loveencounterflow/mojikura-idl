



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
@_symbol_is_lbracket    = ( me, symbol ) -> @grammar.brackets[ symbol ]?.name is 'lbracket'
@_symbol_is_rbracket    = ( me, symbol ) -> @grammar.brackets[ symbol ]?.name is 'rbracket'

#-----------------------------------------------------------------------------------------------------------
@_type_of_symbol = ( me, symbol ) ->
  R = IDL._type_of_symbol.call IDLX, me, symbol
  return 'solitaire'  if @_symbol_is_solitaire  me, symbol
  return 'proxy'      if @_symbol_is_proxy      me, symbol
  return 'lbracket'   if @_symbol_is_lbracket   me, symbol
  return 'rbracket'   if @_symbol_is_rbracket   me, symbol
  return R

#-----------------------------------------------------------------------------------------------------------
@_token_is_rbracket     = ( x ) -> ( @_isa_token x ) and x.t is 'rbracket'
@_token_is_constituent  = ( x ) -> ( @_isa_token x ) and x.t in [ 'component', 'proxy', ]

#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@_get_next_token = ( me, mode ) ->
  R = me.tokens[ me.idx ]
  unless R?
    tokens_txt = @_rpr_tokens me, me.idx - 1
    throw new Error "syntax error: premature end of source in #{tokens_txt})"
  @_advance me unless mode is 'peek'
  return R

#-----------------------------------------------------------------------------------------------------------
@_peek_next_token = ( me ) -> @_get_next_token me, 'peek'
@_advance         = ( me ) -> me.idx += +1
@_try_to_advance  = ( me ) -> me.idx += +1 if me.idx < me.tokens.length - 1

#-----------------------------------------------------------------------------------------------------------
@_parse_tree = ( me, R = null ) ->
  advance = false
  # stay_in_outer_loop = no
  #.........................................................................................................
  loop
    token     = @_get_next_token me
    target    = null
    arity     = null
    switch type = token.t
      #.......................................................................................................
      when 'lbracket'
        advance = yes
        continue
      #.......................................................................................................
      when 'rbracket'
        R = token
        throw new Error "MEH"
      #.......................................................................................................
      when 'operator'
        #.....................................................................................................
        if advance
          target = [ token, ]
          #...................................................................................................
          loop
            next_token = @_peek_next_token me
            if @_token_is_rbracket next_token
              @_advance me
              break
            else if @_token_is_constituent next_token
              target.push next_token
              @_advance me
            else
              target.push @_parse_tree me
        #.....................................................................................................
        else
          arity   = token.a
          target  = [ token, ]
          for count in [ 1 .. arity ] by +1
            @_parse_tree me, target
        #.....................................................................................................
        if R? then  R.push target
        else        R = target
      #.......................................................................................................
      when 'component', 'solitaire', 'proxy'
        if R? then  R.push token
        else        R = token
      #.......................................................................................................
      else
        tokens_txt = @_rpr_tokens me, me.idx - 1
        throw new Error "syntax error: illegal token #{rpr token.s} (type #{rpr type}) in #{tokens_txt}"
    break
  #.........................................................................................................
  return R


############################################################################################################
### Poor Man's MultiMix: ###
module.exports = IDLX = Object.assign ( CND.deep_copy IDL ), @

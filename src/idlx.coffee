



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
#
#-----------------------------------------------------------------------------------------------------------
@_parser_settings = O.idlx


#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@_lexeme_is_solitaire   = ( me, lexeme ) -> lexeme of me.settings.solitaires
@_lexeme_is_proxy       = ( me, lexeme ) -> lexeme of me.settings.proxies
@_lexeme_is_lbracket    = ( me, lexeme ) -> me.settings.brackets[ lexeme ]?.name is 'lbracket'
@_lexeme_is_rbracket    = ( me, lexeme ) -> me.settings.brackets[ lexeme ]?.name is 'rbracket'

#-----------------------------------------------------------------------------------------------------------
@_type_of_lexeme = ( me, lexeme ) ->
  R = IDL._type_of_lexeme.call IDLX, me, lexeme
  return 'solitaire'  if @_lexeme_is_solitaire  me, lexeme
  return 'proxy'      if @_lexeme_is_proxy      me, lexeme
  return 'lbracket'   if @_lexeme_is_lbracket   me, lexeme
  return 'rbracket'   if @_lexeme_is_rbracket   me, lexeme
  return R

#-----------------------------------------------------------------------------------------------------------
@_token_is_rbracket     = ( me, x ) -> ( @_isa_token me, x ) and x.t is 'rbracket'
@_token_is_constituent  = ( me, x ) -> ( @_isa_token me, x ) and x.t in [ 'component', 'proxy', ]

#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@_get_next_token = ( me, mode ) ->
  R = me.tokenlist[ me.idx ]
  unless R?
    @_err me, me.idx - 1, "IDLX: premature end of source"
  @_advance me unless mode is 'peek'
  return R

#-----------------------------------------------------------------------------------------------------------
@_peek_next_token = ( me ) -> @_get_next_token me, 'peek'
@_advance         = ( me ) -> me.idx += +1
@_try_to_advance  = ( me ) -> me.idx += +1 if me.idx < me.tokenlist.length - 1

#-----------------------------------------------------------------------------------------------------------
@_build_tokentree = ( me, R = null ) ->
  advance = false
  #.........................................................................................................
  loop
    token     = @_get_next_token me
    target    = null
    arity     = null
    switch type = token.t
      #.....................................................................................................
      when 'lbracket'
        advance = yes
        continue
      #.....................................................................................................
      when 'rbracket'
        @_err me, me.idx - 1, "IDLX: unexpected right bracket"
      #.....................................................................................................
      when 'operator'
        #...................................................................................................
        if advance
          unless token.a > 1
            @_err me, me.idx - 1, "IDLX: cannot bracket unary operator"
          target = [ token, ]
          #.................................................................................................
          loop
            next_token = @_peek_next_token me
            if @_token_is_rbracket me, next_token
              unless target.length - 1 > token.a
                @_err me, me.idx, "IDLX: too few constituents"
              @_advance me
              break
            else if @_token_is_constituent me, next_token
              target.push next_token
              @_advance me
            else
              target.push @_build_tokentree me
        #...................................................................................................
        else
          arity   = token.a
          target  = [ token, ]
          for count in [ 1 .. arity ] by +1
            @_build_tokentree me, target
        #...................................................................................................
        if R? then  R.push target
        else        R = target
      #.....................................................................................................
      when 'component', 'solitaire', 'proxy'
        if ( type is 'solitaire' ) and ( ( me.idx isnt 1 ) or ( me.tokenlist.length > 1 ) )
          @_err me, me.idx - 1, "IDLX: cannot have a solitaire here"
        if R? then  R.push token
        else        R = token
      #.....................................................................................................
      else
        @_err me, me.idx - 1, "IDLX: illegal token #{rpr token.s} (type #{rpr type})"
    break
  #.........................................................................................................
  return R


############################################################################################################
### Poor Man's MultiMix: ###
module.exports = IDLX = Object.assign ( CND.deep_copy IDL ), @




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
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_err = ( me, idx, message ) ->
  ### Format error message with colors and token hiliting. ###
  tokens_txt = @_rpr_tokens me, idx
  throw new Error "#{message} #{tokens_txt}"


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
### Parser settings contain lists of operators with symbolic names, arity and so on. ###
@_parser_settings = O.idl

#-----------------------------------------------------------------------------------------------------------
@_new_ctx = ( source ) ->
  R =
    '~isa':     'MOJIKURA-IDL/ctx'
    source:     source
    idx:        0
    settings:   @_parser_settings
    tokens:     null
    tokentree:  null
    diagram:    null
  return R


#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@_get_tokenlist = ( me ) ->
  R         = []
  chrs      = MKNCR.chrs_from_text me.source
  for lexeme, idx in chrs
    R.push @_new_token me, lexeme, idx
  me.tokens = R
  return R

#-----------------------------------------------------------------------------------------------------------
@_new_token = ( me, lexeme, idx ) ->
  type    = @_type_of_lexeme me, lexeme
  lexeme  = MKNCR.jzr_as_uchr lexeme
  ### `t` for 'type' ###
  R       = { '~isa': 'MOJIKURA-IDL/token', s: lexeme, idx, t: type, }
  #.........................................................................................................
  switch type
    when 'operator'
      operator  = @_operator_from_lexeme me, lexeme
      R.a       = operator.arity
      R.n       = operator.name
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_isa_token = ( me, x ) -> CND.isa x, 'MOJIKURA-IDL/token'

#-----------------------------------------------------------------------------------------------------------
@_rpr_tokens = ( me, error_idx = null ) ->
  error_idx  ?= me.idx
  R           = []
  for token, idx in me.tokens
    R.push if idx is error_idx then CND.red " ✘ #{token.s} ✘ " else CND.white "#{token.s}"
  return CND.white "[ #{R.join ''} ]"

#-----------------------------------------------------------------------------------------------------------
@_operator_from_lexeme = ( me, lexeme ) ->
  unless ( R = me.settings.operators[ lexeme ] )?
    throw new Error "unknown operator #{rpr lexeme}"
  return R

#-----------------------------------------------------------------------------------------------------------
@_describe_lexeme       = ( me, lexeme ) -> MKNCR.describe lexeme
@_tags_from_lexeme      = ( me, lexeme ) -> ( @_describe_lexeme me, lexeme ).tag ? []
@_lexeme_is_operator    = ( me, lexeme ) -> lexeme of me.settings.operators
@_lexeme_is_component   = ( me, lexeme ) -> 'cjk' in @_tags_from_lexeme me, lexeme

#-----------------------------------------------------------------------------------------------------------
@_type_of_lexeme = ( me, lexeme ) ->
  return 'operator'   if @_lexeme_is_operator   me, lexeme
  return 'component'  if @_lexeme_is_component  me, lexeme
  return 'other'


#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@_diagram_from_tokentree = ( tokentree ) ->
  ### A 'diagram' is a 'lexeme tree', i.e. the simplified version of a token tree, minus all the
  additional data, leaving just nested lists of lexemes. ###
  return tokentree.s if @_isa_token null, tokentree
  return ( @_diagram_from_tokentree token for token in tokentree )

#-----------------------------------------------------------------------------------------------------------
@_get_tokentree = ( me ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of me.source ) is 'text'
  throw new Error "IDL: empty text" unless me.source.length > 0
  # me      = @_new_ctx         me.source
  tokens  = @_get_tokenlist   me
  R       = @_build_tokentree me
  #.........................................................................................................
  if me.idx isnt me.tokens.length
    @_err me, me.idx, "IDL: extra token(s)"
  #.........................................................................................................
  if ( me.tokens.length is 1 ) and ( ( type = me.tokens[ 0 ].t ) in [ 'other', 'component', ] )
    @_err me, 0, "IDL: lone token of type #{rpr type}"
  #.........................................................................................................
  me.tokentree = R
  return R

#-----------------------------------------------------------------------------------------------------------
@_build_tokentree = ( me, R = null ) ->
  token     = me.tokens[ me.idx ]
  unless token?
    @_err me, me.idx - 1, "IDL: premature end of source"
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
        @_build_tokentree me, target
      if R? then  R.push target
      else        R = target
    #.......................................................................................................
    when 'component'
      if R? then  R.push token
      else        R = token
    #.......................................................................................................
    else
      @_err me, me.idx - 1, "IDL: illegal token #{rpr token.s} (type #{rpr type})"
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@_tokentree_as_text = ( me, parse_tree ) ->
  R = []
  for element in parse_tree
    if @_isa_token me, element
      R.push element.s
    else
      R.push @_tokentree_as_text me, element
  #.........................................................................................................
  return R.join ''


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@diagram_from_source    = ( source ) -> @_diagram_from_tokentree  @tokentree_from_source  source
@tokenlist_from_source  = ( source ) -> @_get_tokenlist           @_new_ctx               source
@tokentree_from_source  = ( source ) -> @_get_tokentree           @_new_ctx               source

#-----------------------------------------------------------------------------------------------------------
@parse = ( source ) ->
  R = @_new_ctx source
  @_get_tokenlist      R
  @_get_tokentree R
  return R



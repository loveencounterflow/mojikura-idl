


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
O                         = require './options'

#===========================================================================================================
# COMPATIBILITY WITH MKNCR
#-----------------------------------------------------------------------------------------------------------
@NCR = Object.create require 'ncr'
@NCR._input_default = 'xncr'
@NCR.jzr_as_uchr = ( glyph ) ->
  # return @as_uchr glyph, input: 'xncr' if ( @as_csg glyph, input: 'xncr' ) is 'jzr'
  return @as_uchr glyph if ( @as_csg glyph ) is 'jzr'
  return glyph

#-----------------------------------------------------------------------------------------------------------
@NCR.jzr_as_xncr = ( glyph ) ->
  # nfo = @analyze glyph, input: 'xncr'
  nfo = @analyze glyph
  return glyph unless ( nfo.rsg is 'u-pua' ) or ( nfo.csg is 'jzr' )
  return @as_chr nfo.cid, { csg: 'jzr', }


#===========================================================================================================
# CONTEXTS
#-----------------------------------------------------------------------------------------------------------
### Parser settings contain lists of operators with symbolic names, arity and so on. ###
@_parser_settings = O.idl

#-----------------------------------------------------------------------------------------------------------
@_new_ctx = ( source ) ->
  ### A context contains the state of the current parsing process. At first, only the `source` property is
  set, then—explicitly by calling a dedicated method or implicitly by calling a dependent method—the
  `tokenlist`, `tokentree` and `diagram` properties are set. In theory, it's possible to intervene e.g.
  after tokenization and correct one or more properties of the context so as to affect the resulting
  diagram. ###
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of source ) is 'text'
  throw new Error "IDL: empty text" unless source.length > 0
  R =
    '~isa':         'MOJIKURA-IDL/ctx'
    source:         source
    idx:            0
    settings:       @_parser_settings
    tokenlist:      null
    tokentree:      null
    diagram:        null
    formula_uchr:   null
    formula_xncr:   null
    sexpr_uchr:     null
    sexpr_xncr:     null
  R.settings.sexpr    = O.sexpr
  R.settings.formula  = O.formula
  return R


#===========================================================================================================
# GETTERS
#-----------------------------------------------------------------------------------------------------------
@_get_tokenlist = ( me ) ->
  return R if ( R = me.tokenlist )?
  R         = []
  # chrs      = @NCR.chrs_from_text me.source, input: 'xncr'
  chrs      = @NCR.chrs_from_text me.source
  for lexeme, idx in chrs
    R.push @_new_token me, lexeme, idx
  #.........................................................................................................
  return me.tokenlist = R

#-----------------------------------------------------------------------------------------------------------
@_get_tokentree = ( me ) ->
  return R if ( R = me.tokentree )?
  @_get_tokenlist me
  R = @_build_tokentree me
  #.........................................................................................................
  if me.idx isnt me.tokenlist.length
    @_err me, me.idx, "IDL: extra token(s)"
  #.........................................................................................................
  ### TAINT review the below condition ###
  if ( me.tokenlist.length is 1 ) and ( ( type = me.tokenlist[ 0 ].t ) is 'component' )
    @_err me, 0, "IDL: lone token of type #{rpr type}"
  #.........................................................................................................
  return me.tokentree = R

#-----------------------------------------------------------------------------------------------------------
@_get_diagram = ( me ) ->
  return R if ( R = me.diagram )?
  @_get_tokentree me
  return me.diagram = @_diagram_from_tokentree me, me.tokentree

#-----------------------------------------------------------------------------------------------------------
@_get_formula = ( me, jzr_mode ) ->
  switch jzr_mode
    when 'uchr'
      return R if ( R = me.formula_uchr )?
      return me.formula_uchr = @_tokentree_as_formula me, ( @_get_tokentree me ), jzr_mode
    when 'xncr'
      return R if ( R = me.formula_xncr )?
      return me.formula_xncr = @_tokentree_as_formula me, ( @_get_tokentree me ), jzr_mode
    else throw new Error "expected 'uchr' or 'xncr' for JZR mode, got #{rpr jzr_mode}"
  return null

#-----------------------------------------------------------------------------------------------------------
@_get_sexpr = ( me, jzr_mode ) ->
  switch jzr_mode
    when 'uchr'
      return R if ( R = me.sexpr_uchr )?
      return me.sexpr_uchr = @_tokentree_as_sexpr me, ( @_get_tokentree me ), jzr_mode
    when 'xncr'
      return R if ( R = me.sexpr_xncr )?
      return me.sexpr_xncr = @_tokentree_as_sexpr me, ( @_get_tokentree me ), jzr_mode
    else throw new Error "expected 'uchr' or 'xncr' for JZR mode, got #{rpr jzr_mode}"
  return null


#===========================================================================================================
# TOKENS
#-----------------------------------------------------------------------------------------------------------
@_new_token = ( me, lexeme, idx ) ->
  type    = @_type_of_lexeme me, lexeme
  ### PLAIN-IDL
  null
  ###
  lexeme  = @NCR.jzr_as_uchr lexeme
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
@_operator_from_lexeme = ( me, lexeme ) ->
  unless ( R = me.settings.operators[ lexeme ] )?
    throw new Error "unknown operator #{rpr lexeme}"
  return R

#-----------------------------------------------------------------------------------------------------------
@_lexeme_is_operator    = ( me, lexeme ) -> lexeme of me.settings.operators
@_lexeme_is_component   = ( me, lexeme ) -> not @_lexeme_is_operator me, lexeme

#-----------------------------------------------------------------------------------------------------------
@_type_of_lexeme = ( me, lexeme ) ->
  return 'operator'   if @_lexeme_is_operator   me, lexeme
  return 'component'


#===========================================================================================================
# PARSING
#-----------------------------------------------------------------------------------------------------------
@_diagram_from_tokentree = ( me, tokentree ) ->
  ### A 'diagram' is a 'lexeme tree', i.e. the simplified version of a token tree, minus all the
  additional data, leaving just nested lists of lexemes. ###
  return tokentree.s if @_isa_token null, tokentree
  return ( @_diagram_from_tokentree me, token for token in tokentree )

#-----------------------------------------------------------------------------------------------------------
@_build_tokentree = ( me, R = null ) ->
  token     = me.tokenlist[ me.idx ]
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


#===========================================================================================================
# SERIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_token_as_text = ( me, token, jzr_mode ) ->
  ### TAINT this is highly application-specific and shouldn't be here ###
  ### TAINT make output format configurable ###
  ### PLAIN-IDL
  return token.s
  ###
  switch jzr_mode
    when 'uchr' then return @NCR.jzr_as_uchr token.s
    when 'xncr' then return @NCR.jzr_as_xncr token.s
    else throw new Error "expected 'uchr' or 'xncr' for JZR mode, got #{rpr jzr_mode}"
  return null

#-----------------------------------------------------------------------------------------------------------
@_tokentree_as_formula = ( me, tokentree, jzr_mode ) ->
  return ( @_token_as_text me, tokentree, jzr_mode ) if @_isa_token me, tokentree
  R = []
  for element in tokentree
    if @_isa_token me, element then R.push        @_token_as_text me, element, jzr_mode
    else                            R.push @_tokentree_as_formula me, element, jzr_mode
  #.........................................................................................................
  ### TAINT parametrize ###
  has_brackets  = ( tokentree[ 0 ] ).a isnt tokentree.length - 1
  mid           =       me.settings.formula.spacer
  left          =       me.settings.formula.opener + mid
  right         = mid + me.settings.formula.closer
  return left + ( R.join mid ) + right if has_brackets
  return          R.join mid

# #-----------------------------------------------------------------------------------------------------------
# @_token_as_sexpr = ( me, token ) ->
#   return @NCR.jzr_as_xncr token.s

#-----------------------------------------------------------------------------------------------------------
@_tokentree_as_sexpr = ( me, tokentree, jzr_mode, level = 0 ) ->
  mid   =       me.settings.sexpr.spacer
  left  =       me.settings.sexpr.opener + mid
  right = mid + me.settings.sexpr.closer
  if @_isa_token me, tokentree
    R = ( @_token_as_text me, tokentree, jzr_mode )
    R = left + R + right if level is 0
    return R
  R = []
  for element in tokentree
    if @_isa_token me, element then R.push     @_token_as_text  me, element, jzr_mode
    else                            R.push @_tokentree_as_sexpr me, element, jzr_mode, level + 1
  #.........................................................................................................
  return left + ( R.join mid ) + right

#-----------------------------------------------------------------------------------------------------------
@_tokenlist_as_text = ( me, error_idx = null ) ->
  error_idx  ?= me.idx
  R           = []
  for token, idx in me.tokenlist
    R.push if idx is error_idx then CND.red " ✘ #{token.s} ✘ " else CND.white "#{token.s}"
  return CND.white "[ #{R.join ''} ]"


#===========================================================================================================
# TREE-SHAKING
#-----------------------------------------------------------------------------------------------------------
@shake_tree   = -> throw new Error "not implemented for IDL dialect"
@_shake_tree  = -> throw new Error "not implemented for IDL dialect"

#===========================================================================================================
# EXCEPTIONS
#-----------------------------------------------------------------------------------------------------------
@_err = ( me, idx, message ) ->
  ### Format error message with colors and token hiliting. ###
  tokenlist_txt = @_tokenlist_as_text me, idx
  throw new Error "#{message} #{tokenlist_txt}"


#===========================================================================================================
# PUBLIC API
#-----------------------------------------------------------------------------------------------------------
@tokenlist_from_source  = ( source            ) -> @_get_tokenlist @_new_ctx source
@tokentree_from_source  = ( source            ) -> @_get_tokentree @_new_ctx source
@diagram_from_source    = ( source            ) -> @_get_diagram   @_new_ctx source
@formula_from_source    = ( source, jzr_mode  ) -> @_get_formula ( @_new_ctx source ), jzr_mode
@sexpr_from_source      = ( source, jzr_mode  ) -> @_get_sexpr   ( @_new_ctx source ), jzr_mode

#-----------------------------------------------------------------------------------------------------------
@parse = ( source ) ->
  R = @_new_ctx source
  @_get_diagram R
  return R



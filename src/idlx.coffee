



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

#===========================================================================================================
# TREE-SHAKING
#-----------------------------------------------------------------------------------------------------------
@formula_may_be_suboptimal = ( _, formula ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of formula ) is 'text'
  return @_get_treeshaker_litmus().test formula

#-----------------------------------------------------------------------------------------------------------
@shake_tree = ( ctx ) ->
  delete ctx.tokenlist
  delete ctx.diagram
  @_shake_tree ctx.tokentree
  @_get_diagram ctx
  return ctx

#-----------------------------------------------------------------------------------------------------------
@_shake_tree = ( tree ) ->
  # debug '48982', tree
  #.........................................................................................................
  unless ( type = CND.type_of tree ) is 'list'
    throw new Error "expected a list, got a #{type}"
  #.........................................................................................................
  operator_token  = tree[ 0 ]
  #.........................................................................................................
  unless ( type = CND.type_of operator_token ) is 'MOJIKURA-IDL/token'
    throw new Error "expected a MOJIKURA-IDL/token, got a #{type}"
  #.........................................................................................................
  unless ( type = operator_token.t ) is 'operator'
    throw new Error "expected an operator, got a #{type}"
  #.........................................................................................................
  operator_symbol = operator_token.s
  argument_idx    = 0
  #.........................................................................................................
  loop
    argument_idx += +1
    break if argument_idx > tree.length - 1
  # for argument_idx in [ 1 .. last_token_idx ] by +1
    sub_tree = tree[ argument_idx ]
    #.......................................................................................................
    unless ( token_type = CND.type_of sub_tree ) is 'list'
      # debug ( CND.white argument_idx ), ( CND.cyan operator_symbol ), ( CND.yellow sub_tree.s )
      continue
    #.......................................................................................................
    sub_operator_token = sub_tree[ 0 ]
    #.......................................................................................................
    unless ( type = CND.type_of sub_operator_token ) is 'MOJIKURA-IDL/token'
      throw new Error "expected a MOJIKURA-IDL/token, got a #{type}"
    #.......................................................................................................
    unless ( type = sub_operator_token.t ) is 'operator'
      throw new Error "expected an operator, got a #{type}"
    #.......................................................................................................
    sub_operator_symbol = sub_operator_token.s
    # debug argument_idx, operator_symbol, sub_operator_symbol
    if operator_symbol is sub_operator_symbol
      tree[ argument_idx .. argument_idx ] = sub_tree[ 1 .. ]
      # tokenlist.splice ( sub_operator_token.idx + delta ), 1
      argument_idx += -1
      # delta        += +1
      # debug '33392', tree
    else
      @_shake_tree sub_tree
  return null

#-----------------------------------------------------------------------------------------------------------
@_get_treeshaker_litmus = ->
  ### When `@_get_treeshaker_litmus.pattern` matches a formula, it *may* be non-optimal; if the pattern
  does *not* match a formula, there are certainly no opportunities for optimization. The pattern works by
  trying to match sequences like `/...|(?:O[^MNPQ]*O)|(?:P[^MNOQ]*P)|.../`, where `MNOPQ` are the binary
  operators. ###
  return R if ( R = @_get_treeshaker_litmus.pattern )?
  #.........................................................................................................
  binary_operators = []
  for symbol, { arity, } of @_parser_settings.operators
    binary_operators.push symbol if arity is 2
  binary_operators = binary_operators[ .. 3 ]
  # debug '52998', binary_operators
  pattern = []
  for operator in binary_operators
    sub_pattern = []
    sub_pattern.push '[^'
    for sub_operator in binary_operators
      continue if sub_operator is operator
      sub_pattern.push sub_operator
    sub_pattern.push ']*'
    pattern.push '(?:' + operator + ( sub_pattern.join '' ) + operator + ')'
  #.........................................................................................................
  return @_get_treeshaker_litmus.pattern = new RegExp pattern.join '|'
@_get_treeshaker_litmus.pattern = null


############################################################################################################
### Poor Man's MultiMix: ###
module.exports = IDLX = Object.assign ( CND.deep_copy IDL ), @

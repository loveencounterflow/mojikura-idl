

'use strict'


############################################################################################################
PATH                      = require 'path'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'NEARlEY'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
NEARLEY                   = require 'nearley'
IDL_GRAMMAR               = require './idl'
IDLX_GRAMMAR              = require './idlx'
last_of                   = ( x ) -> x[ x.length - 1 ]
{ isa
  type_of
  validate
  equals   }              = require './types'


#===========================================================================================================
# COMPATIBILITY WITH MKNCR
#-----------------------------------------------------------------------------------------------------------
@_NCR = NCR = Object.create require 'ncr-norangereader'
NCR._input_default = 'xncr'
NCR.jzr_as_uchr = ( glyph ) ->
  # return @as_uchr glyph, input: 'xncr' if ( @as_csg glyph, input: 'xncr' ) is 'jzr'
  return @as_uchr glyph if ( @as_csg glyph ) is 'jzr'
  return glyph

#-----------------------------------------------------------------------------------------------------------
NCR.jzr_as_xncr = ( glyph ) ->
  # nfo = @analyze glyph, input: 'xncr'
  nfo = @analyze glyph
  return glyph unless ( nfo.rsg is 'u-pua' ) or ( nfo.csg is 'jzr' )
  return @as_chr nfo.cid, { csg: 'jzr', }


#===========================================================================================================
# LEXER
#-----------------------------------------------------------------------------------------------------------
Idl_lexer = ->
  @reset ''
  return null

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::reset = ( data, state ) ->
  @buffer = NCR.chrs_from_text data, input: 'xncr'
  @index  = 0
  @line   = if state then state.line else 1
  @prv_nl = if state then -state.col else 0
  return null

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::next = ->
  if @index < @buffer.length
    chr     = NCR.jzr_as_uchr @buffer[ @index ]
    @index += +1
    if chr is '\n'
      @line  += +1
      @prv_nl = @index
    # return { value: chr, line: @line, col: @index - @prv_nl, }
    return { value: chr, }
  return null

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::save = ->
  return { line: @line, col: @index - @prv_nl, }

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::formatError = ( token, message ) ->
  R = "#{message} at index #{@index - 1} (#{@buffer.join ''})"
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@IDL = {}

#-----------------------------------------------------------------------------------------------------------
@IDL.parse = ( source ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = type_of source ) is 'text'
  throw new Error "expected a non-empty text, got an empty text" if source.length is 0
  ### TAINT should we rewind()? finish()? parser? ###
  @_parser = new NEARLEY.Parser IDL_GRAMMAR.ParserRules, IDL_GRAMMAR.ParserStart, { lexer: new Idl_lexer(), }
  # @_parser.reset()
  @_parser.feed source
  throw new Error "Syntax Error: #{rpr source}" unless @_parser.results.length is 1
  R = @_parser.results[ 0 ]
  R = R[ 0 ] if R.length is 1
  return R

# #-----------------------------------------------------------------------------------------------------------
# @IDLX = # Object.assign Object.create @IDL

#-----------------------------------------------------------------------------------------------------------
@IDLX = {}

#-----------------------------------------------------------------------------------------------------------
@IDLX.parse = ( source ) ->
  throw new Error "expected a text, got a #{type}" unless ( type = type_of source ) is 'text'
  throw new Error "expected a non-empty text, got an empty text" if source.length is 0
  ### TAINT should we rewind()? finish()? parser? ###
  @_parser = new NEARLEY.Parser IDLX_GRAMMAR.ParserRules, IDLX_GRAMMAR.ParserStart, { lexer: new Idl_lexer(), }
  # @_parser.reset()
  @_parser.feed source
  throw new Error "Syntax Error: #{rpr source}" unless @_parser.results.length is 1
  R = @_parser.results[ 0 ]
  # debug '33398', ( rpr R ), R.length
  R = R[ 0 ] if R.length is 1
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
### TAINT methods in this section should be made available for IDL as well ###

# #-----------------------------------------------------------------------------------------------------------
# @IDLX.get_literals_and_types = => @_get_literals_and_types IDLX_GRAMMAR

#-----------------------------------------------------------------------------------------------------------
@IDLX._get_literals_and_types = ( grammar ) =>
  paths = @IDLX._paths_from_grammar grammar
  return @IDLX._literals_and_types_from_paths paths

#-----------------------------------------------------------------------------------------------------------
@IDLX._literals_and_types_from_paths = ( paths ) =>
  R = {}
  for path in paths
    ### TAINT pattern should allow literal double quotes ###
    unless ( match = path.match /// \+ ( [^ \/ + ]+ ) \+ .* " ( [^ "] ) "  $ /// )
      throw new Error "illegal path #{rpr path}"
    [ _
      type
      literal ]   = match
    R[ literal ]  = type
    # ( R[ type ] ?= [] ).push literal
  return R

#-----------------------------------------------------------------------------------------------------------
@IDLX._paths_from_grammar = ( grammar ) =>
  registry  = @IDLX._registry_from_grammar grammar
  paths     = new Set()
  @IDLX._condense registry, ( new Set() ), paths, grammar.ParserStart
  return Array.from paths

#-----------------------------------------------------------------------------------------------------------
@IDLX._registry_from_grammar = ( grammar ) =>
  R = {}
  for rule in grammar.ParserRules
    { name, symbols, } = rule
    for symbol in symbols
      if isa.object symbol
        symbol = '"' + symbol.literal + '"'
      entry   = R[ symbol ] ?= []
      target  = R[ name   ] ?= []
      target.push symbol
  return R

#-----------------------------------------------------------------------------------------------------------
@IDLX._condense = ( registry, seen, paths, name, route = [] ) =>
  return if seen.has name
  seen. add name
  symbols         = registry[ name ]
  is_public_name  = not /\$/.test name
  route.push name if is_public_name
  for symbol in symbols
    entry = registry[ symbol ]
    if ( entry.length is 0 )
      route.push symbol
      paths.add path unless /// (?: \/\/ ) | (?: \/ $ ) ///.test ( path = route.join '/' )
      route.pop()
    else
      @IDLX._condense registry, seen, paths, symbol, route
  route.pop() if is_public_name
  return null

#-----------------------------------------------------------------------------------------------------------
@IDLX.type_from_literal = ( literal ) => @IDLX.literals_and_types[ literal ] ? 'component'

#-----------------------------------------------------------------------------------------------------------
@IDLX.list_tokens = ( diagram_or_formula, settings ) =>
  switch type = type_of diagram_or_formula
    when 'text' then diagram = @IDLX.parse  diagram_or_formula
    when 'list' then diagram =              diagram_or_formula
    else throw new Error "expected a text or a list, got a #{type} in #{rpr diagram_or_formula}"
  R         = []
  R.i_base  = -1
  R         = @IDLX._list_tokens diagram, R, settings ? {}
  delete R.i_base
  return R

#-----------------------------------------------------------------------------------------------------------
@IDLX._list_tokens = ( diagram, R, settings ) =>
  ### `settings.all_brackets` is needed by `ngrams.get_relational_bigrams_as_tokens` to get brackets
  around all operators. Brackets that are added for binary operators with two arguments and unary
  operators are here called 'epenthetical'; they get no index (`token.i`) and the indices on the
  other tokens are the same as the ones for a formula without epenthetical brackets. ###
  if settings.all_brackets ? no
    is_bracketed    = yes
    is_epenthetical = ( diagram.length <= 3 )
  #.........................................................................................................
  else
    is_bracketed    = ( diagram.length > 3 )
    is_epenthetical = no
  #.........................................................................................................
  if is_bracketed
    if is_epenthetical
      R.push { t: 'lbracket', s: '(', i: null, }
    else
      R.i_base += +1
      R.push { t: 'lbracket', s: '(', i: R.i_base, }
  #.........................................................................................................
  is_first = yes
  for element in diagram
    switch type = type_of element
      when 'text'
        token_type  = @IDLX.type_from_literal element
        # i           = if is_epenthetical
        R.i_base += +1
        R.push { t: token_type, s: element, i: R.i_base, }
      when 'list'
        if is_first
          throw new Error "expected a text as first element of diagram, got a #{type} in #{rpr diagram}"
        @IDLX._list_tokens element, R, settings
      else
        throw new Error "expected a text or a list, got a #{type} in #{rpr diagram}"
    is_first = no
  #.........................................................................................................
  if is_bracketed
    if is_epenthetical
      R.push { t: 'rbracket', s: ')', i: null, }
    else
      R.i_base += +1
      R.push { t: 'rbracket', s: ')', i: R.i_base, }
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@IDLX.get_formula = ( diagram_or_formula ) =>
  ### TAINT possible inputs should be formula, diagram, or tokenlist ###
  return ( literal for { s: literal, } in @IDLX.list_tokens diagram_or_formula ).join ''

#-----------------------------------------------------------------------------------------------------------
@IDLX._text_with_jzr_glyphs_as_uchrs = ( text ) =>
  return ( NCR.jzr_as_uchr glyph for glyph in NCR.chrs_from_text text ).join ''

#-----------------------------------------------------------------------------------------------------------
@IDLX._text_with_jzr_glyphs_as_xncrs = ( text ) =>
  return ( NCR.jzr_as_xncr glyph for glyph in NCR.chrs_from_text text ).join ''


#===========================================================================================================
# TREE-SHAKING
#-----------------------------------------------------------------------------------------------------------
@IDLX.formula_may_be_nonminimal = ( formula ) =>
  throw new Error "expected a text, got a #{type}" unless ( type = type_of formula ) is 'text'
  return @IDLX._get_treeshaker_litmus().test formula

#-----------------------------------------------------------------------------------------------------------
@IDLX.minimize_diagram = ( diagram ) =>
  unless ( type = type_of diagram ) is 'list'
    throw new Error "expected a list, got a #{type} in #{rpr diagram}"
  return @IDLX._shake_tree JSON.parse JSON.stringify diagram

#-----------------------------------------------------------------------------------------------------------
@IDLX.minimize_formula = ( formula ) =>
  unless ( type = type_of formula ) is 'text'
    throw new Error "expected a text, got a #{type} in #{rpr formula}"
  return @IDLX.get_formula @IDLX._shake_tree @IDLX.parse formula

#-----------------------------------------------------------------------------------------------------------
@IDLX._shake_tree = ( diagram ) =>
  unless ( type = type_of diagram ) is 'list'
    throw new Error "expected a list, got a #{type}"
  #.........................................................................................................
  operator = diagram[ 0 ]
  # #.........................................................................................................
  # unless ( type = operator_token.t ) is 'operator'
  #   throw new Error "expected an operator, got a #{type}"
  #.........................................................................................................
  argument_idx = 0
  #.........................................................................................................
  loop
    argument_idx += +1
    break if argument_idx > diagram.length - 1
    sub_tree      = diagram[ argument_idx ]
    continue unless ( type_of sub_tree ) is 'list'
    sub_operator  = sub_tree[ 0 ]
    #.......................................................................................................
    # unless ( type = type_of sub_operator_token ) is 'MOJIKURA-IDL/token'
    #   throw new Error "expected a MOJIKURA-IDL/token, got a #{type}"
    # #.......................................................................................................
    # unless ( type = sub_operator_token.t ) is 'operator'
    #   throw new Error "expected an operator, got a #{type}"
    #.......................................................................................................
    if operator is sub_operator
      diagram[ argument_idx .. argument_idx ] = sub_tree[ 1 .. ]
      argument_idx += -1
    else
      @IDLX._shake_tree sub_tree
  return diagram

#-----------------------------------------------------------------------------------------------------------
@IDLX._get_treeshaker_litmus = =>
  ### When `@IDLX._get_treeshaker_litmus.pattern` matches a formula, it *may* be non-minimal; if the pattern
  does *not* match a formula, there are certainly no opportunities for optimization. The pattern works by
  trying to match sequences like `/...|(?:O[^MNPQ]*O)|(?:P[^MNOQ]*P)|.../`, where `MNOPQ` are the binary
  operators. ###
  return R if ( R = @IDLX._get_treeshaker_litmus.pattern )?
  #.........................................................................................................
  binary_operators = []
  for symbol, token_type of @IDLX.literals_and_types
    binary_operators.push symbol if token_type is 'binary_operator'
  # binary_operators = binary_operators[ .. 3 ]
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
  return @IDLX._get_treeshaker_litmus.pattern = new RegExp pattern.join '|'

############################################################################################################
@IDLX._get_treeshaker_litmus.pattern  = null
@IDLX.literals_and_types              = @IDLX._get_literals_and_types IDLX_GRAMMAR


#===========================================================================================================
# SILHOUTTES, NGRAMS
#-----------------------------------------------------------------------------------------------------------
### NOTE: do not use parametric `require()` as this may throw off browserify (and rightly so) ###
IDLX        = @IDLX
SILHOUETTES = require './silhouettes'
NGRAMS      = require './ngrams'
do ->
  for name, value of SILHOUETTES
    IDLX[ name ] = value
  for name, value of NGRAMS
    IDLX[ name ] = value
  return null


############################################################################################################
unless module.parent?
    #.........................................................................................................
    info @IDLX._get_literals_and_types IDLX_GRAMMAR
    info @IDLX.type_from_literal IDLX_GRAMMAR
    help '↻', @IDLX.type_from_literal '↻' # 'operator',
    help '〓', @IDLX.type_from_literal '〓' # 'proxy',
    help '§', @IDLX.type_from_literal '§' # 'proxy',
    help '⿰', @IDLX.type_from_literal '⿰' # 'operator',
    help '⿻', @IDLX.type_from_literal '⿻' # 'operator',
    help '◰', @IDLX.type_from_literal '◰' # 'operator',
    help '(', @IDLX.type_from_literal '(' # 'bracket',
    help 'x', @IDLX.type_from_literal 'x' # 'other',
    formula       = '⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))'
    whisper formula
    help diagram  = @IDLX.parse formula
    whisper formula
    help tokens   = @IDLX.list_tokens diagram
    urge @IDLX.get_formula formula
    urge @IDLX.get_formula diagram
    urge @IDLX._get_treeshaker_litmus()
    urge ( CND.yellow formula    ), ( CND.blue CND.truth @IDLX.formula_may_be_nonminimal formula    )
    urge ( CND.yellow '⿱⿱𫝀口㐄'    ), ( CND.blue CND.truth @IDLX.formula_may_be_nonminimal '⿱⿱𫝀口㐄'    )
    urge ( CND.yellow '⿱𫝀⿱口㐄'    ), ( CND.blue CND.truth @IDLX.formula_may_be_nonminimal '⿱𫝀⿱口㐄'    )
    urge ( CND.yellow '⿰韋(⿱白大十)' ), ( CND.blue CND.truth @IDLX.formula_may_be_nonminimal '⿰韋(⿱白大十)' )
    info ( CND.yellow formula    ), ( CND.blue @IDLX.minimize_formula formula                       )
    info ( CND.yellow '⿱⿱𫝀口㐄'    ), ( CND.blue @IDLX.minimize_formula '⿱⿱𫝀口㐄'                       )
    info ( CND.yellow '⿱𫝀⿱口㐄'    ), ( CND.blue @IDLX.minimize_formula '⿱𫝀⿱口㐄'                       )
    info ( CND.yellow '⿰韋(⿱白大十)' ), ( CND.blue @IDLX.minimize_formula '⿰韋(⿱白大十)'                    )
    process.exit 1


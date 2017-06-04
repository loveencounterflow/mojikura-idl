

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


#===========================================================================================================
# COMPATIBILITY WITH MKNCR
#-----------------------------------------------------------------------------------------------------------
NCR = Object.create require 'ncr'
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
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of source ) is 'text'
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
  throw new Error "expected a text, got a #{type}" unless ( type = CND.type_of source ) is 'text'
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


condense = ( grammar ) ->
  registry  = _registry_from_grammar grammar
  paths     = new Set()
  _condense registry, ( new Set() ), paths, grammar.ParserStart
  return Array.from paths

_registry_from_grammar = ( grammar ) ->
  R = {}
  for rule in grammar.ParserRules
    { name, symbols, } = rule
    for symbol in symbols
      if CND.isa_pod symbol
        symbol = '"' + symbol.literal + '"'
      entry   = R[ symbol ] ?= []
      target  = R[ name   ] ?= []
      target.push symbol
  return R

_condense = ( registry, seen, paths, name, route = [] ) ->
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
      _condense registry, seen, paths, symbol, route
  route.pop() if is_public_name
  return null

operators_from_paths = ( paths ) ->
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


############################################################################################################
unless module.parent?
    #.........................................................................................................
    paths = condense IDLX_GRAMMAR
    info paths
    help operators_from_paths paths
    process.exit 1


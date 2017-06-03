

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
GRAMMAR                   = require './idl'


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
  debug '3321-1', 'Idl_lexer::reset', Array.from arguments
  @buffer = NCR.chrs_from_text data, input: 'xncr'
  debug '3321-1', @buffer
  @index  = 0
  @line   = if state then state.line else 1
  @prv_nl = if state then -state.col else 0
  return null

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::next = ->
  debug '3321-2', 'Idl_lexer::next', Array.from arguments
  if @index < @buffer.length
    chr     = @buffer[ @index ]
    @index += +1
    if chr is '\n'
      @line  += +1
      @prv_nl = @index
    debug '3321-2', { value: chr, }
    return { value: chr, }
  return null

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::save = ->
  debug '3321-3', 'Idl_lexer::save', Array.from arguments
  return { line: @line, col: @index - @prv_nl, }

#-----------------------------------------------------------------------------------------------------------
Idl_lexer::formatError = ( token, message ) ->
  debug '3321-4', 'Idl_lexer::formatError', Array.from arguments
  R = "#{message} at index #{@index - 1} (#{@buffer.join ''})"
  debug '3321-4', rpr @index
  debug '3321-4', rpr R
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
new_parser = -> new NEARLEY.Parser GRAMMAR.ParserRules, GRAMMAR.ParserStart, { lexer: new Idl_lexer(), }
help ( new_parser().feed '⿵xx'                          ).results
help ( new_parser().feed '⿰ab'                          ).results
help ( new_parser().feed '⿰⿰abc'                       ).results
# help ( new_parser().feed 'u-cjk-xa-3412   㐒      ⿱⿱刀口乙' ).results
help ( new_parser().feed '⿱刀口'                         ).results
help ( new_parser().feed '⿱⿱刀口乙'                        ).results
help ( new_parser().feed '⿰'                          ).results
help ( new_parser().feed '⿰a'                          ).results
help ( new_parser().feed '⿱⿱ 刀口乙'                       ).results
help ( new_parser().feed '⿱ 刀'                          ).results
# CND.dir x

# help x.results



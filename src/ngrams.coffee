

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'KBM/MIXINS/IPC'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
# { IDL, IDLX, }            = require '../../../mojikura-idl'
last_of                   = ( x ) -> x[ x.length - 1 ]
assign                    = Object.assign

#-----------------------------------------------------------------------------------------------------------
pluck = ( x, key, fallback ) ->
  R = x[ key ]
  R = fallback if R is undefined
  delete x[ key ]
  return R

#-----------------------------------------------------------------------------------------------------------
### TAINT should be derived from options or grammar ###
@_unary_operator_pattern = /≈|<|>|\?|↻|↔|↕/g

#-----------------------------------------------------------------------------------------------------------
@_delete_unary_operators = ( formula ) -> formula.replace @_unary_operator_pattern, ''

#-----------------------------------------------------------------------------------------------------------
@get_relational_bigrams_as_tokens = ( formula ) ->
  formula = @_delete_unary_operators formula
  try
    tokens = @list_tokens formula, { all_brackets: yes, }
  catch error
    if error.message is "invalid syntax at index 0 (#{formula})\nUnexpected \"#{formula}\"\n"
      return []
    throw error
  #.........................................................................................................
  R             = []
  operators     = []
  prvs_token    = null
  for this_token, i in tokens
    this_token = assign {}, this_token, { i, }
    switch this_token.t
      when 'lbracket'
        null
      when 'rbracket'
        operators.pop()
        prvs_token.o = last_of operators
      when 'binary_operator'
        operators.push this_token
      when 'component'
        this_token.o = last_of operators
        if prvs_token?
          operator = pluck prvs_token, 'o'
          R.push [ operator, prvs_token, this_token, ]
        prvs_token = this_token
      else
        throw new Error "unknown token type #{rpr this_token}"
  delete ( last_of last_of R ).o
  return R

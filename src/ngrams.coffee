

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'IDLX/NGRAMS'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
# { IDL, IDLX, }            = require '../../../mojikura-idl'
first_of                  = ( x ) -> x[ 0 ]
last_of                   = ( x ) -> x[ x.length - 1 ]
assign                    = Object.assign

#-----------------------------------------------------------------------------------------------------------
pluck = ( x, key, fallback ) ->
  R = x[ key ]
  R = fallback if R is undefined
  delete x[ key ]
  return R

#-----------------------------------------------------------------------------------------------------------
@get_relational_bigrams = ( formula ) ->
  return ( ( token.s for token in bigram ).join '' for bigram in @get_relational_bigrams_as_tokens formula )

#-----------------------------------------------------------------------------------------------------------
@get_relational_bigrams_as_tokens = ( formula ) ->
  tokens        = @list_tokens formula, { all_brackets: yes, }
  R             = []
  operators     = []
  prvs_token    = null
  # countdowns    = []
  #.........................................................................................................
  for this_token in tokens
    this_token = assign {}, this_token
    # debug '87900', rpr this_token
    switch this_token.t
      when 'lbracket'
        null
      when 'rbracket'
        operators.pop()
        prvs_token.o = last_of operators
      when 'binary_operator'
        operators.push this_token
      when 'unary_operator'
        operators.push this_token
      when 'component', 'proxy'
        this_token.o = last_of operators
        if prvs_token?
          operator = pluck prvs_token, 'o'
          R.push [ operator, prvs_token, this_token, ]
        prvs_token = this_token
      else
        throw new Error "unknown token type #{rpr this_token}"
  #.........................................................................................................
  if R.length > 0
    delete ( last_of last_of R ).o
    ### ⊚⊙⎉⏵⏺⏹⏸ ###
    [ first_operator, first_element,  _,            ] = first_of R
    [ last_operator,  _,              last_element, ] = last_of  R
    start_token = { t: 'start', s: '⊚', i: null, }
    stop_token  = { t: 'stop',  s: '⊚', i: null, }
    R.unshift [ first_operator, start_token,  first_element,  ]
    R.push    [ last_operator,  last_element, stop_token,     ]
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@get_relational_bigrams_as_indices = ( formula ) ->
  return @_indices_from_bigram_tokens @get_relational_bigrams_as_tokens formula

#-----------------------------------------------------------------------------------------------------------
@_indices_from_bigram_tokens = ( bigrams ) ->
  return ( ( token.i for token in bigram ) for bigram in bigrams )

#-----------------------------------------------------------------------------------------------------------
@split_formula = ( formula ) ->
  return ( token.s for token in @list_tokens formula )

#-----------------------------------------------------------------------------------------------------------
@bigrams_from_formula_and_indices = ( formula, bigrams_as_indices ) ->
  return @bigrams_from_parts_and_indices ( @split_formula formula ), bigrams_as_indices

#-----------------------------------------------------------------------------------------------------------
@bigrams_from_parts_and_indices = ( parts, bigrams_as_indices ) ->
  return ( ( ( parts[ idx ] ? '⊚' ) for idx in bigram_indices ) for bigram_indices in bigrams_as_indices )








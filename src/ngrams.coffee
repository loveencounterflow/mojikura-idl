

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
@get_relational_bigrams = ( diagram_or_formula ) ->
  switch type = CND.type_of diagram_or_formula
    when 'text' then diagram = @parse       diagram_or_formula
    when 'list' then diagram =              diagram_or_formula
    else throw new Error "expected a text or a list, got a #{type} in #{rpr diagram_or_formula}"
  #.........................................................................................................
  R = @_bigrams_from_diagram diagram, []
  delete R.operators
  delete R.last_component
  delete R.last_operators
  return R

#-----------------------------------------------------------------------------------------------------------
@_bigrams_from_diagram = ( diagram, R ) ->
  R.operators      ?= []
  R.last_operators ?= []
  # last_component  = null
  #.........................................................................................................
  for part, idx in diagram
    if idx is 0
      R.operators.push part
      continue
    #.......................................................................................................
    if CND.isa_list part
      @_bigrams_from_diagram part, R
    #.......................................................................................................
    else
      if ( last_component = R.last_component )?
        # whisper R.operators, idx
        if idx is 1
          operator = last_of R.last_operators
        else
          operator = last_of R.operators
        #...................................................................................................
        list  = [ operator, last_component, part, ]
        text  = list.join ''
        #...................................................................................................
        R.push { text, list, }
        #...................................................................................................
      if idx is 1
        R.last_operators.push last_of R.operators
      R.last_component = part
  #.........................................................................................................
  R.operators.pop()
  R.last_operators.pop()
  return R


#-----------------------------------------------------------------------------------------------------------
@get_relational_bigrams_II = ( formula ) ->
  # switch type = CND.type_of tokens_or_formula
  #   when 'text' then tokens = @list_tokens tokens_or_formula
  #   when 'list' then tokens =              tokens_or_formula
  #   else throw new Error "expected a text or a list, got a #{type} in #{rpr tokens_or_formula}"
  #.........................................................................................................
  R = @_bigrams_from_diagram_II @list_tokens formula, { all_brackets: yes, }
  # delete R.operators
  # delete R.last_component
  # delete R.last_operators
  return R

#-----------------------------------------------------------------------------------------------------------
@_bigrams_from_diagram_II = ( tokens ) ->
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
  return R

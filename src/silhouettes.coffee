

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
# { IDLX, }            = require '../../../mojikura-idl'

#-----------------------------------------------------------------------------------------------------------
test_case = ->
  debug @silhouette_from_formula '⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'
  debug @silhouette_from_formula '⿱⿰⿵&#123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'
  debug @silhouette_from_formula '⿱⿰⿵&#x123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'
  debug @silhouette_from_formula '⿱⿰⿵&jzr#123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'
  debug @silhouette_from_formula '⿱⿰⿵&jzr#x123;䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝'
  debug @silhouette_from_formula '鐓:(⿰金(⿱亠口子)夊)'
  debug @silhouette_from_formula '敦:⿰(⿱亠口子)夊'

#-----------------------------------------------------------------------------------------------------------
### TAINT pattern should be derived from options or grammar ###
@_silhouette_codepoint_pattern = ///
      (?: & [a-z0-9]* \# (?: x [a-f0-9]+ | [0-9]+ ) ; ) |
      (?: [  \ud800-\udbff ] [ \udc00-\udfff ] ) |
      [^ () ≈<>?↻↔↕∅●▽ o ]
      ///g

#-----------------------------------------------------------------------------------------------------------
### TAINT pattern should be derived from options or grammar ###
@_silhouette_operator_pattern = /// [ ⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰ ] ///g

#-----------------------------------------------------------------------------------------------------------
@silhouette_from_formula = ( formula ) ->
  R = formula
  R = R.replace @_silhouette_operator_pattern,  'o'
  R = R.replace @_silhouette_codepoint_pattern, '.'
  return R




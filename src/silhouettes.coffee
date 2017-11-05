

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
### TAINT patterns should be derived from options or grammar ###
@_silhouette_binary_operator_pattern  = /// [ ⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰ ] ///g
@_silhouette_unary_operator_pattern   = /// [ ≈<>?↻↔↕ ] ///g
@_silhouette_singleton_pattern        = /// [ ∅●▽ ] ///g
### TAINT will fail silently if we ever introduce singleton symbols from beyond U+ffff ###
@_silhouette_element_pattern          = ///
  (?: & [a-z0-9]* \# (?: x [a-f0-9]+ | [0-9]+ ) ; ) |
  (?: [  \ud800-\udbff ] [ \udc00-\udfff ] ) |
  [^ ( ) b u s ]
  ///g

#-----------------------------------------------------------------------------------------------------------
@silhouette_from_formula = ( formula ) ->
  R = formula
  R = R.replace @_silhouette_binary_operator_pattern, 'b'
  R = R.replace @_silhouette_unary_operator_pattern,  'u'
  R = R.replace @_silhouette_singleton_pattern,       's'
  R = R.replace @_silhouette_element_pattern,         '.'
  return R




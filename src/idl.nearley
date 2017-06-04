
@preprocessor coffee

@{%

CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'NEARlEY'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
silent                    = no
silent                    = yes

#-----------------------------------------------------------------------------------------------------------
$unpack = ( label, keys... ) ->
  return ( data, loc, reject ) ->
    R = data
    for key in keys
      break if CND.isa_text R
      R = R[ key ]
    unless silent
      R.label = label
      debug '9982', label, data, rpr R
    return R

%}

start           ->  term                                                  {% $unpack 'start',       0, 0 %}
expression      ->  ( term | component                                  ) {% $unpack 'expression',  0, 0, 0 %}
term            ->  ( binary_term | trinary_term                        ) {% $unpack 'term',        0 %}
binary_term     ->  ( binary_operator  expression expression            ) {% $unpack 'binary_term', 0 %}
trinary_term    ->  ( trinary_operator expression expression expression ) {% $unpack 'trinary_term',0 %}

component       -> . {%
  ( data, loc, reject ) ->
    [ { value: chr, }, ] = data
    return reject if /^\s+$/.test chr
    return reject if /^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test chr
    info '33821', ( rpr data ), ( rpr chr ) unless silent
    return chr
  %}

binary_operator   ->  ( leftright
                      | topdown
                      | surround
                      | cap
                      | cup
                      | leftembrace
                      | topleft
                      | topright
                      | leftbottom
                      | interlace ) {% $unpack 'binary_operator',  0, 0 %}

trinary_operator  ->  ( pillars
                      | layers    ) {% $unpack 'trinary_operator', 0, 0 %}


leftright    -> "⿰" {% $unpack 'leftright',    0, 'value' %}
topdown      -> "⿱" {% $unpack 'topdown',      0, 'value' %}
surround     -> "⿴" {% $unpack 'surround',     0, 'value' %}
cap          -> "⿵" {% $unpack 'cap',          0, 'value' %}
cup          -> "⿶" {% $unpack 'cup',          0, 'value' %}
leftembrace  -> "⿷" {% $unpack 'leftembrace',  0, 'value' %}
topleft      -> "⿸" {% $unpack 'topleft',      0, 'value' %}
topright     -> "⿹" {% $unpack 'topright',     0, 'value' %}
leftbottom   -> "⿺" {% $unpack 'leftbottom',   0, 'value' %}
interlace    -> "⿻" {% $unpack 'interlace',    0, 'value' %}
pillars      -> "⿲" {% $unpack 'pillars',      0, 'value' %}
layers       -> "⿳" {% $unpack 'layers',       0, 'value' %}















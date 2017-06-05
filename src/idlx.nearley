
@preprocessor coffee

# NOTE: in the below grammar, rules with two plusses in their names (like `+binary_operator+`, `+proxy+`,
# `+bracket+ed`) indicate type names. This convention allows us to reverse-engineer the grammar
# to extract a mapping from type name to literals and from literals to type names.


@{%

CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/IDLX'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
help                      = CND.get_logger 'help',      badge

# #-----------------------------------------------------------------------------------------------------------
# O =
#   silent:     no
#   unpack:     yes
#   unbracket:  yes
#   unnest:     yes

#-----------------------------------------------------------------------------------------------------------
O =
  silent:     yes
  unpack:     yes
  unbracket:  yes
  unnest:     yes

#-----------------------------------------------------------------------------------------------------------
before_after = ( before, after ) ->
  return ( CND.grey '\n<- ' ) + ( CND.orange rpr before ) + ( CND.grey '\n-> ' ) + ( CND.lime rpr after )

#-----------------------------------------------------------------------------------------------------------
splice_into = ( target, idx ) ->
  unless ( type = CND.type_of ( sub_data = target[ idx ] ) ) is 'list'
    throw new Error "expected a list, got a #{type} as element 2 of #{rpr target}"
  target.splice idx, 1, sub_data...
  return target

#-----------------------------------------------------------------------------------------------------------
$unpack = ( label, keys... ) ->
  return ( data, loc, reject ) ->
    if O.unpack
      R = data
      for key in keys
        break if CND.isa_text R
        R = R[ key ]
    else
      R = Object.assign [], data
    unless O.silent
      R.label = label
      info '$unpack', label, before_after data, R
    return R

#-----------------------------------------------------------------------------------------------------------
$unbracket = ( label, keys... ) ->
  unpack = $unpack label, keys...
  return ( data, loc, reject ) ->
    R = unpack data, loc, reject
    if O.unbracket
      R = R[ 1 ... R.length - 1 ]
      splice_into R, 1
    unless O.silent
      info '$unbracket', before_after data, R
    return R

#-----------------------------------------------------------------------------------------------------------
$unnest = ( label, keys... ) ->
  unpack = $unpack label, keys...
  return ( data, loc, reject ) ->
    R = unpack data, loc, reject
    if O.unnest
      splice_into R, 2
    unless O.silent
      info '$unnest', before_after data, R
    return R

%}

start       ->  ( +solitaire+ | term                          ) {% $unpack    'start',      0, 0 %}
expr        ->  ( term | component                            ) {% $unpack    'expr',    0, 0, 0 %}
expr3+      ->  ( expr expr expr:+                            ) {% $unnest    'expr3+',        0 %}
term        ->  ( unary | binary | +bracket+ed                ) {% $unpack    'term',          0 %}
unary       ->  ( +unary_operator+   expr                     ) {% $unpack    'unary',         0 %}
binary      ->  ( +binary_operator+  expr expr                ) {% $unpack    'binary',        0 %}
+bracket+ed ->  ( lbracket +binary_operator+  expr3+ rbracket ) {% $unbracket '+bracket+ed',   0 %}

component       -> +proxy+ | . {%
  ( data, loc, reject ) ->
    [ { value: R, }, ] = data
    return reject if /^\s+$/.test R
    # return reject if /^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽ⓧⓨⓩ〓§]$/.test R
    return reject if /^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽〓§]$/.test R
    unless O.silent
      info 'component', before_after data, R
    return R
   %}

+unary_operator+ ->   ( similar
                      | heavy
                      | light
                      | doubt
                      | upsidedown
                      | mirror
                      | flip          ) {% $unpack '+unary_operator+',  0, 0 %}

+binary_operator+ ->  ( leftright
                      | topdown
                      | surround
                      | cap
                      | cup
                      | leftembrace
                      | topleft
                      | topright
                      | leftbottom
                      | interlace
                      | topleftcorner ) {% $unpack '+binary_operator+',  0, 0 %}

# +bracket         ->  ( lbracket
#                     | rbracket      ) {% $unpack '+bracket' %}

+solitaire+       ->  ( nosuchformula
                      | terminator
                      | inhibitor     ) {% $unpack '+solitaire+', 0 %}

+proxy+           ->  ( getamark
                      | curl          ) {% $unpack '+proxy+', 0, 0 %}

# unary operators:
similar         -> "≈"    {% $unpack 'similar',        0, 'value', %}
heavy           -> "<"    {% $unpack 'heavy',          0, 'value', %}
light           -> ">"    {% $unpack 'light',          0, 'value', %}
doubt           -> "?"    {% $unpack 'doubt',          0, 'value', %}
upsidedown      -> "↻"    {% $unpack 'upsidedown',     0, 'value', %}
mirror          -> "↔"    {% $unpack 'mirror',         0, 'value', %}
flip            -> "↕"    {% $unpack 'flip',           0, 'value', %}

# binary operators:
# '???':  { name: 'variable-operator', arity: null, }
# '???':  { name: 'null-operator', arity: 0, }
leftright       -> "⿰"   {% $unpack 'leftright',      0, 'value', %}
topdown         -> "⿱"   {% $unpack 'topdown',        0, 'value', %}
surround        -> "⿴"   {% $unpack 'surround',       0, 'value', %}
cap             -> "⿵"   {% $unpack 'cap',            0, 'value', %}
cup             -> "⿶"   {% $unpack 'cup',            0, 'value', %}
leftembrace     -> "⿷"   {% $unpack 'leftembrace',    0, 'value', %}
topleft         -> "⿸"   {% $unpack 'topleft',        0, 'value', %}
topright        -> "⿹"   {% $unpack 'topright',       0, 'value', %}
leftbottom      -> "⿺"   {% $unpack 'leftbottom',     0, 'value', %}
interlace       -> "⿻"   {% $unpack 'interlace',      0, 'value', %}
topleftcorner   -> "◰"    {% $unpack 'topleftcorner',  0, 'value', %}

# brackets:
lbracket        -> "("    {% $unpack 'lbracket',       0, 'value', %}
rbracket        -> ")"    {% $unpack 'rbracket',       0, 'value', %}

# solitaires:
nosuchformula   -> "∅"    {% $unpack 'nosuchformula',  0, 'value', %}
terminator      -> "●"    {% $unpack 'terminator',     0, 'value', %}
inhibitor       -> "▽"    {% $unpack 'inhibitor',      0, 'value', %}

# proxies:
# variable_x      -> "ⓧ"    {% $unpack 'variable_x',     0, 'value', %}
# variable_y      -> "ⓨ"    {% $unpack 'variable_y',     0, 'value', %}
# variable_z      -> "ⓩ"    {% $unpack 'variable_z',     0, 'value', %}
getamark        -> "〓"    {% $unpack 'getamark',       0, 'value', %}
curl            -> "§"    {% $unpack 'curl',           0, 'value', %}


#   sexpr:
#     opener:     '('
#     closer:     ')'
#     spacer:     ' '

#   formula:
#     opener:     '('
#     closer:     ')'
#     spacer:     ''


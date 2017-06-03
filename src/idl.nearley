
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
  keys.push 0 if keys.length is 0
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

# component       -> [a-z] {% ( d, loc ) -> [ 'component', loc, d..., ] %}
# component       -> . {% ( d, loc ) -> [ 'component', loc, d..., ] %}
# component       -> [^⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}] {% ( d, loc ) -> [ 'component', loc, d..., ] %}



# illegal         -> [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}] {% ( d, loc, reject ) -> reject %}
component       -> . {%
  ( data, loc, reject ) ->
    [ { value: chr, }, ] = data
    return reject if /^\s+$/.test chr
    return reject if /^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test chr
    info '33821', ( rpr data ), ( rpr chr ) unless silent
    return chr
  # [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}]
  #  ( d, loc, reject ) -> throw new Error "#{rpr d} at #{rpr loc}"
   %}

binary_operator -> ( leftright
                   | topdown
                   | surround
                   | cap
                   | cup
                   | leftembrace
                   | topleft
                   | topright
                   | leftbottom
                   | interlace ) {% $unpack '5', 0, 0 %}

trinary_operator -> ( pillars
                  | layers ) {% $unpack '6', 0, 0 %}


leftright    ->      "⿰" {% $unpack '7', 0, 'value' %} # {% ( d, loc ) -> [ 'leftright',   loc, d..., ] %}
topdown      ->      "⿱" {% $unpack '8', 0, 'value' %} # {% ( d, loc ) -> [ 'topdown',     loc, d..., ] %}
surround     ->      "⿴" {% $unpack '9', 0, 'value' %} # {% ( d, loc ) -> [ 'surround',    loc, d..., ] %}
cap          ->      "⿵" {% $unpack '10', 0, 'value' %} # {% ( d, loc ) -> [ 'cap',         loc, d..., ] %}
cup          ->      "⿶" {% $unpack '11', 0, 'value' %} # {% ( d, loc ) -> [ 'cup',         loc, d..., ] %}
leftembrace  ->      "⿷" {% $unpack '12', 0, 'value' %} # {% ( d, loc ) -> [ 'leftembrace', loc, d..., ] %}
topleft      ->      "⿸" {% $unpack '13', 0, 'value' %} # {% ( d, loc ) -> [ 'topleft',     loc, d..., ] %}
topright     ->      "⿹" {% $unpack '14', 0, 'value' %} # {% ( d, loc ) -> [ 'topright',    loc, d..., ] %}
leftbottom   ->      "⿺" {% $unpack '15', 0, 'value' %} # {% ( d, loc ) -> [ 'leftbottom',  loc, d..., ] %}
interlace    ->      "⿻" {% $unpack '16', 0, 'value' %} # {% ( d, loc ) -> [ 'interlace',   loc, d..., ] %}
pillars      ->      "⿲" {% $unpack '17', 0, 'value' %} # {% ( d, loc ) -> [ 'pillars',     loc, d..., ] %}
layers       ->      "⿳" {% $unpack '18', 0, 'value' %} # {% ( d, loc ) -> [ 'layers',      loc, d..., ] %}















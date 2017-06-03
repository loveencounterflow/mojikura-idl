
@preprocessor coffee


expression      ->  ( term | component                                  ) {% id %}
term            ->  ( binary_term | trinary_term                        ) {% id %}
binary_term     ->  ( binary_operator  expression expression            ) {% id %}
trinary_term    ->  ( trinary_operator expression expression expression ) {% id %}

# component       -> [a-z] {% ( d, loc ) -> [ 'component', loc, d..., ] %}
# component       -> . {% ( d, loc ) -> [ 'component', loc, d..., ] %}
# component       -> [^⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}] {% ( d, loc ) -> [ 'component', loc, d..., ] %}



# illegal         -> [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}] {% ( d, loc, reject ) -> reject %}
component       -> . {%
  ( data, loc, reject ) ->
    [ chr, ] = data
    console.log '33821', ( require 'util' ).inspect data
    return reject if /^\s+$/.test chr
    return reject if /^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test chr
    return chr
  # [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}]
  #  ( d, loc, reject ) -> throw new Error "#{( require 'util' ).inspect d} at #{( require 'util' ).inspect loc}"
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
                   | interlace ) {% id %}

trinary_operator -> ( pillars
                  | layers ) {% id %}


leftright    ->      "⿰" {% id %} # {% ( d, loc ) -> [ 'leftright',   loc, d..., ] %}
topdown      ->      "⿱" {% id %} # {% ( d, loc ) -> [ 'topdown',     loc, d..., ] %}
surround     ->      "⿴" {% id %} # {% ( d, loc ) -> [ 'surround',    loc, d..., ] %}
cap          ->      "⿵" {% id %} # {% ( d, loc ) -> [ 'cap',         loc, d..., ] %}
cup          ->      "⿶" {% id %} # {% ( d, loc ) -> [ 'cup',         loc, d..., ] %}
leftembrace  ->      "⿷" {% id %} # {% ( d, loc ) -> [ 'leftembrace', loc, d..., ] %}
topleft      ->      "⿸" {% id %} # {% ( d, loc ) -> [ 'topleft',     loc, d..., ] %}
topright     ->      "⿹" {% id %} # {% ( d, loc ) -> [ 'topright',    loc, d..., ] %}
leftbottom   ->      "⿺" {% id %} # {% ( d, loc ) -> [ 'leftbottom',  loc, d..., ] %}
interlace    ->      "⿻" {% id %} # {% ( d, loc ) -> [ 'interlace',   loc, d..., ] %}
pillars      ->      "⿲" {% id %} # {% ( d, loc ) -> [ 'pillars',     loc, d..., ] %}
layers       ->      "⿳" {% id %} # {% ( d, loc ) -> [ 'layers',      loc, d..., ] %}















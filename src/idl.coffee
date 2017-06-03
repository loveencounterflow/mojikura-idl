# Generated automatically by nearley
# http://github.com/Hardmath123/nearley
do ->
  id = (d)->d[0]

  
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
  
  
  grammar = {
    Lexer: undefined,
    ParserRules: [
          {"name": "start", "symbols": ["term"], "postprocess": $unpack 'start',       0, 0},
          {"name": "expression$subexpression$1", "symbols": ["term"]},
          {"name": "expression$subexpression$1", "symbols": ["component"]},
          {"name": "expression", "symbols": ["expression$subexpression$1"], "postprocess": $unpack 'expression',  0, 0, 0},
          {"name": "term$subexpression$1", "symbols": ["binary_term"]},
          {"name": "term$subexpression$1", "symbols": ["trinary_term"]},
          {"name": "term", "symbols": ["term$subexpression$1"], "postprocess": $unpack 'term',        0},
          {"name": "binary_term$subexpression$1", "symbols": ["binary_operator", "expression", "expression"]},
          {"name": "binary_term", "symbols": ["binary_term$subexpression$1"], "postprocess": $unpack 'binary_term', 0},
          {"name": "trinary_term$subexpression$1", "symbols": ["trinary_operator", "expression", "expression", "expression"]},
          {"name": "trinary_term", "symbols": ["trinary_term$subexpression$1"], "postprocess": $unpack 'trinary_term',0},
          {"name": "component", "symbols": [/./], "postprocess": 
              ( data, loc, reject ) ->
                [ { value: chr, }, ] = data
                return reject if /^\s+$/.test chr
                return reject if /^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test chr
                info '33821', ( rpr data ), ( rpr chr ) unless silent
                return chr
              # [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}]
              #  ( d, loc, reject ) -> throw new Error "#{rpr d} at #{rpr loc}"
               },
          {"name": "binary_operator$subexpression$1", "symbols": ["leftright"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topdown"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["surround"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["cap"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["cup"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["leftembrace"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topleft"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topright"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["leftbottom"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["interlace"]},
          {"name": "binary_operator", "symbols": ["binary_operator$subexpression$1"], "postprocess": $unpack '5', 0, 0},
          {"name": "trinary_operator$subexpression$1", "symbols": ["pillars"]},
          {"name": "trinary_operator$subexpression$1", "symbols": ["layers"]},
          {"name": "trinary_operator", "symbols": ["trinary_operator$subexpression$1"], "postprocess": $unpack '6', 0, 0},
          {"name": "leftright", "symbols": [{"literal":"⿰"}], "postprocess": $unpack '7', 0, 'value'},
          {"name": "topdown", "symbols": [{"literal":"⿱"}], "postprocess": $unpack '8', 0, 'value'},
          {"name": "surround", "symbols": [{"literal":"⿴"}], "postprocess": $unpack '9', 0, 'value'},
          {"name": "cap", "symbols": [{"literal":"⿵"}], "postprocess": $unpack '10', 0, 'value'},
          {"name": "cup", "symbols": [{"literal":"⿶"}], "postprocess": $unpack '11', 0, 'value'},
          {"name": "leftembrace", "symbols": [{"literal":"⿷"}], "postprocess": $unpack '12', 0, 'value'},
          {"name": "topleft", "symbols": [{"literal":"⿸"}], "postprocess": $unpack '13', 0, 'value'},
          {"name": "topright", "symbols": [{"literal":"⿹"}], "postprocess": $unpack '14', 0, 'value'},
          {"name": "leftbottom", "symbols": [{"literal":"⿺"}], "postprocess": $unpack '15', 0, 'value'},
          {"name": "interlace", "symbols": [{"literal":"⿻"}], "postprocess": $unpack '16', 0, 'value'},
          {"name": "pillars", "symbols": [{"literal":"⿲"}], "postprocess": $unpack '17', 0, 'value'},
          {"name": "layers", "symbols": [{"literal":"⿳"}], "postprocess": $unpack '18', 0, 'value'}
      ],
    ParserStart: "start"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;

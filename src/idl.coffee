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
          {"name": "binary_operator", "symbols": ["binary_operator$subexpression$1"], "postprocess": $unpack 'binary_operator',  0, 0},
          {"name": "trinary_operator$subexpression$1", "symbols": ["pillars"]},
          {"name": "trinary_operator$subexpression$1", "symbols": ["layers"]},
          {"name": "trinary_operator", "symbols": ["trinary_operator$subexpression$1"], "postprocess": $unpack 'trinary_operator', 0, 0},
          {"name": "leftright", "symbols": [{"literal":"⿰"}], "postprocess": $unpack 'leftright',    0, 'value'},
          {"name": "topdown", "symbols": [{"literal":"⿱"}], "postprocess": $unpack 'topdown',      0, 'value'},
          {"name": "surround", "symbols": [{"literal":"⿴"}], "postprocess": $unpack 'surround',     0, 'value'},
          {"name": "cap", "symbols": [{"literal":"⿵"}], "postprocess": $unpack 'cap',          0, 'value'},
          {"name": "cup", "symbols": [{"literal":"⿶"}], "postprocess": $unpack 'cup',          0, 'value'},
          {"name": "leftembrace", "symbols": [{"literal":"⿷"}], "postprocess": $unpack 'leftembrace',  0, 'value'},
          {"name": "topleft", "symbols": [{"literal":"⿸"}], "postprocess": $unpack 'topleft',      0, 'value'},
          {"name": "topright", "symbols": [{"literal":"⿹"}], "postprocess": $unpack 'topright',     0, 'value'},
          {"name": "leftbottom", "symbols": [{"literal":"⿺"}], "postprocess": $unpack 'leftbottom',   0, 'value'},
          {"name": "interlace", "symbols": [{"literal":"⿻"}], "postprocess": $unpack 'interlace',    0, 'value'},
          {"name": "pillars", "symbols": [{"literal":"⿲"}], "postprocess": $unpack 'pillars',      0, 'value'},
          {"name": "layers", "symbols": [{"literal":"⿳"}], "postprocess": $unpack 'layers',       0, 'value'}
      ],
    ParserStart: "start"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;

# Generated automatically by nearley
# http://github.com/Hardmath123/nearley
do ->
  id = (d)->d[0]

  
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
  
  
  
  grammar = {
    Lexer: undefined,
    ParserRules: [
          {"name": "start$subexpression$1", "symbols": ["solitaire"]},
          {"name": "start$subexpression$1", "symbols": ["term"]},
          {"name": "start", "symbols": ["start$subexpression$1"], "postprocess": $unpack 'start',    0, 0},
          {"name": "expr$subexpression$1", "symbols": ["term"]},
          {"name": "expr$subexpression$1", "symbols": ["component"]},
          {"name": "expr", "symbols": ["expr$subexpression$1"], "postprocess": $unpack 'expr',  0, 0, 0},
          {"name": "expr3+$subexpression$1$ebnf$1", "symbols": ["expr"]},
          {"name": "expr3+$subexpression$1$ebnf$1", "symbols": ["expr3+$subexpression$1$ebnf$1", "expr"], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "expr3+$subexpression$1", "symbols": ["expr", "expr", "expr3+$subexpression$1$ebnf$1"]},
          {"name": "expr3+", "symbols": ["expr3+$subexpression$1"], "postprocess": $unnest 'expr3+',      0},
          {"name": "term$subexpression$1", "symbols": ["unary"]},
          {"name": "term$subexpression$1", "symbols": ["binary"]},
          {"name": "term$subexpression$1", "symbols": ["bracketed"]},
          {"name": "term", "symbols": ["term$subexpression$1"], "postprocess": $unpack 'term',        0},
          {"name": "unary$subexpression$1", "symbols": ["unary_operator", "expr"]},
          {"name": "unary", "symbols": ["unary$subexpression$1"], "postprocess": $unpack 'unary',       0},
          {"name": "binary$subexpression$1", "symbols": ["binary_operator", "expr", "expr"]},
          {"name": "binary", "symbols": ["binary$subexpression$1"], "postprocess": $unpack 'binary',      0},
          {"name": "bracketed$subexpression$1", "symbols": ["lbracket", "binary_operator", "expr3+", "rbracket"]},
          {"name": "bracketed", "symbols": ["bracketed$subexpression$1"], "postprocess": $unbracket 'bracketed', 0},
          {"name": "component", "symbols": ["proxy"]},
          {"name": "component", "symbols": [/./], "postprocess": 
              ( data, loc, reject ) ->
                [ { value: R, }, ] = data
                return reject if /^\s+$/.test R
                # return reject if /^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽ⓧⓨⓩ〓§]$/.test R
                return reject if /^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽〓§]$/.test R
                unless O.silent
                  info 'component', before_after data, R
                return R
               },
          {"name": "unary_operator$subexpression$1", "symbols": ["similar"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["heavy"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["light"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["doubt"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["upsidedown"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["mirror"]},
          {"name": "unary_operator$subexpression$1", "symbols": ["flip"]},
          {"name": "unary_operator", "symbols": ["unary_operator$subexpression$1"], "postprocess": $unpack 'unary_operator',  0, 0},
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
          {"name": "binary_operator$subexpression$1", "symbols": ["topleftcorner"]},
          {"name": "binary_operator", "symbols": ["binary_operator$subexpression$1"], "postprocess": $unpack 'binary_operator',  0, 0},
          {"name": "bracket$subexpression$1", "symbols": ["lbracket"]},
          {"name": "bracket$subexpression$1", "symbols": ["rbracket"]},
          {"name": "bracket", "symbols": ["bracket$subexpression$1"], "postprocess": $unpack 'bracket'},
          {"name": "solitaire$subexpression$1", "symbols": ["nosuchformula"]},
          {"name": "solitaire$subexpression$1", "symbols": ["terminator"]},
          {"name": "solitaire$subexpression$1", "symbols": ["inhibitor"]},
          {"name": "solitaire", "symbols": ["solitaire$subexpression$1"], "postprocess": $unpack 'solitaire', 0},
          {"name": "proxy$subexpression$1", "symbols": ["getamark"]},
          {"name": "proxy$subexpression$1", "symbols": ["curl"]},
          {"name": "proxy", "symbols": ["proxy$subexpression$1"], "postprocess": $unpack 'proxy'},
          {"name": "similar", "symbols": [{"literal":"≈"}], "postprocess": $unpack 'similar',        0, 'value',},
          {"name": "heavy", "symbols": [{"literal":"<"}], "postprocess": $unpack 'heavy',          0, 'value',},
          {"name": "light", "symbols": [{"literal":">"}], "postprocess": $unpack 'light',          0, 'value',},
          {"name": "doubt", "symbols": [{"literal":"?"}], "postprocess": $unpack 'doubt',          0, 'value',},
          {"name": "upsidedown", "symbols": [{"literal":"↻"}], "postprocess": $unpack 'upsidedown',     0, 'value',},
          {"name": "mirror", "symbols": [{"literal":"↔"}], "postprocess": $unpack 'mirror',         0, 'value',},
          {"name": "flip", "symbols": [{"literal":"↕"}], "postprocess": $unpack 'flip',           0, 'value',},
          {"name": "leftright", "symbols": [{"literal":"⿰"}], "postprocess": $unpack 'leftright',      0, 'value',},
          {"name": "topdown", "symbols": [{"literal":"⿱"}], "postprocess": $unpack 'topdown',        0, 'value',},
          {"name": "surround", "symbols": [{"literal":"⿴"}], "postprocess": $unpack 'surround',       0, 'value',},
          {"name": "cap", "symbols": [{"literal":"⿵"}], "postprocess": $unpack 'cap',            0, 'value',},
          {"name": "cup", "symbols": [{"literal":"⿶"}], "postprocess": $unpack 'cup',            0, 'value',},
          {"name": "leftembrace", "symbols": [{"literal":"⿷"}], "postprocess": $unpack 'leftembrace',    0, 'value',},
          {"name": "topleft", "symbols": [{"literal":"⿸"}], "postprocess": $unpack 'topleft',        0, 'value',},
          {"name": "topright", "symbols": [{"literal":"⿹"}], "postprocess": $unpack 'topright',       0, 'value',},
          {"name": "leftbottom", "symbols": [{"literal":"⿺"}], "postprocess": $unpack 'leftbottom',     0, 'value',},
          {"name": "interlace", "symbols": [{"literal":"⿻"}], "postprocess": $unpack 'interlace',      0, 'value',},
          {"name": "topleftcorner", "symbols": [{"literal":"◰"}], "postprocess": $unpack 'topleftcorner',  0, 'value',},
          {"name": "lbracket", "symbols": [{"literal":"("}], "postprocess": $unpack 'lbracket',       0, 'value',},
          {"name": "rbracket", "symbols": [{"literal":")"}], "postprocess": $unpack 'rbracket',       0, 'value',},
          {"name": "nosuchformula", "symbols": [{"literal":"∅"}], "postprocess": $unpack 'nosuchformula',  0, 'value',},
          {"name": "terminator", "symbols": [{"literal":"●"}], "postprocess": $unpack 'terminator',     0, 'value',},
          {"name": "inhibitor", "symbols": [{"literal":"▽"}], "postprocess": $unpack 'inhibitor',      0, 'value',},
          {"name": "getamark", "symbols": [{"literal":"〓"}], "postprocess": $unpack 'getamark',       0, 'value',},
          {"name": "curl", "symbols": [{"literal":"§"}], "postprocess": $unpack 'curl',           0, 'value',}
      ],
    ParserStart: "start"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;

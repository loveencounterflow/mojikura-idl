

module.exports = O =

  ###
  idlx:
    'operator-2':           /// [ ⿰ ⿱ ⿴ ⿵ ⿶ ⿷ ⿸ ⿹ ⿺ ⿻ ◰ ] ///
    'operator-1':           /// [ ≈ ↻ ↔ ↕ ] ///

  idl:
    # 'assignment-mark':      ':'
    # 'comment-mark':         '#'
    # 'comment-text':         /// ^ [^ \n ]* ///
    'finish-formula':       '●'
    'missing-formula':      '〓'
    'mapped-cp':            '▽'
    'ncr':                  /// & [a-z0-9]* \# (?: x [a-f0-9]+ | [0-9]+ ) ; ///
    # 'ncr':                  /// ^ #{$.ncr-kernel.source} ///
    'operator-2':           /// [⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻] ///
    'operator-3':           /// [⿲⿳] ///
    'similarity-mark':      '≈'
    'curvy-line':           '§'
    'cjk-chr':              @cjk_chr_matcher
  ###

  sexpr:
    opener:     '('
    closer:     ')'
    spacer:     ' '

  formula:
    opener:     '('
    closer:     ')'
    spacer:     ''

  idl:
    operators:
      '⿰': { name: 'left-right',    arity: 2, }
      '⿱': { name: 'top/down',      arity: 2, }
      '⿴': { name: 'surround',      arity: 2, }
      '⿵': { name: 'cap',           arity: 2, }
      '⿶': { name: 'cup',           arity: 2, }
      '⿷': { name: 'left-embrace',  arity: 2, }
      '⿸': { name: 'topleft',       arity: 2, }
      '⿹': { name: 'topright',      arity: 2, }
      '⿺': { name: 'leftbottom',    arity: 2, }
      '⿻': { name: 'interlace',     arity: 2, }
      '⿲': { name: 'pillars',       arity: 3, }
      '⿳': { name: 'layers',        arity: 3, }

  idlx:
    operators:
      # '???':  { name: 'variable-operator', arity: null, }
      # '???':  { name: 'null-operator', arity: 0, }
      '⿰':  { name: 'left-right',     arity: 2, }
      '⿱':  { name: 'top/down',       arity: 2, }
      '⿴':  { name: 'surround',       arity: 2, }
      '⿵':  { name: 'cap',            arity: 2, }
      '⿶':  { name: 'cup',            arity: 2, }
      '⿷':  { name: 'left-embrace',   arity: 2, }
      '⿸':  { name: 'topleft',        arity: 2, }
      '⿹':  { name: 'topright',       arity: 2, }
      '⿺':  { name: 'leftbottom',     arity: 2, }
      '⿻':  { name: 'interlace',      arity: 2, }
      '◰':  { name: 'topleftcorner',  arity: 2, }
      '≈':  { name: 'similar',        arity: 1, } # deprecated
      '<':  { name: 'heavy',          arity: 1, }
      '>':  { name: 'light',          arity: 1, }
      '?':  { name: 'doubt',          arity: 1, }
      '↻':  { name: 'upsidedown',     arity: 1, }
      '↔':  { name: 'mirror',         arity: 1, }
      '↕':  { name: 'flip',           arity: 1, }

    brackets:
      '(':  { name: 'lbracket',                 }
      ')':  { name: 'rbracket',                 }

    solitaires:
      '∅':  { name: 'nosuchformula',           }
      '●':  { name: 'terminator',               }
      '▽':  { name: 'inhibitor',                }

    proxies:
      # 'ⓧ':  { name: 'variable-x',               }
      # 'ⓨ':  { name: 'variable-y',               }
      # 'ⓩ':  { name: 'variable-z',               }
      '〓':  { name: 'getamark',                 }
      '§':  { name: 'curl',                     }













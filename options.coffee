

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

  idl:
    operators:
      '⿰': { name: 'left/right',    arity: 2, }
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


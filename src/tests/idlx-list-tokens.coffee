



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
TAP                       = require 'tap'
{ IDL, IDLX, }            = require '../..'


#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) solitaires", ( T ) ->
  probes_and_matchers = [
    [ '↻', 'unary_operator',   ]
    [ '〓', 'proxy',            ]
    [ '§', 'proxy',            ]
    [ '⿰', 'binary_operator',  ]
    [ '⿻', 'binary_operator',  ]
    [ '◰', 'binary_operator',  ]
    [ '(', 'bracket',          ]
    [ 'x', 'component',        ]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    result = IDLX.type_from_literal probe
    urge ( CND.truth CND.equals result, matcher ), JSON.stringify [ probe, result, ]
    T.ok CND.equals result, matcher
  #.........................................................................................................
  T.end()
  return null

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) get_formula", ( T ) ->
  probes_and_matchers = [
    [ '⿱⿰天天⿰天天',                '⿱⿰天天⿰天天',                ]
    [ '⿰(⿱一八土)⿱山电',          '⿰(⿱一八土)⿱山电'              ]
    [ '(⿱⿶凵⿰⿱丄一⿱丄一开土)',      '(⿱⿶凵⿰⿱丄一⿱丄一开土)'          ]
    [ '⿰⿱名土⿱勿中',             '⿰⿱名土⿱勿中'                 ]
    [ '⿰⿱日有⿱犬土',             '⿰⿱日有⿱犬土'                 ]
    [ '⿰⿱土坐⿱土坐',             '⿰⿱土坐⿱土坐'                 ]
    [ '⿰土(⿱⿰一一⿰日日鹿)',        '⿰土(⿱⿰一一⿰日日鹿)'            ]
    [ '⿰土⿱⿰⿱一日⿱一日鹿',         '⿰土⿱⿰⿱一日⿱一日鹿'             ]
    [ '⿰土⿱⿰𣄼𣄼鹿',             '⿰土⿱⿰𣄼𣄼鹿'                 ]
    [ '⿱𠀎冉',                   '⿱𠀎冉'                       ]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    diagram = IDLX.parse probe
    result  = IDLX.get_formula diagram
    urge ( CND.truth CND.equals result, matcher ), JSON.stringify [ probe, result, ]
    T.ok CND.equals result, matcher
  #.........................................................................................................
  T.end()
  return null

###
result = IDLX.type_from_literal probe
urge ( CND.truth CND.equals result, matcher ), JSON.stringify [ probe, result, ]
T.ok CND.equals result, matcher
info @IDLX._get_literals_and_types IDLX_GRAMMAR
info @IDLX.type_from_literal IDLX_GRAMMAR
help '↻', @IDLX.type_from_literal '↻' # 'operator',
help '〓', @IDLX.type_from_literal '〓' # 'proxy',
help '§', @IDLX.type_from_literal '§' # 'proxy',
help '⿰', @IDLX.type_from_literal '⿰' # 'operator',
help '⿻', @IDLX.type_from_literal '⿻' # 'operator',
help '◰', @IDLX.type_from_literal '◰' # 'operator',
help '(', @IDLX.type_from_literal '(' # 'bracket',
help 'x', @IDLX.type_from_literal 'x' # 'other',
formula       = '⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))'
whisper formula
help diagram  = @IDLX.parse formula
whisper formula
help tokens   = @IDLX.list_tokens diagram
urge @IDLX.get_formula formula
urge @IDLX.get_formula diagram
urge @IDLX._get_treeshaker_litmus()
urge ( CND.yellow formula    ), ( CND.blue CND.truth @IDLX.formula_may_be_suboptimal formula    )
urge ( CND.yellow '⿱⿱𫝀口㐄'    ), ( CND.blue CND.truth @IDLX.formula_may_be_suboptimal '⿱⿱𫝀口㐄'    )
urge ( CND.yellow '⿱𫝀⿱口㐄'    ), ( CND.blue CND.truth @IDLX.formula_may_be_suboptimal '⿱𫝀⿱口㐄'    )
urge ( CND.yellow '⿰韋(⿱白大十)' ), ( CND.blue CND.truth @IDLX.formula_may_be_suboptimal '⿰韋(⿱白大十)' )
info ( CND.yellow formula    ), ( CND.blue @IDLX.normalize_formula formula                       )
info ( CND.yellow '⿱⿱𫝀口㐄'    ), ( CND.blue @IDLX.normalize_formula '⿱⿱𫝀口㐄'                       )
info ( CND.yellow '⿱𫝀⿱口㐄'    ), ( CND.blue @IDLX.normalize_formula '⿱𫝀⿱口㐄'                       )
info ( CND.yellow '⿰韋(⿱白大十)' ), ( CND.blue @IDLX.normalize_formula '⿰韋(⿱白大十)'                    )
###





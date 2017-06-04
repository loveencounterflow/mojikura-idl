



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


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
nice_text_rpr = ( text ) ->
  ### Ad-hoc method to print out text in a readable, CoffeeScript-compatible, triple-quoted way. Line breaks
  (`\\n`) will be shown as line breaks, so texts should not be as spaghettified as they appear with
  JSON.stringify (the last line break of a string is, however, always shown in its symbolic form so it
  won't get swallowed by the CoffeeScript parser). Code points below U+0020 (space) are shown as
  `\\x00`-style escapes, taken up less space than `\u0000` escapes while keeping things explicit. All
  double quotes will be prepended with a backslash. ###
  R = text
  R = R.replace /[\x00-\x09\x0b-\x19]/g, ( $0 ) ->
    cid_hex = ( $0.codePointAt 0 ).toString 16
    cid_hex = '0' + cid_hex if cid_hex.length is 1
    return "\\x#{cid_hex}"
  R = R.replace /"/g, '\\"'
  R = R.replace /\n$/g, '\\n'
  R = '\n"""' + R + '"""'
  return R

#-----------------------------------------------------------------------------------------------------------
resume_next = ( T, method ) ->
  try
    R = method()
  catch error
    return Symbol "### ERROR ### " + error[ 'message' ]
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
TAP.test "dummy", ( T ) -> T.end()


# #===========================================================================================================
# # TESTS (SANITY CHECKS)
# #-----------------------------------------------------------------------------------------------------------
# @[ "sanity checks (grammar data)" ] = ( T ) ->
#   T.ok '⿰' of IDL._parser_settings.operators
#   T.ok '⿱' of IDL._parser_settings.operators
#   T.ok '⿴' of IDL._parser_settings.operators
#   T.ok '⿵' of IDL._parser_settings.operators
#   T.ok '⿶' of IDL._parser_settings.operators
#   T.ok '⿷' of IDL._parser_settings.operators
#   T.ok '⿸' of IDL._parser_settings.operators
#   T.ok '⿹' of IDL._parser_settings.operators
#   T.ok '⿺' of IDL._parser_settings.operators
#   T.ok '⿻' of IDL._parser_settings.operators
#   T.ok '⿲' of IDL._parser_settings.operators
#   T.ok '⿳' of IDL._parser_settings.operators
#   #.........................................................................................................
#   T.ok '⿰' of IDLX._parser_settings.operators
#   T.ok '⿱' of IDLX._parser_settings.operators
#   T.ok '⿴' of IDLX._parser_settings.operators
#   T.ok '⿵' of IDLX._parser_settings.operators
#   T.ok '⿶' of IDLX._parser_settings.operators
#   T.ok '⿷' of IDLX._parser_settings.operators
#   T.ok '⿸' of IDLX._parser_settings.operators
#   T.ok '⿹' of IDLX._parser_settings.operators
#   T.ok '⿺' of IDLX._parser_settings.operators
#   T.ok '⿻' of IDLX._parser_settings.operators
#   T.ok '⿲' not of IDLX._parser_settings.operators
#   T.ok '⿳' not of IDLX._parser_settings.operators
#   T.ok '◰' of IDLX._parser_settings.operators
#   T.ok '≈' of IDLX._parser_settings.operators
#   T.ok '↻' of IDLX._parser_settings.operators
#   T.ok '↔' of IDLX._parser_settings.operators
#   T.ok '↕' of IDLX._parser_settings.operators
#   T.ok '●' of IDLX._parser_settings.solitaires
#   #.........................................................................................................
#   T.ok IDL._parser_settings           isnt IDLX._parser_settings
#   T.ok IDL._parser_settings.operators isnt IDLX._parser_settings.operators
#   T.ok not CND.equals IDL._parser_settings,            IDLX._parser_settings
#   T.ok not CND.equals IDL._parser_settings.operators,  IDLX._parser_settings.operators
#   #.........................................................................................................
#   return null



# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDL) parse tree of simple formulas" ] = ( T ) ->
#   probes_and_matchers = [
#     ["⿲木木木",[{"~isa":"MOJIKURA-IDL/token","s":"⿲","idx":0,"t":"operator","a":3,"n":"pillars"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":1,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"木","idx":3,"t":"component"}]]
#     ["⿱癶⿰弓貝",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},{"~isa":"MOJIKURA-IDL/token","s":"癶","idx":1,"t":"component"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":2,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"弓","idx":3,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"貝","idx":4,"t":"component"}]]]
#     ["⿱⿰亻式貝",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"亻","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"式","idx":3,"t":"component"}],{"~isa":"MOJIKURA-IDL/token","s":"貝","idx":4,"t":"component"}]]
#     ["⿱⿰亻式⿱目八",[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":0,"t":"operator","a":2,"n":"top/down"},[{"~isa":"MOJIKURA-IDL/token","s":"⿰","idx":1,"t":"operator","a":2,"n":"left-right"},{"~isa":"MOJIKURA-IDL/token","s":"亻","idx":2,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"式","idx":3,"t":"component"}],[{"~isa":"MOJIKURA-IDL/token","s":"⿱","idx":4,"t":"operator","a":2,"n":"top/down"},{"~isa":"MOJIKURA-IDL/token","s":"目","idx":5,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"八","idx":6,"t":"component"}]]]
#     ["⿺辶言",[{"~isa":"MOJIKURA-IDL/token","s":"⿺","idx":0,"t":"operator","a":2,"n":"leftbottom"},{"~isa":"MOJIKURA-IDL/token","s":"辶","idx":1,"t":"component"},{"~isa":"MOJIKURA-IDL/token","s":"言","idx":2,"t":"component"}]]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     result = resume_next T, -> IDL.tokentree_from_source probe
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #===========================================================================================================
# # TESTS (IDLX)
# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) parse simple formulas" ] = ( T ) ->
#   probes_and_matchers = [
#     ["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
#     ["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
#     ["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
#     ["⿺辶言",["⿺","辶","言"]]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     result = resume_next T, -> IDLX.diagram_from_source probe
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) reject bogus formulas" ] = ( T ) ->
#   probes_and_matchers = [
#     ["木","IDL: lone token of type 'component' [  ✘ 木 ✘  ]"]
#     [42,"expected a text, got a number"]
#     ["〓","IDL: lone token of type 'proxy' [  ✘ 〓 ✘  ]"]
#     ["","IDL: empty text"]
#     ["⿱⿰亻式⿱目八木木木","IDL: extra token(s) [ ⿱⿰亻式⿱目八 ✘ 木 ✘ 木木 ]"]
#     ["⿺廴聿123","IDL: extra token(s) [ ⿺廴聿 ✘ 1 ✘ 23 ]"]
#     ["⿺","IDLX: premature end of source [  ✘ ⿺ ✘  ]"]
#     ["⿺⿺⿺⿺","IDLX: premature end of source [ ⿺⿺⿺ ✘ ⿺ ✘  ]"]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     try
#       result = IDLX.diagram_from_source probe
#       T.fail "expected an exception, got result #{rpr result}"
#     catch error
#       message = CND.remove_colors error[ 'message' ]
#       warn JSON.stringify [ probe, message, ]
#       T.eq message, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) reject IDL operators with arity 3" ] = ( T ) ->
#   probes_and_matchers = [
#     ["⿲木木木","IDL: extra token(s) [ ⿲ ✘ 木 ✘ 木木 ]"]
#     ["⿳木木木","IDL: extra token(s) [ ⿳ ✘ 木 ✘ 木木 ]"]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     try
#       result = IDLX.diagram_from_source probe
#       T.fail "expected an exception, got result #{rpr result}"
#     catch error
#       message = CND.remove_colors error[ 'message' ]
#       warn JSON.stringify [ probe, message, ]
#       T.eq message, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) parse extended formulas (plain)" ] = ( T ) ->
#   probes_and_matchers = [
#       [ '↻正', [ '↻', '正', ], ]
#       [ '↔≈匕', [ '↔', [ '≈', '匕' ] ], ]
#       [ '↔正', [ '↔', '正', ], ]
#       [ '⿱丶乂', [ '⿱', '丶', '乂', ], ]
#       [ '⿺走⿹◰口戈日', [ '⿺', '走', [ '⿹', [ '◰', '口', '戈' ], '日' ] ], ]
#       ['≈匚', [ '≈', '匚' ], ]
#       ["≈&jzr#xe174;",["≈",""]]
#       ['≈非', [ '≈', '非' ], ]
#       [ '⿺走⿹◰口〓日', [ '⿺', '走', [ '⿹', [ '◰', '口', '〓' ], '日' ] ], ]
#       ["⿻串⿰立&jzr#x1234;",["⿻","串",["⿰","立","ሴ"]]]
#       ["⿱丶⿵𠘨§",["⿱","丶",["⿵","𠘨","§"]]]
#       # [ '𡦹:⿱丶⿵𠘨§', [ '⿱', '§', '&jzr#xe199;' ], ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     result = resume_next T, -> IDLX.diagram_from_source probe
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null



# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) reject bogus formulas (solitaires)" ] = ( T ) ->
#   probes_and_matchers = [
#     ["〓","IDL: lone token of type 'proxy' [  ✘ 〓 ✘  ]"]
#     ["§","IDL: lone token of type 'proxy' [  ✘ § ✘  ]"]
#     ["⿱式●","IDLX: cannot have a solitaire here [ ⿱式 ✘ ● ✘  ]"]
#     ["⿱式▽","IDLX: cannot have a solitaire here [ ⿱式 ✘ ▽ ✘  ]"]
#     ["⿱式∅","IDLX: cannot have a solitaire here [ ⿱式 ✘ ∅ ✘  ]"]
#     ["⿱〓▽","IDLX: cannot have a solitaire here [ ⿱〓 ✘ ▽ ✘  ]"]
#     ["↻●","IDLX: cannot have a solitaire here [ ↻ ✘ ● ✘  ]"]
#     ["↔≈▽","IDLX: cannot have a solitaire here [ ↔≈ ✘ ▽ ✘  ]"]
#     ["●亻","IDLX: cannot have a solitaire here [  ✘ ● ✘ 亻 ]"]
#     ["(●亻式)","IDLX: cannot have a solitaire here [ ( ✘ ● ✘ 亻式) ]"]
#     ["(⿰亻●式)","IDLX: cannot have a solitaire here [ (⿰亻 ✘ ● ✘ 式) ]"]
#     ["(⿱▽㓁允)","IDLX: cannot have a solitaire here [ (⿱ ✘ ▽ ✘ 㓁允) ]"]
#     ["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人●丨))","IDLX: cannot have a solitaire here [ ⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人 ✘ ● ✘ 丨)) ]"]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     try
#       result = IDLX.diagram_from_source probe
#       T.fail "expected an exception, got result #{rpr result}"
#     catch error
#       message = CND.remove_colors error[ 'message' ]
#       warn JSON.stringify [ probe, message, ]
#       T.eq message, matcher
#   #.........................................................................................................
#   return null



# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) _tokentree_as_formula" ] = ( T ) ->
#   ### TAINT configurables:
#   * whether to render JZR codepoints as PUA codepoints or as XNCRs
#   * whether to fix systematic IDL blunders such as ⿺辶言
#   * other normalizations (e.g. order of operators / terms)?
#   ###
#   probes_and_matchers = [
#     ["⿺辶言","⿺辶言"]
#     ["⿺辶〓","⿺辶〓"]
#     ["●","●"]
#     ["∅","∅"]
#     ["▽","▽"]
#     ["⿱癶⿰弓貝","⿱癶⿰弓貝"]
#     ["⿱⿰亻式貝","⿱⿰亻式貝"]
#     ["⿱⿰亻式⿱目八","⿱⿰亻式⿱目八"]
#     ["≈〇","≈〇"]
#     ["⿱〓〓","⿱〓〓"]
#     ["↻正","↻正"]
#     ["↔≈匕","↔≈匕"]
#     ["↔正","↔正"]
#     ["⿱丶乂","⿱丶乂"]
#     ["⿺走⿹◰口戈日","⿺走⿹◰口戈日"]
#     ["≈匚","≈匚"]
#     ["(⿱北㓁允)","(⿱北㓁允)"]
#     ["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))","⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))"]
#     ["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))","⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))"]
#     ["⿰臣(⿱𠂉(⿰人人人)(⿰古古古))","⿰臣(⿱𠂉(⿰人人人)(⿰古古古))"]
#     ["≈&jzr#xe174;","≈&jzr#xe174;"]
#     ["(⿱&jzr#xe223;一八⿰(⿱&jzr#xe223;一八)(⿱&jzr#xe223;一八))","(⿱&jzr#xe223;一八⿰(⿱&jzr#xe223;一八)(⿱&jzr#xe223;一八))"]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     ctx     = IDLX.parse probe
#     # help JSON.stringify IDLX._get_diagram ctx
#     result  = IDLX._tokentree_as_formula ctx, ctx.tokentree, 'xncr'
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) formula_from_source (1)" ] = ( T ) ->
#   probes_and_matchers = [
#     ["(⿱亠口冖一口十)","(⿱亠口冖一口十)"]
#     ["(⿱𠚤冖丿&cdp#x88c6;一八)","(⿱𠚤冖丿&cdp#x88c6;一八)"]
#     ["(⿱卄亠口冖口毛)","(⿱卄亠口冖口毛)"]
#     ["⿱卄⿰木貝","⿱卄⿰木貝"]
#     ["⿱艸⿰白⿹&jzr#xe19f;灬","⿱艸⿰白⿹&jzr#xe19f;灬"]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, ] in probes_and_matchers
#     result = IDLX.formula_from_source probe, 'xncr'
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) formula_from_source (2)" ] = ( T ) ->
#   probes_and_matchers = [
#     ["(⿱亠口冖一口十)","(⿱亠口冖一口十)"]
#     ["(⿱𠚤冖丿&cdp#x88c6;一八)","(⿱𠚤冖丿&cdp#x88c6;一八)"]
#     ["(⿱卄亠口冖口毛)","(⿱卄亠口冖口毛)"]
#     ["⿱卄⿰木貝","⿱卄⿰木貝"]
#     ["⿱艸⿰白⿹&jzr#xe19f;灬","⿱艸⿰白⿹灬"]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, ] in probes_and_matchers
#     result = IDLX.formula_from_source probe, 'uchr'
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) sexpr_from_source" ] = ( T ) ->
#   probes_and_matchers = [
#     ["●","( ● )"]
#     ["∅","( ∅ )"]
#     ["▽","( ▽ )"]
#     ["⿺辶言","( ⿺ 辶 言 )"]
#     ["⿺辶〓","( ⿺ 辶 〓 )"]
#     ["⿱癶⿰弓貝","( ⿱ 癶 ( ⿰ 弓 貝 ) )"]
#     ["⿱⿰亻式貝","( ⿱ ( ⿰ 亻 式 ) 貝 )"]
#     ["⿱⿰亻式⿱目八","( ⿱ ( ⿰ 亻 式 ) ( ⿱ 目 八 ) )"]
#     ["≈〇","( ≈ 〇 )"]
#     ["⿱〓〓","( ⿱ 〓 〓 )"]
#     ["↻正","( ↻ 正 )"]
#     ["(⿱亠口冖一口十)","( ⿱ 亠 口 冖 一 口 十 )"]
#     ["(⿱𠚤冖丿&cdp#x88c6;一八)","( ⿱ 𠚤 冖 丿 &cdp#x88c6; 一 八 )"]
#     ["(⿱卄亠口冖口毛)","( ⿱ 卄 亠 口 冖 口 毛 )"]
#     ["⿱卄⿰木貝","( ⿱ 卄 ( ⿰ 木 貝 ) )"]
#     ["⿱艸⿰白⿹&jzr#xe19f;灬","( ⿱ 艸 ( ⿰ 白 ( ⿹ &jzr#xe19f; 灬 ) ) )"]
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, ] in probes_and_matchers
#     result = IDLX.sexpr_from_source probe, 'xncr'
#     # urge JSON.stringify [ probe, result, ]
#     urge ( CND.grey probe ), ( CND.lime result )
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(experimental) using arbitrary characters as components" ] = ( T ) ->
#   probes_and_matchers = [
#     # [ '⿰ᄀᄀ',        '( ⿰ ᄀ ᄀ )', ]                # ᄁ
#     # [ '⿰（三）',     '( ⿰ （ 三 ） )', ]      # ㈢
#     # [ '⿱⿰株式⿰会社',    '⿱ ⿰ 株 式 ⿰ 会 社', ]      # ㍿
#     # ["⿱´a",""]
#     # ["⿺Lx",""]
#     [ '⿰\\(三\\) )',   '( ⿰ \\( 三 \\) )', ]      # ㈢
#     [ '⿴〇上',        '( ⿴ 〇 上 )', ]          # ㊤
#     # [ '☱', '(⿱xxx)', ]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     try
#       result = IDLX.sexpr_from_source probe, 'xncr'
#     catch error
#       T.fail error.message
#       continue
#     urge JSON.stringify [ probe, result, ]
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) doubt mark" ] = ( T ) ->
#   probes_and_matchers = [
#     ["⿰魚?𦟝","( ⿰ 魚 ( ? 𦟝 ) )"] # 𩼿
#     ]
#   #.........................................................................................................
#   for [ probe, matcher, ] in probes_and_matchers
#     result = IDLX.sexpr_from_source probe, 'xncr'
#     # urge JSON.stringify [ probe, result, ]
#     urge ( CND.grey probe ), ( CND.lime result )
#     T.eq result, matcher
#   #.........................................................................................................
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "(IDLX) tree-shaking" ] = ( T ) ->
#   #.........................................................................................................
#   glyphs_probes_and_matchers = [
#     ["㒚","⿰亻⿱(⿱爫工彐)心",{"formula_uchr":"⿰亻(⿱爫工彐心)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 爫 工 彐 心 ) )","diagram":["⿰","亻",["⿱","爫","工","彐","心"]]}]
#     ["㒚","⿰亻(⿱爫工彐心)",{"formula_uchr":"⿰亻(⿱爫工彐心)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 爫 工 彐 心 ) )","diagram":["⿰","亻",["⿱","爫","工","彐","心"]]}]
#     ["㒚","⿰亻⿱爫⿱工⿱彐心",{"formula_uchr":"⿰亻(⿱爫工彐心)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 爫 工 彐 心 ) )","diagram":["⿰","亻",["⿱","爫","工","彐","心"]]}]
#     ["㒚","⿰亻⿱⿱爫⿱工彐心",{"formula_uchr":"⿰亻(⿱爫工彐心)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 爫 工 彐 心 ) )","diagram":["⿰","亻",["⿱","爫","工","彐","心"]]}]
#     ["㒚","⿰亻⿱⿱⿱爫工彐心",{"formula_uchr":"⿰亻(⿱爫工彐心)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 爫 工 彐 心 ) )","diagram":["⿰","亻",["⿱","爫","工","彐","心"]]}]
#     ["㒢","⿰亻(⿱亼⿰⿰口口口𠕁)",{"formula_uchr":"⿰亻(⿱亼(⿰口口口)𠕁)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 亼 ( ⿰ 口 口 口 ) 𠕁 ) )","diagram":["⿰","亻",["⿱","亼",["⿰","口","口","口"],"𠕁"]]}]
#     ["㒦","⿰亻⿱⿱田⿰田田土",{"formula_uchr":"⿰亻(⿱田⿰田田土)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 田 ( ⿰ 田 田 ) 土 ) )","diagram":["⿰","亻",["⿱","田",["⿰","田","田"],"土"]]}]
#     ["㒦","⿰亻(⿱田⿰田田土)",{"formula_uchr":"⿰亻(⿱田⿰田田土)","sexpr_uchr":"( ⿰ 亻 ( ⿱ 田 ( ⿰ 田 田 ) 土 ) )","diagram":["⿰","亻",["⿱","田",["⿰","田","田"],"土"]]}]
#     ["㒪","(⿱人⿰臣臣⿰止豕)",{"formula_uchr":"(⿱人⿰臣臣⿰止豕)","sexpr_uchr":"( ⿱ 人 ( ⿰ 臣 臣 ) ( ⿰ 止 豕 ) )","diagram":["⿱","人",["⿰","臣","臣"],["⿰","止","豕"]]}]
#     ["𠋕","⿰亻⿱⿰工几木",{"formula_uchr":"⿰亻⿱⿰工几木","sexpr_uchr":"( ⿰ 亻 ( ⿱ ( ⿰ 工 几 ) 木 ) )","diagram":["⿰","亻",["⿱",["⿰","工","几"],"木"]]}]
#     ["𠋕","⿰<木<几",{"formula_uchr":"⿰<木<几","sexpr_uchr":"( ⿰ ( < 木 ) ( < 几 ) )","diagram":["⿰",["<","木"],["<","几"]]}]
#     ["㐒","⿱⿱刀口乙",{"formula_uchr":"(⿱刀口乙)","sexpr_uchr":"( ⿱ 刀 口 乙 )","diagram":["⿱","刀","口","乙"]}]
#     ["㐥","⿱⿰金⿰且力乙",{"formula_uchr":"⿱(⿰金且力)乙","sexpr_uchr":"( ⿱ ( ⿰ 金 且 力 ) 乙 )","diagram":["⿱",["⿰","金","且","力"],"乙"]}]
#     ["㐯","(⿱亠⿱口口⿱禾日)",{"formula_uchr":"(⿱亠口口禾日)","sexpr_uchr":"( ⿱ 亠 口 口 禾 日 )","diagram":["⿱","亠","口","口","禾","日"]}]
#     ]
#   #.........................................................................................................
#   for [ glyph, probe, matcher, ] in glyphs_probes_and_matchers
#     old_ctx       = IDLX.parse probe
#     old_ctx_copy  = JSON.parse JSON.stringify old_ctx
#     # # debug '30303', old_ctx.tokentree
#     new_ctx = IDLX.shake_tree old_ctx
#     T.eq old_ctx, old_ctx_copy
#     # # debug '30303', old_ctx.tokentree
#     # debug '22621', CND.truth CND.equals old_ctx, old_ctx_copy
#     # debug '22621', CND.truth old_ctx.tokentree is new_ctx.tokentree
#     # debug '22618', new_ctx.tokenlist
#     # process.exit 1
#     IDLX._get_formula new_ctx, 'uchr'
#     IDLX._get_sexpr   new_ctx, 'uchr'
#     { formula_uchr, sexpr_uchr, diagram, } = new_ctx
#     probe_maybe_suboptimal  = IDLX.formula_may_be_suboptimal null, probe
#     probe_was_suboptimal    = probe isnt formula_uchr
#     # debug JSON.stringify [ glyph, probe, { formula_uchr, sexpr_uchr, diagram, }, ]
#     # debug ( CND.truth probe_maybe_suboptimal ), ( CND.truth probe_was_suboptimal )
#     T.eq matcher, { formula_uchr, sexpr_uchr, diagram, }
#     if not probe_maybe_suboptimal
#       if probe_was_suboptimal then  T.fail "check for tree-shaking failed for #{rpr probe} (got #{formula_uchr})"
#       else                          T.ok true
#     else
#       T.ok true
#   #.........................................................................................................
#   return null

# ############################################################################################################
# unless module.parent?
#   # debug '0980', JSON.stringify ( Object.keys @ ), null '  '
#   include = [
#     "(IDL) demo"
#     "sanity checks (grammar data)"
#     #.......................................................................................................
#     "(IDL) parse simple formulas"
#     "(IDL) reject bogus formulas"
#     "(IDL) parse tree of simple formulas"
#     #.......................................................................................................
#     "(IDLX) reject bogus formulas"
#     "(IDLX) reject IDL operators with arity 3"
#     "(IDLX) parse simple formulas"
#     "(IDLX) parse extended formulas (plain)"
#     "(IDLX) parse extended formulas (bracketed)"
#     "(IDLX) reject bogus formulas (bracketed)"
#     "(IDLX) reject bogus formulas (solitaires)"
#     #.......................................................................................................
#     "(IDL) _tokentree_as_formula"
#     "(IDLX) _tokentree_as_formula"
#     "(IDLX) formula_from_source (1)"
#     "(IDLX) formula_from_source (2)"
#     "(IDLX) sexpr_from_source"
#     #.......................................................................................................
#     "(IDLX) doubt mark"
#     # "(experimental) using arbitrary characters as components"
#     "(IDLX) tree-shaking"
#     ]
#   @_prune()
#   @_main()


#   # demo_errors = ->
#   #   sources = [
#   #     ""
#   #     "⿺"
#   #     "走"
#   #     "走⿹◰口弓戈〓"
#   #     "⿺走x"
#   #     "⿺走⿹◰口弓戈〓"
#   #     ]
#   #   for source in sources
#   #     try
#   #       d = IDLX.tokentree_from_source source
#   #     catch error
#   #       info error[ 'message' ]

#   demo_new_api = ->
#     debug ( IDLX.diagram_from_source '⿺走日' )
#     debug ( IDLX.diagram_from_source '(⿱山人儿)' ) # ⿱山.*儿, ⿱人儿
#     debug ( IDLX.diagram_from_source '⿺辶〓' )
#     ### 'u-cjk-xb/2a18d' 𪆍 ###
#     debug ( IDLX.diagram_from_source '⿰⿹勹⿱从⿰个个鳥' )
#     # debug ( IDLX.diagram_from_source '⿰⿹勹(⿱从⿰个个)鳥' )
#     debug ( IDLX.diagram_from_source '⿰⿹勹(⿱从从⿰个个)鳥' )
#     debug ( IDLX.diagram_from_source '⿰⿹勹(⿱从⿰个个个)鳥' )
#     debug()
#     debug IDLX.parse                  '⿰阝⿱甘罕'
#     debug IDLX.diagram_from_source    '⿰阝⿱甘罕'
#     debug IDLX.tokenlist_from_source  '⿰阝⿱甘罕'
#     debug IDLX.tokentree_from_source  '⿰阝⿱甘罕'

#   demo_glyph_conversion = ->
#     #-----------------------------------------------------------------------------------------------------------
#     # IDL.NCR.chr_from_cid_and_csg = ( cid, csg  ) -> @as_chr cid, { csg: csg }
#     # #-----------------------------------------------------------------------------------------------------------
#     # IDL.NCR.normalize_to_xncr = ( glyph ) ->
#     #   # throw new Error "do we need this method?"
#     #   cid = @as_cid glyph
#     #   csg = if ( @as_rsg glyph ) is 'u-pua' then 'jzr' else @as_csg glyph
#     #   return @chr_from_cid_and_csg cid, 'jzr'
#     #-----------------------------------------------------------------------------------------------------------
#     IDL.NCR.jzr_as_xncr = ( glyph ) ->
#       nfo = @analyze glyph
#       return glyph unless ( nfo.rsg is 'u-pua' ) or ( nfo.csg is 'jzr' )
#       return @as_chr nfo.cid, { csg: 'jzr', }
#     #-----------------------------------------------------------------------------------------------------------
#     glyph       = "&jzr#xe234;"
#     glyph_uchr  = IDL.NCR.jzr_as_uchr glyph
#     glyph_r1    = IDL.NCR.jzr_as_xncr glyph
#     glyph_r2    = IDL.NCR.jzr_as_xncr glyph_uchr
#     debug '32900', [ glyph, glyph_uchr, glyph_r1, glyph_r2, ]
#     debug '32900', IDL.NCR.jzr_as_xncr 'x'
#   # demo_glyph_conversion()

###

need tests for IDL.parse


basic version should not use mingkwai-ncr; instead, use
Steven Levithan's XRegExp to confine valid components to
non-whitespace, non-meta codepoints

allow meta codepoints as components when escaped?

incorporate full set of JZR IDL operators

IDL algebra

collect operator, component statistics while building the tokentree

###








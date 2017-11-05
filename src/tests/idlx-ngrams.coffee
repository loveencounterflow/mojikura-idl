



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA-IDL/TESTS/NGRAMS'
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
{ IDLX, }                 = require '../..'


###
Ngrams with Relations:
谆:⿰讠(⿱亠口子)
谆∋⿰讠亠
谆∋⿱亠口
谆∋⿱口子
(谆∋⿱亠...子)
(谆∋⿰讠⿱亠)
###

#-----------------------------------------------------------------------------------------------------------
conflate = ( bigrams ) ->
  # bigrams.sort()
  R = []
  for { list, } in bigrams
    R.push ( ( x ? '█' ) for x in list ).join ''
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
conflate_II = ( bigrams ) ->
  # bigrams.sort()
  R = []
  for bigram in bigrams
    R.push ( token.s for token in bigram ).join ''
  return R.join ','

# #-----------------------------------------------------------------------------------------------------------
# TAP.test "(IDLX) ngrams", ( T ) ->
#   ### !!!!!!!!!!!!!!!!!!!! ###
#   [ '䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田' ] ### TAINT not normalized? ###
#   [ '𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝' ] ### TAINT not normalized? ###
#   ### !!!!!!!!!!!!!!!!!!!! ###
#   probes_and_matchers = [
#     ["谆:⿰讠(⿱亠口子)","⿰讠亠,⿱亠口,⿱口子"]
#     ["鐓:(⿰金(⿱亠口子)夊)","⿰金亠,⿱亠口,⿱口子,⿰子夊"]
#     ["享:(⿱亠口子)","⿱亠口,⿱口子"]
#     ["浮:⿰氵⿱爫子","⿰氵爫,⿱爫子"]
#     ["仔:⿰亻子","⿰亻子"]
#     ["郭:⿰(⿱亠口子)阝","⿱亠口,⿱口子,⿰子阝"]
#     ["孫:⿰子系","⿰子系"]
#     ["猛:⿰犭⿱子皿","⿰犭子,⿱子皿"]
#     ["孔:⿰子乚","⿰子乚"]
#     ["孙:⿰子小","⿰子小"]
#     ["乳:⿰⿱爫子乚","⿱爫子,⿰子乚"]
#     ["敦:⿰(⿱亠口子)夊","⿱亠口,⿱口子,⿰子夊"]
#     ["孟:⿱子皿","⿱子皿"]
#     ["孝:⿱耂子","⿱耂子"]
#     ["勃:⿰⿱子力","⿱子,⿰子力"]
#     ["孕:⿱乃子","⿱乃子"]
#     ["遜:⿺辶⿰子系","⿺辶子,⿰子系"]
#     ["鷻:(⿰鳥(⿱亠口子)夊)","⿰鳥亠,⿱亠口,⿱口子,⿰子夊"]
#     ["𤅸:⿰氵⿱⿰臣⿱𠂉⿴占𠂭皿","⿰氵臣,⿰臣𠂉,⿱𠂉占,⿴占𠂭,⿱𠂭皿"]
#     ["𣟁:⿰木⿱⿰阝⿱⿸𠂇工⺝土","⿰木阝,⿰阝𠂇,⿸𠂇工,⿱工⺝,⿱⺝土"]
#     ["𧃚:⿱卄⿰月⿺辶⿱⿸𠂇工⺝","⿱卄月,⿰月辶,⿺辶𠂇,⿸𠂇工,⿱工⺝"]
#     ["䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田","⿱⻗田,⿰田⻗,⿱⻗田,⿱田⻗,⿱⻗田,⿰田⻗,⿱⻗田"]
#     ["𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝,⿱䖝𠘨,⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝"]
#     ["𥷿:⿱𥫗⿰⿱巛田⿸广⿱廿灬","⿱𥫗巛,⿱巛田,⿰田广,⿸广廿,⿱廿灬"]
#     ["𤬣:⿱⿻⿴乂⿰⿱大亏瓜","⿻,⿴乂,⿱乂大,⿱大亏,⿰亏瓜"]
#     ]
#   for [ probe, matcher, ] in probes_and_matchers
#     [ glyph, formula, ] = probe.split ':'
#     diagram             = IDLX.parse formula
#     result              = conflate IDLX.get_relational_bigrams formula
#     debug JSON.stringify [ probe, result, ]
#     if result == matcher then T.ok true
#     else T.fail "expected #{matcher}, got #{result}"
#   T.end()

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) ngrams", ( T ) ->
  ### !!!!!!!!!!!!!!!!!!!! ###
  [ '䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田' ] ### TAINT not normalized? ###
  [ '𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝' ] ### TAINT not normalized? ###
  ### !!!!!!!!!!!!!!!!!!!! ###
  probes_and_matchers = [
    ["乳:⿰⿱爫子乚","⿱爫子,⿰子乚"]
    ["鐓:(⿰金(⿱亠口子)夊)","⿰金亠,⿱亠口,⿱口子,⿰子夊"]
    ["孔:⿰子乚","⿰子乚"]
    ["谆:⿰讠(⿱亠口子)","⿰讠亠,⿱亠口,⿱口子"]
    ["享:(⿱亠口子)","⿱亠口,⿱口子"]
    ["孫:⿰子系","⿰子系"]
    ["浮:⿰氵⿱爫子","⿰氵爫,⿱爫子"]
    ["仔:⿰亻子","⿰亻子"]
    ["郭:⿰(⿱亠口子)阝","⿱亠口,⿱口子,⿰子阝"]
    ["猛:⿰犭⿱子皿","⿰犭子,⿱子皿"]
    ["孙:⿰子小","⿰子小"]
    ["敦:⿰(⿱亠口子)夊","⿱亠口,⿱口子,⿰子夊"]
    ["孟:⿱子皿","⿱子皿"]
    ["孝:⿱耂子","⿱耂子"]
    ["勃:⿰⿱子力","⿱子,⿰子力"]
    ["孕:⿱乃子","⿱乃子"]
    ["遜:⿺辶⿰子系","⿺辶子,⿰子系"]
    ["鷻:(⿰鳥(⿱亠口子)夊)","⿰鳥亠,⿱亠口,⿱口子,⿰子夊"]
    ["𤅸:⿰氵⿱⿰臣⿱𠂉⿴占𠂭皿","⿰氵臣,⿰臣𠂉,⿱𠂉占,⿴占𠂭,⿱𠂭皿"]
    ["𣟁:⿰木⿱⿰阝⿱⿸𠂇工⺝土","⿰木阝,⿰阝𠂇,⿸𠂇工,⿱工⺝,⿱⺝土"]
    ["𧃚:⿱卄⿰月⿺辶⿱⿸𠂇工⺝","⿱卄月,⿰月辶,⿺辶𠂇,⿸𠂇工,⿱工⺝"]
    ["𥷿:⿱𥫗⿰⿱巛田⿸广⿱廿灬","⿱𥫗巛,⿱巛田,⿰田广,⿸广廿,⿱廿灬"]
    ["𤬣:⿱⿻⿴乂⿰⿱大亏瓜","⿻,⿴乂,⿱乂大,⿱大亏,⿰亏瓜"]
    ["䨻:⿱⿰⿱⻗田⿱⻗田⿰⿱⻗田⿱⻗田","⿱⻗田,⿰田⻗,⿱⻗田,⿱田⻗,⿱⻗田,⿰田⻗,⿱⻗田"]
    ["𩙡:⿱⿰⿵𠘨䖝⿵𠘨䖝⿰⿵𠘨䖝⿵𠘨䖝","⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝,⿱䖝𠘨,⿵𠘨䖝,⿰䖝𠘨,⿵𠘨䖝"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    [ glyph, formula, ] = probe.split ':'
    # debug '93209', formula
    urge  '93209', formula
    debug '93209', '\n' + rpr IDLX.list_tokens formula, { all_brackets: yes, }
    # continue
    # result = conflate IDLX.get_relational_bigrams formula
    result = conflate_II IDLX.get_relational_bigrams_II formula
    debug JSON.stringify [ probe, result, ]
    if result == matcher then T.ok true
    else T.fail "expected #{matcher}, got #{result}"
  T.end()




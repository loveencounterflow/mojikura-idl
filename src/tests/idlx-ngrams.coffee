



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
  for bigram in bigrams
    R.push ( token.s for token in bigram ).join ''
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) bigrams", ( T ) ->
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
    ["孙:⿰子小","⿰子小"]
    ["敦:⿰(⿱亠口子)夊","⿱亠口,⿱口子,⿰子夊"]
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
    ["竜:⿱立≈电","⿱立电"]
    ["覽:⿱⿰臣⿱罒見","⿰臣,⿱罒,⿱罒見"]
    ["龟:⿱𠂊≈电","⿱𠂊电"]
    ["𠗬:⿰冫⿸戶用","⿰冫戶,⿸戶用"]
    ["𠗭:(⿱⿰冫士寸)","⿰冫,⿱士,⿱士寸"]
    ["𠚖:⿶≈凵王","⿶凵王"]
    ["𠚜:⿶≈凵⿱爫臼","⿶凵爫,⿱爫臼"]
    ["𠚡:⿶?凵⿱爫臼","⿶凵爫,⿱爫臼"]
    ["繭:⿱卄⿻≈巾⿰糹虫","⿱卄巾,⿻巾糹,⿰糹虫"]
    ["𠕄:↻凹",""]
    ["孝:⿱耂子","⿱耂子"]
    ["猛:⿰犭⿱子皿","⿰犭子,⿱子皿"]
    ["孟:⿱子皿","⿱子皿"]
    ["勃:⿰⿱子力","⿱子,⿰子力"]
    ["郭:⿰(⿱亠口子)阝","⿱亠口,⿱口子,⿰子阝"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    [ glyph, formula, ] = probe.split ':'
    # debug '27821', IDLX.list_tokens formula, { all_brackets: yes, }
    try
      bigrams = IDLX.get_relational_bigrams_as_tokens formula
      # urge  '93209', formula
      # urge  '93209', bigrams
      result  = conflate bigrams
      # debug JSON.stringify [ probe, result, ]
    catch error
      T.fail "#{probe} failed with #{rpr error.message}"
      continue
    if result == matcher then T.ok true
    else T.fail "expected #{matcher}, got #{result}"
  T.end()

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) cached bigrams with indices", ( T ) ->
  probes_and_matchers = [
    ["乳:⿰⿱爫子乚","⿱爫子,⿰子乚"]
    ["鐓:(⿰金(⿱亠口子)夊)","⿰金亠,⿱亠口,⿱口子,⿰子夊"]
    ["孔:⿰子乚","⿰子乚"]
    ["𠃨:⿹⺄&cdp#x88c6;","⿹⺄&cdp#x88c6;"]
    ["𠄋:⿰(⿱&cdp#x855e;日丂)乞","⿱&cdp#x855e;日,⿱日丂,⿰丂乞"]
    ["𠄋:⿰酉⿱日𤴓","⿰酉日,⿱日𤴓"]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    [ glyph, formula, ] = probe.split ':'
    parts               = IDLX.split_formula formula
    bigrams_as_indices  = IDLX.get_relational_bigrams_as_indices formula
    bigrams             = IDLX.bigrams_from_parts_and_indices parts, bigrams_as_indices
    result              = ( bigram.join '' for bigram in bigrams ).join ','
    urge  '93209', glyph, formula
    help  '93209', result
    debug '22020', JSON.stringify [ probe, result, ]
    if result == matcher then T.ok true
    else T.fail "expected #{matcher}, got #{result}"
  T.end()

#-----------------------------------------------------------------------------------------------------------
TAP.test "(IDLX) bigrams as lists of texts", ( T ) ->
  probes_and_matchers = [
    ["乳:⿰⿱爫子乚",["⿱爫子","⿰子乚"]]
    ["鐓:(⿰金(⿱亠口子)夊)",["⿰金亠","⿱亠口","⿱口子","⿰子夊"]]
    ["孔:⿰子乚",["⿰子乚"]]
    ["𠃨:⿹⺄&cdp#x88c6;",["⿹⺄&cdp#x88c6;"]]
    ["𠄋:⿰(⿱&cdp#x855e;日丂)乞",["⿱&cdp#x855e;日","⿱日丂","⿰丂乞"]]
    ["𠄋:⿰酉⿱日𤴓",["⿰酉日","⿱日𤴓"]]
    ["𠕄:↻凹",[]]
    ["孝:⿱耂子",["⿱耂子"]]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    [ glyph, formula, ] = probe.split ':'
    result              = IDLX.get_relational_bigrams formula
    # debug '32321', JSON.stringify [ probe, result, ]
    if ( CND.equals result, matcher ) then T.ok true
    else T.fail "expected #{matcher}, got #{result}"
  T.end()




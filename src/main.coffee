


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MOJIKURA/IDL'
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
MKNCR                     = require 'mingkwai-ncr'


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------



############################################################################################################
unless module.parent?
  texts = [
    '⿺辶言'
    '⿺廴聿123'
    ]
  for text in texts
    for glyph in MKNCR.chrs_from_text text
      nfo             = MKNCR.describe glyph
      tags            = nfo.tag ? []
      tags_txt        = tags.join ' '
      is_cjk          = 'cjk' in tags
      is_ideograph    = 'ideograph' in tags
      is_idl          = 'idl' in tags
      color           = CND.grey
      if is_cjk         then color = CND.gold
      if is_ideograph   then color = CND.lime
      if is_idl         then color = CND.pink
      help ( color glyph ) #, ( CND.white tags_txt )




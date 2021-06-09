


'use strict'

@types    = new ( require 'intertype' ).Intertype()
x         = @types.export()
@isa      = x.isa
@type_of  = x.type_of
@validate = x.validate
@equals   = x.equals



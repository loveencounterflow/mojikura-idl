(function() {
  'use strict';
  var x;

  this.types = new (require('intertype')).Intertype();

  x = this.types.export();

  this.isa = x.isa;

  this.type_of = x.type_of;

  this.validate = x.validate;

  this.equals = x.equals;

}).call(this);

//# sourceMappingURL=types.js.map
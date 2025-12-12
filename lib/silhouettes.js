(function() {
  //###########################################################################################################
  var CND, badge, debug, help, info, rpr, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'KBM/MIXINS/IPC';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  // { IDLX, }            = require '../../../mojikura-idl'

  //-----------------------------------------------------------------------------------------------------------
  /* TAINT patterns should be derived from options or grammar */
  this._silhouette_binary_operator_pattern = /[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰]/g;

  this._silhouette_unary_operator_pattern = /[≈<>?↻↔↕]/g;

  this._silhouette_singleton_pattern = /[∅●▽]/g;

  /* TAINT will fail silently if we ever introduce singleton symbols from beyond U+ffff */
  this._silhouette_element_pattern = /(?:&[a-z0-9]*\#(?:x[a-f0-9]+|[0-9]+);)|(?:[\ud800-\udbff][\udc00-\udfff])|[^()bus]/g;

  //-----------------------------------------------------------------------------------------------------------
  this.silhouette_from_formula = function(formula) {
    var R;
    R = formula;
    R = R.replace(this._silhouette_binary_operator_pattern, 'b');
    R = R.replace(this._silhouette_unary_operator_pattern, 'u');
    R = R.replace(this._silhouette_singleton_pattern, 's');
    R = R.replace(this._silhouette_element_pattern, '.');
    return R;
  };

}).call(this);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vc3JjL3NpbGhvdWV0dGVzLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFFNEc7RUFBQTtBQUFBLE1BQUEsR0FBQSxFQUFBLEtBQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxHQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQTs7RUFDNUcsR0FBQSxHQUE0QixPQUFBLENBQVEsS0FBUjs7RUFDNUIsR0FBQSxHQUE0QixHQUFHLENBQUM7O0VBQ2hDLEtBQUEsR0FBNEI7O0VBQzVCLEtBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxPQUFmLEVBQTRCLEtBQTVCOztFQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1Qjs7RUFDNUIsSUFBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLE1BQWYsRUFBNEIsS0FBNUI7O0VBQzVCLElBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxNQUFmLEVBQTRCLEtBQTVCOztFQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1Qjs7RUFDNUIsT0FBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLFNBQWYsRUFBNEIsS0FBNUIsRUFUZ0Y7Ozs7OztFQWU1RyxJQUFDLENBQUEsbUNBQUQsR0FBd0M7O0VBQ3hDLElBQUMsQ0FBQSxrQ0FBRCxHQUF3Qzs7RUFDeEMsSUFBQyxDQUFBLDZCQUFELEdBQXdDLFNBakJvRTs7O0VBbUI1RyxJQUFDLENBQUEsMkJBQUQsR0FBd0Msc0ZBbkJvRTs7O0VBMEI1RyxJQUFDLENBQUEsdUJBQUQsR0FBMkIsUUFBQSxDQUFFLE9BQUYsQ0FBQTtBQUMzQixRQUFBO0lBQUUsQ0FBQSxHQUFJO0lBQ0osQ0FBQSxHQUFJLENBQUMsQ0FBQyxPQUFGLENBQVUsSUFBQyxDQUFBLG1DQUFYLEVBQWdELEdBQWhEO0lBQ0osQ0FBQSxHQUFJLENBQUMsQ0FBQyxPQUFGLENBQVUsSUFBQyxDQUFBLGtDQUFYLEVBQWdELEdBQWhEO0lBQ0osQ0FBQSxHQUFJLENBQUMsQ0FBQyxPQUFGLENBQVUsSUFBQyxDQUFBLDZCQUFYLEVBQWdELEdBQWhEO0lBQ0osQ0FBQSxHQUFJLENBQUMsQ0FBQyxPQUFGLENBQVUsSUFBQyxDQUFBLDJCQUFYLEVBQWdELEdBQWhEO0FBQ0osV0FBTztFQU5rQjtBQTFCaUYiLCJzb3VyY2VzQ29udGVudCI6WyJcblxuIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5DTkQgICAgICAgICAgICAgICAgICAgICAgID0gcmVxdWlyZSAnY25kJ1xucnByICAgICAgICAgICAgICAgICAgICAgICA9IENORC5ycHJcbmJhZGdlICAgICAgICAgICAgICAgICAgICAgPSAnS0JNL01JWElOUy9JUEMnXG5kZWJ1ZyAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2RlYnVnJywgICAgIGJhZGdlXG53YXJuICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3dhcm4nLCAgICAgIGJhZGdlXG5oZWxwICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2hlbHAnLCAgICAgIGJhZGdlXG51cmdlICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3VyZ2UnLCAgICAgIGJhZGdlXG5pbmZvICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2luZm8nLCAgICAgIGJhZGdlXG53aGlzcGVyICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3doaXNwZXInLCAgIGJhZGdlXG4jIHsgSURMWCwgfSAgICAgICAgICAgID0gcmVxdWlyZSAnLi4vLi4vLi4vbW9qaWt1cmEtaWRsJ1xuXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuIyMjIFRBSU5UIHBhdHRlcm5zIHNob3VsZCBiZSBkZXJpdmVkIGZyb20gb3B0aW9ucyBvciBncmFtbWFyICMjI1xuQF9zaWxob3VldHRlX2JpbmFyeV9vcGVyYXRvcl9wYXR0ZXJuICA9IC8vLyBbIOK/sOK/seK/tOK/teK/tuK/t+K/uOK/ueK/uuK/u+KXsCBdIC8vL2dcbkBfc2lsaG91ZXR0ZV91bmFyeV9vcGVyYXRvcl9wYXR0ZXJuICAgPSAvLy8gWyDiiYg8Pj/ihrvihpTihpUgXSAvLy9nXG5AX3NpbGhvdWV0dGVfc2luZ2xldG9uX3BhdHRlcm4gICAgICAgID0gLy8vIFsg4oiF4peP4pa9IF0gLy8vZ1xuIyMjIFRBSU5UIHdpbGwgZmFpbCBzaWxlbnRseSBpZiB3ZSBldmVyIGludHJvZHVjZSBzaW5nbGV0b24gc3ltYm9scyBmcm9tIGJleW9uZCBVK2ZmZmYgIyMjXG5AX3NpbGhvdWV0dGVfZWxlbWVudF9wYXR0ZXJuICAgICAgICAgID0gLy8vXG4gICg/OiAmIFthLXowLTldKiBcXCMgKD86IHggW2EtZjAtOV0rIHwgWzAtOV0rICkgOyApIHxcbiAgKD86IFsgIFxcdWQ4MDAtXFx1ZGJmZiBdIFsgXFx1ZGMwMC1cXHVkZmZmIF0gKSB8XG4gIFteICggKSBiIHUgcyBdXG4gIC8vL2dcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5Ac2lsaG91ZXR0ZV9mcm9tX2Zvcm11bGEgPSAoIGZvcm11bGEgKSAtPlxuICBSID0gZm9ybXVsYVxuICBSID0gUi5yZXBsYWNlIEBfc2lsaG91ZXR0ZV9iaW5hcnlfb3BlcmF0b3JfcGF0dGVybiwgJ2InXG4gIFIgPSBSLnJlcGxhY2UgQF9zaWxob3VldHRlX3VuYXJ5X29wZXJhdG9yX3BhdHRlcm4sICAndSdcbiAgUiA9IFIucmVwbGFjZSBAX3NpbGhvdWV0dGVfc2luZ2xldG9uX3BhdHRlcm4sICAgICAgICdzJ1xuICBSID0gUi5yZXBsYWNlIEBfc2lsaG91ZXR0ZV9lbGVtZW50X3BhdHRlcm4sICAgICAgICAgJy4nXG4gIHJldHVybiBSXG5cblxuXG4iXX0=

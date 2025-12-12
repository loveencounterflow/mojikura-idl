(function() {
  //###########################################################################################################
  var CND, assign, badge, debug, first_of, help, info, last_of, pluck, rpr, urge, warn, whisper;

  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'IDLX/NGRAMS';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  // { IDL, IDLX, }            = require '../../../mojikura-idl'
  first_of = function(x) {
    return x[0];
  };

  last_of = function(x) {
    return x[x.length - 1];
  };

  assign = Object.assign;

  //-----------------------------------------------------------------------------------------------------------
  pluck = function(x, key, fallback) {
    var R;
    R = x[key];
    if (R === void 0) {
      R = fallback;
    }
    delete x[key];
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.get_relational_bigrams = function(formula) {
    var bigram, token;
    return (function() {
      var i, len, ref, results;
      ref = this.get_relational_bigrams_as_tokens(formula);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        bigram = ref[i];
        results.push(((function() {
          var j, len1, results1;
          results1 = [];
          for (j = 0, len1 = bigram.length; j < len1; j++) {
            token = bigram[j];
            results1.push(token.s);
          }
          return results1;
        })()).join(''));
      }
      return results;
    }).call(this);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.get_relational_bigrams_as_tokens = function(formula) {
    /* ⊚⊙⎉⏵⏺⏹⏸ */
    var R, _, first_element, first_operator, i, last_element, last_operator, len, operator, operators, prvs_token, start_token, stop_token, this_token, tokens;
    tokens = this.list_tokens(formula, {
      all_brackets: true
    });
    R = [];
    operators = [];
    prvs_token = null;
// countdowns    = []
//.........................................................................................................
    for (i = 0, len = tokens.length; i < len; i++) {
      this_token = tokens[i];
      this_token = assign({}, this_token);
      // debug '87900', rpr this_token
      switch (this_token.t) {
        case 'lbracket':
          null;
          break;
        case 'rbracket':
          operators.pop();
          prvs_token.o = last_of(operators);
          break;
        case 'binary_operator':
          operators.push(this_token);
          break;
        case 'unary_operator':
          operators.push(this_token);
          break;
        case 'component':
        case 'proxy':
          this_token.o = last_of(operators);
          if (prvs_token != null) {
            operator = pluck(prvs_token, 'o');
            R.push([operator, prvs_token, this_token]);
          }
          prvs_token = this_token;
          break;
        default:
          throw new Error(`unknown token type ${rpr(this_token)}`);
      }
    }
    //.........................................................................................................
    if (R.length > 0) {
      delete (last_of(last_of(R))).o;
      [first_operator, first_element, _] = first_of(R);
      [last_operator, _, last_element] = last_of(R);
      start_token = {
        t: 'start',
        s: '⊚',
        i: null
      };
      stop_token = {
        t: 'stop',
        s: '⊚',
        i: null
      };
      R.unshift([first_operator, start_token, first_element]);
      R.push([last_operator, last_element, stop_token]);
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.get_relational_bigrams_as_indices = function(formula) {
    return this._indices_from_bigram_tokens(this.get_relational_bigrams_as_tokens(formula));
  };

  //-----------------------------------------------------------------------------------------------------------
  this._indices_from_bigram_tokens = function(bigrams) {
    var bigram, token;
    return (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = bigrams.length; i < len; i++) {
        bigram = bigrams[i];
        results.push((function() {
          var j, len1, results1;
          results1 = [];
          for (j = 0, len1 = bigram.length; j < len1; j++) {
            token = bigram[j];
            results1.push(token.i);
          }
          return results1;
        })());
      }
      return results;
    })();
  };

  //-----------------------------------------------------------------------------------------------------------
  this.split_formula = function(formula) {
    var token;
    return (function() {
      var i, len, ref, results;
      ref = this.list_tokens(formula);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        token = ref[i];
        results.push(token.s);
      }
      return results;
    }).call(this);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.bigrams_from_formula_and_indices = function(formula, bigrams_as_indices) {
    return this.bigrams_from_parts_and_indices(this.split_formula(formula), bigrams_as_indices);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.bigrams_from_parts_and_indices = function(parts, bigrams_as_indices) {
    var bigram_indices, idx;
    return (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = bigrams_as_indices.length; i < len; i++) {
        bigram_indices = bigrams_as_indices[i];
        results.push((function() {
          var j, len1, ref, results1;
          results1 = [];
          for (j = 0, len1 = bigram_indices.length; j < len1; j++) {
            idx = bigram_indices[j];
            results1.push((ref = parts[idx]) != null ? ref : '⊚');
          }
          return results1;
        })());
      }
      return results;
    })();
  };

}).call(this);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vc3JjL25ncmFtcy5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBRTRHO0VBQUE7QUFBQSxNQUFBLEdBQUEsRUFBQSxNQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUEsSUFBQSxFQUFBLElBQUEsRUFBQSxPQUFBLEVBQUEsS0FBQSxFQUFBLEdBQUEsRUFBQSxJQUFBLEVBQUEsSUFBQSxFQUFBOztFQUM1RyxHQUFBLEdBQTRCLE9BQUEsQ0FBUSxLQUFSOztFQUM1QixHQUFBLEdBQTRCLEdBQUcsQ0FBQzs7RUFDaEMsS0FBQSxHQUE0Qjs7RUFDNUIsS0FBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLE9BQWYsRUFBNEIsS0FBNUI7O0VBQzVCLElBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxNQUFmLEVBQTRCLEtBQTVCOztFQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1Qjs7RUFDNUIsSUFBQSxHQUE0QixHQUFHLENBQUMsVUFBSixDQUFlLE1BQWYsRUFBNEIsS0FBNUI7O0VBQzVCLElBQUEsR0FBNEIsR0FBRyxDQUFDLFVBQUosQ0FBZSxNQUFmLEVBQTRCLEtBQTVCOztFQUM1QixPQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsU0FBZixFQUE0QixLQUE1QixFQVRnRjs7O0VBVzVHLFFBQUEsR0FBNEIsUUFBQSxDQUFFLENBQUYsQ0FBQTtXQUFTLENBQUMsQ0FBRSxDQUFGO0VBQVY7O0VBQzVCLE9BQUEsR0FBNEIsUUFBQSxDQUFFLENBQUYsQ0FBQTtXQUFTLENBQUMsQ0FBRSxDQUFDLENBQUMsTUFBRixHQUFXLENBQWI7RUFBVjs7RUFDNUIsTUFBQSxHQUE0QixNQUFNLENBQUMsT0FieUU7OztFQWdCNUcsS0FBQSxHQUFRLFFBQUEsQ0FBRSxDQUFGLEVBQUssR0FBTCxFQUFVLFFBQVYsQ0FBQTtBQUNSLFFB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IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5DTkQgICAgICAgICAgICAgICAgICAgICAgID0gcmVxdWlyZSAnY25kJ1xucnByICAgICAgICAgICAgICAgICAgICAgICA9IENORC5ycHJcbmJhZGdlICAgICAgICAgICAgICAgICAgICAgPSAnSURMWC9OR1JBTVMnXG5kZWJ1ZyAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2RlYnVnJywgICAgIGJhZGdlXG53YXJuICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3dhcm4nLCAgICAgIGJhZGdlXG5oZWxwICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2hlbHAnLCAgICAgIGJhZGdlXG51cmdlICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3VyZ2UnLCAgICAgIGJhZGdlXG5pbmZvICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2luZm8nLCAgICAgIGJhZGdlXG53aGlzcGVyICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ3doaXNwZXInLCAgIGJhZGdlXG4jIHsgSURMLCBJRExYLCB9ICAgICAgICAgICAgPSByZXF1aXJlICcuLi8uLi8uLi9tb2ppa3VyYS1pZGwnXG5maXJzdF9vZiAgICAgICAgICAgICAgICAgID0gKCB4ICkgLT4geFsgMCBdXG5sYXN0X29mICAgICAgICAgICAgICAgICAgID0gKCB4ICkgLT4geFsgeC5sZW5ndGggLSAxIF1cbmFzc2lnbiAgICAgICAgICAgICAgICAgICAgPSBPYmplY3QuYXNzaWduXG5cbiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxucGx1Y2sgPSAoIHgsIGtleSwgZmFsbGJhY2sgKSAtPlxuICBSID0geFsga2V5IF1cbiAgUiA9IGZhbGxiYWNrIGlmIFIgaXMgdW5kZWZpbmVkXG4gIGRlbGV0ZSB4WyBrZXkgXVxuICByZXR1cm4gUlxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBnZXRfcmVsYXRpb25hbF9iaWdyYW1zID0gKCBmb3JtdWxhICkgLT5cbiAgcmV0dXJuICggKCB0b2tlbi5zIGZvciB0b2tlbiBpbiBiaWdyYW0gKS5qb2luICcnIGZvciBiaWdyYW0gaW4gQGdldF9yZWxhdGlvbmFsX2JpZ3JhbXNfYXNfdG9rZW5zIGZvcm11bGEgKVxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBnZXRfcmVsYXRpb25hbF9iaWdyYW1zX2FzX3Rva2VucyA9ICggZm9ybXVsYSApIC0+XG4gIHRva2VucyAgICAgICAgPSBAbGlzdF90b2tlbnMgZm9ybXVsYSwgeyBhbGxfYnJhY2tldHM6IHllcywgfVxuICBSICAgICAgICAgICAgID0gW11cbiAgb3BlcmF0b3JzICAgICA9IFtdXG4gIHBydnNfdG9rZW4gICAgPSBudWxsXG4gICMgY291bnRkb3ducyAgICA9IFtdXG4gICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgZm9yIHRoaXNfdG9rZW4gaW4gdG9rZW5zXG4gICAgdGhpc190b2tlbiA9IGFzc2lnbiB7fSwgdGhpc190b2tlblxuICAgICMgZGVidWcgJzg3OTAwJywgcnByIHRoaXNfdG9rZW5cbiAgICBzd2l0Y2ggdGhpc190b2tlbi50XG4gICAgICB3aGVuICdsYnJhY2tldCdcbiAgICAgICAgbnVsbFxuICAgICAgd2hlbiAncmJyYWNrZXQnXG4gICAgICAgIG9wZXJhdG9ycy5wb3AoKVxuICAgICAgICBwcnZzX3Rva2VuLm8gPSBsYXN0X29mIG9wZXJhdG9yc1xuICAgICAgd2hlbiAnYmluYXJ5X29wZXJhdG9yJ1xuICAgICAgICBvcGVyYXRvcnMucHVzaCB0aGlzX3Rva2VuXG4gICAgICB3aGVuICd1bmFyeV9vcGVyYXRvcidcbiAgICAgICAgb3BlcmF0b3JzLnB1c2ggdGhpc190b2tlblxuICAgICAgd2hlbiAnY29tcG9uZW50JywgJ3Byb3h5J1xuICAgICAgICB0aGlzX3Rva2VuLm8gPSBsYXN0X29mIG9wZXJhdG9yc1xuICAgICAgICBpZiBwcnZzX3Rva2VuP1xuICAgICAgICAgIG9wZXJhdG9yID0gcGx1Y2sgcHJ2c190b2tlbiwgJ28nXG4gICAgICAgICAgUi5wdXNoIFsgb3BlcmF0b3IsIHBydnNfdG9rZW4sIHRoaXNfdG9rZW4sIF1cbiAgICAgICAgcHJ2c190b2tlbiA9IHRoaXNfdG9rZW5cbiAgICAgIGVsc2VcbiAgICAgICAgdGhyb3cgbmV3IEVycm9yIFwidW5rbm93biB0b2tlbiB0eXBlICN7cnByIHRoaXNfdG9rZW59XCJcbiAgIy4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLlxuICBpZiBSLmxlbmd0aCA+IDBcbiAgICBkZWxldGUgKCBsYXN0X29mIGxhc3Rfb2YgUiApLm9cbiAgICAjIyMg4oqa4oqZ4o6J4o+14o+64o+54o+47oGFICMjI1xuICAgIFsgZmlyc3Rfb3BlcmF0b3IsIGZpcnN0X2VsZW1lbnQsICBfLCAgICAgICAgICAgIF0gPSBmaXJzdF9vZiBSXG4gICAgWyBsYXN0X29wZXJhdG9yLCAgXywgICAgICAgICAgICAgIGxhc3RfZWxlbWVudCwgXSA9IGxhc3Rfb2YgIFJcbiAgICBzdGFydF90b2tlbiA9IHsgdDogJ3N0YXJ0JywgczogJ+KKmicsIGk6IG51bGwsIH1cbiAgICBzdG9wX3Rva2VuICA9IHsgdDogJ3N0b3AnLCAgczogJ+KKmicsIGk6IG51bGwsIH1cbiAgICBSLnVuc2hpZnQgWyBmaXJzdF9vcGVyYXRvciwgc3RhcnRfdG9rZW4sICBmaXJzdF9lbGVtZW50LCAgXVxuICAgIFIucHVzaCAgICBbIGxhc3Rfb3BlcmF0b3IsICBsYXN0X2VsZW1lbnQsIHN0b3BfdG9rZW4sICAgICBdXG4gICMuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi5cbiAgcmV0dXJuIFJcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5AZ2V0X3JlbGF0aW9uYWxfYmlncmFtc19hc19pbmRpY2VzID0gKCBmb3JtdWxhICkgLT5cbiAgcmV0dXJuIEBfaW5kaWNlc19mcm9tX2JpZ3JhbV90b2tlbnMgQGdldF9yZWxhdGlvbmFsX2JpZ3JhbXNfYXNfdG9rZW5zIGZvcm11bGFcblxuIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG5AX2luZGljZXNfZnJvbV9iaWdyYW1fdG9rZW5zID0gKCBiaWdyYW1zICkgLT5cbiAgcmV0dXJuICggKCB0b2tlbi5pIGZvciB0b2tlbiBpbiBiaWdyYW0gKSBmb3IgYmlncmFtIGluIGJpZ3JhbXMgKVxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBzcGxpdF9mb3JtdWxhID0gKCBmb3JtdWxhICkgLT5cbiAgcmV0dXJuICggdG9rZW4ucyBmb3IgdG9rZW4gaW4gQGxpc3RfdG9rZW5zIGZvcm11bGEgKVxuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBiaWdyYW1zX2Zyb21fZm9ybXVsYV9hbmRfaW5kaWNlcyA9ICggZm9ybXVsYSwgYmlncmFtc19hc19pbmRpY2VzICkgLT5cbiAgcmV0dXJuIEBiaWdyYW1zX2Zyb21fcGFydHNfYW5kX2luZGljZXMgKCBAc3BsaXRfZm9ybXVsYSBmb3JtdWxhICksIGJpZ3JhbXNfYXNfaW5kaWNlc1xuXG4jLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbkBiaWdyYW1zX2Zyb21fcGFydHNfYW5kX2luZGljZXMgPSAoIHBhcnRzLCBiaWdyYW1zX2FzX2luZGljZXMgKSAtPlxuICByZXR1cm4gKCAoICggcGFydHNbIGlkeCBdID8gJ+KKmicgKSBmb3IgaWR4IGluIGJpZ3JhbV9pbmRpY2VzICkgZm9yIGJpZ3JhbV9pbmRpY2VzIGluIGJpZ3JhbXNfYXNfaW5kaWNlcyApXG5cblxuXG5cblxuXG5cbiJdfQ==

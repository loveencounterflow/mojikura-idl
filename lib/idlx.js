(function() {
  // Generated automatically by nearley, version 2.20.1
  // http://github.com/Hardmath123/nearley
  (function() {
    var $unbracket, $unnest, $unpack, CND, O, badge, before_after, debug, equals, grammar, help, id, info, isa, log, rpr, splice_into, type_of, validate;
    id = function(d) {
      return d[0];
    };
    CND = require('cnd');
    rpr = CND.rpr;
    badge = 'MOJIKURA-IDL/IDLX';
    log = CND.get_logger('plain', badge);
    debug = CND.get_logger('debug', badge);
    info = CND.get_logger('info', badge);
    help = CND.get_logger('help', badge);
    ({isa, type_of, validate, equals} = require('./types'));
    
    // #-----------------------------------------------------------------------------------------------------------
    // O =
    //   silent:     no
    //   unpack:     yes
    //   unbracket:  yes
    //   unnest:     yes

    //-----------------------------------------------------------------------------------------------------------
    O = {
      silent: true,
      unpack: true,
      unbracket: true,
      unnest: true
    };
    
    //-----------------------------------------------------------------------------------------------------------
    before_after = function(before, after) {
      return (CND.grey('\n<- ')) + (CND.orange(rpr(before))) + (CND.grey('\n-> ')) + (CND.lime(rpr(after)));
    };
    
    //-----------------------------------------------------------------------------------------------------------
    splice_into = function(target, idx) {
      var sub_data, type;
      if ((type = type_of((sub_data = target[idx]))) !== 'list') {
        throw new Error(`expected a list, got a ${type} as element 2 of ${rpr(target)}`);
      }
      target.splice(idx, 1, ...sub_data);
      return target;
    };
    
    //-----------------------------------------------------------------------------------------------------------
    $unpack = function(label, ...keys) {
      return function(data, loc, reject) {
        var R, i, key, len;
        if (O.unpack) {
          R = data;
          for (i = 0, len = keys.length; i < len; i++) {
            key = keys[i];
            if (isa.text(R)) {
              break;
            }
            R = R[key];
          }
        } else {
          R = Object.assign([], data);
        }
        if (!O.silent) {
          R.label = label;
          info('$unpack', label, before_after(data, R));
        }
        return R;
      };
    };
    
    //-----------------------------------------------------------------------------------------------------------
    $unbracket = function(label, ...keys) {
      var unpack;
      unpack = $unpack(label, ...keys);
      return function(data, loc, reject) {
        var R;
        R = unpack(data, loc, reject);
        if (O.unbracket) {
          R = R.slice(1, R.length - 1);
          splice_into(R, 1);
        }
        if (!O.silent) {
          info('$unbracket', before_after(data, R));
        }
        return R;
      };
    };
    
    //-----------------------------------------------------------------------------------------------------------
    $unnest = function(label, ...keys) {
      var unpack;
      unpack = $unpack(label, ...keys);
      return function(data, loc, reject) {
        var R;
        R = unpack(data, loc, reject);
        if (O.unnest) {
          splice_into(R, 2);
        }
        if (!O.silent) {
          info('$unnest', before_after(data, R));
        }
        return R;
      };
    };
    grammar = {
      Lexer: void 0,
      ParserRules: [
        {
          "name": "start$subexpression$1",
          "symbols": ["+solitaire+"]
        },
        {
          "name": "start$subexpression$1",
          "symbols": ["term"]
        },
        {
          "name": "start",
          "symbols": ["start$subexpression$1"],
          "postprocess": $unpack('start',
        0,
        0)
        },
        {
          "name": "expr$subexpression$1",
          "symbols": ["term"]
        },
        {
          "name": "expr$subexpression$1",
          "symbols": ["component"]
        },
        {
          "name": "expr",
          "symbols": ["expr$subexpression$1"],
          "postprocess": $unpack('expr',
        0,
        0,
        0)
        },
        {
          "name": "expr3+$subexpression$1$ebnf$1",
          "symbols": ["expr"]
        },
        {
          "name": "expr3+$subexpression$1$ebnf$1",
          "symbols": ["expr3+$subexpression$1$ebnf$1",
        "expr"],
          "postprocess": function(d) {
            return d[0].concat([d[1]]);
          }
        },
        {
          "name": "expr3+$subexpression$1",
          "symbols": ["expr",
        "expr",
        "expr3+$subexpression$1$ebnf$1"]
        },
        {
          "name": "expr3+",
          "symbols": ["expr3+$subexpression$1"],
          "postprocess": $unnest('expr3+',
        0)
        },
        {
          "name": "term$subexpression$1",
          "symbols": ["unary"]
        },
        {
          "name": "term$subexpression$1",
          "symbols": ["binary"]
        },
        {
          "name": "term$subexpression$1",
          "symbols": ["+bracket+ed"]
        },
        {
          "name": "term",
          "symbols": ["term$subexpression$1"],
          "postprocess": $unpack('term',
        0)
        },
        {
          "name": "unary$subexpression$1",
          "symbols": ["+unary_operator+",
        "expr"]
        },
        {
          "name": "unary",
          "symbols": ["unary$subexpression$1"],
          "postprocess": $unpack('unary',
        0)
        },
        {
          "name": "binary$subexpression$1",
          "symbols": ["+binary_operator+",
        "expr",
        "expr"]
        },
        {
          "name": "binary",
          "symbols": ["binary$subexpression$1"],
          "postprocess": $unpack('binary',
        0)
        },
        {
          "name": "+bracket+ed$subexpression$1",
          "symbols": ["lbracket",
        "+binary_operator+",
        "expr3+",
        "rbracket"]
        },
        {
          "name": "+bracket+ed",
          "symbols": ["+bracket+ed$subexpression$1"],
          "postprocess": $unbracket('+bracket+ed',
        0)
        },
        {
          "name": "component",
          "symbols": ["+proxy+"]
        },
        {
          "name": "component",
          "symbols": [/./],
          "postprocess": function(data,
        loc,
        reject) {
            var R;
            [
              {
                value: R
              }
            ] = data;
            if (/^\s+$/.test(R)) {
              return reject;
            }
            if (/^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽〓§]$/.test(R)) {
              // return reject if /^[≈<>?↻↔↕⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻◰()∅●▽ⓧⓨⓩ〓§]$/.test R
              return reject;
            }
            if (!O.silent) {
              info('component',
        before_after(data,
        R));
            }
            return R;
          }
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["similar"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["heavy"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["light"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["doubt"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["upsidedown"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["mirror"]
        },
        {
          "name": "+unary_operator+$subexpression$1",
          "symbols": ["flip"]
        },
        {
          "name": "+unary_operator+",
          "symbols": ["+unary_operator+$subexpression$1"],
          "postprocess": $unpack('+unary_operator+',
        0,
        0)
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["leftright"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["topdown"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["surround"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["cap"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["cup"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["leftembrace"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["topleft"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["topright"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["leftbottom"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["interlace"]
        },
        {
          "name": "+binary_operator+$subexpression$1",
          "symbols": ["topleftcorner"]
        },
        {
          "name": "+binary_operator+",
          "symbols": ["+binary_operator+$subexpression$1"],
          "postprocess": $unpack('+binary_operator+',
        0,
        0)
        },
        {
          "name": "+solitaire+$subexpression$1",
          "symbols": ["nosuchformula"]
        },
        {
          "name": "+solitaire+$subexpression$1",
          "symbols": ["terminator"]
        },
        {
          "name": "+solitaire+$subexpression$1",
          "symbols": ["inhibitor"]
        },
        {
          "name": "+solitaire+",
          "symbols": ["+solitaire+$subexpression$1"],
          "postprocess": $unpack('+solitaire+',
        0)
        },
        {
          "name": "+proxy+$subexpression$1",
          "symbols": ["getamark"]
        },
        {
          "name": "+proxy+$subexpression$1",
          "symbols": ["curl"]
        },
        {
          "name": "+proxy+",
          "symbols": ["+proxy+$subexpression$1"],
          "postprocess": $unpack('+proxy+',
        0,
        0)
        },
        {
          "name": "similar",
          "symbols": [
            {
              "literal": "≈"
            }
          ],
          "postprocess": $unpack('similar',
        0,
        'value')
        },
        {
          "name": "heavy",
          "symbols": [
            {
              "literal": "<"
            }
          ],
          "postprocess": $unpack('heavy',
        0,
        'value')
        },
        {
          "name": "light",
          "symbols": [
            {
              "literal": ">"
            }
          ],
          "postprocess": $unpack('light',
        0,
        'value')
        },
        {
          "name": "doubt",
          "symbols": [
            {
              "literal": "?"
            }
          ],
          "postprocess": $unpack('doubt',
        0,
        'value')
        },
        {
          "name": "upsidedown",
          "symbols": [
            {
              "literal": "↻"
            }
          ],
          "postprocess": $unpack('upsidedown',
        0,
        'value')
        },
        {
          "name": "mirror",
          "symbols": [
            {
              "literal": "↔"
            }
          ],
          "postprocess": $unpack('mirror',
        0,
        'value')
        },
        {
          "name": "flip",
          "symbols": [
            {
              "literal": "↕"
            }
          ],
          "postprocess": $unpack('flip',
        0,
        'value')
        },
        {
          "name": "leftright",
          "symbols": [
            {
              "literal": "⿰"
            }
          ],
          "postprocess": $unpack('leftright',
        0,
        'value')
        },
        {
          "name": "topdown",
          "symbols": [
            {
              "literal": "⿱"
            }
          ],
          "postprocess": $unpack('topdown',
        0,
        'value')
        },
        {
          "name": "surround",
          "symbols": [
            {
              "literal": "⿴"
            }
          ],
          "postprocess": $unpack('surround',
        0,
        'value')
        },
        {
          "name": "cap",
          "symbols": [
            {
              "literal": "⿵"
            }
          ],
          "postprocess": $unpack('cap',
        0,
        'value')
        },
        {
          "name": "cup",
          "symbols": [
            {
              "literal": "⿶"
            }
          ],
          "postprocess": $unpack('cup',
        0,
        'value')
        },
        {
          "name": "leftembrace",
          "symbols": [
            {
              "literal": "⿷"
            }
          ],
          "postprocess": $unpack('leftembrace',
        0,
        'value')
        },
        {
          "name": "topleft",
          "symbols": [
            {
              "literal": "⿸"
            }
          ],
          "postprocess": $unpack('topleft',
        0,
        'value')
        },
        {
          "name": "topright",
          "symbols": [
            {
              "literal": "⿹"
            }
          ],
          "postprocess": $unpack('topright',
        0,
        'value')
        },
        {
          "name": "leftbottom",
          "symbols": [
            {
              "literal": "⿺"
            }
          ],
          "postprocess": $unpack('leftbottom',
        0,
        'value')
        },
        {
          "name": "interlace",
          "symbols": [
            {
              "literal": "⿻"
            }
          ],
          "postprocess": $unpack('interlace',
        0,
        'value')
        },
        {
          "name": "topleftcorner",
          "symbols": [
            {
              "literal": "◰"
            }
          ],
          "postprocess": $unpack('topleftcorner',
        0,
        'value')
        },
        {
          "name": "lbracket",
          "symbols": [
            {
              "literal": "("
            }
          ],
          "postprocess": $unpack('lbracket',
        0,
        'value')
        },
        {
          "name": "rbracket",
          "symbols": [
            {
              "literal": ")"
            }
          ],
          "postprocess": $unpack('rbracket',
        0,
        'value')
        },
        {
          "name": "nosuchformula",
          "symbols": [
            {
              "literal": "∅"
            }
          ],
          "postprocess": $unpack('nosuchformula',
        0,
        'value')
        },
        {
          "name": "terminator",
          "symbols": [
            {
              "literal": "●"
            }
          ],
          "postprocess": $unpack('terminator',
        0,
        'value')
        },
        {
          "name": "inhibitor",
          "symbols": [
            {
              "literal": "▽"
            }
          ],
          "postprocess": $unpack('inhibitor',
        0,
        'value')
        },
        {
          "name": "getamark",
          "symbols": [
            {
              "literal": "〓"
            }
          ],
          "postprocess": $unpack('getamark',
        0,
        'value')
        },
        {
          "name": "curl",
          "symbols": [
            {
              "literal": "§"
            }
          ],
          "postprocess": $unpack('curl',
        0,
        'value')
        },
        {
          "name": "anycomponent",
          "symbols": [
            {
              "literal": "_"
            }
          ],
          "postprocess": $unpack('anycomponent',
        0,
        'value')
        },
        {
          "name": "anyoperator",
          "symbols": [
            {
              "literal": "%"
            }
          ],
          "postprocess": $unpack('anyoperator',
        0,
        'value')
        },
        {
          "name": "anyclause$string$1",
          "symbols": [
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            },
            {
              "literal": "?"
            }
          ],
          "postprocess": function(d) {
            return d.join('');
          }
        },
        {
          "name": "anyclause",
          "symbols": ["anyclause$string$1"],
          "postprocess": $unpack('anyclause',
        0,
        'value')
        }
      ],
      ParserStart: "start"
    };
    if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
      return module.exports = grammar;
    } else {
      return window.grammar = grammar;
    }
  })();

}).call(this);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vc3JjL2lkbHguY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUN1QztFQUFBOztFQUNwQyxDQUFBLFFBQUEsQ0FBQSxDQUFBO0FBQ0gsUUFBQSxVQUFBLEVBQUEsT0FBQSxFQUFBLE9BQUEsRUFBQSxHQUFBLEVBQUEsQ0FBQSxFQUFBLEtBQUEsRUFBQSxZQUFBLEVBQUEsS0FBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsSUFBQSxFQUFBLEVBQUEsRUFBQSxJQUFBLEVBQUEsR0FBQSxFQUFBLEdBQUEsRUFBQSxHQUFBLEVBQUEsV0FBQSxFQUFBLE9BQUEsRUFBQTtJQUFFLEVBQUEsR0FBSyxRQUFBLENBQUMsQ0FBRCxDQUFBO2FBQU8sQ0FBQyxDQUFDLENBQUQ7SUFBUjtJQUdMLEdBQUEsR0FBNEIsT0FBQSxDQUFRLEtBQVI7SUFDNUIsR0FBQSxHQUE0QixHQUFHLENBQUM7SUFDaEMsS0FBQSxHQUE0QjtJQUM1QixHQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsT0FBZixFQUE0QixLQUE1QjtJQUM1QixLQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsT0FBZixFQUE0QixLQUE1QjtJQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1QjtJQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1QjtJQUM1QixDQUFBLENBQUUsR0FBRixFQUNFLE9BREYsRUFFRSxRQUZGLEVBR0UsTUFIRixDQUFBLEdBRzRCLE9BQUEsQ0FBUSxTQUFSLENBSDVCLEVBVkY7Ozs7Ozs7Ozs7SUF1QkUsQ0FBQSxHQUNFO01BQUEsTUFBQSxFQUFZLElBQVo7TUFDQSxNQUFBLEVBQVksSUFEWjtNQUVBLFNBQUEsRUFBWSxJQUZaO01BR0EsTUFBQSxFQUFZO0lBSFosRUF4Qko7OztJQThCRSxZQUFBLEdBQWUsUUFBQSxDQUFF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T0FBQSxDQUFRLFdBQVI7UUFBMEIsQ0FBMUI7UUFBNkIsT0FBN0I7UUFBeEUsQ0F2Rk87T0FGTDtNQTJGUixXQUFBLEVBQWE7SUEzRkw7SUE2RlYsSUFBRyxPQUFPLE1BQVAsS0FBaUIsV0FBakIsSUFBZ0MsT0FBTyxNQUFNLENBQUMsT0FBZCxLQUF5QixXQUE1RDthQUNFLE1BQU0sQ0FBQyxPQUFQLEdBQWlCLFFBRG5CO0tBQUEsTUFBQTthQUdFLE1BQU0sQ0FBQyxPQUFQLEdBQWlCLFFBSG5COztFQTdLQyxDQUFBO0FBRG9DIiwic291cmNlc0NvbnRlbnQiOlsiIyBHZW5lcmF0ZWQgYXV0b21hdGljYWxseSBieSBuZWFybGV5LCB2ZXJzaW9uIDIuMjAuMVxuIyBodHRwOi8vZ2l0aHViLmNvbS9IYXJkbWF0aDEyMy9uZWFybGV5XG5kbyAtPlxuICBpZCA9IChkKSAtPiBkWzBdXG5cbiAgXG4gIENORCAgICAgICAgICAgICAgICAgICAgICAgPSByZXF1aXJlICdjbmQnXG4gIHJwciAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQucnByXG4gIGJhZGdlICAgICAgICAgICAgICAgICAgICAgPSAnTU9KSUtVUkEtSURML0lETFgnXG4gIGxvZyAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAncGxhaW4nLCAgICAgYmFkZ2VcbiAgZGVidWcgICAgICAgICAgICAgICAgICAgICA9IENORC5nZXRfbG9nZ2VyICdkZWJ1ZycsICAgICBiYWRnZVxuICBpbmZvICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2luZm8nLCAgICAgIGJhZGdlXG4gIGhlbHAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAnaGVscCcsICAgICAgYmFkZ2VcbiAgeyBpc2FcbiAgICB0eXBlX29mXG4gICAgdmFsaWRhdGVcbiAgICBlcXVhbHMgICB9ICAgICAgICAgICAgICA9IHJlcXVpcmUgJy4vdHlwZXMnXG4gIFxuICAjICMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICAjIE8gPVxuICAjICAgc2lsZW50OiAgICAgbm9cbiAgIyAgIHVucGFjazogICAgIHllc1xuICAjICAgdW5icmFja2V0OiAgeWVzXG4gICMgICB1bm5lc3Q6ICAgICB5ZXNcbiAgXG4gICMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICBPID1cbiAgICBzaWxlbnQ6ICAgICB5ZXNcbiAgICB1bnBhY2s6ICAgICB5ZXNcbiAgICB1bmJyYWNrZXQ6ICB5ZXNcbiAgICB1bm5lc3Q6ICAgICB5ZXNcbiAgXG4gICMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICBiZWZvcmVfYWZ0ZXIgPSAoIGJlZm9yZSwgYWZ0ZXIgKSAtPlxuICAgIHJldHVybiAoIENORC5ncmV5ICdcXG48LSAnICkgKyAoIENORC5vcmFuZ2UgcnByIGJlZm9yZSApICsgKCBDTkQuZ3JleSAnXFxuLT4gJyApICsgKCBDTkQubGltZSBycHIgYWZ0ZXIgKVxuICBcbiAgIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG4gIHNwbGljZV9pbnRvID0gKCB0YXJnZXQsIGlkeCApIC0+XG4gICAgdW5sZXNzICggdHlwZSA9IHR5cGVfb2YgKCBzdWJfZGF0YSA9IHRhcmdldFsgaWR4IF0gKSApIGlzICdsaXN0J1xuICAgICAgdGhyb3cgbmV3IEVycm9yIFwiZXhwZWN0ZWQgYSBsaXN0LCBnb3QgYSAje3R5cGV9IGFzIGVsZW1lbnQgMiBvZiAje3JwciB0YXJnZXR9XCJcbiAgICB0YXJnZXQuc3BsaWNlIGlkeCwgMSwgc3ViX2RhdGEuLi5cbiAgICByZXR1cm4gdGFyZ2V0XG4gIFxuICAjLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS1cbiAgJHVucGFjayA9ICggbGFiZWwsIGtleXMuLi4gKSAtPlxuICAgIHJldHVybiAoIGRhdGEsIGxvYywgcmVqZWN0ICkgLT5cbiAgICAgIGlmIE8udW5wYWNrXG4gICAgICAgIFIgPSBkYXRhXG4gICAgICAgIGZvciBrZXkgaW4ga2V5c1xuICAgICAgICAgIGJyZWFrIGlmIGlzYS50ZXh0IFJcbiAgICAgICAgICBSID0gUlsga2V5IF1cbiAgICAgIGVsc2VcbiAgICAgICAgUiA9IE9iamVjdC5hc3NpZ24gW10sIGRhdGFcbiAgICAgIHVubGVzcyBPLnNpbGVudFxuICAgICAgICBSLmxhYmVsID0gbGFiZWxcbiAgICAgICAgaW5mbyAnJHVucGFjaycsIGxhYmVsLCBiZWZvcmVfYWZ0ZXIgZGF0YSwgUlxuICAgICAgcmV0dXJuIFJcbiAgXG4gICMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICAkdW5icmFja2V0ID0gKCBsYWJlbCwga2V5cy4uLiApIC0+XG4gICAgdW5wYWNrID0gJHVucGFjayBsYWJlbCwga2V5cy4uLlxuICAgIHJldHVybiAoIGRhdGEsIGxvYywgcmVqZWN0ICkgLT5cbiAgICAgIFIgPSB1bnBhY2sgZGF0YSwgbG9jLCByZWplY3RcbiAgICAgIGlmIE8udW5icmFja2V0XG4gICAgICAgIFIgPSBSWyAxIC4uLiBSLmxlbmd0aCAtIDEgXVxuICAgICAgICBzcGxpY2VfaW50byBSLCAxXG4gICAgICB1bmxlc3MgTy5zaWxlbnRcbiAgICAgICAgaW5mbyAnJHVuYnJhY2tldCcsIGJlZm9yZV9hZnRlciBkYXRhLCBSXG4gICAgICByZXR1cm4gUlxuICBcbiAgIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG4gICR1bm5lc3QgPSAoIGxhYmVsLCBrZXlzLi4uICkgLT5cbiAgICB1bnBhY2sgPSAkdW5wYWNrIGxhYmVsLCBrZXlzLi4uXG4gICAgcmV0dXJuICggZGF0YSwgbG9jLCByZWplY3QgKSAtPlxuICAgICAgUiA9IHVucGFjayBkYXRhLCBsb2MsIHJlamVjdFxuICAgICAgaWYgTy51bm5lc3RcbiAgICAgICAgc3BsaWNlX2ludG8gUiwgMlxuICAgICAgdW5sZXNzIE8uc2lsZW50XG4gICAgICAgIGluZm8gJyR1bm5lc3QnLCBiZWZvcmVfYWZ0ZXIgZGF0YSwgUlxuICAgICAgcmV0dXJuIFJcbiAgXG4gIFxuICBncmFtbWFyID0ge1xuICAgIExleGVyOiB1bmRlZmluZWQsXG4gICAgUGFyc2VyUnVsZXM6IFtcbiAgICAgICAgICB7XCJuYW1lXCI6IFwic3RhcnQkc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCIrc29saXRhaXJlK1wiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInN0YXJ0JHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1widGVybVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInN0YXJ0XCIsIFwic3ltYm9sc1wiOiBbXCJzdGFydCRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAgICAnc3RhcnQnLCAgICAgIDAsIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJleHByJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1widGVybVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImV4cHIkc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJjb21wb25lbnRcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJleHByXCIsIFwic3ltYm9sc1wiOiBbXCJleHByJHN1YmV4cHJlc3Npb24kMVwiXSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICAgICdleHByJywgICAgMCwgMCwgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImV4cHIzKyRzdWJleHByZXNzaW9uJDEkZWJuZiQxXCIsIFwic3ltYm9sc1wiOiBbXCJleHByXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiZXhwcjMrJHN1YmV4cHJlc3Npb24kMSRlYm5mJDFcIiwgXCJzeW1ib2xzXCI6IFtcImV4cHIzKyRzdWJleHByZXNzaW9uJDEkZWJuZiQxXCIsIFwiZXhwclwiXSwgXCJwb3N0cHJvY2Vzc1wiOiAoZCkgLT4gZFswXS5jb25jYXQoW2RbMV1dKX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImV4cHIzKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImV4cHJcIiwgXCJleHByXCIsIFwiZXhwcjMrJHN1YmV4cHJlc3Npb24kMSRlYm5mJDFcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJleHByMytcIiwgXCJzeW1ib2xzXCI6IFtcImV4cHIzKyRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVubmVzdCAgICAnZXhwcjMrJywgICAgICAgIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ0ZXJtJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1widW5hcnlcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ0ZXJtJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wiYmluYXJ5XCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidGVybSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcIiticmFja2V0K2VkXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidGVybVwiLCBcInN5bWJvbHNcIjogW1widGVybSRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAgICAndGVybScsICAgICAgICAgIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ1bmFyeSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcIit1bmFyeV9vcGVyYXRvcitcIiwgXCJleHByXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidW5hcnlcIiwgXCJzeW1ib2xzXCI6IFtcInVuYXJ5JHN1YmV4cHJlc3Npb24kMVwiXSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICAgICd1bmFyeScsICAgICAgICAgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcIitiaW5hcnlfb3BlcmF0b3IrXCIsIFwiZXhwclwiLCBcImV4cHJcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJiaW5hcnlcIiwgXCJzeW1ib2xzXCI6IFtcImJpbmFyeSRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAgICAnYmluYXJ5JywgICAgICAgIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYnJhY2tldCtlZCRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImxicmFja2V0XCIsIFwiK2JpbmFyeV9vcGVyYXRvcitcIiwgXCJleHByMytcIiwgXCJyYnJhY2tldFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIiticmFja2V0K2VkXCIsIFwic3ltYm9sc1wiOiBbXCIrYnJhY2tldCtlZCRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVuYnJhY2tldCAnK2JyYWNrZXQrZWQnLCAgIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJjb21wb25lbnRcIiwgXCJzeW1ib2xzXCI6IFtcIitwcm94eStcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJjb21wb25lbnRcIiwgXCJzeW1ib2xzXCI6IFsvLi9dLCBcInBvc3Rwcm9jZXNzXCI6IFxuICAgICAgICAgICAgICAoIGRhdGEsIGxvYywgcmVqZWN0ICkgLT5cbiAgICAgICAgICAgICAgICBbIHsgdmFsdWU6IFIsIH0sIF0gPSBkYXRhXG4gICAgICAgICAgICAgICAgcmV0dXJuIHJlamVjdCBpZiAvXlxccyskLy50ZXN0IFJcbiAgICAgICAgICAgICAgICAjIHJldHVybiByZWplY3QgaWYgL15b4omIPD4/4oa74oaU4oaV4r+w4r+x4r+04r+14r+24r+34r+44r+54r+64r+74pewKCniiIXil4/ilr3ik6fik6jik6njgJPCp10kLy50ZXN0IFJcbiAgICAgICAgICAgICAgICByZXR1cm4gcmVqZWN0IGlmIC9eW+KJiDw+P+KGu+KGlOKGleK/sOK/seK/tOK/teK/tuK/t+K/uOK/ueK/uuK/u+KXsCgp4oiF4peP4pa944CTwqddJC8udGVzdCBSXG4gICAgICAgICAgICAgICAgdW5sZXNzIE8uc2lsZW50XG4gICAgICAgICAgICAgICAgICBpbmZvICdjb21wb25lbnQnLCBiZWZvcmVfYWZ0ZXIgZGF0YSwgUlxuICAgICAgICAgICAgICAgIHJldHVybiBSXG4gICAgICAgICAgICAgICB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrdW5hcnlfb3BlcmF0b3IrJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wic2ltaWxhclwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIit1bmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJoZWF2eVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIit1bmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJsaWdodFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIit1bmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJkb3VidFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIit1bmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJ1cHNpZGVkb3duXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK3VuYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcIm1pcnJvclwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIit1bmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJmbGlwXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK3VuYXJ5X29wZXJhdG9yK1wiLCBcInN5bWJvbHNcIjogW1wiK3VuYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnK3VuYXJ5X29wZXJhdG9yKycsICAwLCAwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK2JpbmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJsZWZ0cmlnaHRcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcGRvd25cIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInN1cnJvdW5kXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK2JpbmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJjYXBcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImN1cFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIitiaW5hcnlfb3BlcmF0b3IrJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wibGVmdGVtYnJhY2VcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcGxlZnRcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcHJpZ2h0XCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK2JpbmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJsZWZ0Ym90dG9tXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK2JpbmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJpbnRlcmxhY2VcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcGxlZnRjb3JuZXJcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrYmluYXJ5X29wZXJhdG9yK1wiLCBcInN5bWJvbHNcIjogW1wiK2JpbmFyeV9vcGVyYXRvciskc3ViZXhwcmVzc2lvbiQxXCJdLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJytiaW5hcnlfb3BlcmF0b3IrJywgIDAsIDB9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrc29saXRhaXJlKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcIm5vc3VjaGZvcm11bGFcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrc29saXRhaXJlKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRlcm1pbmF0b3JcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrc29saXRhaXJlKyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImluaGliaXRvclwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcIitzb2xpdGFpcmUrXCIsIFwic3ltYm9sc1wiOiBbXCIrc29saXRhaXJlKyRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnK3NvbGl0YWlyZSsnLCAwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK3Byb3h5KyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImdldGFtYXJrXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiK3Byb3h5KyRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImN1cmxcIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCIrcHJveHkrXCIsIFwic3ltYm9sc1wiOiBbXCIrcHJveHkrJHN1YmV4cHJlc3Npb24kMVwiXSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICcrcHJveHkrJywgMCwgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInNpbWlsYXJcIiwgXCJzeW1ib2xzXCI6IFt7XCJsaXRlcmFsXCI6XCLiiYhcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3NpbWlsYXInLCAgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJoZWF2eVwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIjxcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2hlYXZ5JywgICAgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJsaWdodFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIj5cIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2xpZ2h0JywgICAgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJkb3VidFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIj9cIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2RvdWJ0JywgICAgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ1cHNpZGVkb3duXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4oa7XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICd1cHNpZGVkb3duJywgICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwibWlycm9yXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4oaUXCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdtaXJyb3InLCAgICAgICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiZmxpcFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuKGlVwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnZmxpcCcsICAgICAgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImxlZnRyaWdodFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/sFwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnbGVmdHJpZ2h0JywgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRvcGRvd25cIiwgXCJzeW1ib2xzXCI6IFt7XCJsaXRlcmFsXCI6XCLiv7FcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3RvcGRvd24nLCAgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJzdXJyb3VuZFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/tFwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnc3Vycm91bmQnLCAgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImNhcFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/tVwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnY2FwJywgICAgICAgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImN1cFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/tlwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnY3VwJywgICAgICAgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImxlZnRlbWJyYWNlXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+3XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdsZWZ0ZW1icmFjZScsICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidG9wbGVmdFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/uFwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAndG9wbGVmdCcsICAgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRvcHJpZ2h0XCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+5XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICd0b3ByaWdodCcsICAgICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwibGVmdGJvdHRvbVwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/ulwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnbGVmdGJvdHRvbScsICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImludGVybGFjZVwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/u1wifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnaW50ZXJsYWNlJywgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRvcGxlZnRjb3JuZXJcIiwgXCJzeW1ib2xzXCI6IFt7XCJsaXRlcmFsXCI6XCLil7BcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3RvcGxlZnRjb3JuZXInLCAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJsYnJhY2tldFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIihcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2xicmFja2V0JywgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJyYnJhY2tldFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIilcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3JicmFja2V0JywgICAgICAgMCwgJ3ZhbHVlJyx9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJub3N1Y2hmb3JtdWxhXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4oiFXCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdub3N1Y2hmb3JtdWxhJywgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidGVybWluYXRvclwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuKXj1wifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAndGVybWluYXRvcicsICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImluaGliaXRvclwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuKWvVwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnaW5oaWJpdG9yJywgICAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImdldGFtYXJrXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi44CTXCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdnZXRhbWFyaycsICAgICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiY3VybFwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIsKnXCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdjdXJsJywgICAgICAgICAgIDAsICd2YWx1ZScsfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiYW55Y29tcG9uZW50XCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwiX1wifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnYW55Y29tcG9uZW50JywgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImFueW9wZXJhdG9yXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwiJVwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnYW55b3BlcmF0b3InLCAgICAwLCAndmFsdWUnLH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImFueWNsYXVzZSRzdHJpbmckMVwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn0sIHtcImxpdGVyYWxcIjpcIj9cIn1dLCBcInBvc3Rwcm9jZXNzXCI6IChkKSAtPiBkLmpvaW4oJycpfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiYW55Y2xhdXNlXCIsIFwic3ltYm9sc1wiOiBbXCJhbnljbGF1c2Ukc3RyaW5nJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnYW55Y2xhdXNlJywgICAgICAwLCAndmFsdWUnLH1cbiAgICAgIF0sXG4gICAgUGFyc2VyU3RhcnQ6IFwic3RhcnRcIlxuICB9XG4gIGlmIHR5cGVvZiBtb2R1bGUgIT0gJ3VuZGVmaW5lZCcgJiYgdHlwZW9mIG1vZHVsZS5leHBvcnRzICE9ICd1bmRlZmluZWQnXG4gICAgbW9kdWxlLmV4cG9ydHMgPSBncmFtbWFyO1xuICBlbHNlXG4gICAgd2luZG93LmdyYW1tYXIgPSBncmFtbWFyO1xuIl19

(function() {
  // Generated automatically by nearley, version 2.20.1
  // http://github.com/Hardmath123/nearley
  (function() {
    var $unpack, CND, badge, debug, grammar, id, info, isa, log, rpr, silent;
    id = function(d) {
      return d[0];
    };
    CND = require('cnd');
    rpr = CND.rpr;
    badge = 'NEARlEY';
    log = CND.get_logger('plain', badge);
    debug = CND.get_logger('debug', badge);
    info = CND.get_logger('info', badge);
    silent = false;
    silent = true;
    ({isa} = require('./types'));
    
    //-----------------------------------------------------------------------------------------------------------
    $unpack = function(label, ...keys) {
      return function(data, loc, reject) {
        var R, i, key, len;
        R = data;
        for (i = 0, len = keys.length; i < len; i++) {
          key = keys[i];
          if (isa.text(R)) {
            break;
          }
          R = R[key];
        }
        if (!silent) {
          R.label = label;
          debug('9982', label, data, rpr(R));
        }
        return R;
      };
    };
    grammar = {
      Lexer: void 0,
      ParserRules: [
        {
          "name": "start",
          "symbols": ["term"],
          "postprocess": $unpack('start',
        0,
        0)
        },
        {
          "name": "expression$subexpression$1",
          "symbols": ["term"]
        },
        {
          "name": "expression$subexpression$1",
          "symbols": ["component"]
        },
        {
          "name": "expression",
          "symbols": ["expression$subexpression$1"],
          "postprocess": $unpack('expression',
        0,
        0,
        0)
        },
        {
          "name": "term$subexpression$1",
          "symbols": ["binary_term"]
        },
        {
          "name": "term$subexpression$1",
          "symbols": ["trinary_term"]
        },
        {
          "name": "term",
          "symbols": ["term$subexpression$1"],
          "postprocess": $unpack('term',
        0)
        },
        {
          "name": "binary_term$subexpression$1",
          "symbols": ["binary_operator",
        "expression",
        "expression"]
        },
        {
          "name": "binary_term",
          "symbols": ["binary_term$subexpression$1"],
          "postprocess": $unpack('binary_term',
        0)
        },
        {
          "name": "trinary_term$subexpression$1",
          "symbols": ["trinary_operator",
        "expression",
        "expression",
        "expression"]
        },
        {
          "name": "trinary_term",
          "symbols": ["trinary_term$subexpression$1"],
          "postprocess": $unpack('trinary_term',
        0)
        },
        {
          "name": "component",
          "symbols": [/./],
          "postprocess": function(data,
        loc,
        reject) {
            var chr;
            [
              {
                value: chr
              }
            ] = data;
            if (/^\s+$/.test(chr)) {
              return reject;
            }
            if (/^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test(chr)) {
              return reject;
            }
            if (!silent) {
              info('33821',
        rpr(data),
        rpr(chr));
            }
            return chr;
          }
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["leftright"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["topdown"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["surround"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["cap"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["cup"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["leftembrace"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["topleft"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["topright"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["leftbottom"]
        },
        {
          "name": "binary_operator$subexpression$1",
          "symbols": ["interlace"]
        },
        {
          "name": "binary_operator",
          "symbols": ["binary_operator$subexpression$1"],
          "postprocess": $unpack('binary_operator',
        0,
        0)
        },
        {
          "name": "trinary_operator$subexpression$1",
          "symbols": ["pillars"]
        },
        {
          "name": "trinary_operator$subexpression$1",
          "symbols": ["layers"]
        },
        {
          "name": "trinary_operator",
          "symbols": ["trinary_operator$subexpression$1"],
          "postprocess": $unpack('trinary_operator',
        0,
        0)
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
          "name": "pillars",
          "symbols": [
            {
              "literal": "⿲"
            }
          ],
          "postprocess": $unpack('pillars',
        0,
        'value')
        },
        {
          "name": "layers",
          "symbols": [
            {
              "literal": "⿳"
            }
          ],
          "postprocess": $unpack('layers',
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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiLi4vc3JjL2lkbC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQ3VDO0VBQUE7O0VBQ3BDLENBQUEsUUFBQSxDQUFBLENBQUE7QUFDSCxRQUFBLE9BQUEsRUFBQSxHQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxPQUFBLEVBQUEsRUFBQSxFQUFBLElBQUEsRUFBQSxHQUFBLEVBQUEsR0FBQSxFQUFBLEdBQUEsRUFBQTtJQUFFLEVBQUEsR0FBSyxRQUFBLENBQUMsQ0FBRCxDQUFBO2FBQU8sQ0FBQyxDQUFDLENBQUQ7SUFBUjtJQUdMLEdBQUEsR0FBNEIsT0FBQSxDQUFRLEtBQVI7SUFDNUIsR0FBQSxHQUE0QixHQUFHLENBQUM7SUFDaEMsS0FBQSxHQUE0QjtJQUM1QixHQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsT0FBZixFQUE0QixLQUE1QjtJQUM1QixLQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsT0FBZixFQUE0QixLQUE1QjtJQUM1QixJQUFBLEdBQTRCLEdBQUcsQ0FBQyxVQUFKLENBQWUsTUFBZixFQUE0QixLQUE1QjtJQUM1QixNQUFBLEdBQTRCO0lBQzVCLE1BQUEsR0FBNEI7SUFDNUIsQ0FBQSxDQUFFLEdBQUYsQ0FBQSxHQUE0QixPQUFBLENBQVEsU0FBUixDQUE1QixFQVhGOzs7SUFjRSxPQUFBLEdBQVUsUUFBQSxDQUFFLEtBQUYsRUFBQSxHQUFTLElBQVQsQ0FBQTtBQUNSLGFBQU8sUUFBQSxDQUFFLElBQUYsRUFBUSxHQUFSLEVBQWEsTUFBYixDQUFBO0FBQ1gsWUFBQSxDQUFBLEVBQUEsQ0FBQSxFQUFBLEdBQUEsRUFBQTtRQUFNLENBQUEsR0FBSTtRQUNKLEtBQUEsc0NBQUE7O1VBQ0UsSUFBUyxHQUFHLENBQUMsSUFBSixDQUFTLENBQVQsQ0FBVDtBQUFBLGtCQUFBOztVQUNBLENBQUEsR0FBSSxDQUFDLENBQUUsR0FBRjtRQUZQO1FBR0EsS0FB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V0FBNUQ7YUFDRSxNQUFNLENBQUMsT0FBUCxHQUFpQixRQURuQjtLQUFBLE1BQUE7YUFHRSxNQUFNLENBQUMsT0FBUCxHQUFpQixRQUhuQjs7RUE5RUMsQ0FBQTtBQURvQyIsInNvdXJjZXNDb250ZW50IjpbIiMgR2VuZXJhdGVkIGF1dG9tYXRpY2FsbHkgYnkgbmVhcmxleSwgdmVyc2lvbiAyLjIwLjFcbiMgaHR0cDovL2dpdGh1Yi5jb20vSGFyZG1hdGgxMjMvbmVhcmxleVxuZG8gLT5cbiAgaWQgPSAoZCkgLT4gZFswXVxuXG4gIFxuICBDTkQgICAgICAgICAgICAgICAgICAgICAgID0gcmVxdWlyZSAnY25kJ1xuICBycHIgICAgICAgICAgICAgICAgICAgICAgID0gQ05ELnJwclxuICBiYWRnZSAgICAgICAgICAgICAgICAgICAgID0gJ05FQVJsRVknXG4gIGxvZyAgICAgICAgICAgICAgICAgICAgICAgPSBDTkQuZ2V0X2xvZ2dlciAncGxhaW4nLCAgICAgYmFkZ2VcbiAgZGVidWcgICAgICAgICAgICAgICAgICAgICA9IENORC5nZXRfbG9nZ2VyICdkZWJ1ZycsICAgICBiYWRnZVxuICBpbmZvICAgICAgICAgICAgICAgICAgICAgID0gQ05ELmdldF9sb2dnZXIgJ2luZm8nLCAgICAgIGJhZGdlXG4gIHNpbGVudCAgICAgICAgICAgICAgICAgICAgPSBub1xuICBzaWxlbnQgICAgICAgICAgICAgICAgICAgID0geWVzXG4gIHsgaXNhIH0gICAgICAgICAgICAgICAgICAgPSByZXF1aXJlICcuL3R5cGVzJ1xuICBcbiAgIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tXG4gICR1bnBhY2sgPSAoIGxhYmVsLCBrZXlzLi4uICkgLT5cbiAgICByZXR1cm4gKCBkYXRhLCBsb2MsIHJlamVjdCApIC0+XG4gICAgICBSID0gZGF0YVxuICAgICAgZm9yIGtleSBpbiBrZXlzXG4gICAgICAgIGJyZWFrIGlmIGlzYS50ZXh0IFJcbiAgICAgICAgUiA9IFJbIGtleSBdXG4gICAgICB1bmxlc3Mgc2lsZW50XG4gICAgICAgIFIubGFiZWwgPSBsYWJlbFxuICAgICAgICBkZWJ1ZyAnOTk4MicsIGxhYmVsLCBkYXRhLCBycHIgUlxuICAgICAgcmV0dXJuIFJcbiAgXG4gIFxuICBncmFtbWFyID0ge1xuICAgIExleGVyOiB1bmRlZmluZWQsXG4gICAgUGFyc2VyUnVsZXM6IFtcbiAgICAgICAgICB7XCJuYW1lXCI6IFwic3RhcnRcIiwgXCJzeW1ib2xzXCI6IFtcInRlcm1cIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnc3RhcnQnLCAgICAgICAwLCAwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiZXhwcmVzc2lvbiRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRlcm1cIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJleHByZXNzaW9uJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wiY29tcG9uZW50XCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiZXhwcmVzc2lvblwiLCBcInN5bWJvbHNcIjogW1wiZXhwcmVzc2lvbiRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnZXhwcmVzc2lvbicsICAwLCAwLCAwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidGVybSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImJpbmFyeV90ZXJtXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidGVybSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRyaW5hcnlfdGVybVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRlcm1cIiwgXCJzeW1ib2xzXCI6IFtcInRlcm0kc3ViZXhwcmVzc2lvbiQxXCJdLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3Rlcm0nLCAgICAgICAgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV90ZXJtJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wiYmluYXJ5X29wZXJhdG9yXCIsIFwiZXhwcmVzc2lvblwiLCBcImV4cHJlc3Npb25cIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJiaW5hcnlfdGVybVwiLCBcInN5bWJvbHNcIjogW1wiYmluYXJ5X3Rlcm0kc3ViZXhwcmVzc2lvbiQxXCJdLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2JpbmFyeV90ZXJtJywgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRyaW5hcnlfdGVybSRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRyaW5hcnlfb3BlcmF0b3JcIiwgXCJleHByZXNzaW9uXCIsIFwiZXhwcmVzc2lvblwiLCBcImV4cHJlc3Npb25cIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ0cmluYXJ5X3Rlcm1cIiwgXCJzeW1ib2xzXCI6IFtcInRyaW5hcnlfdGVybSRzdWJleHByZXNzaW9uJDFcIl0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAndHJpbmFyeV90ZXJtJywwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiY29tcG9uZW50XCIsIFwic3ltYm9sc1wiOiBbLy4vXSwgXCJwb3N0cHJvY2Vzc1wiOiBcbiAgICAgICAgICAgICAgKCBkYXRhLCBsb2MsIHJlamVjdCApIC0+XG4gICAgICAgICAgICAgICAgWyB7IHZhbHVlOiBjaHIsIH0sIF0gPSBkYXRhXG4gICAgICAgICAgICAgICAgcmV0dXJuIHJlamVjdCBpZiAvXlxccyskLy50ZXN0IGNoclxuICAgICAgICAgICAgICAgIHJldHVybiByZWplY3QgaWYgL15b4r+w4r+x4r+04r+14r+24r+34r+44r+54r+64r+74r+y4r+zXSQvLnRlc3QgY2hyXG4gICAgICAgICAgICAgICAgaW5mbyAnMzM4MjEnLCAoIHJwciBkYXRhICksICggcnByIGNociApIHVubGVzcyBzaWxlbnRcbiAgICAgICAgICAgICAgICByZXR1cm4gY2hyXG4gICAgICAgICAgICAgIH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImxlZnRyaWdodFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcGRvd25cIl19LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJiaW5hcnlfb3BlcmF0b3Ikc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJzdXJyb3VuZFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImNhcFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImN1cFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImxlZnRlbWJyYWNlXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiYmluYXJ5X29wZXJhdG9yJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1widG9wbGVmdFwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcInRvcHJpZ2h0XCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiYmluYXJ5X29wZXJhdG9yJHN1YmV4cHJlc3Npb24kMVwiLCBcInN5bWJvbHNcIjogW1wibGVmdGJvdHRvbVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImludGVybGFjZVwiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcImJpbmFyeV9vcGVyYXRvclwiLCBcInN5bWJvbHNcIjogW1wiYmluYXJ5X29wZXJhdG9yJHN1YmV4cHJlc3Npb24kMVwiXSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdiaW5hcnlfb3BlcmF0b3InLCAgMCwgMH0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRyaW5hcnlfb3BlcmF0b3Ikc3ViZXhwcmVzc2lvbiQxXCIsIFwic3ltYm9sc1wiOiBbXCJwaWxsYXJzXCJdfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidHJpbmFyeV9vcGVyYXRvciRzdWJleHByZXNzaW9uJDFcIiwgXCJzeW1ib2xzXCI6IFtcImxheWVyc1wiXX0sXG4gICAgICAgICAge1wibmFtZVwiOiBcInRyaW5hcnlfb3BlcmF0b3JcIiwgXCJzeW1ib2xzXCI6IFtcInRyaW5hcnlfb3BlcmF0b3Ikc3ViZXhwcmVzc2lvbiQxXCJdLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3RyaW5hcnlfb3BlcmF0b3InLCAwLCAwfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwibGVmdHJpZ2h0XCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+wXCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdsZWZ0cmlnaHQnLCAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidG9wZG93blwiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/sVwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAndG9wZG93bicsICAgICAgMCwgJ3ZhbHVlJ30sXG4gICAgICAgICAge1wibmFtZVwiOiBcInN1cnJvdW5kXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+0XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdzdXJyb3VuZCcsICAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiY2FwXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+1XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdjYXAnLCAgICAgICAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiY3VwXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+2XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdjdXAnLCAgICAgICAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwibGVmdGVtYnJhY2VcIiwgXCJzeW1ib2xzXCI6IFt7XCJsaXRlcmFsXCI6XCLiv7dcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ2xlZnRlbWJyYWNlJywgIDAsICd2YWx1ZSd9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJ0b3BsZWZ0XCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+4XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICd0b3BsZWZ0JywgICAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwidG9wcmlnaHRcIiwgXCJzeW1ib2xzXCI6IFt7XCJsaXRlcmFsXCI6XCLiv7lcIn1dLCBcInBvc3Rwcm9jZXNzXCI6ICR1bnBhY2sgJ3RvcHJpZ2h0JywgICAgIDAsICd2YWx1ZSd9LFxuICAgICAgICAgIHtcIm5hbWVcIjogXCJsZWZ0Ym90dG9tXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+6XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdsZWZ0Ym90dG9tJywgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwiaW50ZXJsYWNlXCIsIFwic3ltYm9sc1wiOiBbe1wibGl0ZXJhbFwiOlwi4r+7XCJ9XSwgXCJwb3N0cHJvY2Vzc1wiOiAkdW5wYWNrICdpbnRlcmxhY2UnLCAgICAwLCAndmFsdWUnfSxcbiAgICAgICAgICB7XCJuYW1lXCI6IFwicGlsbGFyc1wiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/slwifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAncGlsbGFycycsICAgICAgMCwgJ3ZhbHVlJ30sXG4gICAgICAgICAge1wibmFtZVwiOiBcImxheWVyc1wiLCBcInN5bWJvbHNcIjogW3tcImxpdGVyYWxcIjpcIuK/s1wifV0sIFwicG9zdHByb2Nlc3NcIjogJHVucGFjayAnbGF5ZXJzJywgICAgICAgMCwgJ3ZhbHVlJ31cbiAgICAgIF0sXG4gICAgUGFyc2VyU3RhcnQ6IFwic3RhcnRcIlxuICB9XG4gIGlmIHR5cGVvZiBtb2R1bGUgIT0gJ3VuZGVmaW5lZCcgJiYgdHlwZW9mIG1vZHVsZS5leHBvcnRzICE9ICd1bmRlZmluZWQnXG4gICAgbW9kdWxlLmV4cG9ydHMgPSBncmFtbWFyO1xuICBlbHNlXG4gICAgd2luZG93LmdyYW1tYXIgPSBncmFtbWFyO1xuIl19

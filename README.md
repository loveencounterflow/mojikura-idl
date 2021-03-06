<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [MojiKura Ideographic Description Language](#mojikura-ideographic-description-language)
  - [To Do](#to-do)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# MojiKura Ideographic Description Language

文字倉字形描述語言

```coffee
["⿱癶⿰弓貝",["⿱","癶",["⿰","弓","貝"]]]
["⿱⿰亻式貝",["⿱",["⿰","亻","式"],"貝"]]
["⿱⿰亻式⿱目八",["⿱",["⿰","亻","式"],["⿱","目","八"]]]
["⿺辶言",["⿺","辶","言"]]
["(⿰亻聿式)",["⿰","亻","聿","式"]]
["(⿱北㓁允)",["⿱","北","㓁","允"]]
["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))",["⿹","弓",["⿰",["⿱","人","人","丨"],["⿱","人","人","丨"],["⿱","人","人","丨"]]]]
["(⿱&jzr#xe223;一八⿰(⿱&jzr#xe223;一八)(⿱&jzr#xe223;一八))",["⿱","","一","八",["⿰",["⿱","","一","八"],["⿱","","一","八"]]]]
["⿹弓(⿰(⿱人人丨)(⿱人人丨)(⿱人人丨))",["⿹","弓",["⿰",["⿱","人","人","丨"],["⿱","人","人","丨"],["⿱","人","人","丨"]]]]
["⿰臣(⿱𠂉(⿰人人人)(⿰古古古))",["⿰","臣",["⿱","𠂉",["⿰","人","人","人"],["⿰","古","古","古"]]]]
["(⿱屮(⿰屮屮屮)一(⿰𠂈屮又))",["⿱","屮",["⿰","屮","屮","屮"],"一",["⿰","𠂈","屮","又"]]]
["⿱(⿰車(⿱爫龴⿵冂厶)車)(⿰田⿵冂乂田)",["⿱",["⿰","車",["⿱","爫","龴",["⿵","冂","厶"]],"車"],["⿰","田",["⿵","冂","乂"],"田"]]]
["(⿰阝(⿸𠂆虍人)(⿸𠂆虍人))",["⿰","阝",["⿸","𠂆","虍","人"],["⿸","𠂆","虍","人"]]]
["⿰阝(⿱山人儿⿰(⿱山人儿)(⿱山人儿))",["⿰","阝",["⿱","山","人","儿",["⿰",["⿱","山","人","儿"],["⿱","山","人","儿"]]]]]
["⿰阜(⿱山介⿰(⿱山人几)(⿱山人几))",["⿰","阜",["⿱","山","介",["⿰",["⿱","山","人","几"],["⿱","山","人","几"]]]]]
["(⿱厶(⿰刃工刃)一(⿰丶丶丶)口)",["⿱","厶",["⿰","刃","工","刃"],"一",["⿰","丶","丶","丶"],"口"]]
```


## To Do

* remove dependency on [`ncr`](https://github.com/loveencounterflow/ncr) which is only used in submodule `main`:
  * `NCR.chrs_from_text()`
  * `NCR.jzr_as_uchr()`
  * `NCR.jzr_as_xncr()`
* move tests to [`hengist`](https://github.com/loveencounterflow/hengist)
* rewrite tests to use [`guy-test`](https://github.com/loveencounterflow/guy-test)




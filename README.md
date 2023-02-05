版本太舊，待更新，目前不建識使用

## 內容
- spell corrector

  [Spell] 以 dart 實作 spell corrector https://norvig.com/spell-correct.html
- FN
    - head / tail / count / countBy / unique / range
    - asTwoDimensionalList

      強制轉為二維陣列
      __example__
      ```dart
      expect(FN.asTwoDimensionList(list, 1), equals(
              [[1], [2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]]
           ));
      expect(FN.asTwoDimensionList(list, 2), orderedEquals(
                [[1,2], [3,4],[5,6],[7,8],[9,10],[11,12]]
             ));
      ```
- simple logger

- IS
    - is.not
    - is.empty / is.set / is.string / is.array / is.Null / is.present / is.number / is.Int
    - is.union(masterList, subSetList)
    - is.alphabetic(char)
    - is.upperCaseChar
    - is.lowerCaseChar
    - is.underlineChar
    - is.camelCase
    - is.snakeCase
    - is.odd
    - is.even

[Spell]:./lib/src/common.spell.dart
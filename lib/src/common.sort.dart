

class Sort<T> {
  List<T> dateRecords;

  Sort(this.dateRecords);

  // int Function(T a, T b)
  // decByDate(DateTime date(T a)) {
  //   return (T a, T b) =>
  //   date(b)
  //       .difference(date(a))
  //       .inMilliseconds;
  // }
  //
  // int Function(T a, T b)
  // accByDate(DateTime date(T a)) {
  //   return (T a, T b) =>
  //   date(a)
  //       .difference(date(b))
  //       .inMilliseconds;
  // }
  //
  // int Function(T a, T b)
  // decByX(int getter(T a)) {
  //   return (T a, T b) => getter(b) - getter(a);
  // }
  //
  // int Function(T a, T b)
  // accByX(int getter(T a)) {
  //   return (T a, T b) => getter(a) - getter(b);
  // }

  Map<DateTime, List<T>> decByDateWithDuplicateFilter(bool isDiff(T? a, T? b), DateTime dateGetter(T a), bool filterDuplicate(List<T> a, T b)?) {
    try {
      T? a, b;
      List<T> linearStack = [];
      Map<DateTime, List<T>> cate = {};
      dateRecords.sort((a, b) =>
      dateGetter(b).difference(dateGetter(a)).inMilliseconds);

      for (var i = 0; i < dateRecords.length; i ++) {
        b = dateRecords[i];
        if (a != null) {
          if (isDiff(linearStack.isNotEmpty ? linearStack.last : null, a)) {
            linearStack.add(a);
            cate[dateGetter(a)] ??= [];
            cate[dateGetter(a)]!.add(a);
          } else {
            if (filterDuplicate != null && filterDuplicate(cate[dateGetter(linearStack.last)]!, a)) {
              cate[dateGetter(linearStack.last)]!.add(a);
            }
          }

          if (isDiff(linearStack.isNotEmpty ? linearStack.last : null, b)) {
            linearStack.add(b!);
            cate[dateGetter(b)] ??= [];
            cate[dateGetter(b)]!.add(b);
          } else {
            if (filterDuplicate != null && filterDuplicate(cate[dateGetter(linearStack.last)]!, b!)) {
              cate[dateGetter(linearStack.last)]!.add(b);
            }
          }
        }
        a = b;
      }
      return cate;
    } catch (e, s) {
      print('[ERROR] Sort.byDateDec failed: \n$s');
      rethrow;
    }
  }

  Map<DateTime, List<T>> accByDateWithDuplicateFilter(bool isDiff(T? a, T? b), DateTime dateGetter(T a), bool filterDuplicate(List<T> a, T b)?) {
    T? a, b;
    List<T> linearStack = [];
    Map<DateTime, List<T>> cate = {};
    //bool Function() isNotFirstRecord = () => a != null;
    dateRecords.sort((a, b) => dateGetter(a).difference(dateGetter(b)).inMilliseconds);

    for (var i = dateRecords.length - 1; i >= 0; i --) {
      b = dateRecords[i];
      if (a != null) {
        if (isDiff(linearStack.isNotEmpty ? linearStack.last : null, a)) {
          linearStack.add(a);
          cate[dateGetter(a)] ??= [];
          cate[dateGetter(a)]!.add(a);
        } else {
          if (filterDuplicate != null && filterDuplicate(cate[dateGetter(linearStack.last)]!, a)) {
            cate[dateGetter(linearStack.last)]!.add(a);
          } else
            print('blocked record: $a');
        }

        if (isDiff(linearStack.isNotEmpty ? linearStack.last : null, b)) {
          linearStack.add(b!);
          cate[dateGetter(b)] ??= [];
          cate[dateGetter(b)]!.add(b);
        } else {
          if (filterDuplicate != null && filterDuplicate(cate[dateGetter(linearStack.last)]!, a)) {
            cate[dateGetter(linearStack.last)]!.add(b!);
          } else
            print('blocked record: $b');
        }
      }
      a = b;
    }
    return cate;
  }
}

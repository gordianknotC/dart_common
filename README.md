dart 常用一般性工具，待完整測試後 publish

## Usage
```yaml
dart_common:
  git:
    url: https://github.com/gordianknotC/dart_common.git
    refs: master
```

## common.fn.dart
### FN
常用 functional programming 工具

- callEither - 依據A／B 哪一個不是空值，呼叫非空值者 
- orderedEqualBy
- orderedEqual
- assertEitherNotBoth - assert 其中一方為 true, 而非二者皆 true
- uniqueBy - 依 isDuplicated 濾除 data
- getKeyWhereValue
- getElement
- asTwoDimensionList
    ```dart
    expect(FN.asTwoDimensionList(list, 1), equals([[1], [2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]]));
    expect(FN.asTwoDimensionList(list, 2), orderedEquals([[1,2], [3,4],[5,6],[7,8],[9,10],[11,12]]));
    - ```
- range
- head
- tail
- last
- first
- remove
- split
- findIndex
- count
- countBy
- countOn
- unique
- zip
- union_1dList
- union_2dList
- sorted
- forEach
- map
- stripLeft
- stripRight
- strip
- dePrefix
- toCamelCase
- toSnakeCase
- prettyPrint
- stringPrettier
- ensureKeys
- difference

## common.isolate.dart
### ISOLATE
使用 dart Isolate, 簡化 Isolate 使用 
- create
- start
- stop


## common.fetch.dart
### RetryFetcher
fetch 自動重試，直到:
- 超過最大請求次數
- fetch 成功 
- 使用者 cancel

> source
```dart
class RetryFetcher {
  final Duration minInterval;
  final int maxRettries;
  final Future Function() fetcher;
  int retries = 0;

  RetryFetcher({
    required this.fetcher,
    this.minInterval = const Duration(seconds: 0),
    this.maxRettries = 5
  });
}
```

#### example
```dart

void main(){
  group('RetryFetcher base tests', (){
    test('expect 5 retries', ()async {
      int retries = 0;
      final r = RetryFetcher(fetcher: () async {
        retries ++;
        if (retries < 5){
          print('retries $retries with failed response');
          throw Exception('error throws');
        }
        return Future.value('');
      }, maxRettries: 5, duration: Duration(seconds: 1));
      r.fetch();
      for (var i = 0; i < 5; ++i) {
        print(i);
        await Future.delayed(r.duration);
      }
      expect(retries, equals(r.retries));
    });

    test('expect 2 retries, one failed the other success', () async {
      int retries = 0;
      final r = RetryFetcher(fetcher: () async {
        retries ++;
        if (retries == 2){
          print('retries $retries with sucessfully response');
          return Future.value('Success');
        }
        if (retries < 5){
          print('retries $retries with failed response');
          throw Exception('error throws');
        }
      }, maxRettries: 5, duration: Duration(seconds: 1));
      r.fetch();
      for (var i = 0; i < 3; ++i) {
        print(i);
        await Future.delayed(r.duration);
      }
      expect(retries, equals(2));
    });
  });
}
```

## common.platform.dart
### Platform
跨平台 Platform 工具, mobile/web 均可使用
#### loader
```dart
export 'sketch/platform.loader.dart'
if (dart.library.io) 'mobile/io.platform.mobile.dart'
if (dart.library.html) 'web/io.platform.web.dart';
```

#### 介面 PlatformSketch
```dart
abstract class PlatformSketch{
  Map<String, String> get environment;
  bool get isMacOS;
  Uri get script;
  bool get isWeb;
  bool get isWindows ;
  bool get isLinux;
  bool get isAndroid ;
}
```


## common.date.dart
#### CrossingDateDetector
- [CrossingDateDetector] ( singleton )
  
  用於偵測換日, 於[Widget] 時請用 mixin [CrossingDateWidget]

- [addDetectee] 
  
  註冊一個callback, 當crossingDate 發生㫢執行

- [isCrossingDate] 
  
  用來判斷初始化時間是否小於所指定的時間

> source
```dart
class CrossingDateDetector {
  CrossingDateDetector._({
    required this.instantiatedDate,
    this.intervalInSeconds = 5
  }) {
    try {
      _t?.cancel();
      _t = Timer.periodic(Duration(seconds: intervalInSeconds), (t) => _detect());
    } catch (e, s) {
      print('[ERROR] on CrossingDateDetector._, params: f $e');
      rethrow;
    }
  }
  factory CrossingDateDetector.singleton({
    required DateTime instantiatedDate,
    int intervalInSeconds = 5
  }) {
    return _instance ??= CrossingDateDetector._(
            instantiatedDate: instantiatedDate, intervalInSeconds: intervalInSeconds);
  }
}
```

#### CrossingDateWidget

用來偵測 Widget 初始化日期是否晚於現在的日期, 如用於任何 [DateAwareWidget]
若晚於現在的日期，則執行 [addDetectee]

> source
```dart
mixin CrossingDateWidget {
	CrossingDateDetector crossingDateDeteector = CrossingDateDetector.singleton(instantiatedDate: DateTimeExtension.envNow(), period: 5);
	void addDetectee(void onChange()){
		crossingDateDeteector.addDetectee(onChange);
	}

	bool isCrossingDate(DateTime date){
		return crossingDateDeteector.isCrossingDate(date);
	}
}
```

__example:__
```dart
crossingDateWidget.addDetectee(onDetected);
```

#### DateTimeExtension
用以摸擬 app 內部時間
- 提供 appInitialTime 作為 app 起動時的時間
- 提供 pseudoEventTime 作為 app 所錄制事件時間 
- envNow 將系統時間減去以上二者的差值

## common.performance.dart
### Performance
```dart
///
///  量測效能, 記錄 function 執行時間並返回其值;
///
class Performance {
  Future<T> runAsync<T>(Future<T> cb()) async {
    final a = DateTimeExtension.envNow();
    final result = await cb();
    final b = DateTimeExtension.envNow();
    diff = b.difference(a).inMilliseconds;
    _results.add(diff);
    notifyDeBouncer.run(action: (){
      _onNotify?.call(this);
    });
    return result;
  }
  T run<T>(T cb()){
    final a = DateTime.now();
    final result = cb();
    final b = DateTimeExtension.envNow();
    final diff = b.difference(a);
    _results.add(diff.inMilliseconds);
    notifyDeBouncer.run(action: (){
      _onNotify?.call(this);
    });
    return result;
  }
}
```

## common.log.dart
### Logger

## common.is.dart
### IsWhat
- not
- empty
- set
- string
- array
- Null
- number
- Int
- union 
```dart
bool union<E>(List<E> master_set, List<E> sub_set) {
    return sub_set.every((sub) => master_set.any((master) => master == sub));
}
```
- alphabetic
- upperCaseChar
- lowerCaseChar
- underlineChar
- camelCase
- snakeCase
- odd
- even

## common.dart
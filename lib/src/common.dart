import 'dart:math';
import 'package:dart_common/src/common.env.dart';
import 'package:dart_common/src/common.log.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;
import 'dart:convert';
import '../dart_common.dart';

final _D = Logger.filterableLogger(moduleName: 'common', level: ELevel.info);

void tryRaise(Function expression, [Object message = ""]) {
  try {
    try {
      expression();
    } catch (e, s) {
      _D.i(() => "[AnError] $message\n$e \n$s");
      rethrow;
    }
  } catch (e) {}
}

T? guard<T>(T expression(), Object message,
    {bool raiseOnly: true, String error = 'AnError'}) {
  if (raiseOnly) {
    try {
      return expression();
    } catch (e, s) {
      try {
        var trace = StackTrace.fromString(message.toString());
        _D.e(() => "\n[$error] $trace\n$e \n$s");
        rethrow;
      } catch (e) {
        //untested: unbolock this if ...
        //rethrow;
        return null;
      }
    }
  } else {
    try {
      return expression();
    } catch (e, s) {
      _D.e(() => "[ERROR]\n$e \n$s");
      rethrow;
    }
  }
}

T Function(C) observerGuard<T, C>(T expression(), Object message) {
  return (C _) {
    try {
      return expression();
    } catch (e, s) {
      _D.d(() => "[ERROR] $message\n$e\n$s");
      rethrow;
    }
  };
}

void raise(Object message,
    {String error = 'AnError', ELevel level = ELevel.error}) {
  try {
    try {
      throw (message);
    } catch (e, s) {
      _D.e(() => "\n[$error] $message\n$e \n$s");
      rethrow;
    }
  } catch (e) {}
}

class Tuple<K, V> {
  K key;
  V? value;
  String toString() => [key, value].toString();
  Tuple(this.key, [this.value]);
}

Map<K, V> Dict<K, V>(List<MapEntry<K, V>> data) {
  var ret = <K, V>{};
  for (var i = 0; i < data.length; ++i) {
    var d = data[i];
    ret[d.key] = d.value;
  }
  return ret;
}

class Triple<F, M, C> {
  F father;
  M mother;
  C child;

  String toString() => [father, mother, child].toString();

  Triple(this.father, this.mother, this.child);
}

class TLinked<T> {
  void Function(T arg) master;
  void Function(void Function()) slaveSetter;
  void Function()? _slave;

  void Function() get slave {
    if (_slave == null) throw Exception('slave has not been set');
    return _slave!;
  }

  set slave(void cb()) => _slave = cb;

  TLinked(this.master, this.slaveSetter);
}

class Pointer<T> {
  late T value;

  Pointer(this.value);

  Pointer.empty();
}

/// tested:
/// test/cachedPropertyTests.dart
/// [CacheProperty]
/// 快取
///
class CacheProperty<T> {
  static Map<int, List<CacheProperty<dynamic>>> initiateds = {};

  static void clearCachedByKey(int key) {
    if (initiateds.containsKey(key)) {
      initiateds[key]!.forEach((_) => _.clear());
    }
  }

  dynamic instance;
  late T? _value;

  late T? _prev;

  final void Function(T?)? onChange;
  final T? _defaultValue;

  CacheProperty._({this.onChange, T? defaultValue, this.instance})
      : _defaultValue = defaultValue,
        _value = defaultValue;

  factory CacheProperty(
      {void Function(T?)? onChange, T? defaultValue, dynamic instance}) {
    final result = CacheProperty._(
        onChange: onChange, defaultValue: defaultValue, instance: instance);
    if (instance != null) {
      initiateds[instance.hashCode] ??= [];
      initiateds[instance.hashCode]!.add(result);
    }
    return result;
  }

  T? get value {
    if (_value != null && _value == _prev) return _value;
    return _prev = _value;
  }

  void set value(T? value) {
    if (value == _value) return;
    _value = value;
    onChange?.call(value);
  }

  T? get prev => _prev;

  /// clear value without triggering onChange
  void clear() {
    _value = _defaultValue;
    _prev = null;
  }

  void dispose() {
    if (initiateds.containsKey(instance?.hashCode)) {
      if (initiateds[instance.hashCode]!.isNotEmpty)
        initiateds[instance.hashCode]!.removeWhere((e) => e == this);
    }
  }

  static void batchDispose(dynamic instance) {
    if (initiateds.containsKey(instance.hashCode))
      initiateds[instance.hashCode]!.clear();
  }
}

String jsonToQueryString(
    Map<String, dynamic /*String | Iterable<String>>*/ > json) {
  return Uri(queryParameters: json).query;
}

///
///
/// 用於部份 model需要 serialize to queryParameter, e.g.:
/// 1）news model
/// 2)
mixin Serializable {
  Map<String, dynamic> toJson();

  String toValidJsonString({bool stripNull = false}) {
    if (!stripNull) return jsonToQueryString({'json': jsonEncode(toJson())});
    final map = toJson();
    final stripped = {};
    map.forEach((k, v) {
      if (v != null) stripped[k] = v;
    });
    return jsonToQueryString({'json': jsonEncode(stripped)});
  }

  String toQueryString({bool stripNull = false}) {
    if (!stripNull) return jsonToQueryString(toJson());
    final map = toJson();
    final stripped = <String, dynamic>{};
    map.forEach((k, v) {
      if (v != null) stripped[k] = v.toString();
    });
    return jsonToQueryString(stripped);
  }
}

///
/// clamp value within L, R
///
T clamp<T extends num>(T source, {required T L, required T R}) {
  return min(max(source, L), R);
}

/// todo:
/// 重要 model 需要結構上的檢查，雖然用 ternary 可以避開 null 問題
/// 但副作用是，當後端結構發生改變，前端不會收到警告
/// 1） assert 結構檢察
/// 2） throw UnExpectedDataStructureException
///
/// 以下需要進行結構檢察
///
/// [BKMatch]
/// [CKMatch]
/// [SCMatch]
/// [SCMatchBasic]

/// [fields] 不支持 property access
///
void assertStructure(String modelName,
    {required Map<String, dynamic> json, required List<String> fields}) {
  if (appEnv.env == Env.production)
    return;

  final unMatchedFields = <String>{};
  fields.forEach((field) {
    if (!json.containsKey(field)) {
      unMatchedFields.add(field);
    }
  });

  json.keys.forEach((key) {
    if (!fields.contains(key)) {
      unMatchedFields.add(key);
    }
  });

  if (unMatchedFields.isNotEmpty) {
    print("[StructureAssertionFailed] modelName: $modelName, fields: $unMatchedFields");
  }
}

void main([arguments]) {
  if (arguments.length == 1 && arguments[0] == '-directRun') {
    var a = 'helloWorld';
    var b = 'hello_world';

    assert(IS.camelCase(a), '$a expect to be a camel case');
    assert(IS.snakeCase(b), '$b expect to be a snake case');

    var ta = FN.toSnakeCase(a);
    var tb = FN.toCamelCase(b);

    assert(ta == b, '$ta expect to be snake case');
    assert(tb == a, '$tb expect to be camel case');

    var pa = 'onSumChanged';

    assert(FN.dePrefix(pa, 'on', 'changed') == 'Sum',
        '''\nexpect $pa to be Sum, got: ${FN.dePrefix(pa, 'on', 'changed')}''');
    assert(FN.dePrefix(pa, 'on', 'changed', true) == 'sum',
        '''\nexpect $pa to be sum, got: ${FN.dePrefix(pa, 'on', 'changed', true)}''');
  }
}



///
///  tested:
///  依據 instance 取得 Ident Object
///  提供 dispose 方法用以消滅 Ident Object
///
class Ident {
  static Map<dynamic, Map<int, Object>> _identities = {};
  static void set<T>(T val){
    _identities[T] ??= {};
    _identities[T]![val.hashCode] = Object();
  }

  static Object get<T>(T val){
    _identities[T] ??= {};
    if (_identities[T]!.containsKey(val.hashCode)){
      assert(_identities[T]![val.hashCode] != null);
      return _identities[T]![val.hashCode]!;
    }
    set<T>(val);
    return _identities[T]![val.hashCode]!;
  }

  static void dispose<T>(T val){
    _identities[T] ??= {};
    _identities[T]!.remove(val.hashCode);
  }
}

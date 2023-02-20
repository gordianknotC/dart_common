


///
/// a ref, works like a pointer
///
/// 在 dart 裡，址相似於 Object
/// 而值存在 Object 裡面
///
class Ref<T>{
  T? _value;
  Ref(this._value);

  T? get value => _value;
  void set value(T? val) => _value = val;
}

import 'package:dart_common/src/common.fn.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;

/// tested: test/package_number.test.dart
class PackageNumber {
  ///1.12.13+12
  final RegExp regex = RegExp(r'([0-9]+.)([0-9]+.)([0-9]+)(\+[0-9]+){0,1}');
  final String versionString;
  late int _majorNumber = 0;
  late int _minorNumber = 0;
  late int _maintainNumber = 0;
  late int _patchNumber = 0;

  PackageNumber(this.versionString) {
    final result = regex.firstMatch(versionString);
    try {
      assert(result != null);
      assert(result!.group(1) != null, 'group 1');
      assert(result!.group(2) != null, 'group 2');
      assert(result!.group(3) != null, 'group 3');
      _majorNumber = int.parse(result!.group(1)!.split('.').first);
      _minorNumber = int.parse(result.group(2)!.split('.').first);
      _maintainNumber = int.parse(result.group(3)!);
      _patchNumber = int.parse((result.group(4) ?? "+0").split('+').last);
    } catch (e, s) {
      print('[ERROR] on PackageNumber.PackageNumber, versionString $versionString $e\n$s');
      rethrow;
    }
  }

  // bool greaterThanInSequencedOrder(
  //     List<int> numbersCurrent, List<int> numbersOther) {
  //   if (numbersCurrent.first > numbersOther.first)
  //     return true;
  //   else if (numbersCurrent.first == numbersOther.first)
  //     return greaterThanInSequencedOrder(
  //         FN.tail(numbersCurrent).toList(), FN.tail(numbersOther).toList());
  //   return false;
  // }
  //
  // bool lessThanInSequencedOrder(
  //     List<int> numbersCurrent, List<int> numbersOther) {
  //   if (numbersCurrent.first < numbersOther.first)
  //     return true;
  //   else if (numbersCurrent.first == numbersOther.first)
  //     return lessThanInSequencedOrder(
  //         FN.tail(numbersCurrent).toList(), FN.tail(numbersOther).toList());
  //   return false;
  // }

  bool operator >(PackageNumber other) {
    if (_majorNumber > (other._majorNumber))
      return true;
    else if (_majorNumber == other._majorNumber) {
      if (_minorNumber > (other._minorNumber))
        return true;
      else if (_minorNumber == (other._minorNumber)) {
        if (_maintainNumber > (other._maintainNumber))
          return true;
        else if (_maintainNumber == (other._maintainNumber)) {
          if (_patchNumber > (other._patchNumber)) return true;
          return false;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool operator <(PackageNumber other) {
    if (_majorNumber < (other._majorNumber))
      return true;
    else if (_majorNumber == other._majorNumber) {
      if (_minorNumber < (other._minorNumber))
        return true;
      else if (_minorNumber == (other._minorNumber)) {
        if (_maintainNumber < (other._maintainNumber))
          return true;
        else if (_maintainNumber == (other._maintainNumber)) {
          if (_patchNumber < (other._patchNumber)) return true;
          return false;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  bool operator ==(other) {
    if (other is! PackageNumber) return false;
    return _majorNumber == (other._majorNumber) &&
        _minorNumber == (other._minorNumber) &&
        _maintainNumber == (other._maintainNumber) &&
        _patchNumber == (other._patchNumber);
  }

  @override
  String toString() {
    return "$_majorNumber $_minorNumber $_maintainNumber $_patchNumber";
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}





import 'package:dart_common/src/common.fn.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;

/// tested: test/package_number.test.dart
class PackageNumber {
  ///1.12.13+12
  final RegExp regex = RegExp(r'([0-9]+.)([0-9]+.)([0-9]+)(\+[0-9]+){0,1}');
  final String versionString;
  late final int majorNumber ;
  late final int minorNumber ;
  late final int maintainNumber ;
  late final int patchNumber ;

  PackageNumber(this.versionString) {
    final result = regex.firstMatch(versionString);
    try {
      assert(result != null);
      assert(result!.group(1) != null, 'group 1');
      assert(result!.group(2) != null, 'group 2');
      assert(result!.group(3) != null, 'group 3');
      majorNumber = int.parse(result!.group(1)!.split('.').first);
      minorNumber = int.parse(result.group(2)!.split('.').first);
      maintainNumber = int.parse(result.group(3)!);
      patchNumber = int.parse((result.group(4) ?? "+0").split('+').last);
    } catch (e, s) {
      print('[ERROR] on PackageNumber.PackageNumber, versionString $versionString $e\n$s');
      rethrow;
    }
  }

  bool operator >(PackageNumber other) {
    if (majorNumber > (other.majorNumber))
      return true;
    else if (majorNumber == other.majorNumber) {
      if (minorNumber > (other.minorNumber))
        return true;
      else if (minorNumber == (other.minorNumber)) {
        if (maintainNumber > (other.maintainNumber))
          return true;
        else if (maintainNumber == (other.maintainNumber)) {
          if (patchNumber > (other.patchNumber)) return true;
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
    if (majorNumber < (other.majorNumber))
      return true;
    else if (majorNumber == other.majorNumber) {
      if (minorNumber < (other.minorNumber))
        return true;
      else if (minorNumber == (other.minorNumber)) {
        if (maintainNumber < (other.maintainNumber))
          return true;
        else if (maintainNumber == (other.maintainNumber)) {
          if (patchNumber < (other.patchNumber)) return true;
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
    return majorNumber == (other.majorNumber) &&
        minorNumber == (other.minorNumber) &&
        maintainNumber == (other.maintainNumber) &&
        patchNumber == (other.patchNumber);
  }

  @override
  String toString() {
    return "$majorNumber $minorNumber $maintainNumber $patchNumber";
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}





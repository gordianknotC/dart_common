import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:dart_common/src/common.log.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;
import 'package:meta/meta.dart';

final _UPPERCACE_A = 'A'.codeUnitAt(0);
final _UPPERCASE_Z = 'Z'.codeUnitAt(0);
final _LOWERCASE_A = 'a'.codeUnitAt(0);
final _LOWERCASE_Z = 'z'.codeUnitAt(0);

//@formatter:off
class _IsNotWhat {
	bool set(Set set) => !IS.set(set);
	
	bool string(String s) => !IS.string(s);
	
	bool array(List<dynamic> arr) => !IS.array(arr);
	
	bool number(String n) => !IS.number(n);
	
	bool Int(String n) => !IS.Int(n);
	
	bool Null(dynamic a) => !IS.Null(a);
	
	bool empty(dynamic s) => !IS.empty(s);
}

final IS = IsWhat();

class IsWhat {
	late _IsNotWhat _not;
	
	get not {
		_not ??= _IsNotWhat();
		return _not;
	}
	
	bool
	empty(dynamic s) {
		if (s is Set) return s.isEmpty;
		if (s is String) return s.length <= 0;
		if (s is List) return s.length <= 0;
		return s == null || s == 0;
	}
	
	bool
	set(dynamic set) => set is Set;
	
	bool
	string(dynamic text) => text is String;
	
	bool
	array(dynamic arr) => arr is List;
	
	bool
	Null(dynamic a) => a == null;
	
	bool
	number(dynamic text) =>
			text is String
					? double.tryParse(text) != null
					: text is num;
	
	bool
	Int(dynamic text) =>
			text is String
					? int.tryParse(text) != null
					: text is int;
	
	bool
	union<E>(List<E> master_set, List<E> sub_set) {
		return sub_set.every((sub) => master_set.any((master) => master == sub));
	}
	
	bool
	alphabetic(String w) {
		return w.codeUnitAt(0) >= _UPPERCACE_A && w.codeUnitAt(0) <= _LOWERCASE_Z;
	}
	
	bool
	upperCaseChar(String w) {
		return w.codeUnitAt(0) >= _UPPERCACE_A && w.codeUnitAt(0) <= _UPPERCASE_Z;
	}
	
	bool
	lowerCaseChar(String w) {
		return w.codeUnitAt(0) >= _LOWERCASE_A && w.codeUnitAt(0) <= _LOWERCASE_Z;
	}
	
	bool
	underlineChar(String w) {
		return w == '_';
	}
	
	bool
	camelCase(String word) {
		var letters = word.split('');
		var first_test = IS.upperCaseChar(letters[0]) ? IS.upperCaseChar : IS.lowerCaseChar;
		var second_test = first_test == IS.upperCaseChar ? IS.lowerCaseChar : IS.upperCaseChar;
		
		if (first_test(letters[0])) {
			var altered = letters.firstWhere((l) => second_test(l), orElse: () => "");
			var idx = altered.isNotEmpty ? letters.indexOf(altered) : letters.length;
			if (idx < letters.length - 1) {
				if (letters.indexWhere((l) => first_test(l), idx) != -1)
					return true;
			}
			return false;
		} else {
			return false;
		}
	}
	
	bool
	snakeCase(String word) {
		var letters = word.split('');
		var first_test = IS.alphabetic(letters[0]) ? IS.alphabetic : IS.underlineChar;
		var second_test = first_test == IS.alphabetic ? IS.underlineChar : IS.alphabetic;
		
		if (first_test(letters[0])) {
			var altered_char = letters.firstWhere((l) => second_test(l), orElse: () => "");
			var idx = altered_char.isNotEmpty
					? letters.indexOf(altered_char)
					: letters.length;
			if (idx < letters.length - 1) {
				if (letters.indexWhere((l) => first_test(l), idx) != -1)
					return true;
			}
			return false;
		} else {
			return false;
		}
	}
	
	bool
	odd(int num) => num != 0 && ((num - 1) % 2 == 0);
	
	bool
	even(int num) => num != 0 && (num % 2 == 0);
}



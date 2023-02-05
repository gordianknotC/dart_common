import 'dart:async';
import 'dart:isolate';
import 'package:colorize/colorize.dart' show Colorize, Styles;


import '../common.dart';
import 'common.dart';
import 'common.is.dart';

typedef _TEndsStartsWith = bool Function(String source, String end);
typedef _TSubstring = String Function(String source, int start, int end);

String _keepIndent(String source, int level) {
	const tab = '\t';
	var ol = source.length;
	var _source = FN.stripLeft(source, tab);
	var initial_indent = ol - _source.length + level;
	if (initial_indent > 0) {
		return _source.split('\n').map((String line) {
			return (tab * initial_indent) + line;
		}).join('\n');
	}
	return source;
}


class FN {
	static void callEither(Function? a, Function? b){
		assert(a != null || b != null);
		if (a != null)
			a();
		else
			b!();
	}
	
	static bool orderedEqualBy<E>(List<E>? a, List<E>? b, bool eq(E a, E b)){
		if ((a?.isEmpty ?? true) && (b?.isEmpty ?? true))
			return true;
		
		if (a?.length != b?.length)
			return false;
		
		for (var i = 0; i < a!.length; ++i) {
			final _a = a[i];
			final _b = b![i];
			if (!eq(_a, _b))
				return false;
		}
		return true;
	}
	
	static bool orderedTheSame<E>(List<E> a, List<E> b){
		return orderedEqualBy<E>(a, b, (_a, _b) => _a == _b);
	}
	
	static assertEitherNotBoth(bool a, bool b) {
		assert((a || b) == true);
		assert((a && b) == false);
	}
	
	static Iterable<T> uniqueBy<T>(Iterable<T> data, bool isDuplicate(T a, T b)) {
		return data.fold<List<T>>([], (initial, b) {
			if (initial.any((a) => isDuplicate(a, b)))
				return initial;
			return initial + [b];
		});
	}
	
	static Map<Type, Tuple<Isolate, StreamSubscription>> _ISOLATES = {};
	
	static Future<Tuple<Isolate, StreamSubscription>>
	createIsolate<T>(void onIsolate(T s), T data) async {
		if (_ISOLATES.containsKey(T))
			return _ISOLATES[T]!;
		final isolate =  await Isolate.spawn<T>(onIsolate, data);
		return _ISOLATES[T] = Tuple(isolate, null);
	}
	
	static Future<Isolate>
	startIsolate<T>(void onIsolate(T s), T data, void onReceived(dynamic s), ReceivePort receivePort) async {
		final completer = Completer<Isolate>();
		final isolate = await createIsolate<T>(onIsolate, data);
		if (isolate.value == null){
			isolate.value = receivePort.listen((response) {
				onReceived(response);
			});
		}else{
			stopIsolate<T>(isolate.key);
			return startIsolate<T>(onIsolate, data, onReceived, receivePort);
		}
		completer.complete(isolate.key);
		return completer.future;
	}
	
	static void stopIsolate<T>(Isolate? isolate) {
		if (isolate != null) {
			if (_ISOLATES.containsKey(T))	{
				isolate.kill(priority: Isolate.immediate);
				_ISOLATES[T]!.value?.cancel();
				_ISOLATES.remove(T);
			}else{
				guard((){
					final entry = _ISOLATES.entries.firstWhere((entry) => entry.value.key == isolate);
					entry.value.key.kill.call(priority: Isolate.immediate);
					entry.value.value?.cancel.call();
					_ISOLATES.remove(entry.key);
				}, "isolate entry not found");
			}
		}
	}
	
	T? getMapKeyByWhereValue<T, V>(Map<T, V> map, V value) {
		return guard((){
			return map.entries
					.firstWhere((e) => e.value == value)
					.key;
		}, "getMapKeyByWhereValue, value not found $value");
	}
	
	/// --------------------------------------
	/// link master function to slave one
	/// FIXME: untested
	static TLinked<T>
	linkCallback<T>(void master(T arg), void slaveSetter(void slave())) {
		late TLinked<T> result;
		late void Function() relinked_slave;
		void linked_slave(void slave()) {
			slaveSetter(slave);
			relinked_slave = slave;
			result.slave = slave;
		};
		void newMaster(T arg) {
			master(arg);
			relinked_slave();
		}
		return result = TLinked(newMaster, linked_slave);
	}
	
	static T? getEltOrNull<T>(List<T> elements, int id) {
		final l = elements.length;
		if (id < l) return elements[id];
		return null;
	}

	///
	/// 強制轉為二維陣列
	/// __example__
	/// ```dart
	/// expect(FN.asTwoDimensionList(list, 1), equals([[1], [2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]]));
	/// expect(FN.asTwoDimensionList(list, 2), orderedEquals([[1,2], [3,4],[5,6],[7,8],[9,10],[11,12]]));
	/// ```
	static List<List<T>>
	asTwoDimensionList<T>(List<T> list, int dimension) {
		final result = <List<T>>[];
		for (var i = 0; i < list.length; ++i) {
			var o = list[i];
			var reorder = (i / dimension).floor();
//         _D.debug('i: $i, reorder:$reorder');
			if (i % dimension == 0)
				result.add(<T>[]);
			result[reorder].add(o);
		}
		return result;
	}
	
	static E
	range<E>(E s, [int? start, int? end]) {
		if (E == String) {
			var source = s as String;
			if (start != null && start < 0)
				start = source.length + start;
			if (end != null && end < 0)
				end = source.length + end;
			return source.substring(start!, end) as E;
		} else if (E == List) {
			var source = s as List;
			if (start != null && start < 0)
				start = source.length + start;
			if (end != null && end < 0)
				end = source.length + end;
			return source.sublist(start!, end) as E;
		} else {
			throw Exception('Invalid type. Only support for string or list');
		}
	}
	
	static Iterable<E>
	head<E>(List<E> array) {
		return array.sublist(0, array.length - 1);
	}
	
	static Iterable<E>
	tail<E>(List<E> array) {
		return array.sublist(1, array.length);
	}
	
	static E
	last<E>(List<E> array) {
		return array.last;
	}
	
	static E
	first<E>(List<E> array) {
		return array.first;
	}
	
	static T
	remove<T>(List<T> array, T element) {
		return array.removeAt(array.indexOf(element));
	}
	
	static List<String>
	split(String data, String ptn, [int max = 1]) {
		late String d = data, pre, suf;
		var ret = <String>[];
		for (var i = 0; i < max; ++i) {
			var idx = d.indexOf(ptn);
			if (idx == -1) {
				ret.add(d);
				return ret;
			}
			pre = d.substring(0, idx);
			suf = d.substring(pre.length + 1);
			d = suf;
			ret.add(pre);
		}
		ret.add(suf);
		return ret;
	}
	
	static int
	findIndex<T>(List<T> data, bool search(T element)) {
		int? result = -1;
		FN.forEach(data, (T el, [int? i]) {
			if (search(el)) {
				result = i;
				return true;
			}
			return false;
		});
		return result ?? -1;
	}

	static int
	count<E>(List<E> A, E B, bool comp(E a, E b)) {
		var counter = 0;
		var len = A.length;
		for (var ia = 0; ia < len; ++ia) {
			var ra = A[ia];
			if (comp(ra, B))
				counter ++;
		}
		return counter;
	}
	
	static int
	countBy<E>(List<E> data, int comp(E a)){
		return data.fold<int>(0, (initial, b){
			return initial + comp(b);
		});
	}
	
	static List<E>
	unique<E>(List<E> A, bool filter(List<E> acc, E b)) {
		List<E> result = [];
		filter ??= (acc, b) => acc.contains(b);
		for (var i = 0; i < A.length; ++i) {
			var a = A[i];
			if (filter(result, a))
				result.add(a);
		}
		return result;
	}
	
	static Iterable<List<T>>
	zip<T>(Iterable<Iterable<T>> iterables) sync* {
		if (iterables.isEmpty) return;
		//note: without toList(growable: false) - causes infinite loop ???
		final iterators = iterables.map((e) => e.iterator).toList(growable: false);
		while (iterators.every((e) => e.moveNext())) {
			yield iterators.map((e) => e.current).toList(growable: false);
		}
	}
	
	static Iterable<E>
	union_1dlist<E>(List<E> left, List<E> right, [bool comp(List<E> a, E b)?]) {
		var already_in_r = false;
		var ret = left;
		comp ??= (a, b) => a.contains(b);
		
		for (var i = 0; i < right.length; ++i) {
			var r_member = right[i];
			already_in_r = left.any((l_member) => l_member == r_member);
			if (already_in_r) {} else {
				ret.add(r_member);
			};
		}
		return ret;
	}
	
	static List<List<E>>
	union_2dlist<E>(List<List<E>> left, List<List<E>> right, [bool comp(List<E> a, E b)?]) {
		var already_in_r = false;
		var all = <List<E>>[];
		comp ??= (a, b) => a.contains(b);
		
		for (var i = 0; i < right.length; ++i) {
			var r_member = right[i];
			already_in_r = r_member.every((ref) =>
					left.any((l_member) =>
							comp!(l_member, ref)));
			if (already_in_r) {} else {
				all.add(r_member);
			};
		}
		return all;
	}
	
	static List<T>
	sorted<T>(List<T> data, [int compare(T a, T b)?]) {
		if (data.isEmpty) return data;
		final iterators = data.toList(growable: false);
		iterators.sort(compare);
		return iterators;
	}
	
	static void
	forEach<T>(List<T> list, bool Function(T member, [int index]) cb) {
		var length = list.length;
		for (var i = 0; i < length; ++i) {
			if (cb(list[i], i)) return;
		}
	}
	
	static Iterable<T>
	map<T, E>(List<E> list, T Function(E member, [int index]) cb) {
		var i = -1;
		return list.map((e) {
			i ++;
			return cb(e, i);
		});
	}
	
	
	static String
	_strip(String source, List<String> stripper,
			int srlen, int stlen,
			_TEndsStartsWith conditioning, _TSubstring substring) {
		var strip_counter = -1;
		while (strip_counter != 0) {
			strip_counter = 0;
			for (var i = 0; i < stlen; ++i) {
				if (conditioning(source, stripper[i])) {
					source = substring(source, 0, source.length - 1);
					strip_counter ++;
				}
			}
		}
		return source;
	}
	
	static String
	_stripRight(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) {
		return _strip(source, stripper, srlen, stlen, conditioning, substring);
	}
	
	static String
	_stripLeft(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) {
		return _strip(source, stripper, srlen, stlen, conditioning, substring);
	}
	
	static String
	_stripLR(String source, String stripper,
			String Function(String source, List<String> stripper, int srlen, int stlen, _TEndsStartsWith conditioning, _TSubstring substring) pathway,
			_TEndsStartsWith conditioning, _TSubstring substring) {
		var l = stripper.length;
		if (l == 0) return source;
		if (l == 1) {
			if (conditioning(source, stripper)) {
				return substring(source, 0, source.length - 1);
			}
		} else {
			return pathway(source, stripper.split(''), source.length, stripper.length, conditioning, substring);
		}
		return source;
	} //@fmt:on
	
	static String
	stripLeft(String source, [String stripper = " "]) {
		return _stripLR(source, stripper, _stripLeft,
						(String s, String end) => s.startsWith(end),
						(String s, int start, int end) => s.substring(s.length - end));
	}
	
	static String
	stripRight(String source, [String stripper = " "]) {
		return _stripLR(source, stripper, _stripRight,
						(String s, String end) => s.endsWith(end),
						(String s, int start, int end) => s.substring(start, end));
	}
	
	static String
	strip(String source, [String stripper = " "]) {
		return stripLeft(stripRight(source, stripper), stripper);
	}
	
	static String
	dePrefix(String prefixed_name, String prefix, [String suffix = '', bool to_camelcase = false]) {
		var l = prefix.length;
		var r = suffix.length;
		var name = prefixed_name.substring(l, prefixed_name.length - r);
		if (to_camelcase)
			return '${name.substring(0, 1).toLowerCase()}${name.substring(1)}';
		return '${name.substring(0, 1)}${name.substring(1)}';
	}
	
	static String
	toCamelCase(String word) {
		var current_under = IS.upperCaseChar(word[0]),
				last_under = null,
				altered = false;
		if (IS.snakeCase(word)) {
			word = word.split('').map((w) {
				current_under = IS.underlineChar(w);
				altered = last_under != current_under;
				last_under = current_under;
				if (altered && current_under == true)
					return '';
				if (altered)
					return w.toUpperCase();
				return w;
			}).join('');
			return '${word.substring(0, 1).toLowerCase()}${word.substring(1)}';
		}
		return word;
	}
	
	static String
	toSnakeCase(String word) {
		var current_upper = IS.upperCaseChar(word[0]),
				last_upper = null,
				altered = false;
		if (IS.camelCase(word))
			return word.split('').map((w) {
				current_upper = IS.upperCaseChar(w);
				altered = last_upper != current_upper;
				last_upper = current_upper;
				if (altered && current_upper == true)
					return '_' + w.toLowerCase();
				return w;
			}).join('');
		return word;
	}
	
	
	static void
	prettyPrint(dynamic source, [int level = 0, bool colorized = true]) {
		print(FN.stringPrettier(source, level, colorized));
	}
	
	static Object
	stringPrettier(dynamic node, [int level = 0, bool colorized = true]) {
		var output = '';
		if (node is Map) {
			Map _node = node;
			output += "\t" * level + "{" + '\n';
			_node.forEach((n, value) {
				var keyname = "\t" * (level + 1) + n.toString();
				var val = FN.stringPrettier(value, level + 1, colorized).toString().trim();
				output += '$keyname: ${val},\n';
			});
			return output + "\t" * level + '}';
		}
		if (node is List) {
			List _node = node;
			output += "\t" * level + "[" + '\n';
			_node.forEach((value) {
				var val = FN.stringPrettier(value, level + 1, colorized);
				output += '${val}, \n';
			});
			return output + "\t" * level + ']';
		}
		output += node.toString();
		String vstring; //value string
		String tstring; //type string
		if (colorized) {
			var t = Colorize(node.runtimeType.toString());
			var v = Colorize(output);
			v.apply(Styles.LIGHT_GREEN);
			v.apply(Styles.BOLD);
			t.apply(Styles.LIGHT_MAGENTA);
			vstring = v.toString();
			tstring = t.toString();
		} else {
			vstring = output;
			tstring = '';
		}
//      var vstring = v.toString();
		var clines = vstring
				.split('\n')
				.length;
		vstring = clines > 1
				? _keepIndent(vstring, level)
				: vstring;
		return "\t" * (level) + '$tstring $vstring';
	}
	
	static void ensureKeys<T>(Map<T, dynamic> map, List<T> keys) {
		final result = <T>[];
		for (final key in map.keys) {
			if (!keys.contains(key) || map[key] == null) {
				result.add(key);
			}
		}
		if (result.length > 0) {
			throw Exception('Map keys missmatched. following keys are missing:\n ${result.map((m) => m.toString()).toList()}');
		}
	}
	
	static void updateDictByMembers(Map<String, dynamic> target, Map<String, dynamic> source, {
		required List<String> members, bool removeFromSource = false
	}) {
		members.forEach((m) {
			if (source.containsKey(m)) {
				target[m] = source[m];
				if (removeFromSource)
					source.remove(m);
			}
		});
	}
	
	static int countOn<T>(List<T> data, bool Function(T d) condition) {
		int result = 0;
		for (var i = 0; i < data.length; ++i) {
			var o = data[i];
			if (condition(o))
				result ++;
		}
		return result;
	}
	
	//fixme:
	static List<int> difference(List<int> list, List<int> list2) {
		if (list == null || list2 == null)
			throw Exception('list should not be null');
		final longest = list.length > list2.length ? list : list2;
		final shortest = list.length > list2.length ? list2 : list;
		final result = <int>[];
		for (var i = 0; i < longest.length; ++i) {
			var rec = longest[i];
			if (!shortest.contains(rec))
				result.add(rec);
		}
		return result;
	}
}






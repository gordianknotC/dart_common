import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:colorize/colorize.dart' show Colorize, Styles;
import 'dart:collection';

import 'package:meta/meta.dart';


class TwoSeq<A, B>{
	A first;
	B second;
	TwoSeq(this.first, this.second);
}

// fixme: size overflow detection (bigger than 4 bytes)
class TwoDBytes {
	late Uint8List bytes;
	int lengthByes = 4;
	
	TwoDBytes(List<List<int>> twoD_list, {this.lengthByes = 4}) {
		bytes = twoDtoOneDList(twoD_list, lengthByes);
	}
	
	TwoDBytes.fromOneD(this.bytes);
	
	static Uint8List twoDtoOneDList(List<List<int>> tdim, [int lengthByes = 4]) {
		List<int> ret = [tdim.length];
		for (var i = 0; i < tdim.length; ++i) {
			final Uint8List rec_data = Uint8List.fromList(tdim[i]);
			final rec_data_length = rec_data.lengthInBytes;
			final length_in_bytes = intToBytes(rec_data_length, lengthBytes: lengthByes);
			// print('flag: $i');
			// print('rec_data: ${rec_data.sublist(0, 20)}...');
			// print('rec_data_legnth in bytes: $rec_data_length');
			// print('num_of_length_bytes: $length_in_bytes, ${bytesToInt(length_in_bytes)}');
			ret.add(lengthByes);
			ret.addAll(length_in_bytes);
			ret.addAll(rec_data);
		}
		return Uint8List.fromList(ret);
	}
	
	static num bytesToInt(Uint8List bytes) {
		num number = 0;
		for (var i = 0; i < bytes.length; ++i) {
			var n = bytes[i];
			if (i == 0)
				number += n;
			else
				number += (n * pow(256, i));
		}
		return number;
	}
	
	static Uint8List intToBytes(int number, {int lengthBytes = 4}) {
		final list = Uint64List.fromList([number]);
		return Uint8List.view(list.buffer).sublist(0, lengthBytes);
	}
	
	int get length {
		return bytes.lengthInBytes;
	}
	
	int get recordsLength {
		return bytes[0];
	}
	
	Stream<Uint8List> get records async* {
		var r = 2;
		var l = 2;
		late Uint8List data_length;
		late int numberof_data_length;
		try {
			for (var flag = 0; flag < recordsLength; ++flag) {
				l = r;
				data_length = Uint8List.fromList(bytes.sublist(l, l + lengthByes));
				numberof_data_length = bytesToInt(data_length) as int;
				l += lengthByes;
				r = l + numberof_data_length + 1;
				yield Uint8List.fromList(bytes.sublist(l, r - 1));
			}
		} on RangeError catch (e) {
			throw Exception(
					'lbound:$l, rbound:$r, data_length:$data_length, numberof_data_length: $numberof_data_length'
							'\n${StackTrace.fromString(e.toString())}');
		} catch (e) {
			throw Exception(e);
		}
	}
}





extension SetExtension<T> on Set<T>{
	Set exclusive(Set other){
		final added = other.difference(this);
		final subtracted = other.where(this.contains).toSet();
		return Set.from(other)
			..addAll(this)
			..removeAll(subtracted);
	}

	///
	/// final excluded = a.exclusive(b)
	/// a.reverseExcluded(excluded) == b
	///
	Set reverseExclusive(Set exclusived){
		final added = exclusived.difference(this);
		final union = Set.from(this);
		union.removeWhere((_) => exclusived.contains(_));
		return union..addAll(added);
	}
}




mixin ListCommon<T>{
	List<T?> get delegate;
	bool contains(T element){
		return delegate.contains(element);
	}

	T? get first{
		return delegate.first;
	}

	bool get isEmpty{
		return delegate.every((_) => _ == null);
	}

	T? operator [](int idx) {
		return delegate[idx];
	}

	void operator []= (int idx, T? other){
		delegate[idx] = other;
	}

	int get length => delegate.length;

	int indexOf(T element){
		return delegate.indexOf(element);
	}

	Iterable<T?> where(bool condition(T? element)){
		return delegate.where(condition);
	}

	void clear(){
		delegate.clear();
	}

	void add(T element){
		delegate.add(element);
	}

	void addAll(List<T> elements);
}


///
/// [FixedLengthList]
/// 固定長度LIST，當長度溢位 [onExceed]，可重設 List 或 保持不變
/// 用於 [ScoreNotifierModel]
///
class FixedLengthList<T> with ListCommon<T>{
	@override final List<T?> delegate;
	/// [onExceed]
	/// return true to reset index and keep data remain the same, user should
	/// implement data reset strategy by their own;
	///
	final int len;
	final bool Function(List<T?>, int) onExceed;
	final bool resetIdxOnExceed;
	int _idx = 0;
	FixedLengthList(this.len, {required this.onExceed, this.resetIdxOnExceed = true}): delegate = List<T?>.filled(len, null);

	@override void add(T element){
		delegate[_idx] = element;
		_idx = min(len, _idx + 1);
		if (_idx == len){
			try {
				if (onExceed(delegate, len)){
					if (resetIdxOnExceed){
						_idx = 0;
						delegate[_idx] = element;
					}else{
						_idx = len - 1;
						delegate[_idx] = element;
					}
				}
			} catch (e, s) {
				print('[ERROR] on FixedLengthList.add, length: ${delegate.length}/$len $e\n$s');
				rethrow;
			}
		}
	}

	@override void clear(){
		_idx = 0;
		for (var i = 0; i < len; ++i) {
			delegate[i] = null;
		}
	}


	T? get latest{
		return delegate[max(0, _idx -1)];
	}

	@override
	int get length => delegate.where((_) => _ != null).length;

	@override
	void addAll(List<T> elements) {

		for (var i = 0; i < elements.length; ++i) {
			var o = elements[i];
			add(o);
		}
		// TODO: implement addAll
//		if (elements.length > len){
//			final data = elements.sublist(elements.length - len);
//			for (var i = 0; i < data.length; ++i) {
//				var o = data[i];
//				add(o);
//			}
//		}else{
//			for (var i = 0; i < elements.length; ++i) {
//				var o = elements[i];
//				add(o);
//			}
//		}
	}
}





/// [groupBy] 使用的是 Map, 而不是 ordered map
/// [LinkedHashMap] 為 ordered Map
///
LinkedHashMap<T, List<S>> orderedGroupBy<S, T>(Iterable<S> values, T key(S element)) {
	final map = LinkedHashMap<T, List<S>>();
	final data = values.toList();
	for (var i = 0; i < data.length; ++i) {
		final v = data[i];
		map[key(v)] ??= [];
		map[key(v)]!.add(v);
	}
	return map;
}









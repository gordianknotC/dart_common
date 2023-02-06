import 'dart:async';
import 'dart:isolate';


import '../dart_common.dart';
import 'common.dart';

final Map<Type, Tuple<Isolate, StreamSubscription>> ISOLATES_CONTAINER = {};

class ISOLATE {
	static Map<Type, Tuple<Isolate, StreamSubscription>> _ISOLATES = _ISOLATES;

	static Future<Tuple<Isolate, StreamSubscription>>
	create<T>(void onIsolate(T s), T data) async {
		if (_ISOLATES.containsKey(T))
			return _ISOLATES[T]!;
		final isolate =  await Isolate.spawn<T>(onIsolate, data);
		return _ISOLATES[T] = Tuple(isolate, null);
	}

	static Future<Isolate>
	start<T>(void onIsolate(T s), T data, void onReceived(dynamic s), ReceivePort receivePort) async {
		final completer = Completer<Isolate>();
		final isolate = await create<T>(onIsolate, data);
		if (isolate.value == null){
			isolate.value = receivePort.listen((response) {
				onReceived(response);
			});
		}else{
			stop<T>(isolate.key);
			return start<T>(onIsolate, data, onReceived, receivePort);
		}
		completer.complete(isolate.key);
		return completer.future;
	}

	static void stop<T>(Isolate? isolate) {
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
}



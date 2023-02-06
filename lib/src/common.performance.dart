import 'dart:async';
import 'common.date.dart';



/// tested:
class _Debouncer {
	int milliseconds;
	late bool active;
	late Timer? _timer;
	late void Function()? action;

	_Debouncer({ required this.milliseconds }){
		active = false;
	}

	bool get isBouncing {
		return active;
	}

	void update([int? time, void onCompleted()?]){
		milliseconds = time ?? milliseconds;
		if (onCompleted == null)
			run(action: action);
		else{
			final prevAction = action;
			run(action: (){
				prevAction?.call();
				onCompleted();
			});
		}
	}

	void run({required void Function()? action, void onError(StackTrace err)?}) {
		this.action = action;
		_timer?.cancel();
		if (milliseconds != null){
			active = true;
			_timer = Timer(Duration(milliseconds: milliseconds), (){
				try{
					_timer?.cancel();
					this.action?.call();
					active = false;
				}catch(e){
					onError?.call(StackTrace.fromString(e.toString()));
					active = false;
					rethrow;
				}
			});
		}
	}

	void dispose(){
		active = false;
		_timer?.cancel()	;
	}

	void cancel(){
		active = false;
		_timer?.cancel();
	}
}


///
///  量測效能, 記錄 function 執行時間並返回其值;
///
class Performance {
	static final Map<String, Performance> instances = {};
	late _Debouncer notifyDeBouncer;
	late String tagname;
	late int diff;
	List<int> _results = [];

	Performance._(this.tagname);

	factory Performance.singleton(String name, {int notifySpan = 500}){
		if (!instances.containsKey(name))
			return instances[name] = Performance._(name)
				..notifyDeBouncer = _Debouncer(milliseconds: notifySpan);
		return instances[name]!;
	}

	void clear(){
		_results.clear();
	}

	void Function(Performance per)? _onNotify;
	void onNotify(void cb(Performance per)){
		_onNotify = cb;
	}

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








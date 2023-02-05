
import 'dart:async';
import 'common.log.dart';

// final _D = Logger.filterableLogger(moduleName: 'date', level: ELevel.info);


extension DateTimeExtension on DateTime{
	/// event dump 的時間
	static DateTime? _pseudoEventTime;
	/// app 初始化的時間
	static DateTime? _appInitialTime;
	///
	static void setAppInitialTime(DateTime data){
		_appInitialTime = data;
	}
	static void setPseudoEventTime(DateTime date){
		_pseudoEventTime = date;
	}
	static void clearPseudoEventTime(){
		_pseudoEventTime = null;
	}
	static DateTime envNow(){
		assert(_appInitialTime != null && _pseudoEventTime != null);
		final diff = _appInitialTime!.difference(_pseudoEventTime!);
		return DateTime.now().subtract(diff);
	}

	DateTime clone(){
		return DateTime(
			this.year, this.month, this.day, this.hour,
			this.minute, this.second, this.millisecond, this.microsecond,
		);
	}
}



/// untested:
///
/// 用來偵測 Widget 初始化日期是否晚於現在的日期
/// 若晚於現在的日期，則執行 [addDetectee] 所註冊的 callback
/// [isCrossingDate] 用來判斷現在的日期是否晚於 Widget 初始化的日期
///
/// example:
/// crossingDateWidget.addDetectee(onDetected)
///
/// 用於 [DateAwaredButton]
///
mixin CrossingDateWidget {
	CrossingDateDetector crossingDateDeteector = CrossingDateDetector.singleton(instantiatedDate: DateTimeExtension.envNow(), period: 5);
	void addDetectee(void onChange()){
		crossingDateDeteector.addDetectee(onChange);
	}

	bool isCrossingDate(DateTime date){
		return crossingDateDeteector.isCrossingDate(date);
	}
}

/// untested:
/// [CrossingDateDetector] ( singleton )
/// 用於偵測換日, 用於[Widget] 時請用 mixin [CrossingDateWidget]
///
/// [addDetectee] 註冊一個callback, 當crossingDate 發生㫢執行
/// [isCrossingDate] 用來判斷初始化時間是否小於所指定的時間
///
class CrossingDateDetector{
	static late Timer? _t;
	static CrossingDateDetector? _instance;
	static CrossingDateDetector get instance{
		assert(_instance != null);
		return _instance!;
	}

	Set<void Function()> onChangeList = {};
	DateTime instantiatedDate;
	int period;

	CrossingDateDetector._({required this.instantiatedDate, this.period = 5}){
		try {
			_t?.cancel();
			_t = Timer.periodic(Duration(seconds: period), (t) => _detect());
		} catch (e, s) {
			print('[ERROR] on CrossingDateDetector._, params: f $e');
			rethrow;
		}
	}

	factory CrossingDateDetector.singleton({required DateTime instantiatedDate, int period = 5}){
		return _instance ??= CrossingDateDetector._(instantiatedDate: instantiatedDate, period: period);
	}

	void resetSingleton(){
		_instance = null;
	}

	void _detect(){
		if (DateTimeExtension.envNow().day > instantiatedDate.day){
			instantiatedDate = DateTimeExtension.envNow();
			onChangeList.forEach((_) => _());
		}
	}

	void resetInstantiatedDate(){
		instantiatedDate = DateTimeExtension.envNow();
	}

	void addDetectee(void Function() onChange){
		onChangeList.add(onChange);
	}

	bool isCrossingDate(DateTime date){
		return instantiatedDate.day < date.day;
	}

	void updateTimer(int seconds){
		_t?.cancel();
		_t = Timer.periodic(Duration(seconds: seconds), (timer) => _detect());
	}

	Timer getTImer() {
		assert(_t != null);
		return _t!;
	}

	void trigger(){
		final now = DateTimeExtension.envNow();
		final lastDay  = now.subtract(Duration(days: 1));
		instantiatedDate = lastDay;
		_detect();
	}
}
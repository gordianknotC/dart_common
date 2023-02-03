// import 'dart:io';
import 'dart:html';
import 'dart:math';
import 'package:path/path.dart' as _Path;


const METHOD_COUNT = 5;
final _sep = _Path.separator;
final _rsep = _sep == r'\'
		? r'/'
		: r'\';

final _isWeb = Platform().isWeb;
final _log = (String msg) => _isWeb ? window.console.log(msg) : print(msg);
final _debug = (String msg) => _isWeb ? window.console.debug(msg) : print(msg);
final _warn = (String msg) => _isWeb ? window.console.warn(msg) : print(msg);
final _error = (String msg) => _isWeb ? window.console.error(msg) : print(msg);
final _info = (String msg) => _isWeb ? window.console.info(msg) : print(msg);
final _trace = (String msg) => _isWeb ? window.console.trace(msg) : print(msg);

String rectifyPathSeparator(String path) {
	//orig:  if (!path.contains(sep))
	if (IO.Platform().isMacOS && !path.startsWith('/'))
		path = "/$path";
	if (path.contains(_rsep))
		path = path.replaceAll(_rsep, _sep);
	return path;
	//return combinePath(path, sep);
}

enum ELevel {
	debug, warning, error, info, verbose,
	current,
}

extension ELevelExtension on ELevel{
	static const MAP = [
		'debug', 'warning', 'error', 'info', 'verbose',
		'current',
	];
	static final List<String> _Strings = ELevel.values.map((e) => e.name).toList();

	String get name => MAP[index];

	ELevel fromString(String string) {
		final result =  ELevel.values.firstWhereNullable((e) => _Strings[e.index] == string);
		assert(result != null);
		return result!;
	}

	String toEnumString() => _Strings[this.index];
}


const LEVEL0 = [ELevel.debug, ELevel.warning, ELevel.error, ELevel.current, ELevel.info];
const LEVEL1 = [ELevel.warning, ELevel.error, ELevel.current];
const LEVEL2 = [ELevel.error, ELevel.current];


/// [isRunningOnTestEnv]
/// unit test environment 下用來避開 flutter 環境啓動
bool get isRunningOnTestEnv  => IO.Platform().environment.containsKey('FLUTTER_TEST');

/*
   get current script path, no matter where the project root is.
   EX:
      getScriptPath(Platform.script)
*/
String getScriptPath(Uri uri, [String? script_name]) {
	final segments = _Path.dirname(uri.toString()).split('file:///');
	if (script_name == null){
		return rectifyPathSeparator(
				segments.length > 1 ? segments[1] : segments[0]
		);
	}
	return _Path.join(rectifyPathSeparator(
			segments.length > 1 ? segments[1] : segments[0]
	), script_name);
}

final stackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');


String? formatStackTrace(StackTrace stackTrace, {int methodCount = 2, int traceLines = 1, bool filter(String trace)?}) {
	try {
		var lines = stackTrace.toString().split("\n");
		var formatted = <String>[];
		var count = 0;
		for (var line in lines) {
			var match = stackTraceRegex.matchAsPrefix(line);
			if (match != null) {
				if (match.group(2)?.startsWith('package:logger') ?? false) {
					continue;
				}
				if (++count == methodCount) {
					var newLine = "(${match.group(2)})";
					formatted.add(newLine.replaceAll('<anonymous closure>', '()'));
					if (traceLines > 1){
						if (filter != null){
							final _lines = lines.where(filter).toList();
							formatted.addAll(_lines.sublist(min(methodCount, _lines.length), min(methodCount + traceLines - 1, _lines.length)));
						}else{
							formatted.addAll(lines.sublist(min(methodCount, lines.length), min(methodCount + traceLines - 1, lines.length)));
						}
					}
					break;
				}
			} else {
				formatted.add(line);
			}
		}

		if (formatted.isEmpty) {
			return null;
		} else {
			return formatted.join('\n');
		}
	} catch (e, s) {
		_error('[ERROR] on formatStackTrace, params: f $e');
	}
	return null;
}



/// fixme:
/// 應用 AOP (Aspect Oriented Progreamming) - AspectD
/// 實作 logging, websocket 驗證，貫串整個 APP
///
class DebugTool {
	/// [file_sinks]
	/// dump logger 用
	// static Map<String, IO.Platform.IOSink> file_sinks = {'testEnv': null, 'flutter': null};

	static final Map<String, DebugTool> _filterableInstances = {};
	static final Set<String> _disabledModules = {};
	static final Set<ELevel> _disabledLevels = {};
	static final Set<String> _productionModules = {};
	static final Set<String> _unitTestModules = {};

	static Set<ELevel> getDisabledLevel(){
		return _disabledLevels;
	}
	static Set<String> getDisabledModules(){
		return _disabledModules;
	}

	static void setProductionModules(List<String> modules) {
		_productionModules.clear();
		_productionModules.addAll(modules);
	}

	static void setUnitTestModules(List<String> modules) {
		_unitTestModules.addAll(modules);
	}

	static void setDisableLevel(Set<ELevel> level){
		_disabledLevels.clear();
		_disabledLevels.addAll(level);
	}

	static void setDisableModules(List<String> disabledModules){
		_disabledModules.clear();
		_disabledModules.addAll(disabledModules);
	}

	static void addDebugModules(List<String> addedModdules){
		addedModdules.forEach((_){
			_disabledModules.remove(_);
		});
		return;
	}

	static void addDisableModules(List<String> disabledModules){
		_disabledModules.addAll(disabledModules);
	}

	static void disabbleAllExcept(List<String> exception){
		_disabledModules.clear();
		_disabledModules.addAll(FilterableLogs.ALL);
		_disabledModules.removeWhere((_) => exception.contains(_));
	}

	static final emoji = {
		ELevel.verbose : '',
		ELevel.debug   : '🐛 ',
		ELevel.info    : '💡 ',
		ELevel.warning : '⚠️ ',
		ELevel.error   : '⛔ ',
		ELevel.current : '🧡️' ,
	};

	///
	static String stream_filename = 'tempLogger.log';
	static DebugTool? _instance;
	static DebugTool get instance => _instance!;

	static void BkStatus(){
		DebugTool.addDebugModules([
		]);
	}


	/// 開啓動畫 debug 模式
	static void animationDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.AnimBdg,
			FilterableLogs.AnimObj,
			FilterableLogs.IPAnim,
			FilterableLogs.evtFLow,
		]);
	}

	/// 開啓webSocket debug 模式
	static void wsDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.Chain,
			FilterableLogs.WS,
			FilterableLogs.InPlMgr,
		]);
	}

	/// 曞啓 calendar debug
	static void calendarDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.DateServ,
			FilterableLogs.DateWidt,
			FilterableLogs.FulMachPg,
		]);
		AppEnv.testCalendarPageView = true;
	}

	static void matchListDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.MatchView,
			FilterableLogs.MatchWrap,
			FilterableLogs.MatchWpSup,
			FilterableLogs.FulMachPg,
		]);
	}


	/// 開啓 router debug
	static void routerDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.Route,
			FilterableLogs.RouteAw,
			FilterableLogs.CKRoute,
			FilterableLogs.BKRoute,
		]);
	}

	/// 開啓 happening debug
	static void happeningDebug(){
		DebugTool.addDebugModules([
			FilterableLogs.Happening,
			FilterableLogs.MatchWrap,
			FilterableLogs.MatchWpSup,
		]);
	}

	static void backendAudit(){
		DebugTool.addDisableModules(FilterableLogs.ALL);
		DebugTool.addDebugModules([
			FilterableLogs.BackendApi,
		]);
	}

	ELevel? _moduleLevel;
	// IOSink? _fileSink;
	List<ELevel>? _sinkLevel;
	String? moduleName;
	bool showModule = true;
	Logger logger = Logger();

	factory DebugTool() => _instance ??= new DebugTool._();

	DebugTool._();

	DebugTool.debug(dynamic message) {
		logger.d(message);
		try {
		} catch (e, s) {
			_error('[ERROR] on DebugTool.debug, params: f $e\n$s');
		}
	}

	DebugTool.info(dynamic message) {
		logger.i(message);
		try {
		} catch (e, s) {
			_error('[ERROR] on DebugTool.info, params: f $e\n$s');
		}
	}

	DebugTool.warn(dynamic message) {
		logger.w(message);
		try {
		} catch (e, s) {
			_error('[ERROR] on DebugTool.warn, params: f $e\n$s');
		}
	}

	DebugTool.error(dynamic message) {
		logger.e(message);
		try {
		} catch (e, s) {
			_error('[ERROR] on DebugTool.error, params: f $e\n$s');
		}
	}


	factory DebugTool.logger(){
		return _instance ??= DebugTool();
	}

	factory DebugTool.streamLogger({List<ELevel>? sinkLevel}){
		_log('streamLogger init... sinkeLevel: $sinkLevel');
		return _instance ??= DebugTool()
			.._sinkLevel ??= (sinkLevel ?? LEVEL1)
			..fileSinkInit();
	}

	factory DebugTool.filterableLogger({required String moduleName, ELevel level = ELevel.debug, bool showModule = true}){
		return _filterableInstances[moduleName] ??= DebugTool._()
			..moduleName = moduleName
			..showModule = showModule
			.._moduleLevel = level
		;
	}


	///
	/// [filter]
	/// 用來濾除 TraceStack, 讓 TraceStack 只顯示 filter 的 traceline
	///
	/// [methodCount]
	/// 往回推算原始 log caller 的位置
	///
	/// [traceLines]
	/// 需要顯示多少行數的 traceline
	///
	String _getLog(message, ELevel logLevel, {int traceLines = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		try {
			final String msg = message.toString();
			if (logLevel == ELevel.verbose){
				return msg;
			}

			/// methodCount 由_getLog 計算至 caller 的 callStack
			final trace = formatStackTrace(StackTrace.current, methodCount: methodCount, traceLines: traceLines, filter: filter);
			final module = showModule
					? "[${logLevel.toEnumString()}][$moduleName]"
					: "[${logLevel.toEnumString()}]";

			if (msg.length > 100){
				return "$module $msg\n"
						"         ^ $trace`";
			}else{
				return "$module $msg <- $trace";
			}
		} catch (e, s) {
			return '[ERROR] on DebugTool._getLog, params $e';
		}
	}
	///
	/// return false to continue logging via default [Logger]
	/// return true to stop logging via default [Logger]
	///
	bool _filterGuard(String msgGetter(), ELevel logLevel, {int traceLines = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		if (moduleName == null)
			return false;

		if (logLevel != ELevel.error){
			/// non-error level
			if (_moduleLevel == null
					|| _disabledModules.contains(moduleName)
					|| _disabledLevels.contains(_moduleLevel))
				return true;
		}else{
			/// methodCount + 1, since nested in assert expression
			assert((){
				_log(_getLog(msgGetter(), logLevel, traceLines: traceLines, methodCount: methodCount));
				return true;
			}());
			return true;
		}

		if (AppEnv.env == EAppEnv.widgetDebug || AppEnv.env == EAppEnv.debug){
			assert((){
				_log(_getLog(msgGetter(), logLevel, traceLines: traceLines, methodCount: methodCount));
				return true;
			}());
			return true;
		}else{
			return true;
		}
	}

	void _productionLog(String msgGetter(), ELevel logLevel, {int traceLines = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		if (_productionModules.contains(moduleName)){
			_log(_getLog(msgGetter(), logLevel, traceLines: traceLines, methodCount: methodCount-1));
		}
	}

	void _unitTestLog(String msgGetter(), ELevel logLevel, {int traceLines = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		if (_unitTestModules.contains(moduleName)){
			assert((){
				_log(_getLog(msgGetter(), logLevel, traceLines: traceLines, methodCount: methodCount));
				return true;
			}());
		}
	}


	void c(String message(), {int traceBack = 1, bool filter(String trace)?}){
		if (AppEnv.production)
			return _productionLog(message, ELevel.current, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(message, ELevel.current, traceLines: traceBack, filter: filter );
		if (!AppEnv.production){
			if (_filterGuard(message, ELevel.current, traceLines: traceBack, filter: filter))
				return;
			_log(message());
		}
	}
	void p(String message(), {int traceBack = 1, bool filter(String trace)?}){
		if (AppEnv.production)
			return _productionLog(message, ELevel.verbose, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(message, ELevel.verbose, traceLines: traceBack, filter: filter );
		if (!AppEnv.production){
			if (_filterGuard(message, ELevel.verbose, traceLines: traceBack, filter: filter))
				return;
			_log(message());
		}
	}

	void v(String message(), {int traceBack = 1, bool filter(String trace)?}){
		if (AppEnv.production)
			return _productionLog(message, ELevel.verbose, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(message, ELevel.verbose, traceLines: traceBack, filter: filter );
		if(!AppEnv.production){
			if (_filterGuard(message, ELevel.verbose))
				return;
			_debug(message());
		}
	}

	void d(String message(), {int traceBack = 1, bool filter(String trace)?}){
		if (AppEnv.production)
			return _productionLog(message, ELevel.debug, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(message, ELevel.debug, traceLines: traceBack, filter: filter );
		if(!AppEnv.production){
			if (_filterGuard(message, ELevel.debug, traceLines: traceBack, filter: filter))
				return;
			_debug(message());
		}
	}

	void i(String msgGetter(), {int traceBack = 1, bool filter(String trace)?}){
		if (AppEnv.production)
			return _productionLog(msgGetter, ELevel.info, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(msgGetter, ELevel.info, traceLines: traceBack, filter: filter );
		if (_filterGuard(msgGetter, ELevel.info, traceLines: traceBack, filter: filter))
			return;
		_info(msgGetter());
	}

	void w(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		if (AppEnv.production)
			return _productionLog(message, ELevel.warning, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(message, ELevel.warning, traceLines: traceBack, filter: filter );
		if (!AppEnv.production){
			if (_filterGuard(message, ELevel.warning, traceLines: traceBack, filter: filter, methodCount: methodCount))
				return;
			_warn(message());
		}
	}

	///
	/// [filter]
	/// 用來濾除 TraceStack, 讓 TraceStack 只顯示 filter 的 traceline
	///
	/// [methodCount]
	/// 往回推算原始 log caller 的位置
	///
	/// [traceBack]
	/// 需要顯示多少行數的 traceline
	///
	void e(String message, {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
		if (AppEnv.production)
			return _productionLog(()=>message, ELevel.error, traceLines: traceBack, filter: filter );
		if (AppEnv.isUnitTest)
			return _unitTestLog(()=>message, ELevel.error, traceLines: traceBack, filter: filter );
		if(!AppEnv.production){
			if (_filterGuard(()=>message, ELevel.error, traceLines: traceBack, filter: filter, methodCount: methodCount))
				return;
			_error(message);
		}
	}

	void _sink(message, ELevel level){
		/// stream logger 目前用不到
		return;
	}

	// void close_sink() {
	// 	file_sinks.forEach((k,file_sink){
	// 		file_sink?.close();
	// 		file_sinks[k] = null;
	// 	});
	// }

	void fileSinkInit() {
		/// stream logger 目前用不到
		return;
		// _log('fileSinkInit..., running on test: $isRunningOnTestEnv');
		// if (isRunningOnTestEnv){
		// 	final path = rectifyPathSeparator(_Path.join(getScriptPath(IO.Platform().script), 'test', stream_filename));
		// 	if(!File(path).existsSync())
		// 		File(path).createSync();
		// 	_fileSink = file_sinks['testEnv'] ??= File(path).openWrite();
		// 	_log('fileSink path: $path');
		// }else if (appConfigFacade.appDir.path.isEmpty) {
		// 	/// web environment
		// 	_fileSink = null;
		// }else{
		// 	/// 1) android
		// 	/// 2) ios: 路徑在哪？ notice:
		// 	final path = rectifyPathSeparator(
		// 			_Path.join(appConfigFacade.appDir.path, stream_filename)
		// 	);
		// 	if(!File(path).existsSync())
		// 		File(path).createSync();
		// 	_fileSink = file_sinks['flutter'] ??= File(rectifyPathSeparator(
		// 			_Path.join(appConfigFacade.appDir.path, stream_filename)
		// 	)).openWrite();
		// }
	}

}

class FilterableLogs{
	static const String ADS        = 'ADS';         /// 廣告
	static const String AnimBdg    = 'AnimBdg';     /// AnimationObject
	static const String AnimObj    = 'AnimObj';     /// AnimationObject
	static const String BKRoute    = 'BKRoute';
	static const String BackendApi = 'API';
	static const String Behavr		 = 'Behavr';
	static const String Chain      = 'Chain';       /// InplayChain
	static const String CKRoute    = 'CKRoute';
	static const String Common     = 'Common';
	static const String DateServ   = 'DateServ';    /// Date Service
	static const String DateWidt   = 'DateWidt';    /// Date Widget
	static const String Dashboard  = 'Dshbrd';
	static const String evtFLow    = 'evtFLow';     /// Inplay Event Controlller
	static const String ExpLgTab   = 'ExpLgTab';    /// Explore League Tab
	static const String ExpSearch  = 'ExpSearch';   /// Explore Search bar
	static const String ExpTmTab   = 'ExpTmTab';    /// Explore Team Tab
	static const String FavMDL     = 'favMDL';      /// Favorite Model
	static const String Fetch			 = 'fetch';
	static const String App        = 'App';
	static const String FulMachPg  = 'FulMachPg';   /// Full Match Page
	static const String GArena     = 'GArena';      /// Gesture Arena
	static const String Happening  = 'Happening';   /// Happening
	static const String InPlMgr    = 'InPlMgr';     /// InPlayManager
	static const String ImgWrapr   = 'ImgWrapr';
	static const String IPAnim     = 'IPAnim';      /// InPlayAnimation
	static const String LeagueWrap  = "LeagueWrap";
	static const String FlushMsg   = "FlushMsg";
	static const String LivTmScr   = 'LivTmScr';    /// LiveTimeScore
	static const String MatchView  = "MatchView";
	static const String MatchWpSup = 'MatchWpSup';  /// MatchWrapSupplement
	static const String MatchWrap  = "MatchWrap";   /// MatchWrap
	static const String Route      = 'Route';
	static const String RouteAw    = 'RouteAw';     /// RouteAware
	static const String TeamView  = "TeamView";     /// OneTeamView 之下所有的 TabView
	static const String WS         = 'WS';          /// Websocket
	static const String UnitTest   = 'UnitTest';

	static List<String> ALL = [
		FilterableLogs.ADS,
		FilterableLogs.App,
		FilterableLogs.AnimBdg,
		FilterableLogs.AnimObj,
		FilterableLogs.BKRoute,
		FilterableLogs.Chain,
		FilterableLogs.CKRoute,
		FilterableLogs.Common,
		FilterableLogs.DateServ,
		FilterableLogs.DateWidt,
		FilterableLogs.evtFLow,
		FilterableLogs.ExpLgTab,
		FilterableLogs.ExpSearch,
		FilterableLogs.ExpTmTab,
		FilterableLogs.FavMDL,
		FilterableLogs.Fetch,
		FilterableLogs.FulMachPg,
		FilterableLogs.FlushMsg,
		FilterableLogs.GArena,
		FilterableLogs.Happening,
		FilterableLogs.InPlMgr,
		FilterableLogs.ImgWrapr,
		FilterableLogs.IPAnim,
		FilterableLogs.LeagueWrap,
		FilterableLogs.LivTmScr,
		FilterableLogs.MatchView,
		FilterableLogs.MatchWpSup,
		FilterableLogs.MatchWrap,
		FilterableLogs.Route,
		FilterableLogs.RouteAw,
		FilterableLogs.TeamView,
		FilterableLogs.WS,
		FilterableLogs.UnitTest,
	];
}



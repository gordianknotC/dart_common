// import 'dart:io';
// import 'dart:html';
import 'dart:math';
import 'package:dart_common/dart_common.dart';
import 'package:dart_common/src/common.env.dart';
import 'package:logger/logger.dart' as DefaultLogger;
import 'package:path/path.dart' as _Path;
import 'common.platform.dart';

const METHOD_COUNT = 5;
final _sep = _Path.separator;
final _rsep = _sep == r'\'
    ? r'/'
    : r'\';

final _isWeb = Platform().isWeb;
final _log = (String msg) => _isWeb ? Platform().window.console.log(msg) : print(msg);
final _debug = (String msg) => _isWeb ? Platform().window.console.debug(msg) : print(msg);
final _warn = (String msg) => _isWeb ? Platform().window.console.warn(msg) : print(msg);
final _error = (String msg) => _isWeb ? Platform().window.console.error(msg) : print(msg);
final _info = (String msg) => _isWeb ? Platform().window.console.info(msg) : print(msg);
final _trace = (String msg) => _isWeb ? Platform().window.console.trace(msg) : print(msg);

String rectifyPathSeparator(String path) {
  if (Platform().isMacOS && !path.startsWith('/'))
    path = "/$path";
  if (path.contains(_rsep))
    path = path.replaceAll(_rsep, _sep);
  return path;
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
    return guard(() => ELevel.values.firstWhere((e) => _Strings[e.index] == string), "failed to convert enum to string")!;
  }

  String toEnumString() => _Strings[this.index];
}

const LEVEL0 = [ELevel.debug, ELevel.warning, ELevel.error, ELevel.current, ELevel.info];
const LEVEL1 = [ELevel.warning, ELevel.error, ELevel.current];
const LEVEL2 = [ELevel.error, ELevel.current];

/// [isRunningOnTestEnv]
/// unit test environment 下用來避開 flutter 環境啓動
bool get isRunningOnTestEnv  => Platform().environment.containsKey('FLUTTER_TEST');

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
class Logger {
  /// [file_sinks]
  /// dump logger 用
  // static Map<String, Platform.IOSink> file_sinks = {'testEnv': null, 'flutter': null};

  static final Map<String, Logger> _filterableInstances = {};
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

  static void disabbleAllExcept(List<String> exception, List<String> all){
    _disabledModules.clear();
    _disabledModules.addAll(all);
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
  static Logger? _instance;
  static Logger get instance => _instance!;



  ELevel? _moduleLevel;
  // IOSink? _fileSink;
  List<ELevel>? _sinkLevel;
  String? moduleName;
  bool showModule = true;
  DefaultLogger.Logger logger = DefaultLogger.Logger();

  factory Logger() => _instance ??= new Logger._();

  Logger._();

  Logger.debug(dynamic message) {
    logger.d(message);
    try {
    } catch (e, s) {
      _error('[ERROR] on DebugTool.debug, params: f $e\n$s');
    }
  }

  Logger.Logger(dynamic message) {
    logger.i(message);
    try {
    } catch (e, s) {
      _error('[ERROR] on DebugTool.info, params: f $e\n$s');
    }
  }

  Logger.warn(dynamic message) {
    logger.w(message);
    try {
    } catch (e, s) {
      _error('[ERROR] on DebugTool.warn, params: f $e\n$s');
    }
  }

  Logger.error(dynamic message) {
    logger.e(message);
    try {
    } catch (e, s) {
      _error('[ERROR] on DebugTool.error, params: f $e\n$s');
    }
  }


  factory Logger.logger(){
    return _instance ??= Logger();
  }

  factory Logger.streamLogger({List<ELevel>? sinkLevel}){
    _log('streamLogger init... sinkeLevel: $sinkLevel');
    return _instance ??= Logger()
      .._sinkLevel ??= (sinkLevel ?? LEVEL1)
      ..fileSinkInit();
  }

  factory Logger.filterableLogger({required String moduleName, ELevel level = ELevel.debug, bool showModule = true}){
    return _filterableInstances[moduleName] ??= Logger._()
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

    if (appEnv.env == Env.widgetTest || appEnv.env == Env.develop || appEnv.env == Env.unitTest || appEnv.env == Env.widgetDev){
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

  void _i(String message(), {required int traceBack, required ELevel level, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    methodCount+=1;
    if (appEnv.env == Env.production)
      return _productionLog(message, level, traceLines: traceBack, filter: filter );
    if (appEnv.env == Env.unitTest || appEnv.env == Env.widgetTest || appEnv.env ==Env.integrationTest)
      return _unitTestLog(message, level, traceLines: traceBack, filter: filter );
    if (appEnv.env != Env.production){
      if (_filterGuard(message, level, traceLines: traceBack, filter: filter, methodCount: methodCount))
        return;
      dynamic log;
      switch(level){
        case ELevel.debug:
          log = _isWeb ? Platform().window.console.log : print;
          break;
        case ELevel.warning:
          log = _isWeb ? Platform().window.console.warn : print;
          break;
        case ELevel.error:
          log = _isWeb ? Platform().window.console.error : print;
          break;
        case ELevel.info:
          log = _isWeb ? Platform().window.console.info : print;
          break;
        case ELevel.verbose:
          log = _isWeb ? Platform(). window.console.trace : print;
          break;
        case ELevel.current:
          log = _isWeb ? Platform().window.console.log : print;
          break;
      }
      log(message());
    }
  }
  void c(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.current, filter: filter, methodCount: methodCount);
  }
  void p(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.verbose, filter: filter, methodCount: methodCount);
  }

  void v(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.verbose, filter: filter, methodCount: methodCount);
  }

  void d(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.debug, filter: filter, methodCount: methodCount);
  }

  void i(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.info, filter: filter, methodCount: methodCount);
  }

  void w(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.warning, filter: filter, methodCount: methodCount);
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
  void e(String message(), {int traceBack = 1, bool filter(String trace)?, int methodCount = METHOD_COUNT}){
    _i(message, traceBack: traceBack, level: ELevel.error, filter: filter, methodCount: methodCount);
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
    // 	final path = rectifyPathSeparator(_Path.join(getScriptPath(Platform().script), 'test', stream_filename));
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




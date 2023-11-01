part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/10/22
///

class L {
  /// 私有的命名构造函数, 外部无法调用
  L._();

  /// 工厂构造函数, 返回一个单例
  factory L() => instance;

  /// 单例
  static L get instance => _instance ??= L._();
  static L? _instance;

  /// 日志输出级别
  static const int verbose = 0;
  static const int debug = 1;
  static const int info = 2;
  static const int warn = 3;
  static const int error = 4;

  static bool SHOW_TIME = true;
  static bool SHOW_LEVEL = true;
  static bool SHOW_TAG = true;
  static String TAG = 'angcyo';

  /// 开始输出日志
  /// [object] 日志内容
  log(Object? object,
      {int level = debug,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= verbose) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  v(Object? object,
      {int level = verbose,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= verbose) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  d(Object? object,
      {int level = debug,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= debug) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  i(Object? object,
      {int level = info,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= info) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  w(Object? object,
      {int level = warn,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= warn) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  e(Object? object,
      {int level = error,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    if (level >= error) {
      _log(object,
          level: level,
          tag: tag,
          showTime: showTime,
          showLevel: showLevel,
          showTag: showTag);
    }
  }

  _log(Object? object,
      {int level = debug,
      String? tag,
      bool? showTime,
      bool? showLevel,
      bool? showTag}) {
    final time = showTime ?? SHOW_TIME ? '${nowTimeString()} ' : '';
    final levelStr = showLevel ?? SHOW_LEVEL ? _levelStr(level) : '';
    final tagStr = showTag ?? SHOW_TAG ? '[${tag ?? TAG}] ' : '';
    final msg = object?.toString() ?? 'null';
    if ((isDebug && level >= verbose) || level > debug) {
      //print(StackTrace.fromString("...test"));
      //StringBuffer()

      //获取当前调用方法的文件名和行数
      final stackTrace = StackTrace.current.toString();
      final stackTraceList = stackTrace.split("\n");
      final lineStackTrace = stackTraceList[2];
      final fileStr = lineStackTrace.substring(
          lineStackTrace.indexOf("(") + 1, lineStackTrace.indexOf(")"));

      //print(StackTrace.current);
      //print("(package:flutter3_widgets/src/child_background_widget.dart:29:7)");
      //print("child_background_widget.dart:29:7");
      print('$time[$fileStr] $tagStr$levelStr->$msg');
    }
  }

  _levelStr(int level) {
    switch (level) {
      case verbose:
        return 'V';
      case debug:
        return 'D';
      case info:
        return 'I';
      case warn:
        return 'W';
      case error:
        return 'E';
      default:
        return 'D';
    }
  }
}

/// 全局对象
final l = L.instance;

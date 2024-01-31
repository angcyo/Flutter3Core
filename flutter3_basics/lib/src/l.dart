part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/10/22
///
/// [ansicolor: ^2.0.2](https://pub.dev/packages/ansicolor) 控制台颜色设置
/// ```
/// '\x1B[48;5;${color}m'; //背景色 [0~255]
/// '\x1B[38;5;${color}m'; //前景色
/// debugPrint('${_bg(229)}${_fg(0)}[flutter_animate] $message');
/// ```
///
/// [console_bars: ^1.2.0](https://pub.dev/packages/console_bars) 控制台进度条
/// [progressbar2: ^0.3.1](https://pub.dev/packages/progressbar2) Dart 控制台应用程序的进度条。
/// ```
/// stdout.write('\u001b[2K'); //清除当前行
/// stdout.writeCharCode(13); //回到行首
/// stdout.write("██████............"); //输出
/// ```
///
typedef LPrint = void Function(String log);

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

  /// 日志输出函数
  LPrint? filePrint;

  /// 文件日志输出级别>=info
  int fileLogLevel = info;

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
    final msgType =
        object?.runtimeType == null ? '' : '[${object?.runtimeType}]';
    final msg = object?.toString() ?? 'null';

    //获取当前调用方法的文件名和行数
    final stackTrace = StackTrace.current.toString();
    final stackTraceList = stackTrace.split(lineSeparator);
    final lineStackTrace = stackTraceList[min(3, stackTraceList.length) - 1];
    //获取当前的文件名称以及路径行号:列号
    final filePathStr = lineStackTrace.substring(
        lineStackTrace.indexOf("(") + 1, lineStackTrace.indexOf(")"));

    var log = '$time[$filePathStr] $tagStr$levelStr->$msgType$msg';

    if ((isDebug && level >= verbose) || level > debug) {
      //print(StackTrace.fromString("...test"));
      //StringBuffer()

      //print(StackTrace.current);
      //print("(package:flutter3_widgets/src/child_background_widget.dart:29:7)");
      //print("child_background_widget.dart:29:7");
      debugPrint(log);
    }

    //输出到文件
    if (level >= fileLogLevel) {
      filePrint?.call(log);
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

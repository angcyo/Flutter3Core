part of '../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/10/22
///
/// [ansicolor: ^2.0.2](https://pub.dev/packages/ansicolor) 控制台颜色设置
/// ```
/// '\x1B[48;5;${color}m'; //背景色 [0~255] 1:红色 21:蓝色 76:绿色 92:紫色 124:红色
/// '\x1B[38;5;${color}m'; //前景色 [0~255]
/// debugPrint('${_bg(229)}${_fg(0)}[flutter_animate] $message');
/// ```
///
/// - 0 黑色
/// - 1 9 196 红色
/// - 52 88 89 90 暗红色
/// - 91 92 93 暗紫色
/// - 2 淡绿色
/// - 3 淡橙色
/// - 4 6 淡蓝色
/// - 7 8 暗白色
/// - 231 亮白色
/// - 232 黑色 ~ 255 白色
/// - 15 白色
/// - 10 亮绿色
/// - 11 亮橙色
/// - 12 亮蓝色
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

final String _reset = '\x1B[0m';

/// [consoleFgColorLog]
void consoleLog(dynamic msg, [int col = 93]) => consoleFgColorLog(msg, col);

/// 控制台前景颜色日志输出
void consoleFgColorLog(dynamic msg, [int col = 93]) {
  debugPrint('\x1B[38;5;${col}m$msg$_reset');
}

/// 控制台背景颜色日志输出
void consoleBgColorLog(dynamic msg, [int col = 93]) {
  debugPrint('\x1B[48;5;${col}m$msg$_reset');
}

class L {
  /// 私有的命名构造函数, 外部无法调用
  L._();

  /// 工厂构造函数, 返回一个单例
  factory L() => instance;

  /// 单例
  static L get instance => _instance ??= L._();
  static L? _instance;

  /// 日志输出级别
  static const int none = 0;
  static const int verbose = 1;
  static const int debug = 2;
  static const int info = 3;
  static const int warn = 4;
  static const int error = 5;
  static const int trace = 6;

  /// 是否显示日志时间
  static bool kShowTime = true;

  /// 日志时间格式
  static String kTimePattern = "HH:mm:ss.SSS";

  /// 是否显示日志等级字符串
  static bool kShowLevel = true;

  /// 是否显示日志tag
  static bool kShowTag = true;

  /// 是否显示日志方法名
  static bool kShowMethodName = false;

  /// tag
  static String kTag = 'angcyo';

  /// 日志输出函数, 日志等级[fileLogLevel]影响
  LPrint? filePrint;

  /// 额外的输出函数, 受日志等级[logLevel]影响
  /// [printLog]
  List<LPrint> printList = [];

  /// 日志输出级别>=[debug]
  int logLevel = debug;

  /// 文件日志输出级别>=[info]
  int fileLogLevel = info;

  /// 开始输出日志
  /// [forward] 向前追溯几个调用.
  /// [object] 日志内容
  String? log(
    Object? object, {
    int level = debug,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= verbose) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  String? v(
    Object? object, {
    int level = verbose,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= verbose) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  String? d(
    Object? object, {
    int level = debug,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= debug) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  String? i(
    Object? object, {
    int level = info,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= info) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  String? w(
    Object? object, {
    int level = warn,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
  }) {
    if (level >= warn) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
      );
    }
    return null;
  }

  String? e(
    Object? object, {
    int level = error,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= error) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  String? t(
    Object? object, {
    int level = trace,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    if (level >= trace) {
      return _log(
        object,
        level: level,
        tag: tag,
        showTime: showTime,
        showLevel: showLevel,
        showTag: showTag,
        forward: forward,
        stack: stack,
        debugLabel: debugLabel,
        filterType: filterType,
      );
    }
    return null;
  }

  /// [forward] 向前追溯几个调用. 默认是3. 用来获取调用的文件,函数和行数
  String _log(
    Object? object, {
    int level = debug,
    String? tag,
    bool? showTime,
    bool? showLevel,
    bool? showTag,
    int forward = 3,
    StackTrace? stack,
    String? debugLabel,
    String? filterType,
  }) {
    debugger(when: debugLabel != null);
    final time = showTime ?? kShowTime ? '${nowTimeString(kTimePattern)} ' : '';
    final levelStr = showLevel ?? kShowLevel ? _levelStr(level) : '';
    final tagStr = showTag ?? kShowTag ? '[${tag ?? kTag}] ' : '';
    final msgType = object?.runtimeType == null
        ? ''
        : '[${object?.runtimeType}]';
    final msg = object?.toString() ?? 'null';

    //获取当前调用方法的文件名和行数
    final stackTrace = StackTrace.current.toString();
    final stackTraceList = stackTrace.split("\n");
    //关建行
    final lineStackTrace =
        stackTraceList[math.min(forward, stackTraceList.length) - 1];
    //获取当前的文件名称以及路径行号:列号
    //package:flutter3_basics/src/l.dart:352:33
    final filePathStr = lineStackTrace.substring(
      lineStackTrace.indexOf("(") + 1,
      lineStackTrace.indexOf(")"),
    );
    //调用的方法名
    final methodNameList = lineStackTrace
        .replaceAll('<anonymous closure>', '<anonymous_closure>')
        .split(" ");
    final methodName = methodNameList.get(-2);
    //debugger();
    final log =
        '$time[$filePathStr${(!kShowMethodName || methodName == null) ? "" : "#$methodName"}] $tagStr$levelStr->$msgType $msg';

    //MARK: - log panel
    final controller =
        LogScope.get(GlobalConfig.def.globalAppContext) ?? $logController;
    controller.addLogData(
      LogScopeData.log(
        log,
        filterTypeList: [LLevel.fromValue(level).name, ?filterType],
      ),
    );

    //MARK: - print
    if ((isDebug && level >= verbose) || level >= logLevel) {
      //print(StackTrace.fromString("...test"));
      //StringBuffer()

      //print(StackTrace.current);
      //print("(package:flutter3_widgets/src/child_background_widget.dart:29:7)");
      //print("child_background_widget.dart:29:7");
      debugPrint(log);

      //stack
      if (stack != null) {
        debugPrintStack(stackTrace: stack);
      }

      if (level >= logLevel) {
        //外部输出
        printLog(log);
      }
    }

    //MARK: - file

    //输出到文件
    if (filePrint != null && level >= fileLogLevel) {
      try {
        filePrint?.call(log);
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
    return log;
  }

  String _levelStr(int level) {
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

  /// 输出到额外的输出函数
  /// [printList]
  @api
  void printLog(String log) {
    for (final print in printList) {
      try {
        print(log);
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
  }
}

/// 当前调用的文件名
String? get $currentFileName {
  final forward = 2;
  final stackTrace = StackTrace.current.toString();
  final stackTraceList = stackTrace.split("\n");
  //关建行
  final lineStackTrace =
      stackTraceList[math.min(forward, stackTraceList.length) - 1];
  //获取当前的文件名称以及路径行号:列号
  //package:flutter3_basics/src/l.dart:352:33
  final filePathStr = lineStackTrace.substring(
    lineStackTrace.indexOf("(") + 1,
    lineStackTrace.indexOf(")"),
  );
  final filePath = filePathStr.split(":").subListCount(0, 2).join(":");
  //debugger();
  return filePath;
}

/// 当前调用的方法名
String? get $currentMethodName {
  final forward = 2;
  final stackTrace = StackTrace.current.toString();
  final stackTraceList = stackTrace.split("\n");
  //关建行
  final lineStackTrace =
      stackTraceList[math.min(forward, stackTraceList.length) - 1];
  //调用的方法名
  final methodNameList = lineStackTrace
      .replaceAll('<anonymous closure>', '<anonymous_closure>')
      .split(" ");
  final methodName = methodNameList.get(-2);
  //debugger();
  return methodName;
}

enum LLevel {
  none(L.none),
  verbose(L.verbose),
  debug(L.debug),
  info(L.info),
  warn(L.warn),
  error(L.error),
  trace(L.trace);

  const LLevel(this.value);

  final int value;

  static LLevel fromValue(int value) {
    for (final level in LLevel.values) {
      if (level.value == value) {
        return level;
      }
    }
    return LLevel.none;
  }
}

/// 全局对象
final l = L.instance;

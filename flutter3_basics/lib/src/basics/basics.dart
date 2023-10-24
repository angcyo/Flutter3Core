import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region 基础

final random = Random();

int nowTime() => DateTime.now().millisecondsSinceEpoch;

/// 格式化时间
String nowTimeString() => DateTime.now().toIso8601String().replaceAll("T", " ");

/// [min] ~ [max] 之间的随机数
int nextInt(int max, {int min = 0}) => min + random.nextInt(max);

bool nextBool() => random.nextBool();

/// [0~1] 之间的随机数
double nextDouble() => random.nextDouble();

/// 是否是debug模式
const bool isDebug = kDebugMode;

/// 获取当前调用此方法的文件名
/// ```
/// I/flutter ( 2526): #0      currentFileName (package:flutter3_basics/src/basics.dart:36:33)
/// I/flutter ( 2526): #1      main (package:flutter3_abc/main.dart:8:7)
/// I/flutter ( 2526): #2      _runMain.<anonymous closure> (dart:ui/hooks.dart:159:23)
/// I/flutter ( 2526): #3      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:296:19)
/// I/flutter ( 2526): #4      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:189:12)
/// ```
String currentFileName([bool? fileLineNumber]) {
  //获取当前调用方法的文件名和行数
  final stackTrace = StackTrace.current.toString();
  //print(stackTrace);
  final stackTraceList = stackTrace.split("\n");

  //#1      main (package:flutter3_abc/main.dart:8:7)
  final lineStackTrace = stackTraceList[1];

  //package:flutter3_abc/main.dart:8:7
  final fileStr = lineStackTrace.substring(
      lineStackTrace.indexOf("(") + 1, lineStackTrace.indexOf(")"));
  final lineStackTraceList = fileStr.split(":");

  final fileName = lineStackTraceList[1].split("/").last;
  final fileLine = lineStackTraceList[2];
  final buffer = StringBuffer()
    ..write(fileName)
    ..write(fileLineNumber == true ? ":$fileLine" : "");
  return buffer.toString();
}

/// 使用[Timer]尽快执行[callback]
void postCallback(void Function() callback) {
  Timer.run(callback);
}

/// 使用[Future]延迟执行[callback]
/// 内部也是使用[Timer]实现的
/// [Future.wait] 会等待所有的[Future]执行完毕
Future<T> delayCallback<T>(T Function() callback, [Duration? duration]) {
  return Future.delayed(duration ?? Duration.zero, callback);
}

//endregion 基础

//region Asset

/// ```
/// await loadAssetString('config.json');
/// await loadAssetString('assets/config.json');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-text-assets
Future<String> loadAssetString(String key, [String prefix = 'assets/']) async {
  return await rootBundle.loadString(key.ensurePrefix(prefix));
}

/// ```
/// loadAssetImageWidget('png/flutter.png');
/// loadAssetImageWidget('assets/png/flutter.png');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-images-1
Image loadAssetImageWidget(String key, [String prefix = 'assets/']) =>
    Image.asset(key.ensurePrefix(prefix));

/// [ImageProvider]
/// [AssetBundleImageProvider]
/// [AssetImage]
/// [ExactAssetImage]
AssetImage loadAssetImage(String key, [String prefix = 'assets/']) =>
    AssetImage(key.ensurePrefix(prefix));

//endregion Asset

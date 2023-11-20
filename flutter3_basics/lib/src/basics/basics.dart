part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region 基础

/// 是否是debug模式
const bool isDebug = kDebugMode;

/// 随机数生成器
final random = Random();

/// Channel需要先初始化这个
/// [WidgetsFlutterBinding.ensureInitialized]
void ensureInitialized() => WidgetsFlutterBinding.ensureInitialized();

/// 当前时间戳 `1699064019689`
int nowTime() => DateTime.now().millisecondsSinceEpoch;

/// 格式化时间 `2023-11-04 10:13:40.083707`
String nowTimeString() => DateTime.now().toIso8601String().replaceAll("T", " ");

/// [min] ~ [max] 之间的随机数
int nextInt(int max, {int min = 0}) => min + random.nextInt(max);

bool nextBool() => random.nextBool();

/// [0~1] 之间的随机数
/// [min~max] 之间的随机数
double nextDouble({double? min, double? max}) {
  final value = random.nextDouble();
  if (min != null && max != null) {
    return min + value * (max - min);
  } else if (min != null) {
    return min + min * value;
  } else if (max != null) {
    return value * max;
  } else {
    return value;
  }
}

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
void postCallback(VoidCallback callback) {
  Timer.run(callback);
}

/// 使用[Timer]尽快执行[callback]
Timer postDelayCallback(VoidCallback callback,
        [Duration duration = Duration.zero]) =>
    Timer(duration, callback);

/// 使用[Future]延迟执行[callback]
/// 内部也是使用[Timer]实现的
/// [Future.wait] 会等待所有的[Future]执行完毕
Future<T> delayCallback<T>(T Function() callback, [Duration? duration]) {
  return Future.delayed(duration ?? Duration.zero, callback);
}

//error() => Future.error("asynchronous error");
//SystemChrome.setPreferredOrientations
//debugger(message: "等待调试...");
//String.fromEnvironment

/// 获取当前平台的[MediaQueryData]
/// [defaultTargetPlatform]
MediaQueryData platformMediaQuery() =>
    MediaQueryData.fromView(WidgetsBinding.instance.renderView.flutterView);

/// 延迟随机发生器
/// [delay] 延迟多久触发一次[generate]
/// [count] 总共要出发几次[generate]
Stream<T?> delayGenerate<T>(
  T? Function(int index) generate, {
  Duration delay = Duration.zero,
  int count = 1,
}) async* {
  for (int i = 0; i < count; i++) {
    await Future.delayed(delay);
    yield generate(i);
  }
}

//endregion 基础

//region Asset

const kDefAssetsPngPrefix = 'assets/png/';

/// ```
/// await loadAssetString('config.json');
/// await loadAssetString('assets/config.json');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-text-assets
Future<String> loadAssetString(
  String key, {
  String prefix = 'assets/',
  String? package,
}) async {
  return await rootBundle.loadString(
    key.ensurePackagePrefix(package, prefix),
  );
}

/// ```
/// loadAssetImageWidget('png/flutter.png');
/// loadAssetImageWidget('assets/png/flutter.png');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-images-1
/// [ImageIcon]
/// [loadAssetSvgWidget]
Image loadAssetImageWidget(
  String key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
}) =>
    Image.asset(
      key.ensurePackagePrefix(package, prefix),
    );

/// [ImageProvider]
/// [AssetBundleImageProvider]
/// [AssetImage]
/// [ExactAssetImage]
AssetImage loadAssetImage(
  String key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
}) =>
    AssetImage(
      key.ensurePackagePrefix(package, prefix),
    );

//endregion Asset

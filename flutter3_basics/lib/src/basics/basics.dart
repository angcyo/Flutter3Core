part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region Fn Callback

/// 只有返回值的回调
typedef ResultCallback<T> = T Function();

/// [Future] 返回值的回调
typedef FutureResultCallback<R, T> = Future<R> Function(T value);

/// 只有一个值回调
typedef ValueCallback = dynamic Function(dynamic value);

/// 回调一个值和一个错误
typedef ValueErrorCallback = dynamic Function(dynamic value, dynamic error);

//endregion Fn

//region 基础

/// 是否是debug模式
/// 性能优化: https://juejin.cn/post/7066954522655981581
/// 性能检查视图: https://docs.flutter.dev/tools/devtools/inspector
///
/// ```
/// assert(() {
///   final List<DebugPaintCallback> localCallbacks = _debugPaintCallbacks.toList();
///   for (final DebugPaintCallback paintCallback in localCallbacks) {
///     if (_debugPaintCallbacks.contains(paintCallback)) {
///       paintCallback(context, offset, this);
///     }
///   }
///   return true;
/// }());
/// ```
/// [RenderView.paint]
/// [debugAddPaintCallback]
const bool isDebug = kDebugMode;

/// 随机数生成器
final random = Random();

/// Channel需要先初始化这个
/// [WidgetsFlutterBinding.ensureInitialized]
void ensureInitialized() => WidgetsFlutterBinding.ensureInitialized();

/// 当前时间戳 `1699064019689`
int nowTime() => DateTime.now().millisecondsSinceEpoch;

/// 格式化时间 `2023-11-04 10:13:40.083707`
String nowTimeString([String? newPattern = "yyyy-MM-dd HH:mm:ss.SSS"]) =>
    //DateTime.now().toIso8601String().replaceAll("T", " ");
    DateTime.now().format(newPattern);

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

/// 最小值/最大值
/// [double.maxFinite]
int intMaxValue = double.maxFinite.toInt();
int intMinValue = -double.maxFinite.toInt();

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
  final stackTraceList = stackTrace.split(lineSeparator);

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
/// [postFrameCallback]
/// [postCallback]
/// [postDelayCallback]
/// [delayCallback]
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
//SystemChrome.setPreferredOrientations //设置屏幕方向
//SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); //设置状态栏样式
//debugger(message: "等待调试...");
//String.fromEnvironment

/// [RendererBinding.instance]
/// [PlatformDispatcher.implicitView]
/// [FlutterView.display]
/// [FlutterView.display.size] //可以获取屏幕尺寸
ui.FlutterView get flutterView =>
    WidgetsBinding.instance.renderView.flutterView;

/// [WidgetsBinding.instance]
/// [WidgetsBinding.platformDispatcher]
/// [PlatformDispatcher.views]
Iterable<ui.FlutterView> get flutterViews =>
    WidgetsBinding.instance.renderViews.map((e) => e.flutterView);

/// [RendererBinding.renderViews]
Iterable<RenderView> get renderViews => WidgetsBinding.instance.renderViews;

/// 获取当前平台的[MediaQueryData]
/// [defaultTargetPlatform]
/// [PlatformDispatcher.instance]
/// [PlatformDispatcher.displays]
/// [PlatformDispatcher.views]
MediaQueryData get platformMediaQueryData =>
    MediaQueryData.fromView(flutterView);

/// 获取当前平台的亮度模式
Brightness get platformBrightness => platformMediaQueryData.platformBrightness;

/// 获取当前平台的语言设置[Locale]
/// http://www.lingoes.net/en/translator/langcode.htm
Locale get platformLocale => PlatformDispatcher.instance.locale;

/// 获取当前平台的语言设置列表[Locale]
List<Locale> get platformLocales => PlatformDispatcher.instance.locales;

/// 屏幕宽度 [screenWidthPixel]
@dp
double get screenWidth => platformMediaQueryData.size.width;

/// 屏幕高度, 此高度不包含导航栏的高度 [screenHeightPixel]
@dp
double get screenHeight => platformMediaQueryData.size.height;

/// 屏幕宽度 [screenWidth]
@pixel
double get screenWidthPixel =>
    platformMediaQueryData.size.width * platformMediaQueryData.devicePixelRatio;

/// 屏幕高度 [screenHeight]
@pixel
double get screenHeightPixel =>
    platformMediaQueryData.size.height *
    platformMediaQueryData.devicePixelRatio;

/// 设备的宽度 [screenWidth]
@pixel
double get deviceWidthPixel => flutterView.display.size.width;

/// 设备的高度 [screenHeight], 包含导航栏的高度
@pixel
double get deviceHeightPixel => flutterView.display.size.height;

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

/// 平台
/// [defaultTargetPlatform]
bool get isAndroid => UniversalPlatform.isAndroid /*Platform.isAndroid*/;

bool get isIos => UniversalPlatform.isIOS /*Platform.isIOS*/;

/// 是否是web
bool get isWeb => UniversalPlatform.isWeb /*kIsWeb*/;

/// 是否是移动设备
bool get isMobile => isAndroid || isIos;

/// 是否是pc客户端
bool get isDesktop => UniversalPlatform
    .isDesktop /*Platform.isWindows || Platform.isMacOS || Platform.isLinux*/;

/// 是否是pc客户端或者web
bool get isDesktopOrWeb => UniversalPlatform.isDesktopOrWeb;

//endregion 基础

//region 性能

/// io计算
/// [compute] 会创建一个新的[Isolate]来执行[callback]
/// https://pub.dev/documentation/compute/latest/compute/compute-constant.html
Future<R> io<Object, R>(ResultCallback<R> callback) async =>
    compute((message) => callback(), null, debugLabel: "io-${nowTimeString()}");

/// 安排一个轻量的任务
Future<R> scheduleTask<R>(ResultCallback<R> callback,
        [Priority priority = Priority.animation]) =>
    SchedulerBinding.instance.scheduleTask(() => callback(), priority,
        debugLabel: "scheduleTask-${nowTimeString()}");

//endregion 性能

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

/// 所有加载在子包中的资源都需要指定包名前缀[package].
/// Unable to load asset: "assets/png/loadError.png".
/// Exception: Asset not found.
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
  BoxFit? fit,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
}) =>
    Image.asset(
      key.ensurePackagePrefix(package, prefix),
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
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

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/20
///

//region 基础

/// Channel需要先初始化这个
/// [WidgetsFlutterBinding.ensureInitialized]
@initialize
void ensureInitialized() => WidgetsFlutterBinding.ensureInitialized();

/// 当前时间戳 `1699064019689` 13位
/// [DateTime]
int nowTime() => DateTime.now().millisecondsSinceEpoch;

/// 当前的[Duration]
Duration nowDuration() => Duration(milliseconds: nowTime());

/// 格式化时间 `2023-11-04 10:13:40.083707`
String nowTimeString([String? newPattern = "yyyy-MM-dd HH:mm:ss.SSS"]) =>
    //DateTime.now().toIso8601String().replaceAll("T", " ");
    DateTime.now().format(newPattern);

/// 格式化时间`2023-11-04_10-13-40-083` 的文件名
/// [suffix] 文件名后缀, 例如`.png`
/// [newPattern] 时间格式
String nowTimeFileName(
        [String? suffix, String? newPattern = "yyyy-MM-dd_HH-mm-ss-SSS"]) =>
    nowTimeString(newPattern).connect(suffix);

/// uuid文件名
/// [suffix] 文件名后缀, 例如`.png`
String uuidFileName([String? suffix]) => uuid().connect(suffix);

/// [min] ~ [max] 之间的随机数
/// `Must be positive and <= 2^32`
/// `2 ^ 32`
int nextInt(int max, [int min = 0]) => min + random.nextInt(max);

bool nextBool() => random.nextBool();

/// [0~1.0] 之间的随机数
/// [min~max] 之间的随机数
double nextDouble([double? min, double? max]) {
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

/// 限制[x] 在 [min] ~ [max] 之间
dynamic clamp(num x, num? min, num? max) {
  if (min != null && x < min) {
    return min;
  }
  if (max != null && x > max) {
    return max;
  }
  if (x.isNaN) {
    return max ?? x;
  }
  return x;
}

/// orientation: 横向
@flagProperty
const kHorizontal = 0;

/// orientation: 纵向
@flagProperty
const kVertical = 1;

/// 获取当前调用此方法的文件名
/// ```
/// I/flutter ( 2526): #0      currentFileName (package:flutter3_basics/src/basics.dart:36:33)
/// I/flutter ( 2526): #1      main (package:flutter3_abc/main.dart:8:7)
/// I/flutter ( 2526): #2      _runMain.<anonymous closure> (dart:ui/hooks.dart:159:23)
/// I/flutter ( 2526): #3      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:296:19)
/// I/flutter ( 2526): #4      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:189:12)
/// ```
String currentTraceFileName([bool? fileLineNumber]) {
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
/// [Timer.cancel]
Timer postDelayCallback(VoidCallback callback,
        [Duration duration = Duration.zero]) =>
    Timer(duration, callback);

/// 使用[Future]延迟执行[callback]
/// 内部也是使用[Timer]实现的
/// [Future.wait] 会等待所有的[Future]执行完毕
Future<T> delayCallback<T>(T Function() callback, [Duration? duration]) {
  return Future.delayed(duration ?? Duration.zero, callback);
}

/// [delayCallback]
Future futureDelay<T>(Duration duration,
        [FutureOr<T> Function()? computation]) async =>
    Future.delayed(duration, computation);

//error() => Future.error("asynchronous error");
//debugger(message: "等待调试...");
//String.fromEnvironment

/// 报告错误
/// 上报错误到[FlutterError.onError] 最终会调用此方法
/// 通过重写[FlutterError.onError]实现将错误信息写入文件
///
/// [ErrorWidget.builder] 错误小部件构建器
/// [reportError]
/// [printError]
void reportError(exception) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: exception,
      stack: StackTrace.current,
    ),
  );
}

/// 打印错误
/// [FlutterError.presentError]
/// [StackTrace.current]
/// [reportError]
/// [printError]
void printError(exception, [StackTrace? stack]) {
  FlutterError.dumpErrorToConsole(
    exception is FlutterErrorDetails
        ? exception
        : FlutterErrorDetails(
            exception: exception,
            stack: stack ?? StackTrace.current,
          ),
    forceReport: true,
  );
}

/// [ui.window]
/// [RendererBinding.instance]
/// [PlatformDispatcher.implicitView]
/// [FlutterView.display]
/// [FlutterView.display.size] //可以获取屏幕尺寸
///
/// [SingletonFlutterWindow].[FlutterView]
/// [window.physicalSize]
/// [window.devicePixelRatio]
/// [window.refreshRate]
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
/// [ui.window]
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

/// 获取顶部安全区域
@dp
double get screenStatusBar => platformMediaQueryData.padding.top;

/// 获取底部安全区域
@dp
double get screenBottomBar => platformMediaQueryData.padding.bottom;

/// 屏幕像素密度, 1 dp = xx px
double get devicePixelRatio => platformMediaQueryData.devicePixelRatio;

/// 屏幕刷新率
double get refreshRate => flutterView.display.refreshRate;

/// 单位英寸中的像素数, 1 in = xx px
double get dpi => platformMediaQueryData.devicePixelRatio * 160;

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

/// 当前设备的平台
/// [defaultTargetPlatform]
TargetPlatform get currentPlatform {
  if (isAndroid) {
    return TargetPlatform.android;
  } else if (isIos) {
    return TargetPlatform.iOS;
  } else if (isMacOs) {
    return TargetPlatform.macOS;
  } else if (isWindows) {
    return TargetPlatform.windows;
  } else if (isLinux) {
    return TargetPlatform.linux;
  } else if (isFuchsia) {
    return TargetPlatform.fuchsia;
  } else {
    return defaultTargetPlatform;
  }
}

/// 平台
/// [defaultTargetPlatform]
/// [currentUniversalPlatform]
bool get isAndroid => UniversalPlatform.isAndroid /*Platform.isAndroid*/;

bool get isIos => UniversalPlatform.isIOS /*Platform.isIOS*/;

bool get isMacOs => UniversalPlatform.isMacOS /*Platform.isIOS*/;

/// 是否是web
bool get isWeb => UniversalPlatform.isWeb /*kIsWeb*/;

/// 是否是移动设备
bool get isMobile => isAndroid || isIos;

bool get isWindows => UniversalPlatform.isWindows /*Platform.isWindows*/;

bool get isLinux => UniversalPlatform.isLinux /*Platform.isLinux*/;

bool get isFuchsia => UniversalPlatform.isFuchsia /*Platform.isFuchsia*/;

/// 是否是pc客户端
bool get isDesktop => UniversalPlatform
    .isDesktop /*Platform.isWindows || Platform.isMacOS || Platform.isLinux*/;

/// 是否是pc客户端或者web
bool get isDesktopOrWeb => UniversalPlatform.isDesktopOrWeb;

/// 根据rgb的值, 计算出灰度值
int rgbToGray(int r, int g, int b) {
  //(r + g + b) ~/ 3
  return (r * 0.299 + g * 0.587 + b * 0.114).toInt().clamp(0, 255);
}

//endregion 基础

//region 性能

/// 定义一个常量, 当图片像素字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputePixelsSize = 1024 * 1024 * 10;

/// 定义一个常量, 当图片字节数据大于这个值时, 建议使用[flutterCompute]
const kIsolateComputeBytesSize = 1024 * 1024 * 1;

/// 并发
/// https://dart.cn/guides/language/concurrency
///
/// Isolate 的工作原理
/// https://dart.cn/guides/language/concurrency#how-isolates-work
///
/// io计算
/// [compute] 会创建一个新的[Isolate]来执行[callback]
/// https://pub.dev/documentation/compute/latest/compute/compute-constant.html
///
/// ```
/// https://isar.dev/zh/recipes/multi_isolate.html#%E4%BE%8B%E5%AD%90
/// // 创建一个新的 isolate，写入 10000 条讯息到数据库
/// compute(createDummyMessages, 10000).then(() {
///   print('isolate finished');
/// });
/// ```
///
/// io中操作的数据必须通过参数的方式传入/传出, 否则会报错.
///
/// `Illegal argument in isolate message: object is unsendable`
///
/// [Completer]
Future<R> io<M, R>(M message, ComputeCallback<M, R> callback) =>
    compute(callback, message, debugLabel: "io-${nowTimeString()}");

/// 在[Isolate]中运行, [callback]可以直接访问上下文的数据, 不需要send
/// [SendPort.send]
/// ```
/// Invalid argument(s): Illegal argument in isolate message:
/// object is unsendable - Library:'dart:async'
/// Class: _AsyncCompleter@4048458
/// (see restrictions listed at `SendPort.send()` documentation for more information)
/// Isolate._spawnFunction (dart:isolate-patch/isolate_patch.dart:398:25)
/// ```
/// [Future.sync]
Future<R> run<R>(ResultCallback<R> callback) {
  return Isolate.run(() => callback(), debugName: "run-${nowTimeString()}");
}

/// 安排一个轻量的任务
Future<R> scheduleTask<R>(ResultCallback<R> callback,
        [Priority priority = Priority.animation]) =>
    SchedulerBinding.instance.scheduleTask(() => callback(), priority,
        debugLabel: "scheduleTask-${nowTimeString()}");

//endregion 性能

//region Asset

/// 默认的资源路径前缀
const kDefAssetsPngPrefix = 'assets/png/';
const kDefAssetsSvgPrefix = 'assets/svg/';

/// 读取资产中的文本内容
/// ```
/// await loadAssetString('config.json');
/// await loadAssetString('assets/config.json');
/// ```
/// https://flutter.cn/docs/development/ui/assets-and-images#loading-text-assets
///
/// [FileEx.readString]
///
/// [DefaultAssetBundle]
/// [NetworkAssetBundle]
///
/// https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory
/// ```
/// final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
/// // This returns a List<String> with all your images
/// final imageAssetsList = assetManifest.listAssets().where((string) => string.startsWith("assets/images/")).toList()
/// ```
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
Image? loadAssetImageWidget(
  String? key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
  BoxFit? fit,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
}) =>
    key == null
        ? null
        : Image.asset(
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
AssetImage? loadAssetImageProvider(
  String? key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
}) =>
    key == null
        ? null
        : AssetImage(
            key.ensurePackagePrefix(package, prefix),
          );

/// [UiImage]
Future<UiImage>? loadAssetImage(
  String? key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
  ImageConfiguration configuration = const ImageConfiguration(),
}) =>
    loadAssetImageProvider(key, prefix: prefix, package: package)
        ?.toImage(configuration);

//endregion Asset

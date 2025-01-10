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

/// [DateTime]
DateTime nowDateTime() => DateTime.now();

/// [nowTimestamp]
int nowTime() => nowTimestamp();

/// 当前时间戳 `1699064019689` 13位
/// [DateTime]
int nowTimestamp() => DateTime.now().millisecondsSinceEpoch;

/// 当前的[Duration]
Duration nowDuration() => Duration(milliseconds: nowTimestamp());

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
String uuidFileName([String? suffix]) => $uuid.connect(suffix);

/// [min] ~ [max] 之间的随机数
/// `Must be positive and <= 2^32`
/// `2 ^ 32`
int nextInt([int max = intMax32Value, int min = 0]) =>
    min + random.nextInt(max);

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
dynamic clamp(num? x, num? min, num? max) {
  if (x == null) {
    return min ?? max ?? 0;
  }
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

//double lerp(double a, double b, double t) => a + (b - a) * t;
double progressIn(double value, double min, double max) =>
    (value - min) / (max - min);

/// 均分
/// [min] 最小值
/// [max] 最大值
/// [count] 分成多少份
List<int> averageInt(int count, int min, int max) {
  assert(count > 0);
  final step = count > 1
      ? (max - min) / (count - 1)
      : count > 0
          ? max - min
          : 0;
  return List.generate(count, (index) => (min + step * index).round()).toList();
}

/// orientation: 横向 0
@flagProperty
const kHorizontal = 0;

/// orientation: 纵向 1
@flagProperty
const kVertical = 1;

/// 获取当前调用此方法的文件名
/// ```
/// I/flutter ( 2526): #0      currentFileName (package:flutter3_basics/src/basics.dart:36:33)
/// I/flutter ( 2526): #1      main (package:flutter3_mobile_abc/main.dart:8:7)
/// I/flutter ( 2526): #2      _runMain.<anonymous closure> (dart:ui/hooks.dart:159:23)
/// I/flutter ( 2526): #3      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:296:19)
/// I/flutter ( 2526): #4      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:189:12)
/// ```
String currentTraceFileName([bool? fileLineNumber]) {
  //获取当前调用方法的文件名和行数
  final stackTrace = StackTrace.current.toString();
  //print(stackTrace);
  final stackTraceList = stackTrace.split(lineSeparator);

  //#1      main (package:flutter3_mobile_abc/main.dart:8:7)
  final lineStackTrace = stackTraceList[1];

  //package:flutter3_mobile_abc/main.dart:8:7
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
void postRun(VoidCallback callback) {
  Timer.run(callback);
}

/// 使用[Timer]尽快执行[callback]
/// [Timer.cancel]
Timer postDelayCallback(VoidCallback callback,
        [Duration duration = Duration.zero]) =>
    Timer(duration, callback);

/// 使用[Timer]实现一个倒计时
/// [period] tick的周期
/// [Timer.periodic]
/// [Timer.cancel]
Timer countdownCallback(
  Duration duration,
  DurationCallback callback, {
  Duration? period,
  Duration? step,
}) {
  period ??= const Duration(seconds: 1);
  step ??= const Duration(seconds: 1);
  callback(duration); //立即触发一次
  return Timer.periodic(period, (timer) {
    duration -= step!;
    callback(duration);
    if (duration.inSeconds <= 0) {
      timer.cancel();
    }
  });
}

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
/// [FlutterError.resetErrorCount]
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

/// [FlutterError.presentError]
/// [FlutterError.dumpErrorToConsole]
String dumpErrorToString(FlutterErrorDetails details) {
  const maxFrames = 100;
  final label = details.exception.toString();
  final StackTrace stackTrace;
  if (details.stack != null) {
    stackTrace = FlutterError.demangleStackTrace(details.stack!);
  } else {
    stackTrace = StackTrace.current;
  }
  final stackString = stackToString(
    stackTrace: stackTrace,
    label: label,
    maxFrames: maxFrames,
  );
  return stackString;
}

/// [debugPrintStack]
String stackToString({StackTrace? stackTrace, String? label, int? maxFrames}) {
  if (label != null) {
    debugPrint(label);
  }
  if (stackTrace == null) {
    stackTrace = StackTrace.current;
  } else {
    stackTrace = FlutterError.demangleStackTrace(stackTrace);
  }
  Iterable<String> lines = stackTrace.toString().trimRight().split('\n');
  if (kIsWeb && lines.isNotEmpty) {
    // Remove extra call to StackTrace.current for web platform.
    // TODO(ferhat): remove when https://github.com/flutter/flutter/issues/37635
    // is addressed.
    lines = lines.skipWhile((String line) {
      return line.contains('StackTrace.current') ||
          line.contains('dart-sdk/lib/_internal') ||
          line.contains('dart:sdk_internal');
    });
  }
  if (maxFrames != null) {
    lines = lines.take(maxFrames);
  }
  return FlutterError.defaultStackFilter(lines).join('\n');
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

/// 平台事件调度程序单例。
UiPlatformDispatcher get platformDispatcher => UiPlatformDispatcher.instance;

/// 获取当前平台的亮度模式
Brightness get platformBrightness => platformMediaQueryData.platformBrightness;

/// 获取当前平台的语言设置[Locale]
/// http://www.lingoes.net/en/translator/langcode.htm
Locale get platformLocale => PlatformDispatcher.instance.locale;

/// 获取当前平台的语言设置列表[Locale]
List<Locale> get platformLocales => PlatformDispatcher.instance.locales;

/// 屏幕宽度 [screenWidthPixel]
/// 在桌面系统中, 启动时多大, 就已经固定了多大
@dp
double get screenWidth => platformMediaQueryData.size.width;

/// 屏幕高度, 此高度不包含导航栏的高度 [screenHeightPixel]
@dp
double get screenHeight => platformMediaQueryData.size.height;

/// 是否是横屏
bool get isLandscape => screenWidth > screenHeight;

/// 对角线长度
@dp
double get screenDiagonalLength => cl(screenWidth, screenHeight);

/// 获取顶部安全区域
@dp
double get screenStatusBar => platformMediaQueryData.padding.top;

/// 获取底部安全区域
@dp
double get screenBottomBar => platformMediaQueryData.padding.bottom;

/// 底部导航的高度
@dp
double get screenNavigationBar => (deviceHeightPixel - screenHeightPixel) / dpr;

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

/// 屏幕高度 [screenHeight], 此高度不包含导航栏的高度
@pixel
double get screenHeightPixel =>
    platformMediaQueryData.size.height *
    platformMediaQueryData.devicePixelRatio;

/// 对角线长度
@pixel
double get screenDiagonalLengthPixel => cl(screenWidthPixel, screenHeightPixel);

/// 设备的宽度 [screenWidth]
@pixel
double get deviceWidthPixel => flutterView.display.size.width;

@dp
double get deviceWidth => deviceWidthPixel / dpr;

/// 设备的高度 [screenHeight], 包含导航栏的高度
@pixel
double get deviceHeightPixel => flutterView.display.size.height;

@dp
double get deviceHeight => deviceHeightPixel / dpr;

/// 设备对角线的英寸大小 >=7 视为平板, 7.07 大约 10英寸
double get deviceInch => cl(deviceWidthPixel, deviceHeightPixel) / dpi;

/// 是否是平板, 根据屏幕对角线尺寸判断
/// [GlobalConfig.isAdaptiveTablet]
bool get isTabletDevice => deviceInch >= 7;

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
bool get isDesktop =>
    !UniversalPlatform.isWeb &&
    UniversalPlatform
        .isDesktop /*Platform.isWindows || Platform.isMacOS || Platform.isLinux*/;

/// 是否是pc客户端或者web
bool get isDesktopOrWeb => UniversalPlatform.isDesktopOrWeb;

/// 根据rgb的值, 计算出灰度值
/// 加权平均法计算灰度值
///
/// - 加权平均法（Luminosity method）：根据不同的颜色空间分量的重要性赋予它们不同的权重，然后将它们加权平均得到灰度值。例如，常见的加权公式是 gray = 0.2126 * R + 0.7152 * G + 0.0722 * B。
/// - 最大值法（Maximum method）：取 RGB 中的最大值作为灰度值。即 gray = max(R, G, B)。
/// - 最小值法（Minimum method）：取 RGB 中的最小值作为灰度值。即 gray = min(R, G, B)。
/// - 幂律变换法（Power-law transformation）：对每个颜色分量进行幂次转换以增强图像对比度。公式为 gray = c * (R^r + G^r + B^r)^1/r。
/// - 单通道转换法（Channel-by-Channel method）：分别对 R、G、B 通道进行灰度化处理，再将三个结果取平均得到最终的灰度值。
///
///
/// - 平均法：
///    - 优点：简单易实现，计算速度快。
///    - 缺点：对不同颜色通道的重要性没有考虑，可能不能很好地保持图像质量。
/// - 加权平均法：
///    - 优点：考虑到了不同颜色通道的重要性，可以更好地保持图像质量。
///    - 缺点：需要选择合适的权重值，对不同图像可能需要不同的调整。
/// - 最大值法和最小值法：
///    - 优点：简单直观，可以突出图像中的最亮或最暗部分。
///    - 缺点：可能会丢失图像细节，不适用于所有图像。
/// - 幂律变换法：
///    - 优点：可以增强图像对比度，适用于一些需要增强细节的图像。
///    - 缺点：转换参数的选择对效果影响较大，可能会导致图像过度增强或失真。
/// - 单通道转换法：
///    - 优点：可以分别处理不同通道，适用于某些特定的图像。
///    - 缺点：可能会使得灰度图像失去一些整体感，提取的特征不够全面。
///
int rgbToGray(int r, int g, int b) {
  //(r + g + b) ~/ 3
  //return (r * 0.299 + g * 0.587 + b * 0.114).toInt().clamp(0, 255);
  return (r * 0.34 + g * 0.5 + b * 0.16).toInt().clamp(0, 255);
}

/// 平台的名称, 例如: Android, iOS, Windows, Linux, MacOS, Fuchsia
/// 统一小写
String get $platformName {
  if (isAndroid) {
    return "Android".toLowerCase();
  } else if (isIos) {
    return "iOS".toLowerCase();
  } else if (isMacOs) {
    return "MacOS".toLowerCase();
  } else if (isWindows) {
    return "Windows".toLowerCase();
  } else if (isLinux) {
    return "Linux".toLowerCase();
  } else if (isFuchsia) {
    return "Fuchsia".toLowerCase();
  } else {
    return "Unknown".toLowerCase();
  }
}

//---

/// 使用风味文件名
/// - `lib/main_dev.dart`
/// - `lib/main_prod.dart`
///
/// ```
/// flutter run -t lib/main_dev.dart --flavor dev
/// ```
///
/// ```
/// #Run app in `dev` environment
/// flutter run -t lib/main_dev.dart  --flavor=dev
///
/// # Run app in debug mode (Picks up debug signing config)
/// flutter run -t lib/main_dev.dart  --debug --flavor=dev
///
/// # Run app in release mode (Picks up release signing config)
/// flutter run -t lib/main_dev.dart  --release --flavor=dev
///
/// # Create appBundle for Android platform. Runs in release mode by default.
/// flutter build appbundle -t lib/main_dev.dart  --flavor=dev
///
/// # Create APK for dev flavor. Runs in release mode by default.
/// flutter build apk -t lib/main_dev.dart  --flavor=dev
/// ```
///
/// ```
/// flutter run --flavor [environment name]
/// flutter run --flavor free
/// ```
/// https://docs.flutter.dev/deployment/flavors
const String? flutterAppFlavor = appFlavor;

//---

/// 下载状态
enum DownloadState {
  /// 正常状态
  none,

  /// 下载中
  downloading,

  /// 下载完成
  downloaded,

  /// 下载失败
  downloadFailed,

  /// 取消下载
  downloadCanceled,
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

/// 在[Isolate]中运行, [callback]可以直接访问上下文的数据(能够send的数据), 不需要主动send
/// [SendPort.send]
/// https://www.youtube.com/watch?v=PPwJ75vqP_s&list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG&index=2
/// ```
/// final data = await run(() => jsonDecode(jsonString));
/// ```
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

/// 内存隔离, 不共享. 只能传递基础数据类型, 或者可以被`send`的对象
/// [SendPort.send]
///
/// 请尽量在静态方法中调用此方法.
///
/// ```
/// Invalid argument(s): Illegal argument in isolate message:
/// object is unsendable - Library:'dart:isolate' Class:
/// _Timer@1026248 (see restrictions listed at `SendPort.send()`
/// documentation for more information)
/// ```
///
/// [Isolate.run]
/// [Isolate.spawn]
Future<R> isolateRun<R>(ResultCallback<R> callback) => run(callback);

/// 安排一个轻量的任务
/// [scheduleTask]
/// [scheduleMicrotask]
Future<R> scheduleTask<R>(ResultCallback<R> callback,
        [Priority priority = Priority.animation]) =>
    SchedulerBinding.instance.scheduleTask(() => callback(), priority,
        debugLabel: "scheduleTask-${nowTimeString()}");

//endregion 性能

//region Asset

/// 默认的资源路径前缀
const kDefAssetsPrefix = 'assets/';
const kDefAssetsPngPrefix = 'assets/png/';
const kDefAssetsSvgPrefix = 'assets/svg/';

/// [loadAssetString]
Future<ByteData> loadAssetByteData(
  String key, {
  String prefix = kDefAssetsPrefix,
  String? package,
}) async {
  return (await rootBundle
      .load(key.ensurePackagePrefix(package, prefix).transformKey()));
}

/// [loadAssetString]
Future<Uint8List> loadAssetBytes(
  String key, {
  String prefix = kDefAssetsPrefix,
  String? package,
}) async {
  return (await loadAssetByteData(key, prefix: prefix, package: package)).bytes;
}

/// 判断指定的[key]是否存在
Future<bool> isAssetKeyExists(String? key) async {
  try {
    await rootBundle.load(key!.transformKey());
    return true;
  } catch (e) {
    return false;
  }
}

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
/// [loadAssetImage]
/// [loadAssetString]
Future<String> loadAssetString(
  String key, {
  String prefix = kDefAssetsPrefix,
  String? package,
}) async {
  return await rootBundle.loadString(
    key.ensurePackagePrefix(package, prefix).transformKey(),
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
  double? size,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
}) =>
    key == null
        ? null
        : Image.asset(
            key.ensurePackagePrefix(package, prefix).transformKey(),
            fit: fit ?? BoxFit.cover,
            width: size ?? width,
            height: size ?? height,
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
            key.ensurePackagePrefix(package, prefix).transformKey(),
          );

/// [UiImage]
/// [loadAssetString]
/// [loadAssetImage]
/// [loadAssetImageByProvider]
Future<UiImage>? loadAssetImageByProvider(
  String? key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package,
  ImageConfiguration configuration = const ImageConfiguration(),
}) =>
    loadAssetImageProvider(key, prefix: prefix, package: package)
        ?.toImage(configuration);

/// [loadAssetString]
/// [loadAssetImage]
/// [loadAssetImageByProvider]
/// [decodeImageFromList]
Future<UiImage> loadAssetImage(
  String key, {
  String prefix = kDefAssetsPngPrefix,
  String? package,
}) async {
  // 读取图片数据
  ByteData data =
      await loadAssetByteData(key, prefix: prefix, package: package);
  Uint8List bytes = data.buffer.asUint8List();
  // 解码图片
  /*ui.Codec codec = await ui.instantiateImageCodec(bytes);
  ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;*/
  return decodeImageFromList(bytes);
}

//endregion Asset

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/13
///
/// 显示器相关

/// [RendererBinding.renderViews]
Iterable<RenderView> get renderViews => WidgetsBinding.instance.renderViews;

/// [RenderView]
/// [RenderView.size]
RenderView get renderView =>
    renderViews.firstOrNull ?? WidgetsBinding.instance.renderView;

/// [ui.window]
/// [RendererBinding.instance]
/// [PlatformDispatcher.implicitView]
/// [FlutterView.display]
/// [FlutterView.display.size] //可以获取屏幕尺寸, 在windows上这个大小会是0
///
/// [SingletonFlutterWindow].[FlutterView]
/// [window.physicalSize]
/// [window.devicePixelRatio]
/// [window.refreshRate]
ui.FlutterView get flutterView => renderView.flutterView;

/// [WidgetsBinding.instance]
/// [WidgetsBinding.platformDispatcher]
/// [PlatformDispatcher.views]
Iterable<ui.FlutterView> get flutterViews =>
    renderViews.map((e) => e.flutterView);

/// 平台事件调度程序单例。
UiPlatformDispatcher get platformDispatcher => UiPlatformDispatcher.instance;

/// 平台显示器列表
Iterable<ui.Display> get platformDisplays => platformDispatcher.displays;

/// 获取当前平台的[Display]
ui.Display get display => platformDisplays.firstOrNull ?? flutterView.display;

//MARK: - media

/// 获取当前平台的[MediaQueryData]
/// [ui.window]
/// [defaultTargetPlatform]
/// [PlatformDispatcher.instance]
/// [PlatformDispatcher.displays]
/// [PlatformDispatcher.views]
MediaQueryData get platformMediaQueryData =>
    MediaQueryData.fromView(flutterView);

/// 多显示器支持
Iterable<MediaQueryData> get platformMediaQueryDataList => RendererBinding
    .instance
    .renderViews
    .map((v) => MediaQueryData.fromView(v.flutterView));

@alias
MediaQueryData get $platformMediaQueryData => platformMediaQueryData;

/// 获取当前平台的亮度模式
Brightness get platformBrightness => platformMediaQueryData.platformBrightness;

/// 屏幕宽度 [screenWidthPixel]
/// 在桌面系统中, 启动时多大, 就已经固定了多大
@dp
double get screenWidth => platformMediaQueryData.size.width;

@alias
double get $screenWidth => screenWidth;

/// 屏幕高度, 此高度不包含导航栏的高度 [screenHeightPixel]
@dp
double get screenHeight => platformMediaQueryData.size.height;

@alias
double get $screenHeight => screenHeight;

/// 屏幕最小边长
/// - [Size.shortestSide]
/// - [Size.longestSide]
@dp
double get $screenMinSize => min(screenWidth, screenHeight);

/// 屏幕尺寸
@dp
Size get $screenSize => Size(screenWidth, screenHeight);

/// 是否是横屏
bool get isLandscape => screenWidth > screenHeight;

/// 对角线长度
@dp
double get screenDiagonalLength => cl(screenWidth, screenHeight);

/// 获取顶部安全区域
@dp
double get screenStatusBar => platformMediaQueryData.padding.top;

/// - [$screenStatusBar]
/// - [$screenBottomBar]
@alias
double get $screenStatusBar => screenStatusBar;

/// 获取底部安全区域
@dp
double get screenBottomBar => platformMediaQueryData.padding.bottom;

/// - [$screenStatusBar]
/// - [$screenBottomBar]
@alias
double get $screenBottomBar => screenBottomBar;

/// 底部导航的高度
@dp
double get screenNavigationBar => (deviceHeightPixel - screenHeightPixel) / dpr;

/// 屏幕像素密度, 1 dp = xx px
double get devicePixelRatio => platformMediaQueryData.devicePixelRatio;

/// 屏幕刷新率
double get refreshRate => display.refreshRate;

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
double get deviceWidthPixel => display.size.width;

@dp
double get deviceWidth => deviceWidthPixel / dpr;

/// 设备的高度 [screenHeight], 包含导航栏的高度
@pixel
double get deviceHeightPixel => display.size.height;

@dp
double get deviceHeight => deviceHeightPixel / dpr;

/// 设备对角线的英寸大小 >=7 视为平板, 7.07 大约 10英寸
///
/// - [isTabletDevice]
double get deviceInch => cl(deviceWidthPixel, deviceHeightPixel) / dpi;

/// 屏幕对角线的英寸大小, 桌面下可以动态调整窗口的尺寸
double get screenInch => cl(screenWidthPixel, screenHeightPixel) / dpi;

//MARK: - local

/// 获取当前平台的语言设置[Locale], 系统语言.
/// http://www.lingoes.net/en/translator/langcode.htm
Locale get platformLocale => PlatformDispatcher.instance.locale;

/// 获取当前平台的语言设置列表[Locale], 系统语言列表
List<Locale> get platformLocales => PlatformDispatcher.instance.locales;

//MARK: - other

/// 是否是平板, 根据屏幕对角线尺寸判断. 通常认为对角线大于等于 7 英寸的设备为平板。
/// 7 * 25.4mm = 177.8mm 17.78cm
///
/// ```
/// （MediaQuery.of(context).size.shortestSide）。一般：
///  - >= 600dp 认为是 Tablet（平板）
///  - < 600dp 认为是 Phone（手机）
/// ```
///
/// [GlobalConfig.isAdaptiveTablet]
///
/// - [isTabletDevice]
/// - [isTabletWindow]
@Deprecated("请使用[isTabletWindow]")
bool get isTabletDevice => deviceInch >= 7 || screenInch >= 7;

/// 当前窗口是否是平板样式, 在分屏模式下, 窗口的宽度大于等于 600dp 认为是平板样式
///
/// - [responsive_builder] 响应式布局, 内部依赖[provider]
/// - [responsive_framework] 响应式框架
///
/// - [isTabletDevice]
/// - [isTabletWindow]
bool get isTabletWindow => isTabletDevice /*display.size.shortestSide >= 600*/;

/// 是否处于平板宽屏模式
bool get isTabletLandscape =>
    isTabletWindow && screenWidth > screenHeight && screenWidth >= 600;

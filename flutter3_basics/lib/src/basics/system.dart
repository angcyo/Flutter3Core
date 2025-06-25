part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/21
///

/// 设置屏幕方向
///
/// [OrientationBuilder] //屏幕方向监听 [orientationBuilder]
/// [VisibilityDetector ] //可见性探测 https://pub.dev/packages/visibility_detector
///
///
/// ```
/// MediaQuery.of(context).orientation;
/// '屏幕方向: ${orientation == Orientation.portrait ? "纵向" : "横向"}',
/// ```
/// [MediaQueryData]
///
/// [DeviceOrientation.landscapeRight] // 横屏模式，向右旋转
/// [DeviceOrientation.landscapeLeft] // 横屏模式 向左旋转
Future<void> setScreenOrientation([DeviceOrientation? orientation]) =>
    SystemChrome.setPreferredOrientations(
        orientation == null ? [] : [orientation]);

Future<void> setScreenOrientations([List<DeviceOrientation>? orientations]) =>
    SystemChrome.setPreferredOrientations(orientations ?? []);

/// 设置横屏
Future<void> setScreenLandscape(
        [List<DeviceOrientation> orientations = const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]]) =>
    setScreenOrientations(orientations);

/// 设置竖屏
Future<void> setScreenPortrait(
        [List<DeviceOrientation> orientations = const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ]]) =>
    setScreenOrientations(orientations);

/// 根据屏幕方向进行布局
/// ```
/// MediaQuery.of(context).orientation;
/// ```
/// [MediaQueryData]
/// [OrientationBuilder]
Widget orientationBuilder(OrientationWidgetBuilder builder, [Key? key]) {
  return OrientationBuilder(builder: builder, key: key);
}

extension OrientationEx on Orientation {
  bool get isLandscape => this == Orientation.landscape;
}

//--

/// 设置ui模式
/// [SystemChrome.setEnabledSystemUIMode]
/// void

///设置状态栏样式
void setSystemUIOverlayStyle(SystemUiOverlayStyle style) {
  /*// Android状态栏透明 splash为白色,所以调整状态栏文字为黑色
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));*/
  SystemChrome.setSystemUIOverlayStyle(style);
}

/// 设置状态栏为浅色, 亮色背景, 黑色字体
void setSystemUILightStyle() {
  setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

/// 设置状态栏为深色, 暗色背景, 白色字体
void setSystemUIDarkStyle() {
  setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
}

//震动反馈
//Feedback.forLongPress(context);

//声音反馈
//HapticFeedback.lightImpact();
//SystemSound.play();

/// 鼠标是否连接
bool get mouseIsConnected =>
    WidgetsBinding.instance.mouseTracker.mouseIsConnected;

bool get isMouseConnected => mouseIsConnected;

//--

/// 系统小部件相关扩展
extension SystemWidgetEx on Widget {
  /// 设置macOS平台上的菜单栏
  /// 也可以使用`WidgetsBinding.instance.platformMenuDelegate.setMenus(menus);`主动设置,
  /// 但是只能同时使用一种方法设置.
  ///
  /// [PlatformMenuItem] 菜单项
  /// [PlatformMenu] 菜单, 没有分组的菜单会被默认丢到第一个Group中
  /// [PlatformMenuItemGroup] 菜单组, 同时也可以进行分组/分割线设置
  @PlatformFlag("macOS")
  Widget platformMenuBar(
    List<PlatformMenuItem> menus,
  ) =>
      isMacOS ? PlatformMenuBar(menus: menus, child: this) : this;
}

/// 隐藏键盘
/// 发送消息以隐藏键盘，但不改变输入框的焦点
Future<T?> hideKeyboard<T>() =>
    SystemChannels.textInput.invokeMethod<T>('TextInput.hide');

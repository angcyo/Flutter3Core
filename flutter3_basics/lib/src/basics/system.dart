part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/21
///
/// 系统相关

//MARK: - orientation

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
/// - [DeviceOrientation.landscapeRight] // 横屏模式，向右旋转
/// - [DeviceOrientation.landscapeLeft] // 横屏模式 向左旋转
/// - 空, 则表示全方向都支持
Future<void> setScreenOrientation([DeviceOrientation? orientation]) =>
    setScreenOrientations(orientation == null ? [] : [orientation]);

List<DeviceOrientation>? _lastOrientations;

/// [setScreenOrientation]
Future<void> setScreenOrientations([
  List<DeviceOrientation>? orientations,
]) async {
  _lastOrientations = orientations;
  SystemChrome.setPreferredOrientations(orientations ?? []);
}

/// 设置横屏
Future<void> setScreenLandscape([
  List<DeviceOrientation> orientations = const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ],
]) => setScreenOrientations(orientations);

/// 设置竖屏
Future<void> setScreenPortrait([
  List<DeviceOrientation> orientations = const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ],
]) => setScreenOrientations(orientations);

/// 根据屏幕方向进行布局
/// ```
/// MediaQuery.of(context).orientation;
/// ```
/// - [MediaQueryData]
/// - [OrientationBuilder]
/// - [LayoutBuilder]
Widget orientationBuilder(OrientationWidgetBuilder builder, [Key? key]) {
  return OrientationBuilder(builder: builder, key: key);
}

extension OrientationEx on Orientation {
  /// 是否是横屏
  bool get isLandscape => this == Orientation.landscape;
}

//MARK: - OverlayStyle

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

/// 弹出应用
@api
void popApp() {
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

//MARK: - Widget

/// 屏幕方向小部件
/// - 指定进入页面时的屏幕方向
/// - 退出时, 恢复到之前状态
///
/// - [ScreenOrientationWidget]
/// - [MediaQueryDataBuilderWidget]
/// - [MediaQueryDataChangeMixin]
class ScreenOrientationWidget extends StatefulWidget {
  /// 需要指定的屏幕方向
  final List<DeviceOrientation>? orientations;

  /// 退出时, 恢复到之前状态
  @defInjectMark
  final List<DeviceOrientation>? reverseOrientations;
  final Widget? child;
  final Widget Function(
    BuildContext context,
    MediaQueryData? mediaData,
    bool first,
    bool changed,
  )?
  builder;

  /// 是否激活监听屏幕尺寸变化
  final bool enableSizeObserver;

  /// 监听的[ui.FlutterView]
  /// - 多窗口时需要
  final ui.FlutterView? view;

  const ScreenOrientationWidget(
    this.orientations, {
    super.key,
    this.child,
    this.builder,
    this.reverseOrientations,
    this.view,
    this.enableSizeObserver = false,
  }) : assert(builder != null || child != null);

  @override
  State<ScreenOrientationWidget> createState() =>
      _ScreenOrientationWidgetState();
}

class _ScreenOrientationWidgetState extends State<ScreenOrientationWidget>
    with WidgetsBindingObserver {
  //--
  List<DeviceOrientation>? reverseOrientations;

  //--
  ui.FlutterView? _view;
  MediaQueryData? _mediaQueryData;

  /// 是否是第一次进入页面
  bool _isFirst = true;

  @override
  void initState() {
    _isFirst = true;
    reverseOrientations = widget.reverseOrientations ?? _lastOrientations;
    setScreenOrientations(widget.orientations);
    if (widget.enableSizeObserver) {
      _view =
          widget.view ??
          WidgetsBinding.instance.platformDispatcher.views.firstOrNull ??
          flutterViews.firstOrNull ??
          flutterView;
      _mediaQueryData = MediaQueryData.fromView(_view!);
      WidgetsBinding.instance.addObserver(this);
    }
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    setScreenOrientations(reverseOrientations);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    final bool isFirst = _isFirst;
    final bool isChanged = _isChanged;
    _isChanged = false;
    _isFirst = false;
    return widget.builder?.call(context, _mediaQueryData, isFirst, isChanged) ??
        widget.child!;
  }

  /// 是否发生过改变
  bool _isChanged = false;

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final mediaQueryData = MediaQueryData.fromView(_view!);
    //debugger();
    if (_mediaQueryData?.size != mediaQueryData.size) {
      final old = _mediaQueryData;
      _mediaQueryData = mediaQueryData;
      onSelfMediaQuerySizeChanged(old, mediaQueryData);
    }
    //debugger();
  }

  /// [MediaQueryData]数据改变
  void onSelfMediaQuerySizeChanged(MediaQueryData? from, MediaQueryData to) {
    _isChanged = true;
    updateState();
  }
}

//MARK: - extension

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
  Widget platformMenuBar(List<PlatformMenuItem> menus) =>
      isMacOS ? PlatformMenuBar(menus: menus, child: this) : this;

  /// 屏幕方向设置小部件
  Widget orientation(List<DeviceOrientation>? orientations) =>
      ScreenOrientationWidget(orientations, child: this);
}

/// @return 键盘当前是否可见。
bool isKeyboardVisible(BuildContext context) {
  var myContext = context.findRootAncestorStateOfType<ScaffoldState>()?.context;
  myContext ??= context;
  var keyboardVisible = false;
  if (MediaQuery.of(myContext).viewInsets.bottom > 0) {
    keyboardVisible = true;
  }
  return keyboardVisible;
}

/// 隐藏键盘
/// 发送消息以隐藏键盘，但不改变输入框的焦点
Future<T?> hideKeyboard<T>({BuildContext? unfocus}) {
  final result = SystemChannels.textInput.invokeMethod<T>('TextInput.hide');
  if (unfocus != null) {
    FocusScope.of(unfocus).unfocus();
  }
  return result;
}

//region network

/// 获取系统网口/网卡信息
/// - IPV4环回地址: 127.0.0.1
/// - IPV6环回地址: ::1
///
/// - lo0（Loopback Interface）: 本地环回地址, 通常被称为 "localhost" 或 "loopback"。
/// - en0（Ethernet Interface）: en0 代表系统中的第一个以太网接口，它通常是物理网络接口例如 Ethernet 端口或 Wi-Fi 适配器。
/// - wlan0 （Wireless Local Area Network）: wlan0 代表系统中的第一个无线局域网接口，通常用于 Wi-Fi 连接。
/// - utun0（VPN Interface）: utun 是用于虚拟隧道（如 VPN）的网络接口。
/// - dummy0 （Dummy Interface）: dummy0 代表一个虚拟接口，通常用于测试或模拟网络环境。
///
/// - awdl0: awdl 代表 Apple Wireless Direct Link，用于与其他 Apple 设备（如 iPhone、iPad、Mac）进行点对点的无线通信。
/// - llw0: llw0 代表 Apple Link-Local Wireless，低延迟无线通信. 用于 Apple 设备之间的无线通信。
/// - anpi0: 是 macOS 和其他 Unix-like 系统中一个网络接口的名称，表示 Apple Network Protocol Interface。
///
/// # MacOS
/// ```
/// NetworkInterface('lo0', [InternetAddress('127.0.0.1', IPv4), InternetAddress('::1', IPv6), InternetAddress('fe80::1%lo0', IPv6)])↓
/// NetworkInterface('en0', [InternetAddress('192.168.31.232', IPv4)])↓
/// NetworkInterface('en8', [InternetAddress('fe80::fcda:1cff:feb4:51b8%en8', IPv6)])↓
/// NetworkInterface('en12', [InternetAddress('fe80::18c1:53c6:8e6e:8baf%en12', IPv6), InternetAddress('169.254.30.229', IPv4)])↓
/// NetworkInterface('utun0', [InternetAddress('fe80::d04e:ca70:43a1:d9c0%utun0', IPv6)])↓
/// NetworkInterface('utun1', [InternetAddress('fe80::5950:6fce:5c3:8129%utun1', IPv6)])↓
/// NetworkInterface('utun2', [InternetAddress('fe80::4f79:5787:2f4f:d0bb%utun2', IPv6)])↓
/// NetworkInterface('utun3', [InternetAddress('fe80::ce81:b1c:bd2c:69e%utun3', IPv6)])↓
/// NetworkInterface('utun5', [InternetAddress('fe80::a08:b58a:4b96:d1ba%utun5', IPv6)])↓
/// NetworkInterface('utun6', [InternetAddress('fe80::691b:9545:fd59:be96%utun6', IPv6)])
/// NetworkInterface('awdl0', [InternetAddress('fe80::684a:a1ff:fe36:f613%awdl0', IPv6)])↓
/// NetworkInterface('llw0', [InternetAddress('fe80::684a:a1ff:fe36:f613%llw0', IPv6)])↓
/// ```
///
/// # iOS
/// ```
/// NetworkInterface('lo0', [InternetAddress('127.0.0.1', IPv4), InternetAddress('::1', IPv6), InternetAddress('fe80::1%lo0', IPv6)])↓
/// NetworkInterface('en0', [InternetAddress('fe80::cda:e662:f357:81d3%en0', IPv6), InternetAddress('192.168.31.181', IPv4)])↓
/// NetworkInterface('en2', [InternetAddress('fe80::1068:d472:42b1:ef11%en2', IPv6), InternetAddress('169.254.84.141', IPv4)])↓
/// NetworkInterface('utun0', [InternetAddress('fe80::92f9:d353:5a02:d141%utun0', IPv6)])↓
/// NetworkInterface('utun1', [InternetAddress('fe80::8bfd:6bd1:f618:613f%utun1', IPv6)])↓
/// NetworkInterface('utun2', [InternetAddress('fe80::7cc3:a8fb:8095:a91a%utun2', IPv6)])↓
/// NetworkInterface('utun3', [InternetAddress('fe80::ce81:b1c:bd2c:69e%utun3', IPv6)])↓
/// NetworkInterface('utun4', [InternetAddress('fe80::fb48:8ff1:c696:efab%utun4', IPv6)])↓
/// NetworkInterface('utun5', [InternetAddress('fe80::d39a:5795:544a:db65%utun5', IPv6)])↓
/// NetworkInterface('utun6', [InternetAddress('fe80::6cff:9358:581b:1ae7%utun6', IPv6), InternetAddress('fd35:b42f:1c6f::1', IPv6)])
/// NetworkInterface('anpi0', [InternetAddress('fe80::fcda:1cff:feb4:5147%anpi0', IPv6)])↓
/// NetworkInterface('awdl0', [InternetAddress('fe80::185b:acff:fe68:cf2b%awdl0', IPv6)])↓
/// NetworkInterface('llw0', [InternetAddress('fe80::185b:acff:fe68:cf2b%llw0', IPv6)])↓
/// ```
///
/// # Android
/// ```
/// NetworkInterface('lo', [InternetAddress('127.0.0.1', IPv4), InternetAddress('::1%1', IPv6)])↓
/// NetworkInterface('wlan0', [InternetAddress('192.168.31.106', IPv4), InternetAddress('fe80::aca9:3ff:fef8:6ffa%wlan0', IPv6)])↓
/// NetworkInterface('dummy0', [InternetAddress('fe80::6017:57ff:fe0b:f629%dummy0', IPv6)])
/// ```
Future<List<NetworkInterface>> $getNetworkInterfaceList({
  bool includeLoopback = true,
  bool includeLinkLocal = true,
  InternetAddressType type = InternetAddressType.any,
}) async {
  final list = await NetworkInterface.list(
    includeLoopback: includeLoopback,
    includeLinkLocal: includeLinkLocal,
    type: type,
  );
  //final ipv4 = InternetAddress.anyIPv4.address; //0.0.0.0
  //final ipv6 = InternetAddress.anyIPv6.address; //::
  return list;
}

/// 打印网络接口信息
void logNetworkInterfaceList() async {
  final list = await $getNetworkInterfaceList();
  //debugger();
  final ipv4 = InternetAddress.anyIPv4.address; //0.0.0.0
  final ipv6 = InternetAddress.anyIPv6.address; //::
  l.v("网络接口信息(网关)↓\n${list.join("↓\n")}\n\n默认ipv4->$ipv4, 默认ipv6->$ipv6");
}

/// 获取本地IP地址[InternetAddress], 本机ip
///
/// [$getNetworkInterfaceList]
/// - [$getLocalInternetAddress]
/// - [$getLocalIp]
///
/// @return 无网络时, 返回null
Future<InternetAddress?> $getLocalInternetAddress({
  InternetAddressType type = InternetAddressType.IPv4,
  bool includeLinkLocal = false /*是否包含本地连接的网络*/,
  String fallbackIp = "192.168" /*备用ip地址前缀*/,
}) async {
  //debugger();
  final list = await NetworkInterface.list(
    type: type,
    includeLoopback: false,
    includeLinkLocal: includeLinkLocal,
  );
  //回滚的地址
  InternetAddress? rollback;
  for (final element in list) {
    rollback ??= element.addresses.findFirst(
      (e) => e.address.startsWith(fallbackIp),
    );
    final name = element.name;
    if (name.startsWith("wlan") ||
        name.startsWith("eth") ||
        name.startsWith("以太网") ||
        name.startsWith("en")) {
      return element.addresses.first;
    }
  }
  return rollback;
}

/// 获取本机ip
Future<String> $getLocalIp({
  InternetAddressType type = InternetAddressType.IPv4,
}) async {
  return (await $getLocalInternetAddress(type: type))?.address ?? "";
  /*final interfaces = await NetworkInterface.list(
    type: type,
    includeLinkLocal: true,
  );
  debugger();
  try {
    // Try VPN connection first
    final vpnInterface = interfaces.firstWhere(
          (element) => element.name == "tun0",
    );
    return vpnInterface.addresses.first.address;
  } on StateError {
    // Try wlan connection next
    try {
      final interface = interfaces.firstWhere(
            (element) => element.name == "wlan0",
      );
      return interface.addresses.first.address;
    } catch (ex) {
      // Try any other connection next
      try {
        final interface = interfaces.firstWhere(
              (element) => !(element.name == "tun0" || element.name == "wlan0"),
        );
        return interface.addresses.first.address;
      } catch (ex) {
        return "";
      }
    }
  }*/
}

//endregion network

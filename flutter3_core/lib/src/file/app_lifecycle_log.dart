part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/01
///

/// 只要创建了[AppLifecycleListener]对象, 就会自动调用[WidgetsBinding.addObserver]方法
/// [WidgetsBindingObserver]
/// [AppLifecycleObserver] //app生命周期监听
/// [AppLifecycleStateMixin]
/// [NavigatorObserverMixin]
mixin AppLifecycleLogMixin on AppLifecycleListener {
  /// [AppExitResponse.exit]
  /// [AppExitResponse.cancel]
  /// [AppExitResponse.values]
  @override
  Future<UiAppExitResponse> didRequestAppExit() {
    '[${classHash()}]AppLifecycle didRequestAppExit'.writeToLog(
      level: L.verbose,
    );
    return super.didRequestAppExit();
  }

  @override
  void didChangeAccessibilityFeatures() {
    '[${classHash()}]AppLifecycle didChangeAccessibilityFeatures'.writeToLog(
      level: L.verbose,
    );
    super.didChangeAccessibilityFeatures();
  }

  ///语言环境发生改变时回调这里
  @override
  void didChangeLocales(List<Locale>? locales) {
    '[${classHash()}]AppLifecycle didChangeLocales:$locales'.writeToLog(
      level: L.verbose,
    );
    super.didChangeLocales(locales);
  }

  ///手机系统屏幕亮度发生改变时回调
  @override
  void didChangePlatformBrightness() {
    '[${classHash()}]AppLifecycle didChangePlatformBrightness'.writeToLog(
      level: L.verbose,
    );
    super.didChangePlatformBrightness();
  }

  /// RouteInformation->content://com.ss.android.lark.common.fileprovider/external_files/Download/Lark/2024-11-29_2.gc
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    '[${classHash()}]AppLifecycle didPushRouteInformation:${routeInformation.runtimeType}->${routeInformation.uri}'
        .writeToLog(level: L.verbose);
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  void dispose() {
    '[${classHash()}]AppLifecycle dispose'.writeToLog(level: L.verbose);
    super.dispose();
  }

  /// 屏幕旋转/尺寸改变后
  ///系统窗口改变回调 如键盘弹出 屏幕旋转等
  @override
  void didChangeMetrics() {
    '[${classHash()}]didChangeMetrics'
            ' screen:${screenWidth.toDigits(ensureInt: true)}x${screenHeight.toDigits(ensureInt: true)} ${screenInch.toDigits(ensureInt: true)}\''
            ' device:${deviceWidth.toDigits(ensureInt: true)}x${deviceHeight.toDigits(ensureInt: true)} ${deviceInch.toDigits(ensureInt: true)}\' [$dpr]'
            ' viewInsets:${platformMediaQueryData.viewInsets.log} viewPadding:${platformMediaQueryData.viewPadding.log} ${platformMediaQueryData.platformBrightness}'
        .writeToLog(level: L.verbose);
    super.didChangeMetrics();
  }

  /// # 灭屏后/切换到后台/切换其他应用
  /// ```
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didHaveMemoryPressure
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.paused
  /// ```
  ///
  /// # 亮屏后/切换到前台/切换回来
  /// ```
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didChangeAppLifecycleState:AppLifecycleState.resumed
  /// ```
  ///
  /// # 按返回键
  /// ```
  /// didPopRoute
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.paused
  /// didChangeAppLifecycleState:AppLifecycleState.detached  //多了一个detached
  /// ```
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    '[${classHash()}] AppLifecycle didChangeAppLifecycleState:$state'
        .writeToLog(level: L.verbose);
    super.didChangeAppLifecycleState(state);
  }

  /// 低内存回调, 此时需要释放内容
  @override
  void didHaveMemoryPressure() {
    '[${classHash()}] AppLifecycle didHaveMemoryPressure'.writeToLog(
      level: L.verbose,
    );
    super.didHaveMemoryPressure();
  }

  ///手机系统文本缩放系数改变里回调这里
  @override
  void didChangeTextScaleFactor() {
    '[${classHash()}] AppLifecycle didChangeTextScaleFactor'.writeToLog(
      level: L.verbose,
    );
    super.didChangeTextScaleFactor();
  }

  /// didPushRoute:/external_files/Download/Lark/2024-11-29_2.gc
  @override
  Future<bool> didPushRoute(String route) {
    '[${classHash()}]AppLifecycle didPushRoute:$route'.writeToLog(
      level: L.verbose,
    );
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPopRoute() {
    '[${classHash()}] AppLifecycle didPopRoute'.writeToLog(level: L.verbose);
    return super.didPopRoute();
  }
}

//MARK: - AppLifecycleObserver

///
/// App的生命周期观察
///
/// 只要创建了[AppLifecycleListener]对象, 就会自动调用[WidgetsBinding.addObserver]方法
/// 需要先调用[AppLifecycleObserver.install]进行安装.
///
/// - [WidgetsBindingObserver]
/// - [WidgetsBinding.addObserver]
/// - [WidgetsBinding.removeObserver]
class AppLifecycleObserver extends AppLifecycleListener
    with AppLifecycleLogMixin {
  /// 全局App生命周期监听
  /// 刚启动的时候, 不会有这个值
  static LiveStream<AppLifecycleState?> appLifecycleStateStream = $live();

  /// 屏幕上被挡住的部分内容
  static LiveStream<EdgeInsets?> appViewInsetStream = $live();

  /// 底部键盘的高度监听
  /// - [MediaQueryData]
  /// - [MediaQueryData.viewInsets]
  /// - [platformMediaQueryData]
  static LiveStream<double?> appBottomInsetHeightStream = $live();

  /// 注册一个全局的生命周期监听
  @api
  static AppLifecycleObserver install() {
    WidgetsFlutterBinding.ensureInitialized();
    return AppLifecycleObserver();
  }

  /// 移除监听
  @api
  void uninstall() {
    dispose();
  }

  /// [uninstall]
  @override
  void dispose() {
    super.dispose();
  }

  ///
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    appViewInsetStream <= platformMediaQueryData.viewInsets;
    appBottomInsetHeightStream <= platformMediaQueryData.viewInsets.bottom;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    appLifecycleStateStream <= state;
  }
}

/// 监听[MediaQueryData.viewInsets]
/// - 变化有可能是一个动画过程
class ViewInsetsCallbackWidget extends StatefulWidget {
  final Widget child;

  /// 需要监听的边
  final bool? left;
  final bool? top;
  final bool? right;
  final bool? bottom;

  /// 边框变化回调, 不监听的边为null
  final Function(double? left, double? top, double? right, double? bottom)?
  onChanged;

  const ViewInsetsCallbackWidget({
    super.key,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.onChanged,
  });

  @override
  State<ViewInsetsCallbackWidget> createState() =>
      _ViewInsetsCallbackWidgetState();
}

class _ViewInsetsCallbackWidgetState
    extends HookState<ViewInsetsCallbackWidget> {
  @override
  void initState() {
    super.initState();
    hookAny(
      AppLifecycleObserver.appViewInsetStream.listen((data) {
        //debugger();
        if (data != null && widget.onChanged != null) {
          final left = widget.left == true ? data.left : null;
          final top = widget.top == true ? data.top : null;
          final right = widget.right == true ? data.right : null;
          final bottom = widget.bottom == true ? data.bottom : null;
          widget.onChanged!(left, top, right, bottom);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension ViewInsetsCallbackWidgetEx on Widget {
  /// 监听屏幕上被挡住的部分内容
  Widget viewInsetsCallback({
    bool? left,
    bool? top,
    final bool? right,
    bool? bottom,
    Function(double? left, double? top, double? right, double? bottom)?
    onChanged,
  }) {
    return ViewInsetsCallbackWidget(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      onChanged: onChanged,
      child: this,
    );
  }
}

extension MediaQueryDataLogEx on MediaQueryData {
  String get log {
    return 'viewInsets:${viewInsets.log} viewPadding:${viewPadding.log} $platformBrightness';
  }
}

extension EdgeInsetsLogEx on EdgeInsets {
  String get log {
    return 'ltrb:${left.toInt()} ${top.toInt()} ${right.toInt()} ${bottom.toInt()}';
  }
}

extension SizeLogEx on Size {
  String get log {
    return 'wh:${width.toInt()} ${height.toInt()}';
  }
}

/// 判断App是否处于后台运行
bool get $isAppPaused =>
    AppLifecycleObserver.appLifecycleStateStream.value ==
    AppLifecycleState.paused;

/// 判断App是否处于前台运行
bool get $isAppResumed =>
    AppLifecycleObserver.appLifecycleStateStream.value ==
    AppLifecycleState.resumed;

/// 底部插入的高度
double get $appBottomInsetHeight =>
    AppLifecycleObserver.appBottomInsetHeightStream.value ?? 0;

/// 判断App键盘是否显示
bool get $isAppKeyboardShow => $appBottomInsetHeight > 0;

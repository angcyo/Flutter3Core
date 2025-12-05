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
            ' viewInsets:${platformMediaQueryData.viewInsets} viewPadding:${platformMediaQueryData.viewPadding}'
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
    appBottomInsetHeightStream <= platformMediaQueryData.viewInsets.bottom;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    appLifecycleStateStream <= state;
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

/// 判断App键盘是否显示
bool get $isAppKeyboardShow =>
    (AppLifecycleObserver.appBottomInsetHeightStream.value ?? 0) > 0;

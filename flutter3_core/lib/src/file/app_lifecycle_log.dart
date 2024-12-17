part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/01
///

/// 只要创建了[AppLifecycleListener]对象, 就会自动调用[WidgetsBinding.addObserver]方法
/// [WidgetsBindingObserver]
/// [AppLifecycleLog]
/// [AppLifecycleMixin]
/// [NavigatorObserverMixin]
mixin AppLifecycleLogMixin on AppLifecycleListener {
  /// [AppExitResponse.exit]
  /// [AppExitResponse.cancel]
  /// [AppExitResponse.values]
  @override
  Future<UiAppExitResponse> didRequestAppExit() {
    '[${classHash()}]AppLifecycle didRequestAppExit'
        .writeToLog(level: L.verbose);
    return super.didRequestAppExit();
  }

  @override
  void didChangeAccessibilityFeatures() {
    '[${classHash()}]AppLifecycle didChangeAccessibilityFeatures'
        .writeToLog(level: L.verbose);
    super.didChangeAccessibilityFeatures();
  }

  ///语言环境发生改变时回调这里
  @override
  void didChangeLocales(List<Locale>? locales) {
    '[${classHash()}]AppLifecycle didChangeLocales:$locales'
        .writeToLog(level: L.verbose);
    super.didChangeLocales(locales);
  }

  ///手机系统屏幕亮度发生改变时回调
  @override
  void didChangePlatformBrightness() {
    '[${classHash()}]AppLifecycle didChangePlatformBrightness'
        .writeToLog(level: L.verbose);
    super.didChangePlatformBrightness();
  }

  /// RouteInformation->content://com.ss.android.lark.common.fileprovider/external_files/Download/Lark/2024-11-29_2.gc
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    '[${classHash()}]AppLifecycle didPushRouteInformation:${routeInformation
        .runtimeType}->${routeInformation.uri}'
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
    '[${classHash()}]AppLifecycle didChangeMetrics'
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
    '[${classHash()}]AppLifecycle didChangeAppLifecycleState:$state'
        .writeToLog(level: L.verbose);
    super.didChangeAppLifecycleState(state);
  }

  /// 低内存回调
  @override
  void didHaveMemoryPressure() {
    '[${classHash()}]AppLifecycle didHaveMemoryPressure'
        .writeToLog(level: L.verbose);
    super.didHaveMemoryPressure();
  }

  ///手机系统文本缩放系数改变里回调这里
  @override
  void didChangeTextScaleFactor() {
    '[${classHash()}]AppLifecycle didChangeTextScaleFactor'
        .writeToLog(level: L.verbose);
    super.didChangeTextScaleFactor();
  }

  /// didPushRoute:/external_files/Download/Lark/2024-11-29_2.gc
  @override
  Future<bool> didPushRoute(String route) {
    '[${classHash()}]AppLifecycle didPushRoute:$route'
        .writeToLog(level: L.verbose);
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPopRoute() {
    '[${classHash()}]AppLifecycle didPopRoute'.writeToLog(level: L.verbose);
    return super.didPopRoute();
  }
}

///
/// App的生命周期
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///
/// 只要创建了[AppLifecycleListener]对象, 就会自动调用[WidgetsBinding.addObserver]方法
/// [WidgetsBindingObserver]
/// [WidgetsBinding.addObserver]
/// [WidgetsBinding.removeObserver]
class AppLifecycleLog extends AppLifecycleListener with AppLifecycleLogMixin {
  /// 注册一个全局的生命周期监听
  static AppLifecycleLog install() {
    WidgetsFlutterBinding.ensureInitialized();
    return AppLifecycleLog();
  }

  /// 移除监听
  void uninstall() {
    dispose();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

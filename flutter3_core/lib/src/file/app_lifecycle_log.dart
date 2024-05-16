part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/01
///

/// 只要创建了[AppLifecycleListener]对象, 就会自动调用[WidgetsBinding.addObserver]方法
/// [WidgetsBindingObserver]
/// [AppLifecycleLog]
mixin AppLifecycleLogMixin on AppLifecycleListener {
  /// [AppExitResponse.exit]
  /// [AppExitResponse.cancel]
  /// [AppExitResponse.values]
  @override
  Future<AppExitResponse> didRequestAppExit() {
    l.d('AppLifecycle didRequestAppExit'..writeToLog());
    return super.didRequestAppExit();
  }

  @override
  void didChangeAccessibilityFeatures() {
    l.d('AppLifecycle didChangeAccessibilityFeatures'..writeToLog());
    super.didChangeAccessibilityFeatures();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    l.d('AppLifecycle didChangeLocales:$locales'..writeToLog());
    super.didChangeLocales(locales);
  }

  @override
  void didChangePlatformBrightness() {
    l.d('AppLifecycle didChangePlatformBrightness'..writeToLog());
    super.didChangePlatformBrightness();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    l.d('AppLifecycle didPushRouteInformation:$routeInformation'..writeToLog());
    return super.didPushRouteInformation(routeInformation);
  }

  @override
  void dispose() {
    l.d('AppLifecycle dispose'..writeToLog());
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    l.d('AppLifecycle didChangeMetrics'..writeToLog());
    super.didChangeMetrics();
  }

  /// 灭屏后/切换到后台
  /// ```
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didHaveMemoryPressure
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.paused
  /// ```
  /// 亮屏后/切换到前台
  /// ```
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didChangeAppLifecycleState:AppLifecycleState.resumed
  /// ```
  ///
  /// 按返回键
  /// ```
  /// didPopRoute
  /// didChangeAppLifecycleState:AppLifecycleState.inactive
  /// didChangeAppLifecycleState:AppLifecycleState.hidden
  /// didChangeAppLifecycleState:AppLifecycleState.paused
  /// didChangeAppLifecycleState:AppLifecycleState.detached  //多了一个detached
  /// ```
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    l.d('AppLifecycle didChangeAppLifecycleState:$state'..writeToLog());
    super.didChangeAppLifecycleState(state);
  }

  /// 低内存回调
  @override
  void didHaveMemoryPressure() {
    l.d('AppLifecycle didHaveMemoryPressure'..writeToLog());
    super.didHaveMemoryPressure();
  }

  @override
  void didChangeTextScaleFactor() {
    l.d('AppLifecycle didChangeTextScaleFactor'..writeToLog());
    super.didChangeTextScaleFactor();
  }

  @override
  Future<bool> didPushRoute(String route) {
    l.d('AppLifecycle didPushRoute:$route'..writeToLog());
    return super.didPushRoute(route);
  }

  @override
  Future<bool> didPopRoute() {
    l.d('AppLifecycle didPopRoute'..writeToLog());
    return super.didPopRoute();
  }
}

///
/// App的声明周期
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

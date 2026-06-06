part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/06/07
///
/// App生命周期混入, 使用[AppLifecycleListener]实现.
/// - [WidgetsBindingObserver]
/// - [AppLifecycleListener]
/// - [AppLifecycleStateMixin]
/// - [NavigatorObserverMixin]
mixin AppLifecycleStateMixin<T extends StatefulWidget> on State<T> {
  AgentAppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    _appLifecycleListener = AgentAppLifecycleListener(
      onShow: onAppLifecycleShow,
      onResume: onAppLifecycleResume,
      onHide: onAppLifecycleHide,
      onPause: onAppLifecyclePause,
      onStateChange: onAppLifecycleStateChange,
      //--
      onChangeMetrics: onAppChangeMetrics,
      onChangePlatformBrightness: onAppChangePlatformBrightness,
      onChangeTextScaleFactor: onAppChangeTextScaleFactor,
      onHaveMemoryPressure: onAppHaveMemoryPressure,
    );
    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  //---override

  /// [onAppLifecycleShow]->[onAppLifecycleResume]
  @overridePoint
  void onAppLifecycleShow() {
    assert(() {
      l.d('onAppLifecycleShow');
      return true;
    }());
  }

  /// 应用程序恢复
  /// - 从后台切回来
  /// - 从其它程序切回来
  /// [onAppLifecycleShow]
  @overridePoint
  void onAppLifecycleResume() {
    assert(() {
      l.d('onAppLifecycleResume');
      return true;
    }());
  }

  /// 应用程序处于后台时触发
  /// [onAppLifecycleHide]->[onAppLifecyclePause]
  @overridePoint
  void onAppLifecycleHide() {
    assert(() {
      l.d('onAppLifecycleHide');
      return true;
    }());
  }

  /// [onAppLifecyclePause]
  @overridePoint
  void onAppLifecyclePause() {
    assert(() {
      l.d('onAppLifecyclePause');
      return true;
    }());
  }

  ///[AppLifecycleState]
  @overridePoint
  void onAppLifecycleStateChange(AppLifecycleState state) {
    assert(() {
      //l.d('onAppLifecycleStateChange$state');
      return true;
    }());
  }

  //--

  @overridePoint
  void onAppHaveMemoryPressure() {}

  @overridePoint
  void onAppChangePlatformBrightness() {}

  @overridePoint
  void onAppChangeTextScaleFactor() {}

  @overridePoint
  void onAppChangeMetrics() {}
}

/// - [AppLifecycleLogMixin] 日志
class AgentAppLifecycleListener extends AppLifecycleListener {
  final VoidCallback? onChangeMetrics;
  final VoidCallback? onChangePlatformBrightness;
  final VoidCallback? onChangeTextScaleFactor;
  final VoidCallback? onHaveMemoryPressure;

  AgentAppLifecycleListener({
    WidgetsBinding? binding,
    super.onResume,
    super.onInactive,
    super.onHide,
    super.onShow,
    super.onPause,
    super.onRestart,
    super.onDetach,
    super.onExitRequested,
    super.onStateChange,
    this.onChangeMetrics,
    this.onChangePlatformBrightness,
    this.onChangeTextScaleFactor,
    this.onHaveMemoryPressure,
  });

  @override
  void handleCommitBackGesture() {}

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void handleCancelBackGesture() {}

  @override
  void didChangeViewFocus(ui.ViewFocusEvent event) {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  //--

  /// # leak_tracker: ^11.0.2
  /// 内存泄漏跟踪
  /// https://pub.dev/packages/leak_tracker
  /// # memory_usage: ^0.1.0
  /// 内存使用
  /// https://pub.dev/packages/memory_usage
  @override
  void didHaveMemoryPressure() {
    //当前内存占用
    final currentRss = ProcessInfo.currentRss;
    //最大内存占用
    final maxRss = ProcessInfo.maxRss;
    l.w("准备释放内存[${currentRss.toSizeStr()}/${maxRss.toSizeStr()}]...");
    onHaveMemoryPressure?.call();
  }

  @override
  void didChangePlatformBrightness() {
    onChangePlatformBrightness?.call();
  }

  @override
  void didChangeTextScaleFactor() {
    onChangeTextScaleFactor?.call();
  }

  ///屏幕旋转/尺寸改变后
  ///系统窗口改变回调 如键盘弹出 屏幕旋转等
  @override
  void didChangeMetrics() {
    onChangeMetrics?.call();
  }
}

//MARK: - NavigatorObserver

/// 路由导航监听, 为[NavigatorObserverMixin]提供功能支持
/// [NavigatorObserverDispatcher]
/// [NavigatorObserverMixin]
/// [AppLifecycleStateMixin]
final NavigatorObserverDispatcher navigatorObserverDispatcher =
    NavigatorObserverDispatcher();

/// 获取新的路由监听
NavigatorObserverDispatcher get navigatorObserverDispatcherGet =>
    NavigatorObserverDispatcher();

/// 路由回调派发
/// - [NavigatorObserverMixin]功能的提供者
class NavigatorObserverDispatcher extends NavigatorObserver {
  //region --观察者--

  final List<NavigatorObserverMixin> navigatorObserverList = [];

  @api
  void add(NavigatorObserverMixin? observer) {
    if (observer != null && !navigatorObserverList.contains(observer)) {
      navigatorObserverList.add(observer);

      //first
      if (_routeStack.isNotEmpty) {
        observer.onRouteStackChanged(_routeStack);
      }
    }
  }

  @api
  void remove(NavigatorObserverMixin? observer) {
    if (observer != null && navigatorObserverList.contains(observer)) {
      navigatorObserverList.remove(observer);
    }
  }

  //endregion --观察者--

  //region --回调--

  String? debugLabel;

  /// 路由栈数量
  final List<RouteInfo> _routeStack = [];

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _routeStack.remove(
      RouteInfo(route.settings, isPageRoute: route is PageRoute),
    );
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidPop(route, previousRoute);
        element.onRouteStackChanged(_routeStack);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    //debugger();
    _routeStack.add(RouteInfo(route.settings, isPageRoute: route is PageRoute));
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidPush(route, previousRoute);
        element.onRouteStackChanged(_routeStack);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _routeStack.remove(
      RouteInfo(route.settings, isPageRoute: route is PageRoute),
    );
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidRemove(route, previousRoute);
        element.onRouteStackChanged(_routeStack);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidReplace(newRoute: newRoute, oldRoute: oldRoute);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidStartUserGesture(route, previousRoute);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidStopUserGesture();
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    super.didChangeTop(topRoute, previousTopRoute);
    debugger(when: !isIos && debugLabel != null);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidChangeTop(topRoute, previousTopRoute);
      } catch (e) {
        assert(() {
          printError(e);
          return true;
        }());
      }
    }
  }

  //endregion --回调--
}

/// 路由信息, 包含路由类型, 路由设置
/// - [Route]
/// - [RouteSettings]
@immutable
class RouteInfo with EquatableMixin {
  final RouteSettings routeSettings;

  /// 是否是[PageRoute]
  final bool? isPageRoute;

  const RouteInfo(this.routeSettings, {this.isPageRoute});

  @override
  List<Object?> get props => [routeSettings];

  @override
  String toString() {
    return 'RouteInfo{isPageRoute: $isPageRoute, routeSettings: $routeSettings}';
  }
}

/// 导航监听混入, 需要将[navigatorObserverDispatcher]加入到导航观察者中.
/// 需要使用[NavigatorObserverDispatcher]监听观察导航事件
///
/// - [NavigatorObserverMixin]
/// - [NavigatorObserverLogMixin]
mixin NavigatorObserverMixin<T extends StatefulWidget> on State<T> {
  /// 当前的[ModalRoute]
  ModalRoute? currentModalRoute;

  /// 调试标签
  String? get debugLabel => null;

  /// 导航观察调度器
  NavigatorObserverDispatcher get navigatorObserverDispatcherMixin =>
      navigatorObserverDispatcher;

  @override
  void initState() {
    debugger(when: debugLabel != null);
    navigatorObserverDispatcherMixin.debugLabel = debugLabel;
    navigatorObserverDispatcherMixin.add(this);
    super.initState();
    /*postFrameCallback((_) {
      currentModalRoute = ModalRoute.of(context);
    });*/
  }

  @override
  void dispose() {
    navigatorObserverDispatcherMixin.remove(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentModalRoute = ModalRoute.of(context);
  }

  @overridePoint
  void onRouteDidPop(Route route, Route? previousRoute) {}

  @overridePoint
  void onRouteDidPush(Route route, Route? previousRoute) {}

  @overridePoint
  void onRouteDidRemove(Route route, Route? previousRoute) {}

  @overridePoint
  void onRouteDidReplace({Route? newRoute, Route? oldRoute}) {}

  @overridePoint
  void onRouteDidStartUserGesture(Route route, Route? previousRoute) {}

  @overridePoint
  void onRouteDidStopUserGesture() {}

  @overridePoint
  void onRouteDidChangeTop(Route topRoute, Route? previousTopRoute) {}

  //MARK: - override

  ///当路由栈发生改变时触发
  /// - 移除了路由
  /// - 添加了路由
  @overridePoint
  void onRouteStackChanged(List<RouteInfo> routeStack) {}
}

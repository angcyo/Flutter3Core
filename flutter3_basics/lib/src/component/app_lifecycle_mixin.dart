part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/06/07
///
/// App生命周期混入
/// [WidgetsBindingObserver]
/// [AppLifecycleListener]
/// [AppLifecycleMixin]
/// [NavigatorObserverMixin]
mixin AppLifecycleMixin<T extends StatefulWidget> on State<T> {
  AppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(
      onShow: onAppLifecycleShow,
      onResume: onAppLifecycleResume,
      onHide: onAppLifecycleHide,
      onPause: onAppLifecyclePause,
      onStateChange: onAppLifecycleStateChange,
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

  /// [onAppLifecycleShow]
  @overridePoint
  void onAppLifecycleResume() {
    assert(() {
      l.d('onAppLifecycleResume');
      return true;
    }());
  }

  /// [onAppLifecycleHide]->[onAppLifecyclePause]
  @overridePoint
  void onAppLifecycleHide() {
    assert(() {
      l.d('onAppLifecycleHide');
      return true;
    }());
  }

  /// [onAppLifecycleHide]
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
    //l.d('onAppLifecycleStateChange$state');
  }
}

//---

/// 路由导航监听
/// [NavigatorObserverDispatcher]
/// [NavigatorObserverMixin]
/// [AppLifecycleMixin]
final NavigatorObserverDispatcher navigatorObserverDispatcher =
    NavigatorObserverDispatcher();

/// 路由回调派发
class NavigatorObserverDispatcher extends NavigatorObserver {
  final List<NavigatorObserverMixin> navigatorObserverList = [];

  void add(NavigatorObserverMixin observer) {
    navigatorObserverList.add(observer);
  }

  void remove(NavigatorObserverMixin observer) {
    navigatorObserverList.remove(observer);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidPop(route, previousRoute);
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
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidPush(route, previousRoute);
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
    for (final element in navigatorObserverList) {
      try {
        element.onRouteDidRemove(route, previousRoute);
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
}

/// 导航监听混入
/// [NavigatorObserverDispatcher]
/// [NavigatorObserverMixin]
/// [NavigatorObserverLogMixin]
mixin NavigatorObserverMixin<T extends StatefulWidget> on State<T> {
  /// 当前的[ModalRoute]
  ModalRoute? currentModalRoute;

  @override
  void initState() {
    navigatorObserverDispatcher.add(this);
    super.initState();
    postFrameCallback((_) {
      currentModalRoute = ModalRoute.of(context);
    });
  }

  @override
  void dispose() {
    navigatorObserverDispatcher.remove(this);
    super.dispose();
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
}

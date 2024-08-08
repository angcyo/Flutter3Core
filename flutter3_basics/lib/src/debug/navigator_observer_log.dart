part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/09
///

/// [Navigator]
/// [RouteObserver].[RouteAware] 路由感知
/// ```
/// final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
/// ```
/// [NavigatorObserverDispatcher]
/// [NavigatorObserverMixin]
mixin NavigatorObserverLogMixin on NavigatorObserver {
  /// 弹出路由[route]
  /// [previousRoute] 之前的路由
  /// [MaterialPageRoute]
  /// [RouteSettings]
  @override
  void didPop(Route route, Route? previousRoute) {
    l.v('[${classHash()}]Navigator didPop↓\npop->$route\nold->$previousRoute');
  }

  /// 推入新路由[route]
  /// [previousRoute] 之前的路由
  /// [MaterialPageRoute]
  /// [RouteSettings]
  @override
  void didPush(Route route, Route? previousRoute) {
    l.v('[${classHash()}]Navigator didPush↓\nold->$previousRoute\npush->$route');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    l.v('[${classHash()}]Navigator didRemove↓\n$route\n$previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    l.v('[${classHash()}]Navigator didReplace:$newRoute $oldRoute');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    l.v('[${classHash()}]Navigator didStartUserGesture↓\n$route\n$previousRoute');
  }

  @override
  void didStopUserGesture() {
    l.v('[${classHash()}]Navigator didStopUserGesture');
  }
}

/// [NavigatorObserverLogMixin]的实现类
class NavigatorObserverLog extends NavigatorObserver
    with NavigatorObserverLogMixin {}

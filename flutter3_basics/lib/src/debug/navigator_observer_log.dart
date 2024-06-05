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
mixin NavigatorObserverLogMixin on NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    l.v('Navigator didPop↓\npop->$route\nold->$previousRoute');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    l.v('Navigator didPush↓\nold->$previousRoute\npush->$route');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    l.v('Navigator didRemove↓\n$route\n$previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    l.v('Navigator didReplace:$newRoute $oldRoute');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    l.v('Navigator didStartUserGesture↓\n$route\n$previousRoute');
  }

  @override
  void didStopUserGesture() {
    l.v('Navigator didStopUserGesture');
  }
}

/// [NavigatorObserverLogMixin]的实现类
class NavigatorObserverLog extends NavigatorObserver
    with NavigatorObserverLogMixin {}

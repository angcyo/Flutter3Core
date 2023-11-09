part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/09
///

mixin NavigatorObserverLogMixin on NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    l.d('Navigator didPop↓\n$route\n$previousRoute');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    l.d('Navigator didPush↓\n$route\n$previousRoute');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    l.d('Navigator didRemove↓\n$route\n$previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    l.d('Navigator didReplace:$newRoute $oldRoute');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    l.d('Navigator didStartUserGesture↓\n$route\n$previousRoute');
  }

  @override
  void didStopUserGesture() {
    l.d('Navigator didStopUserGesture');
  }
}

class NavigatorObserverLog extends NavigatorObserver
    with NavigatorObserverLogMixin {}

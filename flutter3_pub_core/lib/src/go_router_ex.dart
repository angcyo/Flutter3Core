part of "../flutter3_pub_core.dart";

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/27
///
/// [GoRouterHelper]
extension GoRouterEx on BuildContext {
  /// 整体路由的控制
  /// [RouterConfig]->[GoRouter]
  /// [GoRouter.routerDelegate]
  /// [GoRouter.go]
  GoRouter get goRouter => GoRouter.of(this);

  /// 当路由的状态
  /// [GoRouterState]
  ///
  /// [GoRouterStateRegistryScope]
  GoRouterState get goRouterState => GoRouterState.of(this);

  /// [goRouterState]
  GoRouterState? get goRouterStateOrNull {
    ModalRoute<Object?>? route;
    BuildContext context = this;
    /*GoRouterStateRegistryScope? scope;*/
    int count = 5;
    while (count-- > 0) {
      route = ModalRoute.of(context);
      if (route == null) {
        return null;
      }
      final RouteSettings settings = route.settings;
      if (settings is Page<Object?>) {
        final key = settings.key;
        if (key is ValueKey) {
          //GoRouter 里面这里会是 ["/xxx"]
          if (key.value?.toString().startsWith("/") == true) {
            return context.goRouterState;
          }
        }
      }
      final NavigatorState? state = Navigator.maybeOf(context);
      if (state == null) {
        return null;
      }
      context = state.context;
    }
    return null;
  }

  /// 当前路由下, 是否可以返回[GoRouter.pop]
  /// [GoRouter.of(context).pop]
  bool get goRouterCanPop {
    final RouteMatchList currentConfiguration =
        goRouter.routerDelegate.currentConfiguration;
    final RouteMatch lastMatch = currentConfiguration.last;
    final Uri location = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches.uri
        : currentConfiguration.uri;
    final bool canPop = location.pathSegments.length > 1;
    return canPop;
  }
}

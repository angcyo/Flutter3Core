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

  //--

  /// 复制自[GoRouterHelper] `14.8.1`, 仅做了重命名.
  ///
  /// Get a location from route name and parameters.
  ///
  /// This method can't be called during redirects.
  @Alias("namedLocation")
  String goNamedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    String? fragment,
  }) =>
      GoRouter.of(this).namedLocation(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          fragment: fragment);

  /// Navigate to a location.
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) =>
      GoRouter.of(this).goNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra,
          fragment: fragment);

  /// Push a location onto the page stack.
  ///
  /// See also:
  /// * [pushReplacement] which replaces the top-most page of the page stack and
  ///   always uses a new page key.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  @Alias("push")
  Future<T?> goPush<T extends Object?>(String location, {Object? extra}) =>
      GoRouter.of(this).push<T>(location, extra: extra);

  /// Navigate to a named route onto the page stack.
  @Alias("pushNamed")
  Future<T?> goPushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushNamed<T>(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  /// Returns `true` if there is more than 1 page on the stack.
  @Alias("canPop")
  bool goCanPop() => GoRouter.of(this).canPop();

  /// Pop the top page off the Navigator's page stack by calling
  /// [Navigator.pop].
  @Alias("pop")
  void goPop<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the given location onto the page stack.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  @Alias("pushReplacement")
  void goPushReplacement(String location, {Object? extra}) =>
      GoRouter.of(this).pushReplacement(location, extra: extra);

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', pathParameters={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  @Alias("pushReplacementNamed")
  void goPushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).pushReplacementNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        extra: extra,
      );

  /// Replaces the top-most page of the page stack with the given one but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  /// * [pushReplacement] which replaces the top-most page of the page stack but
  ///   always uses a new page key.
  @Alias("replace")
  void goReplace(String location, {Object? extra}) =>
      GoRouter.of(this).replace<Object?>(location, extra: extra);

  /// Replaces the top-most page with the named route and optional parameters,
  /// preserving the page key.
  ///
  /// This will preserve the state and not run any page animation. Optional
  /// parameters can be provided to the named route, e.g. `name='person',
  /// pathParameters={'fid': 'f2', 'pid': 'p1'}`.
  ///
  /// See also:
  /// * [pushNamed] which pushes the given location onto the page stack.
  /// * [pushReplacementNamed] which replaces the top-most page of the page
  ///   stack but always uses a new page key.
  @Alias("replaceNamed")
  void goReplaceNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      GoRouter.of(this).replaceNamed<Object?>(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          extra: extra);
}

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

  /// 获取当前路由的[Uri]
  Uri get goRouterUri => goRouterState.uri;

  /// 获取当前路由路径
  String get goRouterPath => goRouterUri.path;

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
  }) => GoRouter.of(this).namedLocation(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    fragment: fragment,
  );

  /// Navigate to a location.
  void go(String location, {Object? extra}) => location.go(this, extra: extra);

  /// Navigate to a named route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) => GoRouter.of(this).goNamed(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
    fragment: fragment,
  );

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
  }) => GoRouter.of(this).pushNamed<T>(
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
  }) => GoRouter.of(this).pushReplacementNamed(
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
  }) => GoRouter.of(this).replaceNamed<Object?>(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );
}

extension GoRouterStringEx on String {
  /// Go
  void go(BuildContext context, {Object? extra}) =>
      GoRouter.of(context).go(this, extra: extra);

  /// 判断当前路由是否是[this]
  bool isCurrentRoute(BuildContext context) => startsWith(context.goRouterPath);
}

extension GoRouterWidgetEx on Widget {
  /// 创建 [GoRoute], 支持路由动画[TranslationTypeMixin]
  GoRoute toGoRoute(String path, {String? name}) {
    final child = this;
    return GoRoute(
      path: path,
      name: name,
      builder: (ctx, state) => child,
      pageBuilder: (ctx, state) {
        final route = child.toRoute();
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionsBuilder:
              (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                //l.d("[${child.hash()}]animation:$animation");
                //l.v("[${child.hash()}]secondaryAnimation:$secondaryAnimation");
                return route.buildTransitions(
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                );
                /*return ZoomPageTransitionsBuilder().buildTransitions(
                          context.pageRoute!,
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        );*/
              },
        );
      },
    );
  }
}

/// 创建 [GoRouter] 应用的路由配置。
/// - [GoRouter] <- [RouterConfig]
///   - [GoRoute] <- [RouteBase]
///   - [ShellRoute] <- [ShellRouteBase] <- [RouteBase]
GoRouter goRouter(
  List<RouteBase> routes, {
  List<NavigatorObserver>? observers,
  GlobalKey<NavigatorState>? navigatorKey,
  GoRouterRedirect? redirect,
  //--
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: routes,
    observers: [
      ...?observers,
      lifecycleNavigatorObserver,
      navigatorObserverDispatcher,
      NavigatorObserverLog(),
    ],
    debugLogDiagnostics: isDebug,
    navigatorKey: navigatorKey ?? GlobalConfig.def.rootNavigatorKey,
    /*errorBuilder: (ctx, state) {
      debugger();
      state.error;
      throw Exception("[${state.uri}]${state.error}");
    },*/
    /*errorPageBuilder: (ctx, state) {
      debugger();
      state.error;
      throw Exception("[${state.uri}]${state.error}");
    },*/
    redirect:
        redirect ??
        (initialLocation == null
            ? null
            : (ctx, state) {
                /*l.w(
                  "路由重定向->${state.uri} name:${state.name} path:${state.path}",
                );*/
                if (state.matchedLocation == "/") {
                  //debugger();
                  return initialLocation;
                }
                return null;
              }),
  );
}

/// 创建 [GoRoute] 具体的路由导航项
/// - [路由动画](https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html)
/// - [MaterialPage]
GoRoute goRoute(
  String path, {
  //--
  Widget? child,
  TranslationType? translationType,
  //--
  GoRouterWidgetBuilder? builder,
  GoRouterPageBuilder? pageBuilder,
  //--
  String? name,
  GlobalKey<NavigatorState>? parentNavigatorKey,
  List<RouteBase>? routes,
}) {
  translationType ??=
      child?.getWidgetTranslationType() ??
      (isDesktopOrWeb ? TranslationType.fade : null);
  return GoRoute(
    path: path,
    name: name,
    parentNavigatorKey: parentNavigatorKey,
    builder: child == null ? builder : (ctx, state) => child,
    routes: routes ?? const <RouteBase>[],
    pageBuilder: translationType == null
        ? pageBuilder
        : (ctx, state) {
            final buildChild = builder?.call(ctx, state);
            final route =
                child?.toRoute() ??
                translationType!.toRoute((ctx) => buildChild!);

            final body = child ?? buildChild ?? empty;
            return CustomTransitionPage(
              key: state.pageKey,
              child: body,
              transitionsBuilder:
                  (
                    BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child,
                  ) {
                    //l.d("[${child.hash()}]animation:$animation");
                    //l.v("[${child.hash()}]secondaryAnimation:$secondaryAnimation");
                    return route.buildTransitions(
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    );
                    /*return ZoomPageTransitionsBuilder().buildTransitions(
                          context.pageRoute!,
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        );*/
                  },
            );
          },
  );
}

/// 使用 [GoRouter] 创建 [MaterialApp]
/// https://pub.dev/packages/go_router
/// https://pub.dev/documentation/go_router/latest/topics/Get%20started-topic.html
///
/// - [routerConfig] 路由配置
///   `class GoRouter implements RouterConfig<RouteMatchList>`
///
/// ## Child routes  子路由
///   https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
/// - [GoRoute]
///
/// ```
/// GoRoute(
///   path: '/',
///   builder: (context, state) {
///     return HomeScreen();
///   },
///   routes: [
///     GoRoute(
///       path: 'details',
///       builder: (context, state) {
///         return DetailsScreen();
///       },
///     ),
///   ],
/// )
/// ```
///
/// ## Nested navigation  嵌套导航
///   https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
/// - [ShellRoute]
///   https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/shell_route.dart
///
/// ```
/// ShellRoute(
///   builder:
///       (BuildContext context, GoRouterState state, Widget child) {
///     return Scaffold(
///       body: child,
///       /* ... */
///       bottomNavigationBar: BottomNavigationBar(
///       /* ... */
///       ),
///     );
///   },
///   routes: <RouteBase>[
///     GoRoute(
///       path: 'details',
///       builder: (BuildContext context, GoRouterState state) {
///         return const DetailsScreen();
///       },
///     ),
///   ],
/// ),
/// ```
///
/// ## 路由动画
/// https://pub.dev/documentation/go_router/latest/topics/Transition%20animations-topic.html
///
/// - [MaterialApp]
/// - [MaterialApp.router]
/// - [CupertinoApp.router]
Widget goRouterApp({
  //--
  @defInjectMark GoRouter? routerConfig,
  //--
  List<RouteBase>? routes,
  List<NavigatorObserver>? observers,
  GlobalKey<NavigatorState>? navigatorKey,
  GoRouterRedirect? redirect,
  String? initialLocation,
  //--
  String? title,
  GenerateAppTitle? onGenerateTitle,
  TransitionBuilder? builder /*这里的 context 获取不到 Overlay*/,
  //--
  Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  Iterable<Locale>? supportedLocales,
}) {
  //路由
  return MaterialApp.router(
    routerConfig:
        routerConfig ??
        goRouter(
          routes!,
          observers: observers,
          navigatorKey: navigatorKey,
          redirect: redirect,
          initialLocation: initialLocation,
        ),
    //--
    title: title,
    onGenerateTitle: onGenerateTitle,
    theme: GlobalConfig.def.themeData,
    locale: GlobalConfig.def.locale,
    themeMode: GlobalConfig.def.themeMode,
    builder: builder,
    //--
    localizationsDelegates: [
      ...?localizationsDelegates,
      LibRes.delegate, // 必须
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    //http://www.lingoes.net/en/translator/langcode.htm
    supportedLocales: [
      /*...LibRes.delegate.supportedLocales,*/
      ...?supportedLocales,
      //可以不需要
      const Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      const Locale('en', 'US'),
    ],
    //--
  );
}

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/13
///
/// 导航相关
//region 导航相关

/// 路由动画
/// [DialogPageRoute] 对话框路由, 动画
///
/// [RouteWidgetEx.toRoute] 路由动画
/// [DialogExtensionEx.showDialog] 对话框
/// [showDialogWidget]
///
/// [showDialog]
enum TranslationType {
  /// 无动画
  none,

  /// 默认动画
  def,

  /// [MaterialPageRoute]
  material,

  /// [CupertinoPageRoute]
  cupertino,

  /// [FadePageRoute]
  fade,

  /// [SlidePageRoute]
  slide,

  /// [ScalePageRoute]
  scale,

  /// [ScalePageRoute]
  scaleFade(withFade: true),

  /// [TranslationPageRoute]
  translation(withTranslation: true),

  /// [TranslationPageRoute]
  translationTopToBottom(withTranslation: true, withTopToBottom: true),

  /// [TranslationPageRoute]
  translationFade(withTranslation: true, withFade: true),

  /// [ZoomPageRoute]
  /// [ZoomPageTransitionsBuilder]
  zoom;

  const TranslationType({
    this.withTranslation = false,
    this.withFade = false,
    this.withTopToBottom = false,
  });

  final bool withTranslation;
  final bool withFade;
  final bool withTopToBottom;

  /// [MaterialPageRoute]
  /// [CupertinoPageRoute]
  ///
  /// [MaterialPage]
  /// [PageTransitionsBuilder]
  /// [ZoomPageTransitionsBuilder]
  ///
  ModalRoute<T> toRoute<T>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    TranslationType? type,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) {
    final type = this;
    dynamic targetRoute;
    switch (type) {
      case TranslationType.none:
        targetRoute = PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        );
        break;
      case TranslationType.cupertino:
        targetRoute = CupertinoPageRoute(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.fade:
        targetRoute = FadePageRoute(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.slide:
        targetRoute = SlidePageRoute(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.scale:
      case TranslationType.scaleFade:
        targetRoute = ScalePageRoute(
          fade: type.withFade == true,
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.zoom:
        targetRoute = ZoomPageRoute(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      case TranslationType.translation:
      case TranslationType.translationTopToBottom:
      case TranslationType.translationFade:
        targetRoute = TranslationPageRoute(
          fade: type.withFade == true,
          topToBottom: type.withTopToBottom == true,
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
      default:
        targetRoute = MaterialPageRoute(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          allowSnapshotting: allowSnapshotting,
          barrierDismissible: barrierDismissible,
        );
        break;
    }
    return targetRoute;
  }
}

/// 过渡动画类型
///
/// [NavigatorStateDialogEx.showWidgetDialog]
///
/// [DialogMixin]
/// `mixin DialogMixin implements TranslationTypeImpl`
///
/// [RouteWidgetEx.getWidgetDialogBarrierDismissible]
class TranslationTypeImpl {
  /// [Dialog]对话框外点击是否关闭
  /// [DialogPageRoute]
  bool get dialogBarrierDismissible => true;

  /// [Dialog]对话框背景色 [Colors.black54]
  ///
  /// - [Colors.transparent] 可以指定透明颜色
  ///
  @defInjectMark
  Color? get dialogBarrierColor => null;

  /// [Dialog]对话框路径是否使用根导航器
  bool get dialogUseRootNavigator => true;

  /// [TranslationType]
  /// [DialogPageRoute]
  TranslationType get translationType => TranslationType.material;
}

/// [DialogMixin]
/// [TranslationTypeImpl]
mixin TranslationTypeMixin implements TranslationTypeImpl {
  /// 对话框外点击是否关闭
  @override
  bool get dialogBarrierDismissible => true;

  @override
  Color? get dialogBarrierColor => null;

  @override
  bool get dialogUseRootNavigator => true;

  /// 对话框路径过度动画
  @override
  TranslationType get translationType {
    final type = runtimeType.toString().toLowerCase();
    //debugger();
    if (type.isScreenName) {
      return TranslationType.translation;
    }
    return TranslationType.translationFade;
  }
}

/// [TranslationTypeImpl]
/// - 路由小部件扩展
///
/// - [RouteWidgetEx]
/// - [NavigatorWidgetEx]
extension RouteWidgetEx on Widget {
  /// 获取[Widget]的指定的过渡动画类型
  TranslationType? getWidgetTranslationType({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    if (this is TranslationTypeImpl) {
      return (this as TranslationTypeImpl).translationType;
    } else if (this is SingleChildRenderObjectWidget) {
      final child = (this as SingleChildRenderObjectWidget).child;
      if (child != null) {
        return child.getWidgetTranslationType(depth: depth - 1);
      }
    } else {
      try {
        final child = (this as dynamic).child;
        if (child is Widget) {
          return child.getWidgetTranslationType(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  /// 获取[Widget]的指定的障碍区域点击可销毁
  bool? getWidgetDialogBarrierDismissible({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    if (this is TranslationTypeImpl) {
      return (this as TranslationTypeImpl).dialogBarrierDismissible;
    } else if (this is SingleChildRenderObjectWidget) {
      final child = (this as SingleChildRenderObjectWidget).child;
      if (child != null) {
        return child.getWidgetDialogBarrierDismissible(depth: depth - 1);
      }
    } else {
      try {
        final child = (this as dynamic).child;
        if (child is Widget) {
          return child.getWidgetDialogBarrierDismissible(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  /// 获取[Widget]的指定的障碍区域颜色
  Color? getWidgetDialogBarrierColor({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    if (this is TranslationTypeImpl) {
      return (this as TranslationTypeImpl).dialogBarrierColor;
    } else if (this is SingleChildRenderObjectWidget) {
      final child = (this as SingleChildRenderObjectWidget).child;
      if (child != null) {
        return child.getWidgetDialogBarrierColor(depth: depth - 1);
      }
    } else {
      try {
        final child = (this as dynamic).child;
        if (child is Widget) {
          return child.getWidgetDialogBarrierColor(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  /// 获取[Widget]的路由使用情况
  bool? getWidgetDialogUseRootNavigator({int depth = 3}) {
    if (depth <= 0) {
      return null;
    }
    if (this is TranslationTypeImpl) {
      return (this as TranslationTypeImpl).dialogUseRootNavigator;
    } else if (this is SingleChildRenderObjectWidget) {
      final child = (this as SingleChildRenderObjectWidget).child;
      if (child != null) {
        return child.getWidgetDialogUseRootNavigator(depth: depth - 1);
      }
    } else {
      try {
        final child = (this as dynamic).child;
        if (child is Widget) {
          return child.getWidgetDialogUseRootNavigator(depth: depth - 1);
        }
      } catch (e, s) {
        /*assert(() {
          printError(e, s);
          return true;
        }());*/
      }
    }
    return null;
  }

  /// [MaterialPageRoute]
  /// [CupertinoPageRoute]
  ///
  /// [MaterialPage]
  /// [PageTransitionsBuilder]
  /// [ZoomPageTransitionsBuilder]
  ///
  ModalRoute<T> toRoute<T>({
    RouteSettings? settings,
    TranslationType? type,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
    bool barrierDismissible = false,
  }) {
    type ??= getWidgetTranslationType() ?? TranslationType.def;
    return type.toRoute(
      (ctx) => this,
      settings: settings,
      type: type,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      barrierDismissible: barrierDismissible,
    );
  }
}

/// - 导航小部件扩展
///
/// - [RouteWidgetEx]
/// - [NavigatorWidgetEx]
extension NavigatorWidgetEx on Widget {
  /// 将当前小部件转换成路由, 并且放在导航的路由栈中
  /// - [home] 指定首页, 不指定则就是[this]
  /// - [onGenerateRoute] 路由生成器[RouteSettings]
  Widget navigator({
    Key? key,
    Widget? home,
    RouteFactory? onGenerateRoute,
    List<NavigatorObserver>? observers,
    NavigatorObserverMixin? navigatorObserver,
    //--
    String? debugLabel,
  }) {
    return Navigator(
      key: key,
      initialRoute: Navigator.defaultRouteName,
      /*transitionDelegate: NoTransitionDelegate(),*/
      observers: [
        /*navigatorObserverDispatcher,*/
        NavigatorObserverDispatcher()
          ..debugLabel = debugLabel
          ..add(navigatorObserver),
        NavigatorObserverLog(),
        ...?observers,
      ],
      onGenerateRoute: (settings) {
        return onGenerateRoute?.call(settings) ??
            /*PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  home ?? this,
            );*/
            MaterialPageRoute(
              settings: settings,
              builder: (context) => home ?? this,
            );
      },
      onUnknownRoute: isDebug
          ? (settings) {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => "onUnknownRoute->$settings".text(),
              );
            }
          : null,
      onDidRemovePage: isDebug
          ? (route) {
              l.d("onDidRemovePage->$route");
            }
          : null,
    );
  }
}

/// 导航扩展
///使用 ModalRoute.of(context).settings.arguments; 获取参数
extension NavigatorEx on BuildContext {
  //--NavigatorState↓

  /// 从上往下查找 [NavigatorState]
  /// [Navigator.of]
  NavigatorState? findNavigatorState() {
    var element = findElementOfWidget<Navigator>();
    if (element is StatefulElement) {
      return element.state as NavigatorState;
    }
    return null;
  }

  /// 当前路由是否是根路由
  bool get isInRootNavigator => navigatorOf(false) == navigatorOf(true);

  //---Route↓

  /// 获取当前路由
  /// [Route]
  /// [OverlayRoute]
  /// [TransitionRoute]
  /// [ModalRoute]
  ModalRoute? get modalRoute => ModalRoute.of(this);

  /// [ModalRoute] -> [PageRoute]
  /// [ModalRoute] -> [PopupRoute]
  PageRoute? get pageRoute {
    final route = modalRoute;
    return route is PageRoute ? route : null;
  }

  /// [ModalRoute.settingsOf]
  RouteSettings? get routeSettings => modalRoute?.settings;

  /// 路由处于活跃状态
  bool get isRouteActive => modalRoute?.isActive ?? false;

  /// 是否是第一个路由
  bool get isRouteFirst => modalRoute?.isFirst ?? false;

  /// 是否是最上面的路由
  bool get isRouteCurrent => modalRoute?.isCurrent ?? false;

  /// 是否要显示返回按键, 路由页面下面是否还有活动的路由
  /// [Route.hasActiveRouteBelow]
  bool get isAppBarDismissal => modalRoute?.impliesAppBarDismissal ?? false;

  /// 获取导航元素的上下文
  BuildContext? get navigatorContext => navigatorOf().buildContext;

  /// 获取一个导航器[NavigatorState]
  NavigatorState navigatorOf([bool rootNavigator = false]) =>
      Navigator.of(this, rootNavigator: rootNavigator);

  /// 获取导航中的所有页面
  List<Page<dynamic>>? getRoutePages({bool rootNavigator = false}) {
    return navigatorOf(rootNavigator).getRoutePages();
  }

  //---push↓

  /// 推送一个路由
  /// 与`go_router`中的扩展命名冲突
  /// [popTop] 是否弹出之前的顶层
  /// [toRoot] 是否直接跳到顶层, 移除之前所有路由
  Future<T?> push<T extends Object?>(
    Route<T> route, {
    bool rootNavigator = false,
    bool popTop = false,
    bool toRoot = false,
    bool removeAll = false,
  }) {
    final navigator = navigatorOf(rootNavigator);
    if (toRoot || removeAll) {
      //debugger();
      return navigator.pushAndRemoveToRoot(route, removeAll: removeAll);
    } else {
      if (popTop) {
        navigator.pop();
      }
      return navigator.push(route);
    }
  }

  /// 命名冲突
  Future<T?> pushRoute<T extends Object?>(
    Route<T> route, {
    bool rootNavigator = false,
    bool popTop = false,
    bool toRoot = false,
  }) =>
      push(route, rootNavigator: rootNavigator, popTop: popTop, toRoot: toRoot);

  /// 支持路由动画
  /// [popTop] 是否弹出之前的顶层
  /// [push]
  Future<T?> pushWidget<T extends Object?>(
    Widget page, {
    String? routeName,
    RouteSettings? settings,
    TranslationType? type,
    bool rootNavigator = false,
    bool popTop = false,
    bool toRoot = false,
    bool removeAll = false,
  }) {
    return push(
      page.toRoute(
        type: type,
        settings:
            settings ??
            (routeName != null ? RouteSettings(name: routeName) : null),
      ),
      rootNavigator: rootNavigator,
      popTop: popTop,
      toRoot: toRoot,
      removeAll: removeAll,
    );
  }

  /// 推送一个路由, 并且移除之前的路由
  Future<T?> pushReplacement<T extends Object?>(
    Route<T> route, {
    bool rootNavigator = false,
    dynamic result,
  }) {
    return navigatorOf(rootNavigator).pushReplacement(route, result: result);
  }

  /// [pushReplacement]
  Future<T?> pushReplacementWidget<T extends Object?>(
    Widget page, {
    String? routeName,

    RouteSettings? settings,
    TranslationType? type,
    bool rootNavigator = false,
  }) {
    return pushReplacement(
      page.toRoute(
        type: type,
        settings:
            settings ??
            (routeName != null ? RouteSettings(name: routeName) : null),
      ),
      rootNavigator: rootNavigator,
    );
  }

  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRootWidget<T extends Object?>(
    Widget page, {
    String? routeName,

    RouteSettings? settings,
    TranslationType? type,
    RoutePredicate? predicate,
    bool rootNavigator = false,
  }) {
    var root = ModalRoute.withName('/');
    return navigatorOf(rootNavigator).pushAndRemoveUntil(
      page.toRoute(
        type: type,
        settings:
            settings ??
            (routeName != null ? RouteSettings(name: routeName) : null),
      ),
      predicate ?? root,
    );
  }

  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRoot<T extends Object?>(
    Route<T> route, {
    RoutePredicate? predicate,
    bool rootNavigator = false,
  }) {
    var root = ModalRoute.withName('/');
    return navigatorOf(
      rootNavigator,
    ).pushAndRemoveUntil(route, predicate ?? root);
  }

  //---pop↓

  /// 是否可以弹出一个路由
  /// [checkDismissal] 是否检测弹出最后一个根路由
  bool canPop({bool rootNavigator = false, bool checkDismissal = true}) {
    if (!checkDismissal || (checkDismissal && isAppBarDismissal)) {
      return navigatorOf(rootNavigator).canPop();
    } else {
      return false;
    }
  }

  /// 弹出一个路由, 不能被[PopScope]拦截.
  ///
  /// 与`go_router`中的扩展命名冲突
  /// - [rootNavigator] 是否使用根导航器
  /// - [checkDismissal] 是否弹出检测, 保留最后一个根路由页面.
  ///
  /// - [isAppBarDismissal]
  void pop<T extends Object?>({
    T? result,
    bool rootNavigator = false,
    bool checkDismissal = true,
  }) {
    //debugger();
    if (!checkDismissal || (checkDismissal && isAppBarDismissal)) {
      navigatorOf(rootNavigator).pop(result);
    }
  }

  /// 别名, 和go路由命名冲突
  @alias
  void popRoute<T extends Object?>({
    T? result,
    bool rootNavigator = false,
    bool checkDismissal = true,
  }) => pop(
    result: result,
    rootNavigator: rootNavigator,
    checkDismissal: checkDismissal,
  );

  /// 弹出一个菜单路由
  void popDialog<T extends Object?>([
    T? result,
    bool rootNavigator = false,
    bool checkDismissal = false,
  ]) => pop(
    result: result,
    rootNavigator: rootNavigator,
    checkDismissal: checkDismissal,
  );

  /// 弹出一个菜单路由
  @alias
  void popMenu<T extends Object?>([
    T? result,
    bool rootNavigator = false,
    bool checkDismissal = false,
  ]) => pop(
    result: result,
    rootNavigator: rootNavigator,
    checkDismissal: checkDismissal,
  );

  /// 尝试弹出一个路由, 可以被[PopScope]拦截
  Future<bool> maybePop<T extends Object?>({
    T? result,
    bool rootNavigator = false,
    bool checkDismissal = true,
  }) async {
    //debugger();
    if (!checkDismissal || (checkDismissal && isAppBarDismissal)) {
      return navigatorOf(rootNavigator).maybePop(result);
    }
    return false;
  }

  /// [ModalRoute.withName('/login')]
  void popUntil<T extends Object?>(
    RoutePredicate predicate, [
    bool rootNavigator = false,
    bool checkDismissal = true,
  ]) {
    if (!checkDismissal || (checkDismissal && isAppBarDismissal)) {
      navigatorOf(rootNavigator).popUntil(predicate);
    }
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    bool rootNavigator = false,
  }) {
    return navigatorOf(
      rootNavigator,
    ).popAndPushNamed(routeName, arguments: arguments, result: result);
  }

  /// 弹出所有非指定的路由
  /// [RoutePredicate]
  void popToRoot([bool rootNavigator = false, RoutePredicate? predicate]) {
    navigatorOf(rootNavigator).popToRoot(predicate);
  }

  /// 移除当前路由
  @api
  void removeModalRoute<T extends Object?>({
    bool rootNavigator = false,
    T? result,
  }) {
    removeRouteIf(modalRoute, rootNavigator: rootNavigator, result: result);
  }

  /// 移除指定的路由
  /// - [route] 路由, 不指定则表示当前
  void removeRouteIf<T extends Object?>(
    Route<dynamic>? route, {
    bool rootNavigator = false,
    T? result,
  }) {
    navigatorOf(rootNavigator).removeRouteIf(route, result);
  }
}

extension NavigatorStateEx on NavigatorState {
  /// 获取导航中的所有页面
  List<Page<dynamic>>? getRoutePages() {
    return widget.pages;
  }

  //---push↓

  /// 支持路由动画
  /// - [toRoot]是否要移除之前所有的路由
  /// - [routeName] 路由名称
  ///
  /// - [push]
  Future<T?> pushWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    String? routeName,
    RouteSettings? settings,
    bool removeAll = false,
  }) {
    final route = page.toRoute<T>(
      type: type,
      settings:
          settings ??
          (routeName != null ? RouteSettings(name: routeName) : null),
    );
    if (removeAll) {
      return pushAndRemoveUntil(route, (route) => false);
    }
    return push(route);
  }

  /// [pushReplacement]
  Future<T?> pushReplacementWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    String? routeName,
    RouteSettings? settings,
  }) {
    return pushReplacement(
      page.toRoute(
        type: type,
        settings:
            settings ??
            (routeName != null ? RouteSettings(name: routeName) : null),
      ),
    );
  }

  /// 推送一个路由, 并移除之前除home之外的所有路由
  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRootWidget<T extends Object?>(
    Widget page, {
    TranslationType? type,
    RoutePredicate? predicate,
    String? routeName,

    RouteSettings? settings,
  }) {
    final root = ModalRoute.withName('/');
    return pushAndRemoveUntil(
      page.toRoute(
        type: type,
        settings:
            settings ??
            (routeName != null ? RouteSettings(name: routeName) : null),
      ),
      predicate ?? root,
    );
  }

  /// 推送一个路由, 并移除之前除home之外的所有路由
  /// [pushAndRemoveUntil]
  Future<T?> pushAndRemoveToRoot<T extends Object?>(
    Route<T> route, {
    bool removeAll = false,
    RoutePredicate? predicate,
  }) {
    final root = removeAll ? (route) => false : ModalRoute.withName('/');
    return pushAndRemoveUntil(route, predicate ?? root);
  }

  //---pop↓

  /// 是否可以弹出一个路由
  bool canPop() => this.canPop();

  /// 弹出一个路由
  void pop<T extends Object?>([T? result]) {
    this.pop(result);
  }

  /// 尝试弹出一个路由
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return this.maybePop(result);
  }

  /*void popUntil<T extends Object?>(RoutePredicate predicate) {
    popUntil(predicate);
  }*/

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return this.popAndPushNamed(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 弹出所有非指定的路由
  /// [RoutePredicate]
  void popToRoot([RoutePredicate? predicate]) {
    final root = ModalRoute.withName('/');
    popUntil(predicate ?? root);
  }

  /// 移除指定的路由
  void removeRouteIf<T extends Object?>([Route<dynamic>? route, T? result]) {
    if (route != null) {
      removeRoute(route, result);
    }
  }

  /// 移除指定名字的路由
  /// - 现将[name]上面的所有路由移除
  /// - 再移除自身
  void removeRouteByName(String name, [Object? result]) {
    final root = ModalRoute.withName(name);
    popUntil(root);
    pop(result);
  }

  /// [removeRoute]
  /// [removeRouteBelow]
  void testRoute() {
    //removeRoute(route)
    //removeRouteBelow(anchorRoute)
  }
}

//endregion 导航相关

/// 没有过度动画的[DefaultTransitionDelegate]
class NoTransitionDelegate<T> extends TransitionDelegate<T> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
    locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
    pageRouteToPagelessRoutes,
  }) {
    debugger();
    throw UnimplementedError();
  }
}

part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/06
///
/// 用来监听路由的变化, 当不是根路由时显示pop小部件, 用于弹出路由
///
/// - 需要注册路由观察者[routeBackObserver]
///
/// - [FloatBackActionWidget]
/// - [RouteBackWidget]
class RouteBackWidget extends StatefulWidget {
  /// 指定返回按键
  @defInjectMark
  final Widget? child;

  /// 导航器key
  final GlobalKey<NavigatorState>? navigatorKey;

  /// 是否是使用的子路由, 自动合并路由前缀key
  @defInjectMark
  final bool? isInSubNavigator;

  const RouteBackWidget({
    super.key,
    this.child,
    this.navigatorKey,
    this.isInSubNavigator,
  });

  @override
  State<RouteBackWidget> createState() => _RouteBackWidgetState();
}

/// - [RouteObserver]
///   - [RouteAware]
/// - [NavigatorObserverMixin]
class _RouteBackWidgetState extends State<RouteBackWidget>
    with NavigatorObserverMixin /*RouteAware*/ {
  /// 是否显示返回按键
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return FloatBackActionWidget(
      floatStyle: true,
      navigatorKey: widget.navigatorKey,
      child: widget.child,
    ).visible(visible: _visible);
  }

  //MARK: - NavigatorObserverMixin

  /*@override
  String? get debugLabel => "RouteBackWidgetState";*/

  @override
  NavigatorObserverDispatcher get navigatorObserverDispatcherMixin =>
      routeBackObserverDispatcher;

  @override
  void onRouteStackChanged(List<RouteInfo> routeStack) {
    //debugger();
    super.onRouteStackChanged(routeStack);
    /*final route1 = ModalRoute.of(
      widget.navigatorKey?.currentState?.overlay?.context ?? context,
    );
    final route2 = ModalRoute.of(
      widget.navigatorKey?.currentContext ?? context,
    );*/
    //final route3 = ModalRoute.of(context);
    //final impliesAppBarDismissal2 = route?.impliesAppBarDismissal;
    //debugger();

    final isInSubNavigator =
        widget.isInSubNavigator ??
        (widget.navigatorKey?.currentContext?.isInRootNavigator ??
                buildContext?.isInRootNavigator) ==
            false;

    // 相同前缀路由路径对应的路由数量
    final routePathCountMap = <String, int>{};
    String? lastKey;
    for (final route in routeStack) {
      if (route.isPageRoute == true) {
        final routeSettings = route.routeSettings;
        final routeName = routeSettings.name;
        String? routeFlag = routeName;
        if (routeName == null && routeSettings is Page) {
          final routeKey = routeSettings.key;
          if (routeKey is ValueKey) {
            final routeKeyValue = routeKey.value;
            if (routeKeyValue != null) {
              routeFlag = "$routeKeyValue";
            }
          }
        }

        if (routeFlag == null && isInSubNavigator) {
          routeFlag = lastKey;
        }
        //--
        if (routeFlag == null) {
          lastKey = "${nowTimestamp()}";
          routePathCountMap[lastKey] = 1;
        } else {
          final key = routePathCountMap.keys.findFirst(
            (e) => routeFlag == e || routeFlag?.startsWith("$e/") == true,
          );
          lastKey = key ?? routeFlag;
          if (key != null) {
            if (isInSubNavigator) {
              //合并子路由的主路径
              if (routeFlag.startsWith("$key/")) {
                routePathCountMap.remove(key);
                routePathCountMap[routeFlag] =
                    (routePathCountMap[routeFlag] ?? 0) + 1;
                lastKey = routeFlag;
              } else {
                routePathCountMap[key] = (routePathCountMap[key] ?? 0) + 1;
              }
            } else {
              routePathCountMap[key] = (routePathCountMap[key] ?? 0) + 1;
            }
          } else {
            routePathCountMap[routeFlag] = 1;
          }
        }
      }
    }
    _visible = isInSubNavigator
        ? (routePathCountMap[lastKey ?? ""] ?? 0) > 1
        : routePathCountMap.length > 1;
    updateState();
    //l.w("[RouteBackWidget]: $effectiveRouteCount");
  }

  //MARK: - RouteAware

  /*@override
  void didPop() {
    l.v('【Route 日志】: 当前页面被关闭销毁 (didPop)');
    debugger();
    super.didPop();
  }

  @override
  void didPopNext() {
    l.v('【Route 日志】: 顶层页面关闭，重新回到了当前页面 (didPopNext)');
    debugger();
    super.didPopNext();
  }

  @override
  void didPush() {
    l.v('【Route 日志】: 当前页面被打开 (didPush)');
    debugger();
    super.didPush();
  }

  @override
  void didPushNext() {
    l.v('【Route 日志】: 从当前页去往了新页面 (didPushNext)，当前页被盖住');
    debugger();
    super.didPushNext();
  }

  /// 元素的依赖关系发生改变, 比如parent不一样了.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugger();
    // 4. 订阅路由变化
    // 注意：ModalRoute.of(context) 必须是 PageRoute 才能被 RouteObserver 识别
    final route = ModalRoute.of(widget.navigatorKey?.currentContext ?? context);
    if (route is PageRoute) {
      routeBackObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 5. 极其重要：销毁时必须取消订阅，防止内存泄漏
    debugger();
    routeBackObserver.unsubscribe(this);
    super.dispose();
  }*/
}

/// 1. 定义全局的路由观察者
/// - 配置[RouteAware]一起使用, 只能感知当前路由的状态
/*final RouteObserver<ModalRoute<void>> routeBackObserver =
    RouteObserver<ModalRoute<void>>();*/
//final routeBackObserver = NavigatorObserverLog();

/// 导航观察调度器
final NavigatorObserverDispatcher routeBackObserverDispatcher =
    NavigatorObserverDispatcher();

/// 扩展方法
extension RouteBackWidgetEx on Widget {
  /// [RouteBackWidget]
  Widget routeBackWidget({
    Key? key,
    bool? floatStyle,
    Object? result,
    Widget? child,
    GlobalKey<NavigatorState>? navigatorKey,
  }) => [
    this,
    RouteBackWidget(
      key: key,
      /*floatStyle: floatStyle,
      result: result,*/
      navigatorKey: navigatorKey,
      child: child,
    ),
  ].stack()!;
}

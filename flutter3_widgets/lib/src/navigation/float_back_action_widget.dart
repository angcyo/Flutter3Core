part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/02/09
///
/// 浮动在左上角的导航back按钮小部件
/// - [FloatBackActionWidget] 只在当前页上使用
/// - [RouteBackWidget] 在所有路由上使用
class FloatBackActionWidget extends StatefulWidget {
  /// 是否要浮动, 否则一直显示. 在桌面端默认浮动显示
  /// - 浮动时: 鼠标悬停时, 显示; 鼠标离开时, 隐藏;
  @defInjectMark
  final bool? floatStyle;

  /// 返回结果
  final Object? result;

  /// 指定返回按键
  @defInjectMark
  final Widget? child;

  /// 指定body顶上的Context, 用来find导航器
  /// - 导航器在此Context下面
  final BuildContext? rootContext;

  /// 指定导航器key
  final GlobalKey<NavigatorState>? navigatorKey;

  /// 检查是否可以关闭
  final bool? checkDismissal;

  const FloatBackActionWidget({
    super.key,
    this.floatStyle,
    this.result,
    this.child,
    this.rootContext,
    this.navigatorKey,
    this.checkDismissal,
  });

  @override
  State<FloatBackActionWidget> createState() => _FloatBackActionWidgetState();
}

class _FloatBackActionWidgetState extends State<FloatBackActionWidget> {
  @override
  void initState() {
    super.initState();
    /*final navigator = widget.navigatorKey?.currentState;
    if (navigator != null) {
      final route = ModalRoute.of(navigator.context);
      l.w("route->[$route]${route?.impliesAppBarDismissal}");
    } else {
      l.w("route->null");
    }*/
  }

  @override
  void didUpdateWidget(covariant FloatBackActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //l.w("route->didUpdateWidget");
  }

  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    final forceNavigator = widget.navigatorKey?.currentState;
    final noForceNavigator =
        forceNavigator == null && widget.rootContext == null;
    //--
    Widget body =
        widget.child ??
        globalConfig.appBarDismissalBuilder(context, widget) ??
        Icon(
          Icons.arrow_back_ios_new,
          color: globalConfig.globalTheme.icoNormalColor,
        ).insets(all: kX);
    //--
    body = body
        .inkWellCircle(() {
          //debugger();
          //widget.navigatorKey?.currentState?.maybePop();
          final navigator =
              forceNavigator ?? widget.rootContext?.findNavigatorState();
          buildContext?.maybePop(
            navigator: navigator,
            rootNavigator: noForceNavigator,
            result: widget.result,
            checkDismissal: widget.checkDismissal ?? noForceNavigator,
          );
        })
        .card(
          shape: CircleBorder(),
          /*color: globalConfig.globalTheme.appBarBackgroundColor,*/
        );
    final isFloatStyle = widget.floatStyle ?? isDesktopOrWeb;
    if (isFloatStyle) {
      body = body.mouseHoverVisibility().mouseHoverProvider();
    }
    return body /*.visible(
      enable: forceNavigator != null,
      visible: forceNavigator?.canPop() == true,
    )*/;
  }
}

/// 扩展方法
extension FloatBackActionWidgetEx on Widget {
  /// 在主体上浮动一个[FloatBackActionWidget]路由返回按键
  /// - [floatStyle] 是否要强制浮动, 否则一直显示. 在桌面端默认浮动显示
  /// - [result] 路由pop返回结果
  Widget floatBackActionWidget({
    bool enable = true,
    Key? key,
    bool? floatStyle,
    Object? result,
    Widget? child,
    BuildContext? rootContext,
    GlobalKey<NavigatorState>? navigatorKey,
  }) => enable
      ? [
          this,
          FloatBackActionWidget(
            key: key,
            floatStyle: floatStyle,
            result: result,
            rootContext: rootContext,
            navigatorKey: navigatorKey,
            child: child,
          ),
        ].stack()!
      : this;
}

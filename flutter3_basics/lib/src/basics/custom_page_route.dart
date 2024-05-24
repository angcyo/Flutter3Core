part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/15
///

/// 一样的路由弹窗时的动画处理, 不一样的路由弹窗使用系统默认动画
/// 启动当前路由:
///  [didPush]->[didChangeNext]->[didChangePrevious]->[buildTransitions]->[buildPage]
/// 关闭当前路由:
///  [didPop]->[didComplete]->[buildTransitions]
/// 关闭上层路由:
///  [didPopNext]->[buildTransitions]->[buildPage]
mixin SameRouteTransitionMixin<T> on ModalRoute<T> {
  /// 是否pop相同的路由
  bool _isPopSameRoute = true;

  /// 是否启用二级动画
  /// 在[PopupRoute].[RawDialogRoute]路由中, 建议关闭
  bool _enableSecondaryAnimation = true;

  @override
  ui.Color? get barrierColor => super.barrierColor;

  @override
  Curve get barrierCurve => super.barrierCurve;

  @override
  bool get barrierDismissible => super.barrierDismissible;

  @override
  String? get barrierLabel => super.barrierLabel;

  @override
  bool get impliesAppBarDismissal => super.impliesAppBarDismissal;

  @override
  Widget buildModalBarrier() {
    return super.buildModalBarrier();
  }

  @override
  void didAdd() {
    debugger();
    super.didAdd();
  }

  /// 当前路由即将push
  @override
  TickerFuture didPush() {
    debugger();
    return super.didPush();
  }

  /// 当前路由即将发生变化
  /// [nextRoute] 下一个路由, 如果有; 如果没有, 则有可能是自身.
  @override
  void didChangeNext(Route? nextRoute) {
    var settings = this.settings;
    var setting = nextRoute?.settings;
    //debugger();
    _isPopSameRoute = nextRoute == null || nextRoute.runtimeType == runtimeType;
    super.didChangeNext(nextRoute);
  }

  /// 完成当前路由显示之后
  /// [previousRoute] 前一个路由
  @override
  void didChangePrevious(Route? previousRoute) {
    //debugger();
    super.didChangePrevious(previousRoute);
  }

  /// 即将完成pop
  @override
  void didComplete(T? result) {
    //debugger();
    super.didComplete(result);
  }

  /// 当前路由被移除之后
  /// [result] 移除时的返回值
  @override
  bool didPop(T? result) {
    //debugger();
    _isPopSameRoute = true;
    return super.didPop(result);
  }

  /// 当前路由上的[nextRoute]路由即将pop
  @override
  void didPopNext(Route nextRoute) {
    debugger();
    _isPopSameRoute = nextRoute.runtimeType == runtimeType;
    super.didPopNext(nextRoute);
  }

  @override
  void didReplace(Route? oldRoute) {
    debugger();
    super.didReplace(oldRoute);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    //debugger();
    return super.buildPage(context, animation, secondaryAnimation);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var settings = this.settings;
    //debugger();
    if (_isPopSameRoute) {
      return buildSameTransitions(context, animation, secondaryAnimation,
          child) /*.dataProvider(animation)*/;
    }
    return super
        .buildTransitions(context, animation, secondaryAnimation, child);
  }

  /// 需要实现的方法
  @protected
  Widget buildSameTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child);
}

/// https://api.flutter.dev/flutter/animation/Curves-class.html
/// 底部页面的动画如何控制?
/// 渐变路由动画
/// [PageRouteBuilder]
/// [MaterialPageRoute]
/// [PageTransitionsTheme]
class FadePageRoute<T> extends MaterialPageRoute<T>
    with SameRouteTransitionMixin<T> {
  FadePageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    bool enableSecondaryAnimation = true,
  }) {
    _enableSecondaryAnimation = enableSecondaryAnimation;
  }

  @override
  Widget buildSameTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    //logAnimation("Fade", animation, secondaryAnimation);
    //顶部进入动画
    final enter = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //底部退出动画
    final exit = Tween<double>(
      begin: 1,
      end: 0.8,
    ).chain(CurveTween(curve: Curves.easeIn)).animate(secondaryAnimation);
    return FadeTransition(
      opacity: enter,
      child: FadeTransition(
        opacity: exit,
        child: child,
      ),
    );
  }
}

/// 上下滑动路由动画
class TranslationPageRoute<T> extends MaterialPageRoute<T>
    with SameRouteTransitionMixin<T> {
  /// 通否同时激活透明渐隐动画
  final bool fade;

  /// 是否从上到下, 默认是从下到上
  final bool topToBottom;

  TranslationPageRoute({
    required super.builder,
    this.fade = true,
    this.topToBottom = false,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    bool enableSecondaryAnimation = true,
  }) {
    _enableSecondaryAnimation = enableSecondaryAnimation;
  }

  @override
  Widget buildSameTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    //debugger();
    //logAnimation("Translation", animation, secondaryAnimation);
    //l.d('child:$child');

    //进入动画
    final enter = Tween<Offset>(
      begin: topToBottom ? const Offset(0, -1) : const Offset(0, 1),
      end: topToBottom ? Offset.zero : Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //退出动画
    final exit = Tween<Offset>(
      begin: topToBottom ? Offset.zero : Offset.zero,
      end: topToBottom ? const Offset(0, -0.2) : const Offset(0, -0.2),
    ).chain(CurveTween(curve: Curves.easeIn)).animate(secondaryAnimation);

    final Widget slide;
    if (!_enableSecondaryAnimation) {
      slide = SlideTransition(
        position: enter,
        child: child,
      );
    } else {
      slide = SlideTransition(
        position: enter,
        child: SlideTransition(
          position: exit,
          child: child,
        ),
      );
    }

    if (fade) {
      return slide.fade(opacity: animation);
    }
    return slide;
  }
}

/// 左右滑动路由动画
class SlidePageRoute<T> extends MaterialPageRoute<T>
    with SameRouteTransitionMixin<T> {
  SlidePageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    bool enableSecondaryAnimation = true,
  }) {
    _enableSecondaryAnimation = enableSecondaryAnimation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return super.buildPage(context, animation, secondaryAnimation);
  }

  /// in [buildPage]
  @override
  Widget buildContent(BuildContext context) {
    return super.buildContent(context);
  }

  @override
  Widget buildSameTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    /*return super
        .buildTransitions(context, animation, secondaryAnimation, child);*/

/*
    const begin = Offset(1, 0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);
    final offsetSecondaryAnimation = secondaryAnimation.drive(tween);

    l.w("1:->${animation.status} ${animation.value}->${offsetAnimation.value}");
    l.e("2:->${secondaryAnimation.status} ${secondaryAnimation.value}->${offsetSecondaryAnimation.value}");
*/

    /*return SlideTransition(
      position: offsetAnimation,
      child: child,
    );*/
    /*return Opacity(
      opacity: animation.value,
      child: child,
    );*/
    //logAnimation("Slide", animation, secondaryAnimation);
    //顶部进入动画
    var enter = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //底部退出动画
    var exit = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).chain(CurveTween(curve: Curves.easeIn)).animate(secondaryAnimation);

    return SlideTransition(
      position: enter,
      child: SlideTransition(
        position: exit,
        child: child,
      ),
    );
  }
}

///缩放路由动画
class ScalePageRoute<T> extends MaterialPageRoute<T>
    with SameRouteTransitionMixin<T> {
  /// 通否同时激活透明渐隐动画
  final bool fade;

  ScalePageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    this.fade = false,
    bool enableSecondaryAnimation = true,
  }) {
    _enableSecondaryAnimation = enableSecondaryAnimation;
  }

  @override
  Widget buildSameTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    //logAnimation("Scale", animation, secondaryAnimation);
    //顶部进入动画
    final enter = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //底部退出动画
    final exit = Tween<double>(
      begin: 1,
      end: 0.8,
    ).chain(CurveTween(curve: Curves.easeIn)).animate(secondaryAnimation);

    final scale = ScaleTransition(
      scale: enter,
      alignment: Alignment.center,
      child: ScaleTransition(
        scale: exit,
        alignment: Alignment.center,
        child: child,
      ),
    );

    if (fade) {
      return scale.fade(opacity: animation);
    }

    return scale;
  }
}

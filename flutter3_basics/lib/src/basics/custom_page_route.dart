part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/15
///

/// https://api.flutter.dev/flutter/animation/Curves-class.html
/// 底部页面的动画如何控制?
/// 渐变路由动画
/// [PageRouteBuilder]
/// [MaterialPageRoute]
class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    logAnimation("Fade", animation, secondaryAnimation);
    //顶部进入动画
    var enter = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //底部退出动画
    var exit = Tween<double>(
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
class TranslationPageRoute<T> extends MaterialPageRoute<T> {
  TranslationPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    logAnimation("Translation", animation, secondaryAnimation);
    //顶部进入动画
    var enter = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);
    //底部退出动画
    var exit = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
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

/// 左右滑动路由动画
class SlidePageRoute<T> extends MaterialPageRoute<T> {
  SlidePageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

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
  Widget buildTransitions(
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
    logAnimation("Slide", animation, secondaryAnimation);
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

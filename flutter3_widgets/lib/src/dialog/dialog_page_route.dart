part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///
/// 参考[DialogRoute]
/// [RouteWidgetEx.toRoute]
/// [DisplayFeatureSubScreen]
/// [DisplayFeatureSubScreen.anchorPoint]
class DialogPageRoute<T> extends RawDialogRoute<T> {
  DialogPageRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible,
    String? barrierLabel,
    bool useSafeArea = true,
    this.useBarrierColorAnimate = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    //---新增的参数---
    Duration? transitionDuration,
    TranslationType? type,
  }) : super(
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: type == TranslationType.none
              ? Duration.zero
              : (transitionDuration ?? const Duration(milliseconds: 200)),
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = themes?.wrap(pageChild) ?? pageChild;
            return dialog.safeArea(useSafeArea: useSafeArea);
          },
          transitionBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            if (type == TranslationType.none) {
              return child;
            }
            if (type?.withTranslation == true) {
              return TranslationPageRoute(
                builder: (content) => child,
                topToBottom: type?.withTopToBottom == true,
                fade: type?.withFade == true,
                enableSecondaryAnimation: false,
              ).buildSameTransitions(
                  context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.fade) {
              return FadePageRoute(
                builder: (content) => child,
                enableSecondaryAnimation: false,
              ).buildSameTransitions(
                  context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.slide) {
              return SlidePageRoute(
                builder: (content) => child,
                enableSecondaryAnimation: false,
              ).buildSameTransitions(
                  context, animation, secondaryAnimation, child);
            }
            if (type == TranslationType.scale ||
                type == TranslationType.scaleFade) {
              return ScalePageRoute(
                builder: (content) => child,
                fade: type?.withFade == true,
                enableSecondaryAnimation: false,
              ).buildSameTransitions(
                  context, animation, secondaryAnimation, child);
            }
            return buildMaterialDialogTransitions(
                context, animation, secondaryAnimation, child);
          },
        ) {
    _initialBarrierColor = barrierColor;
  }

  /// 是否使用障碍颜色动画
  final bool useBarrierColorAnimate;

  /// 初始时的障碍颜色, 用来计算[progressBarrierColor]
  Color? _initialBarrierColor;

  /// 根据进度, 动态计算出来的障碍颜色
  /// 通常在下拉返回组件中, 根据进度算出来的颜色
  Color? progressBarrierColor;

  @override
  Duration get transitionDuration => super.transitionDuration;

  @override
  Color? get barrierColor => progressBarrierColor ?? super.barrierColor;

  @override
  bool get barrierDismissible => super.barrierDismissible;

  @override
  AnimationController? get controller => super.controller;

  @override
  AnimationController createAnimationController() {
    return super.createAnimationController();
  }

  @override
  Widget buildModalBarrier() {
    return (useBarrierColorAnimate && controller == null)
        ? super.buildModalBarrier()
        : AnimatedBuilder(
            animation: controller!,
            builder: (context, child) {
              return super.buildModalBarrier();
            });
  }

  /// 2:再构建界面
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return useBarrierColorAnimate
        ? NotificationListener<ProgressStateNotification>(
            onNotification: (notification) {
              if (notification.tag == PullBackWidget &&
                  notification.progress != null) {
                _initialBarrierColor ??= barrierColor;
                progressBarrierColor ??= barrierColor;
                if (_initialBarrierColor != null) {
                  progressBarrierColor = _initialBarrierColor!.withAlpha(
                      (_initialBarrierColor!.alpha *
                              (1 - notification.progress!))
                          .round());
                }
                if (controller?.value != null) {
                  //更新界面
                  //[notifyListeners]
                  controller?.value = controller!.value;
                }
                return true;
              }
              return false;
            },
            child: super.buildPage(
              context,
              animation,
              secondaryAnimation,
            ),
          )
        : super.buildPage(
            context,
            animation,
            secondaryAnimation,
          );
  }

  /// 1:先[buildTransitions]生成动画
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

/// 系统默认的动画
/// [_buildMaterialDialogTransitions]
Widget buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

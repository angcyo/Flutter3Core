part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/24
///
/// 参考[DialogRoute]
/// - 支持穿透手势事件
///
/// - [RouteWidgetEx.toRoute]
/// - [DisplayFeatureSubScreen]
/// - [DisplayFeatureSubScreen.anchorPoint]
///
/// - [DialogPageRoute]
/// - [ArrowPopupRoute]
class DialogPageRoute<T> extends RawDialogRoute<T> {
  /// 通过[IgnorePointerType.all]属性, 可以让弹窗穿透点击事件
  final IgnorePointerType? barrierIgnorePointerType;

  DialogPageRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible,
    String? barrierLabel,
    bool useSafeArea = true,
    bool maintainBottomViewPadding = false /*是否保留系统默认的底部填充, 否则需要自行填充底部内容*/,
    this.useBarrierColorAnimate = true,
    super.settings,
    super.anchorPoint,
    super.traversalEdgeBehavior,
    //---新增的参数---
    Duration? transitionDuration,
    TranslationType? type,
    //2024-7-6
    this.barrierIgnorePointerType,
  }) : super(
         barrierLabel:
             barrierLabel ??
             MaterialLocalizations.of(context).modalBarrierDismissLabel,
         transitionDuration: type == TranslationType.none
             ? Duration.zero
             : (transitionDuration ?? const Duration(milliseconds: 200)),
         pageBuilder:
             (
               BuildContext buildContext,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) {
               final Widget pageChild = Builder(builder: builder);
               Widget dialog = themes?.wrap(pageChild) ?? pageChild;
               return dialog.safeArea(
                 useSafeArea: useSafeArea,
                 maintainBottomViewPadding: maintainBottomViewPadding,
               );
             },
         transitionBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
               Widget child,
             ) {
               return buildDialogTransitions(
                 context,
                 animation,
                 secondaryAnimation,
                 child,
                 type,
               );
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

  ///
  @override
  Duration get transitionDuration => super.transitionDuration;

  @override
  Color? get barrierColor => progressBarrierColor ?? super.barrierColor;

  ///
  @override
  bool get barrierDismissible => super.barrierDismissible;

  @override
  AnimationController? get controller => super.controller;

  ///
  @override
  AnimationController createAnimationController() {
    return super.createAnimationController();
  }

  @override
  Widget buildModalBarrier() {
    return (useBarrierColorAnimate && controller == null)
        ? super.buildModalBarrier().ignoreSelfPointer(
            ignoreType: barrierIgnorePointerType,
          )
        : AnimatedBuilder(
            animation: controller!,
            builder: (context, child) {
              return super.buildModalBarrier().ignoreSelfPointer(
                ignoreType: barrierIgnorePointerType,
              );
            },
          );
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
                    (_initialBarrierColor!.alpha * (1 - notification.progress!))
                        .round(),
                  );
                }
                if (controller?.value != null && !isSchedulerPhase) {
                  //更新界面
                  //[notifyListeners]
                  try {
                    //This ListenableBuilder widget cannot be marked as needing to build because the framework is already in the process of building widgets.
                    // A widget can be marked as needing to be built during the build phase only if one of its ancestors is currently building. This exception is allowed because the framework builds parent widgets before children, which means a dirty descendant will always be built.
                    // Otherwise, the framework might not visit this widget during this build phase.
                    controller?.value = controller!.value;
                  } catch (e) {
                    assert(() {
                      l.w(e);
                      return true;
                    }());
                  }
                }
                return true;
              }
              return false;
            },
            child: super.buildPage(context, animation, secondaryAnimation),
          )
        : super.buildPage(context, animation, secondaryAnimation);
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

  ///
  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return super.createOverlayEntries();
  }
}

/// 忽略非点击事件的对话框, 这样就可以穿透到下层路由
/// [DialogPageRoute]
/// [IgnorePointerType]
/*class DialogPageIgnoreRoute<T> extends PopupRoute<T> {
  final bool useSafeArea;
  final WidgetBuilder builder;
  final CapturedThemes? themes;

  //---新增的参数---
  final TranslationType? type;

  DialogPageIgnoreRoute({
    required BuildContext context,
    required this.builder,
    this.useSafeArea = true,
    this.themes,
    this.type,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54, //const Color(0x80000000)
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 200),
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
  })  : _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String? get barrierLabel => _barrierLabel;
  final String? _barrierLabel;

  @override
  Color? get barrierColor => _barrierColor;
  final Color? _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  /// 界面就是通过这个方法构建并显示在界面上的
  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return super.createOverlayEntries();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget pageChild = Builder(builder: builder);
    Widget dialog = themes?.wrap(pageChild) ?? pageChild;
    return dialog.safeArea(useSafeArea: useSafeArea);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return buildDialogTransitions(
        context, animation, secondaryAnimation, child, type);
  }
}*/

/// 构建对话框的过渡动画
Widget buildDialogTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  TranslationType? type,
) {
  if (type == TranslationType.none) {
    return child;
  }
  if (type?.withTranslation == true) {
    return TranslationPageRoute(
      builder: (content) => child,
      topToBottom: type?.withTopToBottom == true,
      fade: type?.withFade == true,
      enableSecondaryAnimation: false,
    ).buildSameTransitions(context, animation, secondaryAnimation, child);
  }
  if (type == TranslationType.fade) {
    return FadePageRoute(
      builder: (content) => child,
      enableSecondaryAnimation: false,
    ).buildSameTransitions(context, animation, secondaryAnimation, child);
  }
  if (type == TranslationType.slide) {
    return SlidePageRoute(
      builder: (content) => child,
      enableSecondaryAnimation: false,
    ).buildSameTransitions(context, animation, secondaryAnimation, child);
  }
  if (type == TranslationType.scale || type == TranslationType.scaleFade) {
    return ScalePageRoute(
      builder: (content) => child,
      fade: type?.withFade == true,
      enableSecondaryAnimation: false,
    ).buildSameTransitions(context, animation, secondaryAnimation, child);
  }
  return buildMaterialDialogTransitions(
    context,
    animation,
    secondaryAnimation,
    child,
  );
}

/// 系统默认的动画
/// [_buildMaterialDialogTransitions]
Widget buildMaterialDialogTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}

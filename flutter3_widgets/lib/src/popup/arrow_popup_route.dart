part of 'popup.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///
/// https://github.com/herowws/flutter_popup
///
/// 用来显示popup的路由
/// 使用路由的方式显示popup, 会阻止手势穿透
/// [ArrowPopupOverlay]
class ArrowPopupRoute extends PopupRoute<void> with ArrowDirectionMixin {
  final Rect anchorRect;
  final Widget child;

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color arrowColor;
  final bool showArrow;
  final Color? barriersColor;

  /// 是否根据锚点的位置, 自动设置箭头的方向
  /// 否则在不指定[arrowDirection]的情况下, 会根据剩余空间的大小, 自动设置箭头的方向
  final bool autoArrowDirection;

  @override
  double arrowDirectionMinOffset;

  /// 指定箭头方向
  @override
  AxisDirection? arrowDirection;

  ArrowPopupRoute({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    required this.child,
    required this.anchorRect,
    this.backgroundColor = Colors.white,
    this.arrowColor = Colors.white,
    required this.showArrow,
    this.autoArrowDirection = true,
    this.barriersColor,
    this.arrowDirectionMinOffset = 15,
    this.arrowDirection, //可以强制指定箭头方向
  });

  @override
  Color? get barrierColor => barriersColor ?? Colors.black.withOpacity(0.1);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'ArrowPopup';

  @override
  TickerFuture didPush() {
    super.offstage = true;
    applyAutoSetArrowDirection(autoArrowDirection, anchorRect);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final childRect = getGlobalKeyChildRect(_childKey);
      final arrowRect = getGlobalKeyChildRect(_arrowKey);
      calculateChildOffset(
        anchorRect: anchorRect,
        childRect: childRect,
      );
      calculateArrowOffset(
        anchorRect: anchorRect,
        childRect: childRect,
        arrowRect: arrowRect,
      );
      super.offstage = false;
    });
    return super.didPush();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    //debugger();
    //final result = super.buildPage(context, animation, secondaryAnimation);
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    //debugger();
    child = ArrowLayout(
      childKey: _childKey,
      arrowKey: _arrowKey,
      arrowDirectionOffset: _arrowDirectionOffset,
      arrowDirection: arrowDirection ?? AxisDirection.down,
      backgroundColor: backgroundColor,
      arrowColor: arrowColor,
      showArrow: showArrow,
      child: child,
    );
    if (!animation.isCompleted) {
      child = FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: FractionalOffset(_scaleAlignDx, _scaleAlignDy),
          scale: animation,
          child: child,
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
          left: _left,
          right: _right,
          top: _top,
          bottom: _bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ArrowDirectionMixin._viewportRect.width,
              maxHeight: _maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

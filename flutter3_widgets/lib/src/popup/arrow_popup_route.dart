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
  final double? radius;
  final Color? arrowColor;
  final bool showArrow;
  final Color? barriersColor;

  /// 是否根据锚点的位置, 自动设置箭头的方向
  /// 否则在不指定[arrowDirection]的情况下, 会根据剩余空间的大小, 自动设置箭头的方向
  final bool autoArrowDirection;

  final IgnorePointerType? barrierIgnorePointerType;

  @override
  AxisDirection? get arrowDirection => _arrowDirection;
  AxisDirection? _arrowDirection;

  @override
  set arrowDirection(AxisDirection? value) {
    _arrowDirection = value;
  }

  double _arrowDirectionMinOffset = 15;

  @override
  double get arrowDirectionMinOffset => _arrowDirectionMinOffset;

  @override
  set arrowDirectionMinOffset(double value) {
    _arrowDirectionMinOffset = value;
  }

  /// 内容的padding
  final EdgeInsets? padding;

  /// 与锚点之间/屏幕之间的间距
  final EdgeInsets? margin;

  /// 计算child的偏移量回调
  /// 返回child的left top偏移量
  final ArrowLayoutChildOffsetCallback? childOffsetCallback;

  /// [PopupEx.showArrowPopupRoute]
  ArrowPopupRoute({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    required this.child,
    required this.anchorRect,
    this.backgroundColor = Colors.white,
    this.radius,
    this.arrowColor,
    required this.showArrow,
    this.autoArrowDirection = true,
    this.barriersColor,
    this.padding = const EdgeInsets.all(kH),
    this.margin = const EdgeInsets.all(kX),
    double arrowDirectionMinOffset = 15,
    AxisDirection? arrowDirection, //可以强制指定箭头方向
    this.barrierIgnorePointerType, //障碍手势穿透
    this.animate = true,
    @defInjectMark this.animateDuration,
    this.childOffsetCallback,
  }) : _arrowDirectionMinOffset = arrowDirectionMinOffset,
       _arrowDirection = arrowDirection;

  /// 是否需要动画
  bool animate;

  /// 动画时长
  @defInjectMark
  Duration? animateDuration;

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
        childOffsetCallback: childOffsetCallback,
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

  ///
  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return super.createOverlayEntries();
  }

  @override
  Widget buildModalBarrier() {
    return super.buildModalBarrier().ignoreSelfPointer(
      ignoreType: barrierIgnorePointerType,
    );
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
      radius: radius,
      arrowColor: arrowColor,
      showArrow: showArrow,
      padding: padding,
      margin: margin,
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
  Duration get transitionDuration => animate
      ? animateDuration ?? const Duration(milliseconds: 150)
      : Duration.zero;
}

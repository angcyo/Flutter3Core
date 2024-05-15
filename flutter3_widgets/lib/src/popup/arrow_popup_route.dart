part of 'popup.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///
/// https://github.com/herowws/flutter_popup
///
/// 用来显示popup的路由
/// 使用路由的方式显示popup, 会阻止手势穿透
class ArrowPopupRoute extends PopupRoute<void> {
  final Rect anchorRect;
  final Widget child;

  static const double _margin = 10;
  static final Rect _viewportRect = Rect.fromLTWH(
    _margin,
    screenStatusBar + _margin,
    screenWidth - _margin * 2,
    screenHeight - screenStatusBar - screenBottomBar - _margin * 2,
  );

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color arrowColor;
  final bool showArrow;
  final Color? barriersColor;

  double _maxHeight = _viewportRect.height;
  AxisDirection? arrowDirection;
  double _arrowHorizontal = 0;
  double _scaleAlignDx = 0.5;
  double _scaleAlignDy = 0.5;
  double? _bottom;
  double? _top;
  double? _left;
  double? _right;

  ArrowPopupRoute({
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    required this.child,
    required this.anchorRect,
    this.backgroundColor = Colors.white,
    this.arrowColor = Colors.white,
    required this.showArrow,
    this.barriersColor,
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final childRect = _getRect(_childKey);
      final arrowRect = _getRect(_arrowKey);
      _calculateArrowOffset(arrowRect, childRect);
      _calculateChildOffset(childRect);
      super.offstage = false;
    });
    return super.didPush();
  }

  Rect? _getRect(GlobalKey key) {
    final currentContext = key.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    return offset & renderBox.paintBounds.size;
  }

  // Calculate the horizontal position of the arrow
  void _calculateArrowOffset(Rect? arrowRect, Rect? childRect) {
    if (childRect == null || arrowRect == null) return;
    // Calculate the distance from the left side of the screen based on the middle position of the target and the popover layer
    var leftEdge = anchorRect.center.dx - childRect.center.dx;
    final rightEdge = leftEdge + childRect.width;
    leftEdge = leftEdge < _viewportRect.left ? _viewportRect.left : leftEdge;
    // If it exceeds the screen, subtract the excess part
    if (rightEdge > _viewportRect.right) {
      leftEdge -= rightEdge - _viewportRect.right;
    }
    final center = anchorRect.center.dx - leftEdge - arrowRect.center.dx;
    // Prevent the arrow from extending beyond the padding of the popover
    if (center + arrowRect.center.dx > childRect.width - 15) {
      _arrowHorizontal = center - 15;
    } else if (center < 15) {
      _arrowHorizontal = 15;
    } else {
      _arrowHorizontal = center;
    }

    _scaleAlignDx = (_arrowHorizontal + arrowRect.center.dx) / childRect.width;
  }

  // Calculate the position of the popover
  void _calculateChildOffset(Rect? childRect) {
    //debugger();
    if (childRect == null) return;

    // Calculate the vertical position of the popover
    final topHeight = anchorRect.top - _viewportRect.top;
    final bottomHeight = _viewportRect.bottom - anchorRect.bottom;
    final maximum = max(topHeight, bottomHeight);
    _maxHeight = childRect.height > maximum ? maximum : childRect.height;
    if (_maxHeight > bottomHeight) {
      // Above the target
      _bottom = screenHeight - anchorRect.top;
      arrowDirection ??= AxisDirection.down;
      _scaleAlignDy = 1;
    } else {
      // Below the target
      _top = anchorRect.bottom;
      arrowDirection ??= AxisDirection.up;
      _scaleAlignDy = 0;
    }

    // Calculate the vertical position of the popover
    final left = anchorRect.center.dx - childRect.center.dx;
    final right = left + childRect.width;
    if (right > _viewportRect.right) {
      // at right
      _right = _margin;
    } else {
      // at left
      _left = left < _margin ? _margin : left;
    }
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
      arrowDirectionOffset: _arrowHorizontal,
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
              maxWidth: _viewportRect.width,
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

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

  /// 是否根据锚点的位置, 自动设置箭头的方向
  /// 否则在不指定[arrowDirection]的情况下, 会根据剩余空间的大小, 自动设置箭头的方向
  final bool autoArrowDirection;

  /// 指定箭头方向
  AxisDirection? arrowDirection;

  double _maxHeight = _viewportRect.height;

  double arrowDirectionMinOffset = 0;
  double _arrowDirectionOffset = 0;
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
    _autoArrowDirection();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final childRect = _getRect(_childKey);
      final arrowRect = _getRect(_arrowKey);
      _calculateArrowOffset(arrowRect, childRect);
      _calculateChildOffset(childRect);
      super.offstage = false;
    });
    return super.didPush();
  }

  /// 设置箭头的方向
  void _autoArrowDirection() {
    //debugger();
    if (autoArrowDirection && arrowDirection == null) {
      //如果锚点在屏幕的上半部分, 则箭头指向下
      if (anchorRect.center.dy < screenHeight / 2) {
        arrowDirection = AxisDirection.up;
      } else {
        arrowDirection = AxisDirection.down;
      }
    }
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

    if (arrowDirection == null ||
        arrowDirection == AxisDirection.down ||
        arrowDirection == AxisDirection.up) {
      //箭头需要水平偏移

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
      if (center + arrowRect.center.dx >
          childRect.width - arrowDirectionMinOffset) {
        _arrowDirectionOffset = center - arrowDirectionMinOffset;
      } else if (center < arrowDirectionMinOffset) {
        _arrowDirectionOffset = arrowDirectionMinOffset;
      } else {
        _arrowDirectionOffset = center;
      }
      _scaleAlignDx =
          (_arrowDirectionOffset + arrowRect.center.dx) / childRect.width;
    } else {
      //箭头需要垂直偏移
      //debugger();

      // Calculate the distance from the left side of the screen based on the middle position of the target and the popover layer
      var topEdge = anchorRect.center.dy - childRect.center.dy;
      final bottomEdge = topEdge + childRect.height;
      topEdge = topEdge < _viewportRect.top ? _viewportRect.top : topEdge;
      // If it exceeds the screen, subtract the excess part
      if (bottomEdge > _viewportRect.bottom) {
        topEdge -= bottomEdge - _viewportRect.bottom;
      }

      final center = anchorRect.center.dy - topEdge - arrowRect.center.dy;
      // Prevent the arrow from extending beyond the padding of the popover
      if (center + arrowRect.center.dy >
          childRect.height - arrowDirectionMinOffset) {
        _arrowDirectionOffset = center - arrowDirectionMinOffset;
      } else if (center < arrowDirectionMinOffset) {
        _arrowDirectionOffset = arrowDirectionMinOffset;
      } else {
        _arrowDirectionOffset = center;
      }
      _scaleAlignDy =
          (_arrowDirectionOffset + arrowRect.center.dy) / childRect.height;
    }
  }

  // Calculate the position of the popover
  void _calculateChildOffset(Rect? childRect) {
    //debugger();
    if (childRect == null) return;

    if (arrowDirection == null) {
      //未指定方向
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
    } else {
      //指定了方向
      if (arrowDirection! == AxisDirection.up ||
          arrowDirection! == AxisDirection.down) {
        final left = anchorRect.center.dx - childRect.center.dx;
        final right = left + childRect.width;
        if (right > _viewportRect.right) {
          // at right
          _right = _margin;
        } else {
          // at left
          _left = left < _margin ? _margin : left;
        }

        if (arrowDirection! == AxisDirection.up) {
          _top = anchorRect.bottom;
          _scaleAlignDy = 0;
        } else {
          _bottom = screenHeight - anchorRect.top;
          _scaleAlignDy = 1;
        }
      } else {
        //debugger();
        final top = anchorRect.center.dy - childRect.center.dy;
        final bottom = top + childRect.height;
        if (bottom > _viewportRect.bottom) {
          // at bottom
          _bottom = _margin;
        } else {
          // at top
          _top = top < _margin ? _margin : top;
        }

        if (arrowDirection! == AxisDirection.left) {
          _left = anchorRect.right;
          _scaleAlignDx = 0;
        } else {
          _right = screenWidth - anchorRect.left;
          _scaleAlignDx = 1;
        }
      }
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

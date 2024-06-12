part of 'popup.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/15
///

/// 箭头布局
/// [TrianglePainter]
class ArrowLayout extends StatefulWidget {
  //--arrow

  /// 是否要显示箭头
  final bool showArrow;

  /// 强制指定箭头的方向
  final AxisDirection arrowDirection;

  /// 箭头在[arrowDirection]方向上的偏移, 计算偏移时, 请使用中心点计算
  /// 理论上应该显示在锚点的中心位置
  /// 让箭头指向锚点中心位置
  final double arrowDirectionOffset;

  /// 箭头相对于内容的偏移
  final double arrowOffsetContent;

  /// 箭头的大小
  final Size arrowSize;

  /// 箭头的颜色
  final Color arrowColor;

  //--content

  /// 真实的内容
  final Widget child;

  final GlobalKey? childKey;
  final GlobalKey? arrowKey;

  //--

  /// 是否要使用默认的[Container]包裹[child]
  /// 默认为true, 会自动添加一层[Container], 有阴影/背景等效果
  final bool wrapChild;

  final double minWidth;

  /// 背景颜色
  final Color? backgroundColor;

  /// 内容的padding
  final EdgeInsets? padding;

  /// 与锚点之间/屏幕之间的间距
  final EdgeInsets? margin;

  const ArrowLayout({
    super.key,
    required this.child,
    this.childKey,
    this.arrowKey,
    this.showArrow = true,
    this.arrowColor = Colors.white,
    Size? arrowSize,
    this.arrowDirection = AxisDirection.down,
    this.arrowDirectionOffset = 0,
    this.arrowOffsetContent = 2,
    this.wrapChild = true,
    this.minWidth = kMinHeight,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(kH),
    this.margin = const EdgeInsets.all(kX),
  }) : arrowSize = arrowSize ??
            (arrowDirection == AxisDirection.up ||
                    arrowDirection == AxisDirection.down
                ? const Size(16, 8)
                : const Size(8, 16));

  @override
  State<ArrowLayout> createState() => _ArrowLayoutState();
}

class _ArrowLayoutState extends State<ArrowLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arrowDirection = widget.arrowDirection;
    // 箭头相对于内容还需要的偏移
    double arrowOffsetContent = widget.arrowOffsetContent;
    if (widget.wrapChild) {
      switch (widget.arrowDirection) {
        case AxisDirection.up:
          arrowOffsetContent +=
              (widget.margin?.top ?? widget.arrowSize.height) -
                  widget.arrowSize.height;
          break;
        case AxisDirection.down:
          arrowOffsetContent +=
              (widget.margin?.bottom ?? widget.arrowSize.height) -
                  widget.arrowSize.height;
          break;
        case AxisDirection.left:
          arrowOffsetContent +=
              (widget.margin?.left ?? widget.arrowSize.width) -
                  widget.arrowSize.width;
          break;
        case AxisDirection.right:
          arrowOffsetContent +=
              (widget.margin?.right ?? widget.arrowSize.width) -
                  widget.arrowSize.width;
          break;
      }
    }

    return Stack(
      children: [
        (widget.wrapChild
                ? Container(
                    padding: widget.padding,
                    margin: widget.margin?.copyWith(
                      top: arrowDirection == AxisDirection.down ? 0 : null,
                      bottom: arrowDirection == AxisDirection.up ? 0 : null,
                      left: arrowDirection == AxisDirection.right ? 0 : null,
                      right: arrowDirection == AxisDirection.left ? 0 : null,
                    ),
                    constraints: BoxConstraints(minWidth: widget.minWidth),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: widget.child,
                  )
                : widget.child)
            .childKeyed(widget.childKey),
        if (widget.showArrow)
          Positioned(
            top: widget.arrowDirection == AxisDirection.left ||
                    widget.arrowDirection == AxisDirection.right
                ? widget.arrowDirectionOffset
                : widget.arrowDirection == AxisDirection.up
                    ? arrowOffsetContent
                    : null,
            bottom: widget.arrowDirection == AxisDirection.down
                ? arrowOffsetContent
                : null,
            left: widget.arrowDirection == AxisDirection.up ||
                    widget.arrowDirection == AxisDirection.down
                ? widget.arrowDirectionOffset
                : widget.arrowDirection == AxisDirection.left
                    ? arrowOffsetContent
                    : null,
            right: widget.arrowDirection == AxisDirection.right
                ? arrowOffsetContent
                : null,
            child: CustomPaint(
              key: widget.arrowKey,
              size: widget.showArrow ? widget.arrowSize : Size.zero,
              painter: TrianglePainter(
                color: widget.arrowColor,
                direction: widget.arrowDirection,
              ),
            ),
          ),
      ],
    );
  }
}

//---

/// 用来计算箭头的方向, 和偏移
mixin ArrowDirectionMixin {
  static const double _margin = 0;
  static final Rect _viewportRect = Rect.fromLTWH(
    _margin,
    screenStatusBar + _margin,
    screenWidth - _margin * 2,
    screenHeight - screenStatusBar - screenBottomBar - _margin * 2,
  );

  double _maxHeight = _viewportRect.height;
  double _arrowDirectionOffset = 0;
  double _scaleAlignDx = 0.5;
  double _scaleAlignDy = 0.5;
  double? _bottom;
  double? _top;
  double? _left;
  double? _right;

  double arrowDirectionMinOffset = 15;

  /// 指定箭头方向
  AxisDirection? arrowDirection;

  /// 获取元素的位置信息
  /// 在路由中和在overlay中, 获取的位置信息不一样
  Rect? getGlobalKeyChildRect(GlobalKey key) {
    final currentContext = key.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    //在路由中, offset返回为0
    //在overlay中, offset返回非0
    return offset & renderBox.paintBounds.size;
  }

  /// 设置箭头的方向
  void applyAutoSetArrowDirection(bool autoArrowDirection, Rect anchorRect) {
    if (autoArrowDirection && arrowDirection == null) {
      //如果锚点在屏幕的上半部分, 则箭头指向下
      if (anchorRect.center.dy < screenHeight / 2) {
        arrowDirection = AxisDirection.up;
      } else {
        arrowDirection = AxisDirection.down;
      }
    }
  }

  // Calculate the position of the popover
  void calculateChildOffset({required Rect anchorRect, Rect? childRect}) {
    if (childRect == null) return;

    // Calculate the vertical position of the popover
    final topHeight = anchorRect.top - _viewportRect.top;
    final bottomHeight = _viewportRect.bottom - anchorRect.bottom;
    final maximum = max(topHeight, bottomHeight);
    _maxHeight = childRect.height > maximum ? maximum : childRect.height;

    //debugger();
    if (arrowDirection == null) {
      //未指定方向
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

  // Calculate the horizontal position of the arrow
  void calculateArrowOffset({
    required Rect anchorRect,
    Rect? arrowRect,
    Rect? childRect,
  }) {
    //debugger();
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
}

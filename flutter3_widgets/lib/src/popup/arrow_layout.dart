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
                    constraints: const BoxConstraints(minWidth: 50),
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

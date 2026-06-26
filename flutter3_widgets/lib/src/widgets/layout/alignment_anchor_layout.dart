part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/26
///
/// 对齐锚点的布局, 在[Stack]中使用
class AlignmentAnchorLayout extends StatefulWidget {
  /// 需要显示的内容
  final Widget? child;

  /// 对齐锚点的什么位置
  @autoInjectMark
  final Alignment? targetAnchor;

  /// [child]内容的什么位置
  @autoInjectMark
  final Alignment? followerAnchor;

  /// 对齐后, 额外的偏移量
  final Offset? alignmentOffset;

  //MARK: anchor

  /// 获取锚点的位置
  final Rect? Function()? getAnchorBoundsAction;
  final Rect? anchorRect;
  final BuildContext? anchorChild;
  final RenderObject? anchorAncestor;

  /// 获取内容应该偏移的位置量, 所有对齐方式, 参考left top 0,0 计算
  /// - [edgeOffset]当溢出时, 需要的偏移量
  static Offset getFollowerAlignmentOffset({
    required Rect anchorRect,
    required Size parentSize,
    required Size childSize,
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
    Offset? edgeOffset,
  }) {
    //所有对齐方式, 参考left top 0,0 计算
    //MARK: - target offset
    //偏移到对齐锚点的位置
    double offsetX = anchorRect.left;
    double offsetY = anchorRect.top;
    if (targetAnchor == .topLeft) {
      //def
    } else if (targetAnchor == .topCenter) {
      offsetX = anchorRect.center.dx;
      offsetY = anchorRect.top;
    } else if (targetAnchor == .topRight) {
      offsetX = anchorRect.right;
      offsetY = anchorRect.top;
    } else if (targetAnchor == .centerLeft) {
      offsetX = anchorRect.left;
      offsetY = anchorRect.center.dy;
    } else if (targetAnchor == .center) {
      offsetX = anchorRect.center.dx;
      offsetY = anchorRect.center.dy;
    } else if (targetAnchor == .centerRight) {
      offsetX = anchorRect.right;
      offsetY = anchorRect.center.dy;
    } else if (targetAnchor == .bottomLeft) {
      offsetX = anchorRect.left;
      offsetY = anchorRect.bottom;
    } else if (targetAnchor == .bottomCenter) {
      offsetX = anchorRect.center.dx;
      offsetY = anchorRect.bottom;
    } else if (targetAnchor == .bottomRight) {
      offsetX = anchorRect.right;
      offsetY = anchorRect.bottom;
    }

    //MARK: - follower offset
    //偏移到自身的位置
    offsetX += alignmentOffset?.dx ?? 0;
    offsetY += alignmentOffset?.dy ?? 0;
    if (followerAnchor == Alignment.topLeft) {
      //def
    } else if (followerAnchor == Alignment.topCenter) {
      offsetX -= childSize.width / 2;
    } else if (followerAnchor == Alignment.topRight) {
      offsetX -= childSize.width;
    } else if (followerAnchor == Alignment.centerRight) {
      offsetX -= childSize.width;
      offsetY -= childSize.height / 2;
    } else if (followerAnchor == Alignment.bottomRight) {
      offsetX -= childSize.width;
      offsetY -= childSize.height;
    } else if (followerAnchor == Alignment.bottomCenter) {
      offsetX -= childSize.width / 2;
      offsetY -= childSize.height;
    } else if (followerAnchor == Alignment.bottomLeft) {
      offsetY -= childSize.height;
    } else if (followerAnchor == Alignment.centerLeft) {
      offsetY -= childSize.height / 2;
    } else if (followerAnchor == Alignment.center) {
      offsetX -= childSize.width / 2;
      offsetY -= childSize.height / 2;
    }
    //debugger();
    final parentWidth = parentSize.width;
    final parentHeight = parentSize.height;
    //MARK: - 溢出计算
    if (offsetX < 0) {
      offsetX = edgeOffset?.dx ?? 0;
    }
    if (offsetY < 0) {
      offsetY = edgeOffset?.dy ?? 0;
    }
    return Offset(offsetX, offsetY);
  }

  const AlignmentAnchorLayout({
    super.key,
    this.child,
    this.targetAnchor,
    this.followerAnchor,
    this.alignmentOffset,
    //--
    this.getAnchorBoundsAction,
    this.anchorRect,
    this.anchorChild,
    this.anchorAncestor,
  });

  @override
  State<AlignmentAnchorLayout> createState() => _AlignmentAnchorLayoutState();
}

class _AlignmentAnchorLayoutState extends State<AlignmentAnchorLayout> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateChildPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _offstage,
      child: Stack(
        children: [
          Positioned(
            left: _childOffset.dx,
            top: _childOffset.dy,
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: AfterLayout(
                afterLayoutAction: (ctx, renderBox) {
                  final childSize = renderBox.size;
                  if (_childSize != childSize) {
                    _childSize = childSize;
                    if (!_offstage) {
                      _updateChildPosition();
                    }
                  }
                },
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //--

  /// 离屏状态, 用来获取内容大小
  @tempFlag
  bool _offstage = true;

  /// 容器大小, 防止溢出
  @tempFlag
  Size _parentSize = Size.zero;

  /// 内容大小
  @tempFlag
  Size _childSize = Size.zero;

  /// 锚点位置
  @tempFlag
  Rect _anchorRect = Rect.zero;

  /// 计算后的位置偏移量
  @tempFlag
  Offset _childOffset = Offset.zero;

  /// 更新内容位置
  void _updateChildPosition() {
    final anchorRect =
        widget.anchorRect ??
        widget.getAnchorBoundsAction?.call() ??
        widget.anchorChild?.findRenderObject()?.getGlobalBounds(
          widget.anchorAncestor,
        );
    final parentSize =
        widget.anchorAncestor?.renderSize ??
        context.findRenderObject()?.renderSize;
    if (parentSize != null) {
      _parentSize = parentSize;
    }
    if (anchorRect != null && _anchorRect != anchorRect) {
      _anchorRect = anchorRect;
      _childOffset = AlignmentAnchorLayout.getFollowerAlignmentOffset(
        targetAnchor: widget.targetAnchor,
        followerAnchor: widget.followerAnchor,
        alignmentOffset: widget.alignmentOffset ?? Offset.zero,
        edgeOffset: Offset(kX, kX),
        anchorRect: anchorRect,
        parentSize: _parentSize,
        childSize: _childSize,
      );
      _offstage = false;
      updateState();
    } else {
      assert(() {
        l.w("无法获取锚点的位置!");
        debugger();
        return true;
      }());
    }
  }
}

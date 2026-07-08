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

  /// 溢出时, 添加的偏移量
  @defInjectMark
  final Offset? edgeOffset;

  /// 内容位置确定后的回调
  final void Function(
    Rect anchorRect,
    Size parentSize,
    Size childSize,
    Offset childOffset,
  )?
  onChildUpdatePosition;

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
    Offset? edgeOffset /*开启溢出并保证最低偏移量*/,
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
    if (edgeOffset != null) {
      if (offsetX < 0) {
        offsetX = edgeOffset.dx ?? 0;
      } else if (offsetX + childSize.width > parentWidth) {
        offsetX = parentWidth - childSize.width - (edgeOffset.dx ?? 0);
      }
      if (offsetY < 0) {
        offsetY = edgeOffset.dy ?? 0;
      } else if (offsetY + childSize.height > parentHeight) {
        offsetY = parentHeight - childSize.height - (edgeOffset.dy ?? 0);
      }
    }
    return Offset(offsetX, offsetY);
  }

  const AlignmentAnchorLayout({
    super.key,
    this.child,
    this.targetAnchor,
    this.followerAnchor,
    this.alignmentOffset,
    this.edgeOffset,
    this.onChildUpdatePosition,
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
  /// 拖拽偏移
  @tempFlag
  Offset? _dragOffset;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateChildPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dragOffsetLive = OverlayEntryControlStateScope.of(
      context,
    )?.dragOffsetLive;
    if (dragOffsetLive == null) {
      return buildBody(context);
    }
    return dragOffsetLive.build((ctx, offset) {
      if (offset is Offset) {
        _dragOffset = offset;
        _updateChildPosition();
      }
      return buildBody(context);
    });
  }

  Widget buildBody(BuildContext context) {
    return Offstage(
      offstage: _offstage,
      child: Stack(
        children: [
          Positioned(
            left: _childOffset?.dx,
            top: _childOffset?.dy,
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
  Size? _parentSize;

  /// 内容大小
  @tempFlag
  Size? _childSize;

  /// 锚点位置
  @tempFlag
  Rect? _anchorRect;

  /// 计算后的位置偏移量
  @tempFlag
  Offset? _childOffset;

  /// 更新内容位置
  void _updateChildPosition() {
    _anchorRect ??=
        widget.anchorRect ??
        widget.getAnchorBoundsAction?.call() ??
        widget.anchorChild?.findRenderObject()?.getGlobalBounds(
          widget.anchorAncestor,
        );
    _parentSize ??=
        widget.anchorAncestor?.renderSize ??
        context.findRenderObject()?.renderSize;
    if (_anchorRect != null && _parentSize != null && _childSize != null) {
      _childOffset = AlignmentAnchorLayout.getFollowerAlignmentOffset(
        targetAnchor: widget.targetAnchor,
        followerAnchor: widget.followerAnchor,
        alignmentOffset:
            (widget.alignmentOffset ?? Offset.zero) +
            (_dragOffset ?? Offset.zero),
        edgeOffset: widget.edgeOffset ?? Offset(kX, kX),
        anchorRect: _anchorRect!,
        parentSize: _parentSize!,
        childSize: _childSize!,
      );
      _offstage = false;
      widget.onChildUpdatePosition?.call(
        _anchorRect!,
        _parentSize!,
        _childSize!,
        _childOffset!,
      );
      updateState();
    } else if (!_offstage) {
      assert(() {
        l.w("无法获取锚点的位置!");
        debugger();
        return true;
      }());
    }
  }
}

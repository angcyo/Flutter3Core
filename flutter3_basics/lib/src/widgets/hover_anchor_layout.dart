part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/03
///
/// 支持在一个锚点[anchor]布局, 鼠标悬停显示提示或界面的布局
///
/// [Tooltip]
///
class HoverAnchorLayout extends StatefulWidget {
  /// 锚点布局
  final Widget anchor;

  /// 悬停/点击时显示的内容
  final Widget? content;

  const HoverAnchorLayout({
    super.key,
    required this.anchor,
    this.content,
  });

  @override
  State<HoverAnchorLayout> createState() => _HoverAnchorLayoutState();
}

class _HoverAnchorLayoutState extends State<HoverAnchorLayout> {
  final OverlayPortalController controller = OverlayPortalController();

  /// 是否激活当前的部件功能
  bool get isEnable => widget.content != null;

  @override
  void initState() {
    _initLayoutState();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HoverAnchorLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initLayoutState();
  }

  void _initLayoutState() {
    if (isEnable) {}
  }

  /// 是否已经显示了悬停布局
  bool _isShowHoverLayout = false;

  /// [TooltipState._handleMouseEnter]
  void _handleMouseEnter(PointerEnterEvent event) {
    if (_isShowHoverLayout) {
      return;
    }
    l.d("show->${nowTimeString()}");
    controller.show();
    _isShowHoverLayout = true;
    /*postFrame(() {
      _isShowHoverLayout = true;
    });*/
  }

  /// [TooltipState._handleMouseExit]
  void _handleMouseExit(PointerExitEvent event) {
    if (!_isShowHoverLayout) {
      return;
    }
    l.i("hide");
    _isShowHoverLayout = false;
    controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEnable) {
      return widget.anchor;
    }
    return MouseRegion(
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: OverlayPortal(
          controller: controller,
          overlayChildBuilder: (ctx) {
            final anchorBounds = context.findRenderObject()?.getGlobalBounds(
                  Overlay.maybeOf(context)?.context.findRenderObject(),
                );
            l.d("anchorBounds:$anchorBounds");
            return $any(
              child: MouseRegion(
                onEnter: _handleMouseEnter,
                onExit: _handleMouseExit,
                child: widget.content,
              ),
              onGetChildOffset: (constraints, parentSize, childSize) {
                //debugger();
                return Offset(
                  anchorBounds!.right,
                  anchorBounds.center.dy - childSize.height / 2,
                );
              },
              onPaint: (render, canvas, size) {
                canvas.drawRect(
                  anchorBounds ?? Rect.zero,
                  Paint()
                    ..color = Colors.red
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                );
              },
            );
          },
          child: widget.anchor,
        ));
  }
}

//--

/// [_ExclusiveMouseRegion]
@fromFramework
class _ExclusiveMouseRegion extends MouseRegion {
  const _ExclusiveMouseRegion({
    super.onEnter,
    super.onExit,
    super.child,
  });

  @override
  _RenderExclusiveMouseRegion createRenderObject(BuildContext context) {
    return _RenderExclusiveMouseRegion(
      onEnter: onEnter,
      onExit: onExit,
    );
  }
}

/// [_RenderExclusiveMouseRegion]
@fromFramework
class _RenderExclusiveMouseRegion extends RenderMouseRegion {
  _RenderExclusiveMouseRegion({
    super.onEnter,
    super.onExit,
  });

  static bool isOutermostMouseRegion = true;
  static bool foundInnermostMouseRegion = false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool isHit = false;
    final bool outermost = isOutermostMouseRegion;
    isOutermostMouseRegion = false;
    if (size.contains(position)) {
      isHit =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if ((isHit || behavior == HitTestBehavior.translucent) &&
          !foundInnermostMouseRegion) {
        foundInnermostMouseRegion = true;
        result.add(BoxHitTestEntry(this, position));
      }
    }

    if (outermost) {
      // The outermost region resets the global states.
      isOutermostMouseRegion = true;
      foundInnermostMouseRegion = false;
    }
    return isHit;
  }
}

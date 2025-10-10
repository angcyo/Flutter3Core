part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/09
///
/// 锚点[anchor]元素在屏幕中的位置跟踪
/// - 当锚点位置发生改变时, 触发通知
/// - 当锚点不存在时, 触发通知
///
/// - 需要动态构建元素?
@implementation
@Deprecated("implementation")
class AnchorTraceLayout extends SingleChildRenderObjectWidget {
  /// 需要跟踪位置的锚点元素
  final BuildContext? anchor;

  /// 锚点元素位置改变时, 构建新的元素. 会替换[child]
  final AnchorTraceCallback? builder;

  const AnchorTraceLayout({super.key, this.anchor, this.builder, super.child});

  @override
  AnchorTraceRenderObject createRenderObject(BuildContext context) {
    return AnchorTraceRenderObject();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    AnchorTraceRenderObject renderObject,
  ) {
    renderObject.anchor = anchor;
  }

  @override
  void didUnmountRenderObject(AnchorTraceRenderObject renderObject) {
    super.didUnmountRenderObject(renderObject);
  }
}

/// [WidgetBuilder]
typedef AnchorTraceCallback =
    Widget? Function(BuildContext context, Rect? anchorRect);

/// - [CustomSingleChildLayout]
/// - [AbstractLayoutBuilder]
/// - [ConstrainedLayoutBuilder]
class AnchorTraceRenderObject extends RenderProxyBox {
  BuildContext? _anchor;

  BuildContext? get anchor => _anchor;

  set anchor(BuildContext? value) {
    if (_anchor != value) {
      _anchor = value;
      _checkAnchorPosition();
    }
  }

  AnchorTraceCallback? builder;

  AnchorTraceRenderObject({
    BuildContext? anchor,
    this.builder,
    RenderBox? child,
  }) : _anchor = anchor,
       super(child);

  @override
  void performLayout() {
    super.performLayout();
  }

  /// 锚点当前的位置
  Rect? _anchorRect;

  /// 检查锚点的位置是否发生改变, 并触发通知
  void _checkAnchorPosition() {}
}

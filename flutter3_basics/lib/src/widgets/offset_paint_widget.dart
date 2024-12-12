part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/12
///
/// 在保证原有结构不变的情况下, 仅在绘制的时候, 添加一定的偏移量
/// [FittedBox]
class OffsetPaintWidget extends SingleChildRenderObjectWidget {
  final Offset offset;

  const OffsetPaintWidget({
    super.key,
    super.child,
    this.offset = Offset.zero,
  });

  @override
  _OffsetPaintRenderObject createRenderObject(BuildContext context) =>
      _OffsetPaintRenderObject(offset: offset);

  @override
  void updateRenderObject(
      BuildContext context, _OffsetPaintRenderObject renderObject) {
    renderObject.offset = offset;
    renderObject.markNeedsPaint();
  }
}

class _OffsetPaintRenderObject extends RenderProxyBox {
  Offset offset = Offset.zero;

  _OffsetPaintRenderObject({
    RenderBox? child,
    this.offset = Offset.zero,
  }) : super(child);

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset + this.offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    assert(!debugNeedsLayout);
    return result.addWithPaintOffset(
      offset: offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    debugger();
    /*transform.translate(
      translation.dx * size.width,
      translation.dy * size.height,
    );*/
  }
}

extension OffsetPaintWidgetEx on Widget {
  /// [OffsetPaintWidget]
  Widget offsetPaint({
    double? dx,
    double? dy,
    Offset? offset,
  }) =>
      dx != null || dy != null || offset != null
          ? OffsetPaintWidget(
              offset: offset ?? Offset(dx ?? 0, dy ?? 0),
              child: this,
            )
          : this;
}

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/10
///
/// 用来绘制[child]的边界
class BoundsWidget extends SingleChildRenderObjectWidget {
  /// 边界颜色
  final Color color;

  ///
  final double strokeWidth;

  const BoundsWidget({
    super.key,
    super.child,
    this.color = Colors.red,
    this.strokeWidth = 1,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _BoundsWidgetRenderObject(this);

  @override
  void updateRenderObject(
    BuildContext context,
    _BoundsWidgetRenderObject renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..config = this
      ..markNeedsPaint();
  }
}

class _BoundsWidgetRenderObject extends RenderProxyBox {
  BoundsWidget? config;

  _BoundsWidgetRenderObject(this.config);

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    final canvas = context.canvas;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      Paint()
        ..color = config?.color ?? Colors.red.withOpacity(0.2)
        ..strokeWidth = config?.strokeWidth ?? 1
        ..style = PaintingStyle.stroke,
    );
  }
}

extension BoundsWidgetEx on Widget {
  /// [BoundsWidget]
  Widget bounds({
    Color color = Colors.red,
    double strokeWidth = 1,
  }) =>
      BoundsWidget(
        color: color,
        strokeWidth: strokeWidth,
        child: this,
      );
}

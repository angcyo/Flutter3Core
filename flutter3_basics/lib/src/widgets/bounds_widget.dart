part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/12/10
///
/// 用来绘制[child]的边界
class BoundsWidget extends SingleChildRenderObjectWidget {
  /// 边界颜色
  final Color color;

  /// 边界线宽
  final double strokeWidth;

  /// 圆角大小
  final double radius;

  final String? debugLabel;

  const BoundsWidget({
    super.key,
    super.child,
    this.color = Colors.red,
    this.strokeWidth = 1,
    this.radius = 0,
    this.debugLabel,
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
  BoundsWidget config;

  _BoundsWidgetRenderObject(this.config);

  @override
  void attach(PipelineOwner owner) {
    debugger(when: config.debugLabel != null);
    super.attach(owner);
  }

  @override
  void detach() {
    debugger(when: config.debugLabel != null);
    super.detach();
  }

  @override
  void dispose() {
    debugger(when: config.debugLabel != null);
    super.dispose();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    if (config.color != Colors.transparent && config.strokeWidth > 0) {
      final canvas = context.canvas;
      canvas.drawRRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
        ).toRRect(config.radius),
        Paint()
          ..color = config.color
          ..strokeWidth = config.strokeWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }
}

extension BoundsWidgetEx on Widget {
  /// [BoundsWidget]
  Widget bounds({
    Key? key,
    Color color = Colors.red,
    double strokeWidth = 1,
    double radius = 0,
    String? debugLabel,
  }) => BoundsWidget(
    key: key,
    color: color,
    strokeWidth: strokeWidth,
    radius: radius,
    debugLabel: debugLabel,
    child: this,
  );
}

part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/25
///
/// 全屏警报动画提示小部件
class DangerWarningWidget extends SingleChildRenderObjectWidget {
  /// 警报的颜色
  final Color color;

  /// 警报的宽度
  final double width;

  const DangerWarningWidget({
    super.key,
    super.child,
    this.color = Colors.red,
    this.width = 20,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _DangerWarningRender(color: color, width: width);

  @override
  void updateRenderObject(
      BuildContext context, _DangerWarningRender renderObject) {
    renderObject
      ..color = color
      ..width = width
      ..markNeedsPaint();
  }
}

class _DangerWarningRender extends RenderProxyBox {
  /// 警报的颜色
  Color color;

  /// 警报的宽度
  double width;

  /// 进度
  double _progress = 0;
  bool _reverse = false;

  _DangerWarningRender({
    this.color = Colors.red,
    this.width = 20,
  });

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    _paintSelf(context.canvas, offset);
    super.paint(context, offset);
  }

  void _paintSelf(Canvas canvas, ui.Offset offset) {
    //debugger();
    final pair = _progress.rrt(300, _reverse);
    _progress = pair.$1;
    _reverse = pair.$2;
    final w = width * _progress;

    final colors = [color, color.withOpacity(0.3), Colors.transparent];

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final left = Rect.fromLTWH(offset.dx, offset.dy, w, size.height);
    paint.shader = linearGradientShader(colors, rect: left);
    canvas.drawRect(left, paint);

    final right = Rect.fromLTWH(size.width - w, offset.dy, w, size.height);
    paint.shader = linearGradientShader(
      colors,
      from: right.topRight,
      to: right.topLeft,
    );
    canvas.drawRect(right, paint);

    final top = Rect.fromLTWH(offset.dx, offset.dy, size.width, w);
    paint.shader =
        linearGradientShader(colors, from: top.topLeft, to: top.bottomLeft);
    canvas.drawRect(top, paint);

    final bottom =
        Rect.fromLTWH(offset.dx, offset.dy + size.height - w, size.width, w);
    paint.shader = linearGradientShader(
      colors,
      from: bottom.bottomLeft,
      to: bottom.topLeft,
    );
    canvas.drawRect(bottom, paint);

    postMarkNeedsPaint();
  }
}

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/27
///
/// 描边转圈加载动画
class StrokeLoadingWidget extends LeafRenderObjectWidget {
  /// 线的颜色
  final Color color;

  /// 线的宽度
  final double lineWidth;

  /// 内部内容的大小
  final Size? contentSize;

  /// 当前的进度
  /// 为空时表示 不确定性的进度
  /// [0.0-1.0]
  final double? progress;

  const StrokeLoadingWidget({
    super.key,
    this.color = Colors.black12,
    this.lineWidth = 4,
    this.contentSize = const Size(kMinInteractiveHeight, kMinInteractiveHeight),
    this.progress,
  });

  @override
  StrokeLoadingRenderObject createRenderObject(BuildContext context) =>
      StrokeLoadingRenderObject()
        ..lineColor = color
        ..lineWidth = lineWidth
        ..contentSize = contentSize
        ..progress = progress;

  @override
  void updateRenderObject(
    BuildContext context,
    StrokeLoadingRenderObject renderObject,
  ) {
    renderObject
      ..lineColor = color
      ..lineWidth = lineWidth
      ..contentSize = contentSize
      ..progress = progress
      ..markNeedsPaint();
  }
}

class StrokeLoadingRenderObject extends RenderBox {
  /// 线的颜色
  Color lineColor = Colors.black12;

  /// 线的宽度
  double lineWidth = 4;

  /// 内部内容的大小
  Size? contentSize;

  /// 当前的进度
  /// 为空时表示 不确定性的进度
  /// [0.0-1.0]
  double? progress;

  /// 不确定性的进度sweep的角度
  double indeterminateSweepAngle = 3;

  /// 每次绘制旋转的增量角度
  double rotateAngleStep = 4;

  /// 开始的角度
  double _startAngle = 0;

  StrokeLoadingRenderObject();

  @override
  void performLayout() {
    //size = constraints.constrainDimensions(screenWidth, screenHeight);
    //debugger();
    final biggest = constraints.biggest;
    size = biggest.ensureValid(
        width: minOf(biggest.width, biggest.height),
        height: minOf(biggest.width, biggest.height));
    //debugger();
  }

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    final canvas = context.canvas;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Size size = contentSize ?? this.size;
    size = ui.Size(
      math.min(size.width, this.size.width),
      math.min(size.width, this.size.height),
    );
    final off = offset + alignChildOffset(Alignment.center, this.size, size);

    Rect rect = (off & size).deflateValue(lineWidth / 2);
    canvas.drawArc(rect, 0, 360.hd, false, paint);

    //progress
    _startAngle += rotateAngleStep.rr;
    _startAngle = _startAngle.sanitizeDegrees;

    rect = rect.deflateValue(lineWidth + lineWidth / 2);
    if (progress == null) {
      canvas.drawArc(
          rect, _startAngle.hds, indeterminateSweepAngle.hds, false, paint);
    } else {
      canvas.drawArc(
          rect, _startAngle.hds, (360 * progress!).hds, false, paint);
    }
    postMarkNeedsPaint();
  }
}

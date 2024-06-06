part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///
/// 雷达扫描动画
class RadarScanWidget extends LeafRenderObjectWidget {
  /// 是否需要动画
  final bool isLoading;

  /// 雷达开始的半径
  final double radarRadius;

  /// 雷达线的宽度
  final double radarWidth;

  /// 雷达的颜色
  final Color radarColor;

  /// 雷达扫描线, 渐变开始的颜色
  final Color radarScanColor;

  /// 扫描的步长
  final double radarScanStep;

  /// 雷达半径增长比例
  final double radarRadiusIncrease;

  const RadarScanWidget({
    super.key,
    this.isLoading = true,
    this.radarRadius = 40,
    this.radarWidth = 1,
    this.radarColor = Colors.purpleAccent,
    this.radarScanColor = Colors.purpleAccent,
    this.radarScanStep = -4,
    this.radarRadiusIncrease = 0.4,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RadarScanBox(this);

  @override
  void updateRenderObject(BuildContext context, RadarScanBox renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..widget = this
      ..markNeedsPaint();
  }
}

class RadarScanBox extends RenderBox {
  /// 扫描的当前角度
  double _radarScanDegrees = 0;

  RadarScanWidget widget;

  RadarScanBox(this.widget);

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (constraints.isTight) {
      size = constraints.biggest;
    } else {
      final width = constraints.maxWidth == double.infinity
          ? screenWidth
          : constraints.maxWidth;
      final height = constraints.maxHeight == double.infinity
          ? screenHeight
          : constraints.maxHeight;
      final s = min(width, height);
      size = constraints.constrain(Size(s, s));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    //super.paint(context, offset);
    final canvas = context.canvas;

    //发光背景

    //绘制雷达背景
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = widget.radarColor
      ..shader = null
      ..strokeWidth = widget.radarWidth;

    final bounds = offset & size;

    //最大半径
    final maxR = max(bounds.width / 2, bounds.height / 2);
    //当前的半径
    double r = widget.radarRadius;
    double lastR = r;
    while (r <= maxR) {
      lastR = r;
      canvas.drawCircle(bounds.center, r, paint);
      r += r * widget.radarRadiusIncrease;
    }

    //绘制扫描
    canvas.withScale(1.0, -1.0, () {
      canvas.withRotate(
        _radarScanDegrees,
        () {
          paint.style = PaintingStyle.fill;
          paint.shader = sweepGradientShader(
            [
              widget.radarScanColor,
              widget.radarScanColor.withOpacityRatio(0.5),
              Colors.transparent,
            ],
            colorStops: [0, 0.3, 1],
            center: bounds.center,
          );
          canvas.drawCircle(bounds.center, lastR, paint);
        },
        anchor: bounds.center,
      );
    }, anchor: bounds.center);

    //动画
    if (widget.isLoading) {
      _radarScanDegrees += widget.radarScanStep.rr;
      if (_radarScanDegrees < 0) {
        _radarScanDegrees = 360;
      } else if (_radarScanDegrees > 360) {
        _radarScanDegrees = 0;
      }
      postMarkNeedsPaint();
    }
  }
}

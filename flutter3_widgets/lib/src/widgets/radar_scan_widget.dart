part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/10
///
/// 雷达扫描动画
class RadarScanWidget extends LeafRenderObjectWidget {
  /// 是否需要动画
  final bool isLoading;

  /// 是否需要包裹大小, 否则会使用最大的边
  final bool wrapSize;

  /// 是否显示圆圈扫描线
  final bool showScanLine;

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

  /// 扫描线的颜色渐变分布比例
  final List<double> radarColorStops;

  /// 绘制时的偏移
  final Offset paintOffset;

  const RadarScanWidget({
    super.key,
    this.isLoading = true,
    this.showScanLine = true,
    this.wrapSize = false,
    this.radarRadius = 40,
    this.radarWidth = 1,
    this.radarColor = Colors.purpleAccent,
    this.radarScanColor = Colors.purpleAccent,
    this.radarScanStep = -4,
    this.radarRadiusIncrease = 0.4,
    this.radarColorStops = const [0, 0.3, 1],
    this.paintOffset = Offset.zero,
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
    final center = bounds.center + widget.paintOffset;
    //debugger();

    //最大半径
    final maxR = widget.wrapSize
        ? min(bounds.width / 2, bounds.height / 2)
        : max(bounds.width / 2, bounds.height / 2);

    double r = widget.showScanLine ? widget.radarRadius : maxR;
    double lastR = r;

    if (widget.showScanLine) {
      //当前的半径
      while (r <= maxR) {
        lastR = r;
        canvas.drawCircle(center, r, paint);
        r += r * widget.radarRadiusIncrease;
      }
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
            colorStops: widget.radarColorStops,
            center: center,
          );
          canvas.drawCircle(center, lastR, paint);
        },
        anchor: center,
      );
    }, anchor: center);

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

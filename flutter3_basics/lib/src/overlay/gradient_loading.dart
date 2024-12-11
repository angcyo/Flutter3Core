part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/12/08
///
/// 扫描渐变加载动画小部件
class SweepGradientLoadingWidget extends LeafRenderObjectWidget {
  /// 内边距
  final EdgeInsets? padding;

  /// 宽度
  final double strokeWidth;

  /// 渐变颜色的集合
  /// [startColor]
  /// [endColor]
  final List<Color>? colors;

  /// 渐变开始的颜色
  final Color startColor;

  /// 渐变结束的颜色
  final Color endColor;

  //--

  /// 是否加载中
  final bool isLoading;

  /// 加载每一帧的步长
  final double rotateStep;

  //--

  /// [strokeWidth]需要消耗的角度(弧度值)
  final double strokeWidthRadian;

  const SweepGradientLoadingWidget({
    super.key,
    this.padding,
    this.strokeWidth = 3,
    this.colors,
    this.startColor = Colors.orange,
    this.endColor = Colors.transparent,
    this.isLoading = true,
    this.rotateStep = 4,
    this.strokeWidthRadian = 0.15,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SweepGradientLoadingRender(config: this);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _SweepGradientLoadingRender renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
    renderObject.config = this;
  }
}

class _SweepGradientLoadingRender extends RenderBox {
  SweepGradientLoadingWidget config;

  Offset get paddingOffset =>
      Offset(config.padding?.left ?? 0, config.padding?.top ?? 0);

  Offset get paddingSize => Offset(
      (config.padding?.right ?? 0) - (config.padding?.left ?? 0),
      (config.padding?.bottom ?? 0) - (config.padding?.top ?? 0));

  Offset get strokeWidthOffset =>
      Offset(config.strokeWidth / 2, config.strokeWidth / 2);

  _SweepGradientLoadingRender({
    required this.config,
  });

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

  /// 开始旋转的角度
  double _startAngle = 0;

  @override
  void paint(PaintingContext context, ui.Offset offset) {
    super.paint(context, offset);
    final center = size.center(offset);
    final circleSizeSize = Size(
      size.width - paddingSize.dx - config.strokeWidth,
      size.height - paddingSize.dy - config.strokeWidth * 2,
    );
    final arc = Rect.fromCenter(
      center: center,
      width: circleSizeSize.shortestSide,
      height: circleSizeSize.shortestSide,
    );
    final strokeWidthRadian = config.strokeWidthRadian;
    final canvas = context.canvas;
    canvas.withRotate(_startAngle, () {
      canvas.drawArc(
          arc,
          strokeWidthRadian,
          pi * 2 - strokeWidthRadian * 2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = config.strokeWidth
            ..shader = ui.Gradient.sweep(
              center,
              (config.colors ??
                      [
                        config.startColor,
                        config.endColor,
                      ])
                  .reversed
                  .toList(),
            ));
    }, anchor: arc.center);
    if (config.isLoading) {
      _startAngle += config.rotateStep.rr;
      _startAngle %= 360;
      postMarkNeedsPaint();
    }
  }
}

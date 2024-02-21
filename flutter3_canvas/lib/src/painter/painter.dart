part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///

/// 绘制元数据
class PaintMeta {
  /// [CanvasViewBox.originMatrix]
  final Matrix4? originMatrix;

  /// [CanvasViewBox.canvasMatrix]
  final Matrix4? canvasMatrix;

  //final CanvasViewBox? viewBox;

  PaintMeta({
    this.originMatrix,
    this.canvasMatrix,
  });

  /// 组合[originMatrix] 和 [canvasMatrix]
  void withPaintMatrix(Canvas canvas, VoidCallback action) {
    //debugger();
    canvas.withMatrix(originMatrix ?? Matrix4.identity(), () {
      canvas.withMatrix(canvasMatrix ?? Matrix4.identity(), action);
    });
  }
}

/// 绘制接口
abstract class IPainter {
  void paint(Canvas canvas, PaintMeta paintMeta);
}

/// 绘制一些监视信息, 比如坐标轴的缩放比例
class CanvasMonitorPainter extends IPainter {
  final CanvasDelegate canvasDelegate;

  CanvasMonitorPainter(this.canvasDelegate);

  @override
  void paint(Canvas canvas, PaintMeta paintMeta) {
    final viewBox = canvasDelegate.canvasViewBox;
    final text = "${(viewBox.scaleX * 100).round()}%";
    final drawAxis = canvasDelegate.canvasPaintManager.axisManager.drawType
        .have(AxisManager.DRAW_AXIS);
    final x = drawAxis
        ? canvasDelegate.canvasPaintManager.axisManager.yAxisWidth
        : 0.0;
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 9,
            )),
        textDirection: TextDirection.ltr)
      ..layout();
    //debugger();
    painter.paint(
      canvas,
      Offset(x + 2, viewBox.paintBounds.bottom - painter.height),
    );
  }
}

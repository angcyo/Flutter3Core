part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 绘制管理, 所有绘制相关的操作, 都在这里, 绘制的入口
class CanvasPaintManager with Diagnosticable {
  final CanvasDelegate canvasDelegate;

  /// 坐标系
  late AxisManager axisManager = AxisManager(this);

  /// 监视信息
  late CanvasMonitorPainter monitorPainter =
      CanvasMonitorPainter(canvasDelegate);

  CanvasPaintManager(this.canvasDelegate);

  /// 绘制边界大小更新后触发
  @entryPoint
  void onUpdatePaintBounds() {
    final paintBounds = canvasDelegate.canvasViewBox.paintBounds;
    final xAxisLeft = paintBounds.left + axisManager.yAxisWidth;
    final yAxisTop = paintBounds.top + axisManager.xAxisHeight;
    axisManager.xAxisBounds = Rect.fromLTRB(xAxisLeft, paintBounds.top,
        paintBounds.right, paintBounds.top + axisManager.xAxisHeight);
    axisManager.yAxisBounds = Rect.fromLTRB(paintBounds.left, yAxisTop,
        paintBounds.left + axisManager.yAxisWidth, paintBounds.bottom);
  }

  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.withOffset(offset, () {
      if (isDebug) {
        /*canvas.drawRect(canvasDelegate.canvasViewBox.canvasBounds,
            Paint()..color = Colors.blue);*/
      }
      final viewBox = canvasDelegate.canvasViewBox;
      final paintMeta = PaintMeta(
        originMatrix: viewBox.originMatrix,
        canvasMatrix: viewBox.canvasMatrix,
      );

      //
      axisManager.painting(canvas, paintMeta);
      //
      canvasDelegate.canvasElementManager.paintElements(canvas, paintMeta);
      //
      monitorPainter.painting(canvas, paintMeta);
    });
    /*canvas.drawRect(canvasDelegate.canvasViewBox.canvasBounds + offset,
        Paint()..color = Colors.blue);
    TextPainter(
        text: TextSpan(
            text: '${canvasDelegate.repaint.value}',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            )),
        textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, offset);*/
  }
}

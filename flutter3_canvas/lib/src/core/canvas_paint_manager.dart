part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/02
///
/// 绘制管理, 所有绘制相关的操作, 都在这里, 绘制的入口
class CanvasPaintManager with Diagnosticable{
  final CanvasDelegate canvasDelegate;

  /// 坐标系
  late AxisManager axisManager = AxisManager(this);

  CanvasPaintManager(this.canvasDelegate);

  @entryPoint
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.withOffset(offset, () {
      canvas.drawRect(canvasDelegate.canvasViewBox.canvasBounds,
          Paint()..color = Colors.blue);

      axisManager.paint(canvas, PaintMeta(matrix: Matrix4.zero()));
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

/// 绘制元数据
class PaintMeta {
  final Matrix4 matrix;

  PaintMeta({
    required this.matrix,
  });
}

/// 绘制接口
abstract class IPaint {
  void paint(Canvas canvas, PaintMeta paintMeta);
}

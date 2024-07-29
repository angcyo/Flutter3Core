part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///
/// 绘制一些监视信息, 比如坐标轴的缩放比例
class CanvasMonitorPainter extends IPainter {
  final CanvasDelegate canvasDelegate;
  final Fps fps = Fps();

  CanvasMonitorPainter(this.canvasDelegate);

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    if (isDebug) {
      fps.update();
    }
    final viewBox = canvasDelegate.canvasViewBox;
    final text =
        "${(viewBox.scaleX * 100).round()}%${isDebug ? " ${fps.fps}" : ""}";
    final drawAxis = canvasDelegate.canvasPaintManager.axisManager.drawType
        .have(CanvasAxisManager.sDrawAxis);
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
    /*assert(() {
      canvas.drawRect(
          viewBox.paintBounds,
          Paint()
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke
            ..color = Colors.redAccent);
      return true;
    }());*/
  }
}

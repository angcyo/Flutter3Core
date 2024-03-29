part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/20
///

/// 绘制元数据
class PaintMeta {
  /// 宿主对象, 标识当前的绘制操作是由哪个对象发起的
  @flagProperty
  final dynamic host;

  /// 坐标系原点偏移
  /// [CanvasViewBox.originMatrix]
  final Matrix4? originMatrix;

  /// 画布缩放/平移/旋转/倾斜
  /// [CanvasViewBox.canvasMatrix]
  final Matrix4? canvasMatrix;

  //final CanvasViewBox? viewBox;

  PaintMeta({
    this.host,
    this.originMatrix,
    this.canvasMatrix,
  });

  /// 获取画布缩放的系数
  double get canvasScale => canvasMatrix?.scaleX ?? 1.0;

  /// 组合[originMatrix] 和 [canvasMatrix]
  void withPaintMatrix(Canvas canvas, VoidCallback action) {
    //debugger();
    canvas.withMatrix(originMatrix ?? Matrix4.identity(), () {
      canvas.withMatrix(canvasMatrix ?? Matrix4.identity(), action);
    });
  }
}

/// 绘制接口
abstract class IPainter with Diagnosticable {
  /// 绘制入口
  void painting(Canvas canvas, PaintMeta paintMeta);
}

/// 绘制一些监视信息, 比如坐标轴的缩放比例
class CanvasMonitorPainter extends IPainter {
  final CanvasDelegate canvasDelegate;

  CanvasMonitorPainter(this.canvasDelegate);

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    final viewBox = canvasDelegate.canvasViewBox;
    final text = "${(viewBox.scaleX * 100).round()}%";
    final drawAxis = canvasDelegate.canvasPaintManager.axisManager.drawType
        .have(AxisManager.sDrawAxis);
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

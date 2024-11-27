part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/27
///
/// [PathSimulationBuilder]
/// [List<PathSimulationInfo>]仿真数据绘制
class PathSimulationPainter extends ElementPainter {
  /// 仿真数据集合
  List<PathSimulationInfo>? simulationInfoList;

  PathSimulationPainter() {
    forceVisibleInCanvasBox = true;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    super.onPaintingSelf(canvas, paintMeta);
    /*canvas.drawRect(
      Rect.fromLTWH(100, 100, 100, 100),
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.red,
    );*/
    for (final info in simulationInfoList ?? <PathSimulationInfo>[]) {
      final path = info.path;
      if (path != null) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth =
                (paintStrokeWidth ?? 1.toDpFromPx()) / paintMeta.canvasScale
            ..color = Colors.red,
        );
      }
    }
  }
}

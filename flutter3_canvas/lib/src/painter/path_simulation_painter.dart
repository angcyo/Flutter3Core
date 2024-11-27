part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/27
///
/// [PathSimulationBuilder]
/// [List<PathSimulationInfo>]仿真数据绘制
class PathSimulationPainter extends ElementPainter {
  /// 仿真数据集合
  PathSimulationInfo? _simulationInfo;

  PathSimulationInfo? get simulationInfo => _simulationInfo;

  set simulationInfo(PathSimulationInfo? value) {
    distance = -1;
    _simulationInfo = value;
    initPaintProperty(rect: value?.bounds);
  }

  /// 绘制的距离, 不能超过[PathSimulationInfo.length]
  /// 同时也是当前光标的位置
  /// -1: 表示绘制所有
  /// other: 绘制进度
  double distance = -1;

  /// 模拟速度, 每一帧移动的距离
  double simulationSpeed = 1;

  /// 是否开始了模拟动画
  bool isStartSimulation = false;

  //--

  /// 移动以及光标的颜色
  Color moveColor = Colors.red;

  /// 线颜色
  Color lineColor = Colors.black;

  /// 十字光标的大小
  @dp
  double crossCursorLength = 20;

  //--

  PathSimulationPainter() {
    forceVisibleInCanvasBox = true;
  }

  /// 开始仿真动画
  @api
  void startSimulation({
    double? speed,
    double? distance,
  }) {
    isStartSimulation = true;
    simulationSpeed = speed ?? simulationSpeed;
    this.distance = distance ?? 0;
    refresh();
  }

  /// 在当前位置暂停
  @api
  void pauseSimulation() {
    isStartSimulation = false;
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

    double startLength = 0;
    for (final part in simulationInfo?.partList ?? <PathSimulationPart>[]) {
      final path = part.path;
      final endLength = startLength + part.length;

      /*assert(() {
        l.d("distance:$distance ($startLength~$endLength) isStartSimulation:$isStartSimulation");
        return true;
      }());*/

      if (path != null) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              (paintStrokeWidth ?? 1.toDpFromPx()) / paintMeta.canvasScale
          ..color = part.color ??
              (part.type == PathSimulationType.line ? lineColor : moveColor);
        //--
        //debugger();
        if (distance < 0 || distance >= startLength) {
          //可能需要绘制
          if (distance < 0 || distance >= endLength) {
            //需要绘制完全的路径
            canvas.drawPath(path, paint);

            if (distance < 0 || distance <= endLength) {
              //绘制光标
              final position = path.getTangentForOffset(0)?.position;
              if (position != null) {
                _drawCrossPath(canvas, paintMeta, paint, position);
              }
            }
          } else {
            //需要绘制一部分的路径
            final partStart = distance - startLength;
            canvas.drawPath(path.extractPath(0, partStart), paint);

            //绘制光标
            final position = path.getTangentForOffset(partStart)?.position;
            if (position != null) {
              _drawCrossPath(canvas, paintMeta, paint, position);
            }
          }
        }
      }
      startLength = endLength;
    }

    //debugger();
    if (simulationInfo != null && isStartSimulation) {
      distance += simulationSpeed;
      if (distance < simulationInfo!.length) {
        refresh();
      } else {
        distance = simulationInfo!.length;
        isStartSimulation = false;
        refresh();
      }
    }
  }

  /// 绘制十字光标
  void _drawCrossPath(
    Canvas canvas,
    PaintMeta paintMeta,
    Paint paint,
    Offset position,
  ) {
    paint.color = moveColor;
    canvas.drawPath(
      generateCrossPath(
        center: position,
        length: crossCursorLength / paintMeta.canvasScale,
      ),
      paint,
    );
  }
}

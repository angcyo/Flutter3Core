part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/27
///
/// [PathSimulationBuilder]
/// [List<PathSimulationInfo>]仿真数据绘制
class PathSimulationPainter extends ElementPainter {
  /// 默认的仿真速度
  /// 1mm ≈ 6.299212598425196
  /// 0.1mm ≈ 0.6299212598425196
  static double baseSimulationSpeed = 1.toDpFromMm();

  /// 仿真数据集合
  @configProperty
  PathSimulationInfo? _simulationInfo;

  PathSimulationInfo? get simulationInfo => _simulationInfo;

  set simulationInfo(PathSimulationInfo? value) {
    distance = -1;
    _simulationInfo = value;
    initPaintProperty(rect: value?.bounds);
  }

  double _distance = -1;

  /// 绘制的距离, 不能超过[PathSimulationInfo.length]
  /// 同时也是当前光标的位置
  /// -1: 表示绘制所有
  /// other: 绘制进度
  @configProperty
  double get distance => _distance;

  set distance(double value) {
    _distance = value;
    onSimulationDistanceChangedAction?.call();
  }

  /// 模拟速度, 每一帧移动的距离
  @configProperty
  double simulationSpeed = baseSimulationSpeed;

  /// [simulationSpeed]的倍率
  @configProperty
  double simulationSpeedScale = 1;

  /// 模拟动画状态
  @configProperty
  SimulationState simulationState = SimulationState.init;

  bool get isStartSimulation => simulationState == SimulationState.start;

  /// 是否绘制移动的路径类型
  @configProperty
  bool enableMovePath = true;

  //--

  /// 移动以及光标的颜色
  @configProperty
  Color moveColor = Colors.red;

  /// 线颜色
  @configProperty
  Color lineColor = Colors.black;

  /// 十字光标的大小
  @dp
  @configProperty
  double crossCursorLength = 20;

  /// 仿真距离改变通知
  @configProperty
  VoidCallback? onSimulationDistanceChangedAction;

  //--

  PathSimulationPainter() {
    forceVisibleInCanvasBox = true;
  }

  /// 开始仿真动画
  /// [start] 是否开始动画
  /// [restart] 是否要重新开始
  /// [speed] 速度
  /// [distance] 指定当前的距离
  @api
  void startSimulation({
    bool start = true,
    double? speed,
    double? speedScale,
    double? distance,
  }) {
    if (start) {
      simulationSpeed = speed ?? simulationSpeed;
      simulationSpeedScale = speedScale ?? simulationSpeedScale;

      if (isStartSimulation) {
        //重复开始
        return;
      }
      simulationState = SimulationState.start;
      if (simulationState == SimulationState.pause) {
        //恢复动画
      } else {
        //重新开始动画
        this.distance = distance ?? max(0, this.distance);
      }
      refresh();
    } else {
      if (isStartSimulation) {
        simulationState = SimulationState.pause;
      } else {
        simulationState = SimulationState.init;
      }
    }
  }

  /// 暂停仿真动画
  @api
  void pauseSimulation() {
    if (isStartSimulation) {
      simulationState = SimulationState.pause;
    }
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

    //是否绘制了光标
    bool isDrawCross = false;
    //当前枚举的路径长度
    double startLength = 0;
    for (final part in simulationInfo?.partList ?? <PathSimulationPart>[]) {
      final path = part.path;
      final endLength = startLength + part.length;

      /*if (!enableMovePath) {
        //debugger(when: isStartSimulation);
        if (part.type != PathSimulationType.line) {
          //跳过移动路径绘制
          if (isStartSimulation) {
            if (distance >= startLength && distance <= endLength) {
              distance = endLength;
              break;
            }
          }
          startLength = endLength;
          continue;
        }
      }*/

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
            _drawPath(canvas, paint, path, part);

            if (distance < 0 || distance <= endLength) {
              //绘制光标
              final position = path.getTangentForOffset(0)?.position;
              if (!isDrawCross && position != null) {
                _drawCrossPath(canvas, paintMeta, paint, position);
                isDrawCross = true;
              }
            }
          } else {
            //需要绘制一部分的路径
            final partStart = distance - startLength;
            _drawPath(canvas, paint, path.extractPath(0, partStart), part);

            //绘制光标
            final position = path.getTangentForOffset(partStart)?.position;
            if (!isDrawCross && position != null) {
              _drawCrossPath(canvas, paintMeta, paint, position);
              isDrawCross = true;
            }
          }
        }
      }
      startLength = endLength;
    }

    //debugger();
    if (simulationInfo != null && isStartSimulation) {
      distance += simulationSpeed * simulationSpeedScale;
      if (distance < simulationInfo!.length) {
        refresh();
      } else {
        distance = simulationInfo!.length;
        simulationState = SimulationState.finish;
        refresh();
      }
    }
  }

  /// 绘制路径
  void _drawPath(
    Canvas canvas,
    Paint paint,
    Path path,
    PathSimulationPart part,
  ) {
    if (part.type == PathSimulationType.line ||
        (part.type != PathSimulationType.line && enableMovePath)) {
      canvas.drawPath(path, paint);
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

/// 仿真状态
enum SimulationState {
  /// 初始化
  init,

  /// 开始了
  start,

  /// 暂停中
  pause,

  /// 结束了
  finish,
}

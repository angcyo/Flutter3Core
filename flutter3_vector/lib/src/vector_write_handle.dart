part of '../flutter3_vector.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/29
///

mixin VectorWriteMixin {
  /// 当前点与上一个点之间的关系, 起点
  static const int pointTypeStart = 0;

  /// 当前点和上一个点在一条直线上
  static const int pointTypeLine = 1;

  /// 当前点和上一个点在一条圆弧上
  static const int pointTypeArc = 2;

  /// flag: 标识位, 表示当前的点和上一个点是同一类型的点
  static const int pointTypeSame = 0x10000;

  /// 矢量公差, 2点之间的凸起或凹陷小于这个值时, 认为是一条直线
  /// 值越大曲线误差越大, 返回的数据量越少;
  /// 值越小, 曲线误差越小, 返回的数据量越多;
  @configProperty
  @dp
  double vectorTolerance = kVectorTolerance.toDpFromMm();

  /// 圆心之间的距离小于这个值时, 认为是一个圆
  @dp
  double get circleTolerance => 1;

  /// 是否启用矢量拟合曲线, 否则只拟合直线
  @configProperty
  @implementation
  bool enableVectorArc = false;

  /// 字符串收集
  @output
  StringBuffer? stringBuffer;

  /// 关键点位收集, 点位数据只能用来拟合直线, 不能拟合曲线
  @output
  List<List<Offset>>? contourPointList;

  ///追加一个点位信息, 拟合成直线或曲线
  ///[posIndex] 当前点的索引, 在轮廓上的第几个点
  ///[ratio] 枚举点位在轮廓上的进度比例[0~1]等于1时, 表示当前的轮廓结束
  ///[contourIndex] 当前点所在的轮廓索引, 不同轮廓上的点, 会被分开处理.
  ///[angle] 当前点的弧度
  @entryPoint
  void appendPoint(
    int posIndex,
    double ratio,
    int contourIndex,
    Offset position,
    double? angle,
  ) {
    final newPoint = VectorPoint(position: position, angle: angle);
    if (_pointList.isEmpty || _lastContourIndex != contourIndex) {
      //第一个点 or 新的轮廓开始
      handleAndClearPointList();
      newPoint.type = pointTypeStart;
      _lastContourIndex = contourIndex;
      _pointList.add(newPoint);
      onContourStart();
      onWritePoint(newPoint);
      _checkEnd(ratio);
      return;
    }
    _lastContourIndex = contourIndex;
    newPoint.type = pointTypeLine;
    if (_pointList.length == 1) {
      //之前只有1个点
      _pointList.add(newPoint);
      _checkEnd(ratio);
      return;
    }
    //---
    final startPoint = _pointList.first;
    final beforePoint = _pointList.last;
    if (enableVectorArc) {
      //曲线拟合
      newPoint.circleStart = startPoint.position;
      newPoint.circleCenter = centerOfCircle(
          newPoint.position, startPoint.position, beforePoint.position);
      if (beforePoint.circleCenter == null) {
        //之前的点没有圆心
        if (isPointInLine(newPoint, startPoint)) {
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        }
      } else if (isPointInCircle(
          beforePoint.circleCenter!, newPoint, startPoint, beforePoint)) {
        newPoint.type = pointTypeArc;
        newPoint.sweepFlag = (angle == null || angle > 0) ? 0 : 1;

        /*if (newPoint.angle != null &&
            startPoint.angle != null &&
            ((newPoint.angle! > 0 && startPoint.angle! > 0) ||
                (newPoint.angle! < 0 && startPoint.angle! < 0))) {
          if (newPoint.angle! > 0 && startPoint.angle! > 0) {
            newPoint.sweepFlag = (newPoint.angle! - startPoint.angle!) -
                        (beforePoint.angle! - startPoint.angle!) >
                    0
                ? 1
                : 0;
          }

          //同向
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        } else {
          handleAndClearPointList();
          _pointList.add(beforePoint);
          _pointList.add(newPoint);
        }*/

        //如果弧度在变大, 则是顺时针, 否则是逆时针
        newPoint.sweepFlag = isClockwise(
                startPoint.position, newPoint.circleCenter!, newPoint.position)
            ? 1
            : 0;
        if (this is SvgWriteHandle &&
            newPoint.angle != null &&
            startPoint.angle != null &&
            (newPoint.angle!.sanitizeRadians -
                        startPoint.angle!.sanitizeRadians)
                    .abs() >=
                pi) {
          //使用A拟合曲线时, 只能模拟小弧, 不成超过180°
          handleAndClearPointList();
          _pointList.add(beforePoint);
          _pointList.add(newPoint);
        } else {
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        }
      } else {
        if (!beforePoint.type.have(pointTypeArc) &&
            isPointInLine(newPoint, startPoint)) {
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        } else {
          handleAndClearPointList();
          _pointList.add(beforePoint);
          _pointList.add(newPoint);
        }
      }
    } else {
      //直线拟合
      if (isPointInLine(newPoint, startPoint)) {
        //相同类型的点
        _pointList.removeLastIfNotEmpty();
        _pointList.add(newPoint);
      } else {
        handleAndClearPointList();
        _pointList.add(newPoint);
      }
    }
    _checkEnd(ratio);
  }

  void _checkEnd(double ratio) {
    //---end---
    if (ratio >= 1) {
      //轮廓结束
      handleAndClearPointList();
      onContourEnd();
    }
  }

  /// 一个轮廓的开始
  @overridePoint
  void onContourStart() {}

  /// 一个轮廓的结束
  @overridePoint
  void onContourEnd() {}

  /// 需要处理的点位
  /// 有可能是一个新的点
  /// 有可能是line
  /// 有可能是arc
  @overridePoint
  void onWritePoint(VectorPoint point) {}

  /// 写入一个点位时可以用来转换坐标
  @overridePoint
  Offset transformPoint(Offset point) => point;

  /// 输出矢量字符串, 比如svg path数据, 或者 svg xml文档, 或者 gcode 文本字符串
  @api
  String? getVectorString() => stringBuffer?.toString();

  /// 判断当前点是否在指定的圆心圆上
  /// [circleCenter] 指定的圆心坐标
  bool isPointInCircle(Offset circleCenter, VectorPoint point,
      VectorPoint startPoint, VectorPoint beforePoint) {
    final cc = centerOfCircle(
        point.position, startPoint.position, beforePoint.position);
    if (cc == null) {
      return false;
    }
    final c = distance(circleCenter, cc);
    return c.abs() < circleTolerance;
  }

  /// 判断2个点是否在一条直线上
  bool isPointInLine(VectorPoint point, VectorPoint beforePoint) {
    final beforeAngle = beforePoint.angle;
    final angle = point.angle;
    if (beforeAngle == null || angle == null) {
      return false;
    }
    final c = distance(point.position, beforePoint.position);
    final h = tan((angle - beforeAngle).abs() / 4) * c / 2;
    return h.abs() < vectorTolerance;
  }

  /// 初始化字符串收集
  StringBuffer initStringBuffer() => stringBuffer ??= StringBuffer();

  //region ---中间数据---

  /// 上一个轮廓的索引
  int? _lastContourIndex;

  /// 采样点, 用来拟合直线或曲线
  List<VectorPoint> _pointList = [];

  /// 处理和重置点位[_pointList]列表
  void handleAndClearPointList() {
    if (_pointList.isNotEmpty) {
      if (_pointList.length > 1) {
        onWritePoint(_pointList.last);
      }
    }
    _pointList = [];
  }

//endregion ---中间数据---
}

/// 矢量上的点
class VectorPoint {
  @dp
  Offset position;

  /// 当前点在路径上的弧度
  double? angle;

  /// 点的类型
  int type;

  //---

  /// 圆开始的坐标, 如果有
  @dp
  Offset? circleStart;

  /// 圆心坐标, 如果有
  @dp
  Offset? circleCenter;

  /// 用来确定是要画小弧（0）还是画大弧（1）
  @implementation
  int largeArcFlag = 0;

  /// 顺时针方向（1）还是逆时针方向（0）
  @implementation
  int sweepFlag = 1;

  VectorPoint({
    required this.position,
    this.angle,
    this.type = VectorWriteMixin.pointTypeStart,
    this.circleStart,
    this.circleCenter,
  });
}

/// 用来输出成svg的path路径数据, 或者svg xml文档
class SvgWriteHandle with VectorWriteMixin {
  /// 是否是闭合路径, 影响z的输出
  bool isPathClose = false;

  @override
  void onWritePoint(VectorPoint point) {
    initStringBuffer();
    final position = transformPoint(point.position);
    if (point.type == VectorWriteMixin.pointTypeStart) {
      stringBuffer?.write('M${position.dx},${position.dy}');
    } else if (point.type.have(VectorWriteMixin.pointTypeLine)) {
      stringBuffer?.write(' L${position.dx},${position.dy}');
    } else if (point.type.have(VectorWriteMixin.pointTypeArc)) {
      final c = distance(position, point.circleCenter!);
      stringBuffer?.write(
          ' A$c,$c 0 ${point.largeArcFlag} ${point.sweepFlag} ${position.dx},${position.dy}');
    }
  }

  @override
  void onContourEnd() {
    if (isPathClose) {
      stringBuffer?.write('z');
    }
  }
}

/// 输出json字符串
class JsonWriteHandle with VectorWriteMixin {
  List<List<Map<String, dynamic>>> jsonResultBuilder = [];
  List<Map<String, dynamic>>? jsonBuilder;

  @override
  void onContourStart() {
    jsonBuilder = [];
  }

  @override
  void onWritePoint(VectorPoint point) {
    final position = transformPoint(point.position);
    if (jsonBuilder != null) {
      jsonBuilder!.add({
        "x": position.dx,
        "y": position.dy,
        "angle": point.angle,
      });
    }
  }

  @override
  void onContourEnd() {
    if (jsonBuilder != null) {
      jsonResultBuilder.add(jsonBuilder!);
      jsonBuilder = null;
    }
  }

  @override
  String? getVectorString() => jsonResultBuilder.toJsonString();
}

/// 用来输出成gcode文本字符串
class GCodeWriteHandle with VectorWriteMixin {
  @override
  void onContourStart() {
    initStringBuffer();
    stringBuffer?.writeln('M03S255');
  }

  @override
  void onContourEnd() {
    stringBuffer?.writeln('M05S0');
  }

  @override
  void onWritePoint(VectorPoint point) {
    initStringBuffer();
    final position = transformPoint(point.position);
    if (point.type == VectorWriteMixin.pointTypeStart) {
      stringBuffer?.writeln('G0X${position.dx}Y${position.dy}');
    } else if (point.type.have(VectorWriteMixin.pointTypeLine)) {
      stringBuffer?.writeln('G1X${position.dx}Y${position.dy}');
    } else if (point.type.have(VectorWriteMixin.pointTypeArc)) {
      if (point.sweepFlag == 1) {
        //顺时针
        stringBuffer?.write("G3");
      } else {
        //逆时针
        stringBuffer?.write("G2");
      }
      final ij = transformPoint(Offset(
          point.circleCenter!.dx - point.circleStart!.dx,
          point.circleCenter!.dy - point.circleStart!.dy));
      stringBuffer?.write('X${position.dx}Y${position.dy}');
      stringBuffer?.writeln('I${ij.dx}J${ij.dy}');
    }
  }
}

extension VectorPathEx on Path {
  /// 转换成gcode字符串数据
  /// [toSvgPathString]
  String? toGCodeString({
    @dp double? pathStep,
    @mm double? tolerance,
  }) {
    final handle = GCodeWriteHandle();
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    handle.initStringBuffer().write('G90\nG21\n');
    //handle.vectorTolerance = 10;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      /*assert(() {
        l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
            'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
        return true;
      }());*/
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, pathStep);
    return handle.getVectorString();
  }

  /// 转换成svg路径字符串数据
  /// [pathStep] 路径采样步长, 默认[kPathAcceptableError]
  /// [tolerance] 公差, 默认[kVectorTolerance]
  String? toSvgPathString({
    @dp double? pathStep,
    @mm double? tolerance,
  }) {
    final handle = SvgWriteHandle();
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      /*assert(() {
        l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
            'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
        return true;
      }());*/
      //debugger();
      handle.isPathClose = isClose;
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, pathStep);
    return handle.getVectorString();
  }

  ///[toSvgPathString]
  String? toPathPointJsonString({
    @dp double? pathStep,
    @mm double? tolerance,
  }) {
    final handle = JsonWriteHandle();
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      /*assert(() {
        l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
            'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
        return true;
      }());*/
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, pathStep);
    return handle.getVectorString();
  }
}

extension VectorListPathEx on List<Path> {
  /// [VectorPathEx.toSvgPathString]
  String? toSvgPathString({
    @dp double? pathStep,
    @mm double? tolerance,
  }) {
    if (isNil(this)) {
      return null;
    }
    final buffer = StringBuffer();
    for (final path in this) {
      final svgPath =
          path.toSvgPathString(pathStep: pathStep, tolerance: tolerance);
      if (!isNil(svgPath)) {
        buffer.write(svgPath);
      }
    }
    return buffer.toString();
  }
}

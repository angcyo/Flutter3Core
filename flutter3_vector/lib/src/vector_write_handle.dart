part of flutter3_vector;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/29
///

/// 公差
/// 1.575 = 0.25mm
/// 0.1 精度可以
/// 0.5 也还可以
@dp
const double kVectorTolerance = 0.5; //

/// 路径采样误差
@dp
const double kPathAcceptableError = 0.01; //

mixin VectorWriteMixin {
  /// 当前点与上一个点之间的关系, 起点
  static const int POINT_TYPE_START = 0;

  /// 当前点和上一个点在一条直线上
  static const int POINT_TYPE_LINE = 1;

  /// 当前点和上一个点在一条圆弧上
  static const int POINT_TYPE_ARC = 2;

  /// flag: 标识位, 表示当前的点和上一个点是同一类型的点
  static const int POINT_TYPE_SAME = 0x10000;

  /// 矢量公差, 2点之间的凸起或凹陷小于这个值时, 认为是一条直线
  /// 值越大曲线误差越大, 返回的数据量越少;
  /// 值越小, 曲线误差越小, 返回的数据量越多;
  @configProperty
  @dp
  double vectorTolerance = kVectorTolerance;

  /// 圆心之间的距离小于这个值时, 认为是一个圆
  @dp
  double get circleTolerance => vectorTolerance;

  /// 是否启用矢量拟合曲线, 否则只拟合直线
  @configProperty
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
      newPoint.type = POINT_TYPE_START;
      _lastContourIndex = contourIndex;
      _pointList.add(newPoint);
      onContourStart();
      onWritePoint(newPoint);
      _checkEnd(ratio);
      return;
    }
    _lastContourIndex = contourIndex;
    newPoint.type = POINT_TYPE_LINE;
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
        newPoint.type = POINT_TYPE_ARC;
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
        if (!beforePoint.type.have(POINT_TYPE_ARC) &&
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
    this.type = VectorWriteMixin.POINT_TYPE_START,
    this.circleStart,
    this.circleCenter,
  });
}

/// 用来输出成svg的path路径数据, 或者svg xml文档
class SvgWriteHandle with VectorWriteMixin {
  @override
  void onWritePoint(VectorPoint point) {
    initStringBuffer();
    final position = transformPoint(point.position);
    if (point.type == VectorWriteMixin.POINT_TYPE_START) {
      stringBuffer?.write('M${position.dx},${position.dy}');
    } else if (point.type.have(VectorWriteMixin.POINT_TYPE_LINE)) {
      stringBuffer?.write(' L${position.dx},${position.dy}');
    } else if (point.type.have(VectorWriteMixin.POINT_TYPE_ARC)) {
      final c = distance(position, point.circleCenter!);
      stringBuffer?.write(
          ' A$c,$c 0 ${point.largeArcFlag} ${point.sweepFlag} ${position.dx},${position.dy}');
    }
  }

  @override
  void onContourEnd() {
    stringBuffer?.write('z');
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
    if (point.type == VectorWriteMixin.POINT_TYPE_START) {
      stringBuffer?.writeln('G0X${position.dx}Y${position.dy}');
    } else if (point.type.have(VectorWriteMixin.POINT_TYPE_LINE)) {
      stringBuffer?.writeln('G1X${position.dx}Y${position.dy}');
    } else if (point.type.have(VectorWriteMixin.POINT_TYPE_ARC)) {
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
  String? toGCodeString() {
    final handle = GCodeWriteHandle();
    handle.enableVectorArc = true;
    handle.initStringBuffer().write('G90\nG21\n');
    //handle.vectorTolerance = 10;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      /*l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
          'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');*/
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, kPathAcceptableError);
    return handle.getVectorString();
  }

  /// 转换成svg路径字符串数据
  String? toSvgPathString() {
    final handle = SvgWriteHandle();
    handle.enableVectorArc = true;
    //handle.vectorTolerance = 10;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
          'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, 0.3 /*kPathAcceptableError*/);
    return handle.getVectorString();
  }

  String? toPathPointJsonString() {
    final handle = JsonWriteHandle();
    handle.enableVectorArc = false;
    handle.vectorTolerance = 0.02;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
          'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, 0.02 /*kPathAcceptableError*/);
    return handle.getVectorString();
  }
}

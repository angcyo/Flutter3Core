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
    final point = VectorPoint(position: position, angle: angle);
    if (_pointList.isEmpty || _lastContourIndex != contourIndex) {
      //第一个点 or 新的轮廓开始
      handleAndClearPointList();
      point.type = POINT_TYPE_START;
      _lastContourIndex = contourIndex;
      _pointList.add(point);
      onContourStart();
      return;
    }
    _lastContourIndex = contourIndex;
    if (_pointList.length == 1) {
      //之前只有一个点
      point.type = POINT_TYPE_LINE;
      _pointList.add(point);
      return;
    }
    final startPoint = _pointList.first;
    final beforePoint = _pointList.last;
    calcPointType(point, startPoint, beforePoint);
    //---

    if (point.type == POINT_TYPE_START) {
      _pointList.add(point);
      onWritePoint(point);
    } else if (point.type.have(POINT_TYPE_SAME)) {
      //相同类型的点
      _pointList.removeLastIfNotEmpty();
      _pointList.add(point);
    } else if (_pointList.length <= 1) {
      //等待下一个点
    } else {
      handleAndClearPointList();
      if (beforePoint != null) {
        _pointList.add(beforePoint);
      }
      _pointList.add(point);
    }
    _lastContourIndex = contourIndex;
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

  /// 输出矢量字符串, 比如svg path数据, 或者 svg xml文档, 或者 gcode 文本字符串
  @api
  String? getVectorString() => stringBuffer?.toString();

  /// 计算点的类型
  /// [point] 当前点
  /// [startPoint] 起点
  /// [beforePoint] 前一个点
  void calcPointType(
    VectorPoint point,
    VectorPoint startPoint,
    VectorPoint beforePoint,
  ) {
    final beforeAngle = beforePoint.angle;
    final angle = point.angle;
    if (beforeAngle == null || angle == null) {
      //没有角度信息, 这个分支不应该进入
      point.type = POINT_TYPE_LINE;
      return;
    }

    //---
    final diffAngle = angle - beforeAngle;
    if (enableVectorArc) {
      //拟合曲线
      final circleCenter = centerOfCircle(
          point.position, startPoint.position, beforePoint.position);
      point.circleCenter = circleCenter;

      final beforeCircleCenter = beforePoint.circleCenter;
      if (beforeCircleCenter == null) {
        //之前的点没有圆心
      } else {
        final c = distance(circleCenter, beforeCircleCenter);
        if (c.abs() < circleTolerance) {
          //在一个圆上
          point.type = POINT_TYPE_ARC;
          if (beforePoint.type.have(POINT_TYPE_ARC)) {
            point.type = point.type | POINT_TYPE_SAME;
          }
          return;
        }
      }
    }

    //拟合直线, 使用公差采样
    point.type = POINT_TYPE_LINE;
    final c = distance(point.position, beforePoint.position);
    final h = tan(diffAngle.abs() / 4) * c / 2;
    if (h.abs() < vectorTolerance) {
      //debugger();
      //在一条直线上
      if (beforePoint.type.have(POINT_TYPE_LINE)) {
        point.type = point.type | POINT_TYPE_SAME;
      }
    }
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

  void initStringBuffer() {
    stringBuffer ??= StringBuffer();
  }

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

  /// 圆心坐标, 如果有
  @dp
  Offset? circleCenter;

  VectorPoint({
    required this.position,
    this.angle,
    this.type = VectorWriteMixin.POINT_TYPE_START,
    this.circleCenter,
  });
}

/// 用来输出成svg的path路径数据, 或者svg xml文档
class SvgWriteHandle with VectorWriteMixin {
  @override
  void onWritePoint(VectorPoint point) {
    initStringBuffer();
    if (point.type == VectorWriteMixin.POINT_TYPE_START) {
      stringBuffer?.write('M${point.position.dx},${point.position.dy} ');
    } else if (point.type.have(VectorWriteMixin.POINT_TYPE_LINE)) {
      stringBuffer?.write('L${point.position.dx},${point.position.dy} ');
    }
  }

  @override
  void onContourEnd() {
    stringBuffer?.write('z');
  }
}

/// 用来输出成gcode文本字符串
class GCodeWriteHandle with VectorWriteMixin {}

extension VectorPathEx on Path {
  String? toSvgString() {
    final svgWriteHandle = SvgWriteHandle();
    svgWriteHandle.enableVectorArc = true;
    //svgWriteHandle.vectorTolerance = 10;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      l.d('$isClose posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
          'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
      svgWriteHandle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, kVectorTolerance);
    return svgWriteHandle.getVectorString();
  }
}

part of flutter3_vector;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/29
///

/// 公差
@dp
const vectorTolerance = 1.0;

mixin VectorWriteMixin {
  /// 当前点与上一个点之间的关系, 起点
  static const int POINT_TYPE_START = 0;

  /// 当前点和上一个点在一条直线上
  static const int POINT_TYPE_LINE = 1;

  /// 当前点和上一个点在一条圆上
  static const int POINT_TYPE_CIRCLE = 2;

  /// 字符串收集
  @output
  StringBuffer? stringBuffer;

  /// 关键点位收集, 点位数据只能用来拟合直线, 不能拟合曲线
  List<List<Offset>>? contourPointList;

  ///追加一个点位信息, 拟合成直线或曲线
  ///[posIndex] 当前点的索引, 在轮廓上的第几个点
  ///[contourIndex] 当前点所在的轮廓索引, 不同轮廓上的点, 会被分开处理.
  ///[angle] 当前点的弧度
  @entryPoint
  void appendPoint(
    int posIndex,
    int contourIndex,
    Offset position,
    double? angle,
  ) {}

  /// 输出矢量字符串, 比如svg path数据, 或者 svg xml文档, 或者 gcode 文本字符串
  @api
  String? getVectorString() => stringBuffer?.toString();

  /// 计算点的类型
  void calcPointType(VectorPoint point, VectorPoint? beforePoint) {
    //point.type = POINT_TYPE_START;
  }

  //region ---中间数据---

  /// 上一个轮廓的索引
  int? _lastContourIndex;

  /// 采样点, 用来拟合直线或曲线
  List<VectorPoint> _pointList = [];

//endregion ---中间数据---
}

/// 矢量上的点
class VectorPoint {
  @dp
  Offset position;

  /// 弧度
  double? angle;

  /// 点的类型
  int type;

  VectorPoint({
    required this.position,
    this.angle,
    this.type = VectorWriteMixin.POINT_TYPE_START,
  });
}

class SvgWriteHandle with VectorWriteMixin {}

extension VectorPathEx on Path {
  String? toSvgString() {
    final svgWriteHandle = SvgWriteHandle();
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle) {
      l.d('posIndex:$posIndex ratio:${ratio.toDigits()} contourIndex:$contourIndex '
          'position:$position angle:${angle.toDigits()} ${angle.toDegrees}°');
      svgWriteHandle.appendPoint(posIndex, contourIndex, position, angle);
    }, 20);
    return svgWriteHandle.getVectorString();
  }
}

part of '../flutter3_vector.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/02/29
///

/// svg xml头部
const _kSvgHeader = '<?xml version="1.0" encoding="UTF-8"?>'
    '<!-- Created with LaserPecker Design Space (https://www.laserpecker.net/pages/software) -->\n';

/// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute
String _wrapSvgXml(Rect bounds, void Function(StringBuffer) action) {
  StringBuffer buffer = StringBuffer();
  buffer.write(_kSvgHeader);
  buffer.write('<svg xmlns="http://www.w3.org/2000/svg" ');
  buffer.write('xmlns:acy="https://www.github.com/angcyo" ');
  buffer.write(
      'viewBox="${bounds.left} ${bounds.top} ${bounds.width} ${bounds.height}" ');
  buffer.write(
      'width="${bounds.width.toMmFromDp()}mm" height="${bounds.height.toMmFromDp()}mm" ');
  buffer.write('acy:author="angcyo" acy:version="1">');
  action(buffer);
  buffer.write('</svg>');
  return buffer.toString();
}

/// https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill-rule
void _wrapSvgPath(
  StringBuffer? buffer,
  String? svgPath, {
  bool fill = false,
  Color fillColor = Colors.black,
  bool stroke = true,
  Color strokeColor = Colors.black,
  @dp double strokeWidth = 1,
}) {
  if (isNil(svgPath)) {
    return;
  }
  buffer?.write('<path d="$svgPath" ');
  if (fill) {
    buffer?.write('fill="${fillColor.toHex(a: false)}" ');
  } else {
    buffer?.write('fill="none" ');
  }
  buffer?.write('fill-rule="evenodd" ');
  if (stroke) {
    buffer?.write('stroke="${strokeColor.toHex(a: false)}" ');
    buffer?.write('stroke-width="$strokeWidth" ');
  }
  buffer?.write('/>');
}

/// gcode 默认头部
const kGCodeHeader = 'G21\nG90\nM8\nM5\nM3\n';

/// gcode 自动激光头
const kGCodeAutoHeader = 'G21\nG90\nM8\nM5\nM4\n';

/// gcode 默认尾部
const kGCodeFooter = 'M5\nM9\nG1 S0\nM2\n';

/// 默认切割数据使用的宽度/直径
@mm
const sDefaultCutWidth = 0.3;

/// 默认切割数据使用的步长
@mm
const sDefaultCutStep = 0.03;

mixin VectorWriteMixin {
  /// 当前点与上一个点之间的关系, 起点
  static const int sPointTypeStart = 0;

  /// 当前点和上一个点在一条直线上
  static const int sPointTypeLine = 1;

  /// 当前点和上一个点在一条圆弧上
  static const int sPointTypeArc = 2;

  /// flag: 标识位, 表示当前的点和上一个点是同一类型的点
  static const int sPointTypeSame = 0x10000;

  /// 保留的小数点位数
  int digits = 6;

  /// 矢量公差, 2点之间的凸起或凹陷小于这个值时, 认为是一条直线
  /// 值越大曲线误差越大, 返回的数据量越少;
  /// 值越小, 曲线误差越小, 返回的数据量越多;
  @configProperty
  @dp
  double vectorTolerance = kVectorTolerance.toDpFromMm();

  /// 存储的矢量步长, 用来枚举[Path]路径
  /// [kPathAcceptableError]
  @dp
  double vectorStep = kPathAcceptableError;

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
  List<List<Point>>? get contourPointList => pointWriteHandle?.pointList;

  /// 配置此项后才会收集点位数据[contourPointList]
  PointWriteHandle? pointWriteHandle;

  /// 父类的写入句柄
  VectorWriteMixin? parentWriteHandle;

  /// [transformPoint]
  @configProperty
  Offset Function(Offset point)? transformPointAction;

  ///追加一个点位信息, 拟合成直线或曲线
  ///[posIndex] 当前点的索引, 在轮廓上的第几个点
  ///[ratio] 枚举点位在轮廓上的进度比例[0~1]等于1时, 表示当前的轮廓结束
  ///[contourIndex] 当前点所在的轮廓索引, 不同轮廓上的点, 会被分开处理.
  ///[angle] 当前点的弧度
  ///[data] 附加的点位额外数据, 用来自定义标识
  @entryPoint
  void appendPoint(
    int posIndex,
    double ratio,
    int contourIndex,
    Offset position,
    double? angle, [
    dynamic data,
  ]) {
    parentWriteHandle?.appendPoint(
      posIndex,
      ratio,
      contourIndex,
      position,
      angle,
    );
    final newPoint = VectorPoint(position: position, angle: angle);
    if (_pointList.isEmpty || _lastContourIndex != contourIndex) {
      //第一个点 or 新的轮廓开始
      handleAndClearPointList(data);
      newPoint.type = sPointTypeStart;
      _lastContourIndex = contourIndex;
      _pointList.add(newPoint);
      onContourStart();
      onWritePoint(newPoint, data);
      _checkEnd(ratio, data);
      return;
    }
    _lastContourIndex = contourIndex;
    newPoint.type = sPointTypeLine;
    if (_pointList.length == 1) {
      //之前只有1个点
      _pointList.add(newPoint);
      _checkEnd(ratio, data);
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
        newPoint.type = sPointTypeArc;
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
          handleAndClearPointList(data);
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
          handleAndClearPointList(data);
          _pointList.add(beforePoint);
          _pointList.add(newPoint);
        } else {
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        }
      } else {
        if (!beforePoint.type.have(sPointTypeArc) &&
            isPointInLine(newPoint, startPoint)) {
          _pointList.removeLastIfNotEmpty();
          _pointList.add(newPoint);
        } else {
          handleAndClearPointList(data);
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
        handleAndClearPointList(data);
        _pointList.add(newPoint);
      }
    }
    _checkEnd(ratio, data);
  }

  void _checkEnd(double ratio, [dynamic data]) {
    //---end---
    if (ratio >= 1) {
      //轮廓结束
      handleAndClearPointList(data);
      onContourEnd();
    }
  }

  /// 一个轮廓的开始
  @overridePoint
  @mustCallSuper
  void onContourStart() {
    pointWriteHandle?.onContourStart();
  }

  /// 一个轮廓的结束
  @overridePoint
  @mustCallSuper
  void onContourEnd() {
    pointWriteHandle?.onContourEnd();
  }

  /// 需要处理的点位
  /// 有可能是一个新的点
  /// 有可能是line
  /// 有可能是arc
  /// [VectorWriteMixin.appendPoint]
  @overridePoint
  @mustCallSuper
  void onWritePoint(VectorPoint point, [dynamic data]) {
    pointWriteHandle?.onWritePoint(point, data);
  }

  /// 写入一个点位时可以用来转换坐标
  @overridePoint
  Offset transformPoint(Offset point) =>
      transformPointAction?.call(point) ?? point;

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
  void handleAndClearPointList([dynamic data]) {
    if (_pointList.isNotEmpty) {
      if (_pointList.length > 1) {
        onWritePoint(_pointList.last, data);
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
    this.type = VectorWriteMixin.sPointTypeStart,
    this.circleStart,
    this.circleCenter,
  });

  /// copy
  VectorPoint copyWith({
    Offset? position,
    double? angle,
    int? type,
    Offset? circleStart,
    Offset? circleCenter,
    int? largeArcFlag,
    int? sweepFlag,
  }) {
    return VectorPoint(
      position: position ?? this.position,
      angle: angle ?? this.angle,
      type: type ?? this.type,
      circleStart: circleStart ?? this.circleStart,
      circleCenter: circleCenter ?? this.circleCenter,
    );
  }
}

/// 用来输出成svg的path路径数据, 或者svg xml文档
class SvgWriteHandle with VectorWriteMixin {
  /// 是否是闭合路径, 影响z的输出
  bool isPathClose = false;

  @override
  void onWritePoint(VectorPoint point, [dynamic data]) {
    initStringBuffer();
    final position = transformPoint(point.position);
    var x = position.dx.toDigits(digits: digits);
    var y = position.dy.toDigits(digits: digits);
    if (point.type == VectorWriteMixin.sPointTypeStart) {
      stringBuffer?.write('M$x,$y');
    } else if (point.type.have(VectorWriteMixin.sPointTypeLine)) {
      stringBuffer?.write(' L$x,$y');
    } else if (point.type.have(VectorWriteMixin.sPointTypeArc)) {
      final c =
          distance(position, point.circleCenter!).toDigits(digits: digits);
      stringBuffer
          ?.write(' A$c,$c 0 ${point.largeArcFlag} ${point.sweepFlag} $x,$y');
    }
    super.onWritePoint(point.copyWith(position: position), data);
  }

  @override
  void onContourEnd() {
    super.onContourEnd();
    if (isPathClose) {
      stringBuffer?.write('z');
    }
  }
}

/// 输出二维点位数组
class PointWriteHandle with VectorWriteMixin {
  List<List<Point>> pointResultBuilder = [];
  List<Point>? pointBuilder;

  /// 获取点位数据
  List<List<Point>> get pointList => pointResultBuilder;

  @override
  void onContourStart() {
    super.onContourStart();
    pointBuilder = [];
  }

  @override
  void onWritePoint(VectorPoint point, [dynamic data]) {
    final position = transformPoint(point.position);
    if (pointBuilder != null) {
      var x = position.dx;
      var y = position.dy;
      var a = point.angle;
      pointBuilder?.add(Point(x, y, a));
    }
    super.onWritePoint(point.copyWith(position: position), data);
  }

  @override
  void onContourEnd() {
    super.onContourEnd();
    if (pointBuilder != null) {
      pointResultBuilder.add(pointBuilder!);
      pointBuilder = null;
    }
  }

  @override
  String? getVectorString() => pointResultBuilder.toJsonString(null);
}

/// 输出json字符串, 二维数组
class JsonWriteHandle with VectorWriteMixin {
  List<List<Map<String, dynamic>>> jsonResultBuilder = [];
  List<Map<String, dynamic>>? jsonBuilder;

  @override
  void onContourStart() {
    super.onContourStart();
    jsonBuilder = [];
  }

  @override
  void onWritePoint(VectorPoint point, [dynamic data]) {
    final position = transformPoint(point.position);
    if (jsonBuilder != null) {
      var x = position.dx.toDigits(digits: digits);
      var y = position.dy.toDigits(digits: digits);
      var a = point.angle?.toDigits(digits: digits);
      jsonBuilder!.add({
        "x": x,
        "y": y,
        "a": a, //弧度
      });
    }
    super.onWritePoint(point.copyWith(position: position), data);
  }

  @override
  void onContourEnd() {
    super.onContourEnd();
    if (jsonBuilder != null) {
      jsonResultBuilder.add(jsonBuilder!);
      jsonBuilder = null;
    }
  }

  @override
  String? getVectorString() => jsonResultBuilder.toJsonString(null);
}

/// 用来输出成gcode文本字符串
/// ```
/// GCode文本的头尾, 需要自行添加
/// handle.initStringBuffer().write('G90\nG21\nM8\nG1F12000\n');
/// handle.initStringBuffer().write(M2\n');
/// ```
class GCodeWriteHandle with VectorWriteMixin {
  /// 默认GCode使用毫米单位, 入参的数据需要时dp单位
  /// [IUnit.mm]
  IUnit? unit = IUnit.mm;

  //---

  /// 功率 255
  int? power;

  ///速度, GCode里面是每分钟 12000/m
  int? speed;

  String get _powerString => power != null ? 'S$power' : '';

  String get _speedString => speed != null ? 'F$speed' : '';

  //---

  /// 是否使用切割数据
  bool useCutData = false;

  /// 切割单次循环次数
  int cutDataLoopCount = 1;

  /// 切割数据的宽度
  @mm
  double cutDataWidth = sDefaultCutWidth;

  /// 切割数据的枚举步长
  @mm
  double cutDataStep = sDefaultCutStep;

  @mm
  @override
  Offset transformPoint(@dp Offset point) {
    if (transformPointAction != null) {
      return transformPointAction?.call(point) ?? point;
    }
    final x = unit?.toUnitFromDp(point.dx) ?? point.dx;
    final y = unit?.toUnitFromDp(point.dy) ?? point.dy;
    return Offset(x, y);
  }

  @override
  void onContourStart() {
    super.onContourStart();
    initStringBuffer();
  }

  /// 是否是轮廓的第一个点
  bool _isContourFirst = true;

  @override
  void onContourEnd() {
    super.onContourEnd();
    _isContourFirst = true;
  }

  /// 自动激光在第一个G1指令后面写入功率和速度
  void _writePowerSpeed() {
    if (_isContourFirst) {
      stringBuffer?.writeln('$_powerString$_speedString');
      _isContourFirst = false;
    } else {
      stringBuffer?.write('\n');
    }
  }

  @override
  void onWritePoint(VectorPoint point, [dynamic data]) {
    initStringBuffer();
    final position = transformPoint(point.position);
    var x = position.dx.toDigits(digits: digits);
    var y = position.dy.toDigits(digits: digits);
    if (point.type == VectorWriteMixin.sPointTypeStart) {
      stringBuffer?.writeln('G0X${x}Y$y');
    } else if (point.type.have(VectorWriteMixin.sPointTypeLine)) {
      if (useCutData && data == null) {
        // 通过data来判断是否需要使用切割数据
        for (var i = 0; i < cutDataLoopCount; i++) {
          //fillCutGCodeByZ(lastWriteX, lastWriteY, point.x, point.y)
          final startPosition = _pointList.firstOrNull;
          if (startPosition != null) {
            _pointList.removeFirstIfNotEmpty();
            _fillCutGCodeByCircle(startPosition.position, point.position);
            if (i != cutDataLoopCount - 1) {
              //多次循环数据的话, 需要移动到起点
              stringBuffer?.writeln('G0X${x}Y$y');
            }
          }
        }
      } else {
        stringBuffer?.write('G1X${x}Y$y');
        _writePowerSpeed();
      }
    } else if (point.type.have(VectorWriteMixin.sPointTypeArc)) {
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
      stringBuffer?.write('X${x}Y$y');
      stringBuffer?.writeln(
          'I${ij.dx.toDigits(digits: digits)}J${ij.dy.toDigits(digits: digits)}');
      _writePowerSpeed();
    }
    super.onWritePoint(point.copyWith(position: position), data);
  }

  /// 使用圆形切割数据填充一根线段
  /// [startPosition] 开始的点,未[transformPoint]之前的原始位置
  /// [endPosition] 结束的点, 未[transformPoint]之前的原始位置
  ///
  /// [VectorPathEx.toVectorString]
  void _fillCutGCodeByCircle(@dp Offset startPosition, @dp Offset endPosition) {
    //圆的直径
    @dp
    final diameter = cutDataWidth.toDpFromMm();
    //圆心移动步长
    @dp
    final step = cutDataStep.toDpFromMm();

    //直线
    final linePath = Path();
    linePath.moveTo(startPosition.dx, startPosition.dy);
    linePath.lineTo(endPosition.dx, endPosition.dy);

    /// 在指定的位置画一个圆
    /// [center] 圆心坐标
    void circleIn(@dp Offset center) {
      final circlePath = Path();
      circlePath.addOval(Rect.fromCircle(center: center, radius: diameter / 2));

      circlePath.eachPathMetrics(
          (posIndex, ratio, contourIndex, position, angle, isClose) {
        appendPoint(
            posIndex, ratio, contourIndex + 0xffff, position, angle, "cut");
      }, vectorStep);
    }

    linePath.eachPathMetrics(
        (posIndex, ratio, contourIndex, position, angle, isClose) {
      circleIn(position);
    }, step);
  }
}

extension VectorPathEx on Path {
  /// 转换成矢量字符串数据
  String? toVectorString(
    VectorWriteMixin handle, {
    @dp double? pathStep,
    @mm double? tolerance,
  }) {
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    handle.vectorStep = pathStep ?? kPathAcceptableError;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      handle.appendPoint(
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
      );
    }, handle.vectorStep);
    return handle.getVectorString();
  }

  /// 转换成gcode字符串数据
  /// [toSvgPathString]
  /// [VectorListPathEx.toGCodeString]
  String? toGCodeString({
    @dp double? pathStep,
    @mm double? tolerance,
    int? power,
    int? speed,
    String? header = kGCodeAutoHeader,
    String? footer = kGCodeFooter,
    GCodeWriteHandle? handle,
  }) {
    handle ??= GCodeWriteHandle();
    handle
      ..power = power
      ..speed = speed;
    handle.initStringBuffer().write(header);
    toVectorString(handle, pathStep: pathStep, tolerance: tolerance);
    handle.initStringBuffer().write(footer);
    return handle.getVectorString();
  }

  /// 转换成svg路径字符串数据
  /// [pathStep] 路径采样步长, 默认[kPathAcceptableError]
  /// [tolerance] 公差, 默认[kVectorTolerance]
  /// `M0,0 L100,0 L100,100 L0,100 L0,0z`
  String? toSvgPathString({
    @dp double? pathStep,
    @mm double? tolerance,
    SvgWriteHandle? handle,
  }) {
    handle ??= SvgWriteHandle();
    return toVectorString(
      handle,
      pathStep: pathStep,
      tolerance: tolerance,
    );
  }

  /// 输出svg xml文件格式
  /// [toSvgPathString]
  String? toSvgXmlString({
    @dp double? pathStep,
    @mm double? tolerance,
    SvgWriteHandle? handle,
  }) {
    final svgPath = toSvgPathString(
      pathStep: pathStep,
      tolerance: tolerance,
      handle: handle,
    );
    if (isNil(svgPath)) {
      return null;
    }
    final bounds = getExactBounds(true, pathStep);
    return _wrapSvgXml(bounds, (buffer) {
      _wrapSvgPath(buffer, svgPath);
    });
  }

  ///[toSvgPathString], `a`是弧度
  ///```
  /// [[{"x":"0","y":"0","a":"0"},
  /// {"x":"100","y":"0","a":"0"},
  /// {"x":"100","y":"100","a":"-1.570796"},
  /// {"x":"0","y":"100","a":"-3.141593"},
  /// {"x":"0","y":"0","a":"1.570796"}]]
  ///```
  String? toPathPointJsonString({
    @dp double? pathStep,
    @mm double? tolerance,
    JsonWriteHandle? handle,
  }) {
    handle ??= JsonWriteHandle();
    return toVectorString(handle, pathStep: pathStep, tolerance: tolerance);
  }

  /// ```
  /// [[Point{x:0.0, y:0.0 a:-0.0}, Point{x:100.0, y:0.0 a:-0.0},
  /// Point{x:100.0, y:100.0 a:-1.5707963267948966}, Point{x:0.0, y:100.0 a:-3.141592653589793},
  /// Point{x:0.0, y:0.0 a:1.5707963267948966}]]
  /// ```
  List<List<Point>> toPointList({
    @dp double? pathStep,
    @mm double? tolerance,
    PointWriteHandle? handle,
  }) {
    handle ??= PointWriteHandle();
    toVectorString(handle, pathStep: pathStep, tolerance: tolerance);
    return handle.pointList;
  }
}

extension VectorListPathEx on List<Path> {
  /// [VectorPathEx.toSvgPathString]
  String? toSvgPathString({
    @dp double? pathStep,
    @mm double? tolerance,
    SvgWriteHandle? handle,
  }) {
    if (isNil(this)) {
      return null;
    }
    final buffer = StringBuffer();
    for (final path in this) {
      final svgPath = path.toSvgPathString(
        pathStep: pathStep,
        tolerance: tolerance,
        handle: handle,
      );
      if (!isNil(svgPath)) {
        buffer.write(svgPath);
      }
    }
    return buffer.toString();
  }

  /// [VectorPathEx.toSvgXmlString]
  String? toSvgXmlString({
    @dp double? pathStep,
    @mm double? tolerance,
    SvgWriteHandle? handle,
  }) {
    if (isNil(this)) {
      return null;
    }
    final bounds = getExactBounds(true, pathStep);
    return _wrapSvgXml(bounds, (buffer) {
      for (final path in this) {
        final svgPath = path.toSvgPathString(
          pathStep: pathStep,
          tolerance: tolerance,
          handle: handle,
        );
        if (!isNil(svgPath)) {
          _wrapSvgPath(buffer, svgPath);
        }
      }
    });
  }

  /// 转换成gcode字符串数据
  /// [VectorPathEx.toGCodeString]
  String? toGCodeString({
    @dp double? pathStep,
    @mm double? tolerance,
    int? power,
    int? speed,
    String? header = kGCodeAutoHeader,
    String? footer = kGCodeFooter,
    GCodeWriteHandle? handle,
  }) {
    final buffer = StringBuffer();
    handle ??= GCodeWriteHandle();
    handle
      ..power = power
      ..speed = speed;
    buffer.write(header);
    for (final path in this) {
      handle.stringBuffer = StringBuffer();
      final gcode = path.toVectorString(
        handle,
        pathStep: pathStep,
        tolerance: tolerance,
      );
      if (!isNil(gcode)) {
        buffer.write(gcode);
      }
    }
    buffer.write(footer);
    return buffer.toString();
  }
}

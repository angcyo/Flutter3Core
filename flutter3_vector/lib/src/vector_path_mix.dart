part of '../flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/23
///
/// 矢量[Path]相关扩展
extension VectorPathEx on Path {
  /// 路径对应的轮廓数量
  /// - [VectorPathEx.contourCount]
  int get contourCount => computeMetrics().length;

  /// 将轮廓拆分成对应的[Path]
  ///
  /// - [VectorPathEx.splitContours]
  List<Path> splitContours() {
    final result = <Path>[];
    final metrics = computeMetrics();
    for (final metric in metrics) {
      final contour = metric.extractPath(
        0,
        metric.length,
        startWithMoveTo: true,
      );
      if (!contour.isEmpty) {
        result.add(contour);
      }
    }
    return result;
  }

  /// 处理矢量路径
  /// - [kVectorTolerance]
  /// - [kPathAcceptableError]
  void handleVectorPath(
    VectorWriteMixin handle, {
    bool isMmPath = false,
    @defInjectMark @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
  }) {
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    handle.vectorStep = pathStep ?? handle.vectorStep;

    if (isMmPath) {
      handle.vectorTolerance = handle.vectorTolerance.toMmFromDp();
      //handle.vectorStep = handle.vectorStep.toMmFromDp();
    }

    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      handle.appendPoint(posIndex, ratio, contourIndex, position, angle);
    }, handle.vectorStep);
  }

  /// [handleVectorPath]
  Future handleVectorPathAsync(
    VectorWriteMixin handle, {
    @dp double? pathStep,
    @mm double? tolerance,
    //--
    int? contourInterval /*轮廓枚举延迟*/,
    int? stepInterval /*步长枚举延迟*/,
  }) async {
    handle.enableVectorArc = false;
    handle.vectorTolerance = tolerance?.toDpFromMm() ?? handle.vectorTolerance;
    handle.vectorStep = pathStep ?? kPathAcceptableError;
    await eachPathMetricsAsync(
      (posIndex, ratio, contourIndex, position, angle, isClose) {
        handle.appendPoint(posIndex, ratio, contourIndex, position, angle);
      },
      handle.vectorStep,
      contourInterval,
      stepInterval,
    );
  }

  /// 转换成矢量字符串数据
  String? toVectorString(
    VectorWriteMixin handle, {
    bool isMmPath = false,
    @defInjectMark @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
  }) {
    handleVectorPath(
      handle,
      isMmPath: isMmPath,
      pathStep: pathStep,
      tolerance: tolerance,
    );
    return handle.getVectorString();
  }

  /// [toVectorString] 的异步api
  Future<String?> toVectorStringAsync(
    VectorWriteMixin handle, {
    @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
    //--
    int? contourInterval /*轮廓枚举延迟*/,
    int? stepInterval /*步长枚举延迟*/,
  }) async {
    await handleVectorPathAsync(
      handle,
      pathStep: pathStep,
      tolerance: tolerance,
      contourInterval: contourInterval,
      stepInterval: stepInterval,
    );
    return handle.getVectorString();
  }

  /// 转换成gcode字符串数据
  /// - [unit] 当前[path]的数据需要转换成的单位
  ///   - 如果当前[path]已经是mm单位, 则传入null
  ///
  /// - [toSvgPathString]
  /// - [VectorListPathEx.toGCodeString]
  String? toGCodeString({
    @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
    //--
    String? header,
    String? footer,
    String? toolOn,
    String? toolOff,
    //--用来生成上述的[header]/[footer]/[toolOn]/[toolOff]
    int? power,
    int? speed,
    bool? autoLaser, //必须指定才会自动生成GCode参数
    GCodeWriteHandle? handle,
    int digits = 3,
    IUnit? unit = IUnit.mm,
  }) {
    header ??= autoLaser != null
        ? GCodeWriteHandle.gcodeHeader(power, speed, auto: autoLaser)
        : null;
    footer ??= autoLaser != null
        ? GCodeWriteHandle.gcodeFooter(autoLaser)
        : null;
    toolOn ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOn(auto: autoLaser, power: speed)
        : null;
    toolOff ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOff(autoLaser)
        : null;

    handle ??= GCodeWriteHandle();
    handle
      ..unit = unit
      ..digits = digits
      ..toolOn = toolOn
      ..toolOff = toolOff;
    handle.initStringBuffer().write(header ?? "");
    toVectorString(handle, pathStep: pathStep, tolerance: tolerance);
    handle.initStringBuffer().write(footer ?? "");
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
    //--
    int? digits,
  }) {
    handle ??= SvgWriteHandle();
    handle.digits = digits ?? handle.digits;
    return toVectorString(handle, pathStep: pathStep, tolerance: tolerance);
  }

  /// [toSvgPathString]
  Future<String?> toSvgPathStringAsync({
    @dp double? pathStep,
    @mm double? tolerance,
    //--
    int? contourInterval /*轮廓枚举延迟*/,
    int? stepInterval /*步长枚举延迟*/,
    //--
    SvgWriteHandle? handle,
    //--
    int? digits,
  }) async {
    handle ??= SvgWriteHandle();
    handle.digits = digits ?? handle.digits;

    return toVectorStringAsync(
      handle,
      pathStep: pathStep,
      tolerance: tolerance,
      contourInterval: contourInterval,
      stepInterval: stepInterval,
    );
  }

  /// 输出svg xml文件格式
  /// [toSvgPathString]
  String? toSvgXmlString({
    bool? exact,
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
    final bounds = getExactBounds(exact, pathStep);
    return _wrapSvgXml(bounds, (buffer) {
      _wrapSvgPath(buffer, svgPath);
    });
  }

  /// [toSvgXmlString]
  Future<String?> toSvgXmlStringAsync({
    bool? exact,
    @dp double? pathStep,
    @mm double? tolerance,
    SvgWriteHandle? handle,
  }) async {
    final svgPath = await toSvgPathStringAsync(
      pathStep: pathStep,
      tolerance: tolerance,
      handle: handle,
    );
    if (isNil(svgPath)) {
      return null;
    }
    final bounds = getExactBounds(exact, pathStep);
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
  ///
  /// - [precision] 数据输出的精度, 也就是输出数据需要放大的小数点后几位
  List<List<Point>> toPointList({
    bool isMmPath = false,
    int precision = 0,
    @defInjectMark @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
    PointWriteHandle? handle,
  }) {
    handle ??= PointWriteHandle();
    handle.digits = precision;
    if (isMmPath) {
      handle.unit = IUnit.mm;
    } else {
      handle.unit = null;
    }
    toVectorString(
      handle,
      isMmPath: isMmPath,
      pathStep: pathStep,
      tolerance: tolerance,
    );
    return handle.pointList;
  }

  /// 将path转换为切割GCode数据
  /// [toCutPathList]
  String toCutGCodeString({
    @mm double cutDataStep = sDefaultCutStep,
    @mm double cutDataWidth = sDefaultCutWidth,
    String? header,
    String? footer,
    String? toolOn,
    String? toolOff,
    //--用来生成上述的[header]/[footer]/[toolOn]/[toolOff]
    int? power,
    int? speed,
    bool? autoLaser, //必须指定才会自动生成
    int digits = 3,
    //--
    String space = kGCodeSpace,
  }) {
    final buffer = StringBuffer();
    //圆的直径
    @dp
    final diameter = cutDataWidth.toDpFromMm();
    //圆心移动步长
    @dp
    final step = cutDataStep.toDpFromMm();

    header ??= autoLaser != null
        ? GCodeWriteHandle.gcodeHeader(power, speed, auto: autoLaser)
        : null;
    footer ??= autoLaser != null
        ? GCodeWriteHandle.gcodeFooter(autoLaser)
        : null;
    toolOn ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOn(auto: autoLaser, power: speed)
        : null;
    toolOff ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOff(autoLaser)
        : null;

    //mm单位缩放因子
    double? factor = $mmFactor;

    final radius = diameter / 2;
    /*final i = (radius / factor).toDigits(digits: digits);
    final j = i;*/

    buffer.writeIf(header ?? "");
    eachPathMetrics((
      posIndex,
      ratio,
      contourIndex,
      position,
      radians,
      isClose,
    ) {
      final matrix = createRotateMatrix(radians, anchor: position);
      Offset startOffset = Offset(position.dx - radius, position.dy - radius);
      startOffset = matrix.mapPoint(startOffset);

      //使用圆形数据切割
      final x = (startOffset.dx / factor).toDigits(digits: digits);
      final y = (startOffset.dy / factor).toDigits(digits: digits);

      final i = ((position.dx - startOffset.dx) / factor).toDigits(
        digits: digits,
      );
      final j = ((position.dy - startOffset.dy) / factor).toDigits(
        digits: digits,
      );

      buffer.writelnIf(toolOff);
      buffer.writelnIf('G0${space}X$x${space}Y$y');
      buffer.writelnIf(toolOn);
      buffer.writelnIf("G2${space}X$x${space}Y$y${space}I$i${space}J$j");
    }, step);
    buffer.writeIf(footer ?? "");
    return buffer.toString();
  }

  /// 将path转换为切割路径集合
  /// [cutDataWidth] 切割的宽度
  /// [cutDataStep] 切割的步长
  /// [kVectorTolerance]
  /// [kPathAcceptableError]
  List<Path> toCutPathList({
    @mm double cutDataStep = sDefaultCutStep,
    @mm double cutDataWidth = sDefaultCutWidth,
  }) {
    final result = <Path>[];
    //圆的直径
    @dp
    final diameter = cutDataWidth.toDpFromMm();
    //圆心移动步长
    @dp
    final step = cutDataStep.toDpFromMm();

    eachPathMetrics((
      posIndex,
      ratio,
      contourIndex,
      position,
      radians,
      isClose,
    ) {
      //使用圆形数据切割
      final circlePath = Path();
      circlePath.addOval(
        Rect.fromCircle(center: position, radius: diameter / 2),
      );
      /*circlePath.transformPath(createRotateMatrix(radians, anchor: position));*/
      result.add(circlePath);
    }, step);
    return result;
  }
}

extension VectorListPathEx on List<Path> {
  /// 所有路径对应的轮廓数量
  /// - [VectorPathEx.contourCount]
  int get contourCount => fold(0, (prev, path) => prev + path.contourCount);

  /// - [VectorPathEx.splitContours]
  List<Path> splitContours() {
    final result = <Path>[];
    for (final path in this) {
      result.addAll(path.splitContours());
    }
    return result;
  }

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
    //--
    @dp Rect? pathBounds,
    //--
    bool writeSvgProperty = true,
    bool writeAcyProperty = false,
  }) {
    if (isNil(this)) {
      return null;
    }
    @dp
    final bounds = pathBounds ?? getExactBounds(true, pathStep);
    return _wrapSvgXml(
      bounds,
      (buffer) {
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
      },
      writeSvgProperty: writeSvgProperty,
      writeAcyProperty: writeAcyProperty,
    );
  }

  /// 转换成gcode字符串数据
  /// [VectorPathEx.toGCodeString]
  String? toGCodeString({
    @dp double? pathStep,
    @mm double? tolerance,
    //--
    String? header,
    String? footer,
    String? toolOn,
    String? toolOff,
    //--用来生成上述的[header]/[footer]/[toolOn]/[toolOff]
    int? power,
    int? speed,
    bool? autoLaser, //必须指定才会自动生成
    GCodeWriteHandle? handle,
    int digits = 3,
    //--
    String space = kGCodeSpace,
  }) {
    if (isNil(this)) {
      return null;
    }
    header ??= autoLaser != null
        ? GCodeWriteHandle.gcodeHeader(
            power,
            speed,
            auto: autoLaser,
            space: space,
          )
        : null;
    footer ??= autoLaser != null
        ? GCodeWriteHandle.gcodeFooter(autoLaser)
        : null;
    toolOn ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOn(
            auto: autoLaser,
            power: speed,
            space: space,
          )
        : null;
    toolOff ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOff(autoLaser)
        : null;

    final buffer = StringBuffer();
    handle ??= GCodeWriteHandle();
    handle
      ..space = space
      ..digits = digits
      ..toolOn = toolOn
      ..toolOff = toolOff;
    buffer.write(header ?? "");
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
    buffer.write(footer ?? "");
    return buffer.toString();
  }

  /// 转换成N段线段折点数据
  /// - [precision] 精度, 会将数值乘以10E2存储
  /// - [unit] 输出数值的单位
  /// - [contourMaxPointCount] 限制一段最多多少个点, 超过之后, 起一个新段
  /// - [VectorPathEx.toGCodeString]
  @mm
  List<List<Point>>? toPointList({
    bool isMmPath = false,
    @defInjectMark @dp double? pathStep,
    @defInjectMark @mm double? tolerance,
    IUnit? unit = IUnit.mm,
    int precision = 2,
    @dp double offsetX = 0,
    @dp double offsetY = 0,
    double scaleXFactor = 1,
    double scaleYFactor = 1,
    int? contourMaxPointCount,
    PointWriteHandle? handle,
  }) {
    if (isNil(this)) {
      return null;
    }
    final result = <List<Point>>[];
    handle ??= PointWriteHandle();
    handle
      ..unit = isMmPath ? null : unit
      ..contourMaxPointCount = contourMaxPointCount
      ..digits = precision
      ..offsetX = offsetX
      ..offsetY = offsetY
      ..scaleXFactor = scaleXFactor
      ..scaleYFactor = scaleYFactor;
    for (final path in this) {
      handle.pointResultBuilder = []; //reset
      path.handleVectorPath(
        handle,
        isMmPath: isMmPath,
        pathStep: pathStep,
        tolerance: tolerance,
      );
      final pointList = handle.pointList;
      if (!isNil(pointList)) {
        result.addAll(pointList);
      }
    }
    return result;
  }

  /// [VectorPathEx.toCutPathList]
  List<Path> toCutPathList({
    @mm double cutDataStep = sDefaultCutStep,
    @mm double cutDataWidth = sDefaultCutWidth,
  }) {
    final result = <Path>[];
    for (final path in this) {
      final cutPathList = path.toCutPathList(
        cutDataStep: cutDataStep,
        cutDataWidth: cutDataWidth,
      );
      if (!isNil(cutPathList)) {
        result.addAll(cutPathList);
      }
    }
    return result;
  }

  /// [VectorPathEx.toCutGCodeString]
  String toCutGCodeString({
    @mm double cutDataStep = sDefaultCutStep,
    @mm double cutDataWidth = sDefaultCutWidth,
    String? header,
    String? footer,
    String? toolOn,
    String? toolOff,
    //--用来生成上述的[header]/[footer]/[toolOn]/[toolOff]
    int? power,
    int? speed,
    bool? autoLaser, //必须指定才会自动生成
    int digits = 3,
  }) {
    if (isNil(this)) return "";
    final buffer = StringBuffer();

    header ??= autoLaser != null
        ? GCodeWriteHandle.gcodeHeader(power, speed, auto: autoLaser)
        : null;
    footer ??= autoLaser != null
        ? GCodeWriteHandle.gcodeFooter(autoLaser)
        : null;
    toolOn ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOn(auto: autoLaser, power: speed)
        : null;
    toolOff ??= autoLaser != null
        ? GCodeWriteHandle.gcodeToolOff(autoLaser)
        : null;

    buffer.writeIf(header ?? "");
    for (final path in this) {
      final gcode = path.toCutGCodeString(
        cutDataStep: cutDataStep,
        cutDataWidth: cutDataWidth,
        digits: digits,
        toolOn: toolOn,
        toolOff: toolOff,
      );
      if (!isNil(gcode)) {
        buffer.writeIf(gcode);
      }
    }
    buffer.writeIf(footer ?? "");
    return buffer.toString();
  }
}

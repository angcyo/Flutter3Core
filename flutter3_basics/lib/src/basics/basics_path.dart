part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
///
/// 虚线
/// https://github.com/dnfield/flutter_path_drawing/blob/master/lib/src/dash_path.dart
///

/// 路径采样间隙, 每隔多少距离, 采样一次路径上的点
@dp
const double kPathAcceptableError = 0.025; //2024-11-28: 1 ;// 0.025

/// 矢量拟合公差
/// 1.575dp = 0.25mm
/// 0.1dp 精度可以
/// 0.5dp 也还可以
/// 0.01mm
@mm
const double kVectorTolerance = 0.001; //

/// 是否精确计算边界
/// [PathEx.getExactBounds]
const bool kExactBounds = true;

/// 定义一个空路径
final Path kEmptyPath = Path();

/// 在指定中心点位置生成一个指定大小的十字路径[Path]
/// 创建交叉十字路径
Path generateCrossPath({
  double? cx,
  double? cy,
  Offset? center,
  double length = 20,
}) {
  cx ??= center?.dx ?? 0;
  cy ??= center?.dy ?? 0;

  final r = length / 2;
  return Path()
    ..moveTo(cx - r, cy)
    ..lineTo(cx + r, cy)
    ..moveTo(cx, cy - r)
    ..lineTo(cx, cy + r);
}

/// [Path]路径上每个点的信息
/// [PathEx.eachPathMetrics]
class PathPointInfo {
  int posIndex;
  double ratio;
  int contourIndex;
  Offset position;
  double angle;
  bool isClosed;

  PathPointInfo({
    this.posIndex = 0,
    this.ratio = 0,
    this.contourIndex = 0,
    this.position = Offset.zero,
    this.angle = 0,
    this.isClosed = false,
  });

  @override
  String toString() {
    return "angle:$angle position:$position";
  }
}

/// [Matrix4Ex.mapRect]
extension PathEx on Path {
  /// 判断路径是否为空
  bool get isEmpty {
    //return computeMetrics().isEmpty;
    return getBounds().isEmpty;
  }

  /// 添加一个圆到路径中
  /// [center] 圆心
  /// [radius] 半径
  void addCircle(Offset center, double radius) {
    addOval(Rect.fromCircle(center: center, radius: radius));
  }

  /// 添加一个扇形到路径中
  /// [center] 中心点
  /// [radius] 半径
  /// [startAngle] 起始角度, 角度值
  /// [sweepAngle] 扫描角度, 角度值
  /// [size] 大小/高度
  void addFanShaped(
    Offset center,
    double radius, {
    required double startAngle,
    required double sweepAngle,
    double size = 4,
  }) {
    sweepAngle = sweepAngle.jdm;
    final r = radius;
    if (sweepAngle.abs() != 360) {
      //扇形左上角坐标
      final cx = center.x;
      final cy = center.y;

      final lt = getCirclePoint(center, r + size, startAngle.hd);
      final rt =
          getCirclePoint(center, r + size, startAngle.hd + sweepAngle.hd);
      final lb = getCirclePoint(center, r, startAngle.hd);
      final rb = getCirclePoint(center, r, startAngle.hd + sweepAngle.hd);

      Rect ovalRect = Rect.fromLTRB(
        cx - r - size,
        cy - r - size,
        cx + r + size,
        cy + r + size,
      );

      moveTo(lt.x, lt.y);
      arcTo(ovalRect, startAngle.hd, sweepAngle.hd, false);

      lineTo(rb.x, rb.y);
      ovalRect = Rect.fromLTRB(cx - r, cy - r, cx + r, cy + r);
      arcTo(ovalRect, startAngle.hd + sweepAngle.hd, -sweepAngle.hd, false);
      lineTo(lt.x, lt.y);
    } else {
      //360°, 就是圆
      addCircle(center, r + size);
      addCircle(center, r);
    }
  }

  /// 获取精度更高的路径边界
  /// [exact] 是否获取精确计算的边界, 会有性能损耗
  /// [pathAcceptableError] 路径采样误差
  /// [PathEx.getExactBounds]
  /// [ListPathEx.getExactBounds]
  @dp
  Rect getExactBounds([
    bool? exact,
    double? pathAcceptableError = 1,
  ]) {
    //debugger();
    exact ??= kExactBounds;
    if (exact != true) {
      return getBounds();
    }
    Rect? rect;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClosed) {
      //debugger();
      /*assert(() {
        l.d(
            "posIndex:$posIndex/$contourIndex position:$position ratio:$ratio isClosed:$isClosed");
        return true;
      }());*/
      if (rect == null) {
        rect = Rect.fromPoints(position, position);
      } else {
        rect = rect!.union(position);
      }
    }, pathAcceptableError);
    /*assert(() {
      l.i("bounds:$rect");
      return true;
    }());*/
    //debugger();
    return rect ?? getBounds();
  }

  /// 根据给定operation指定的方式组合两个路径
  /// [Path.fillType]
  /// [PathFillType]
  /// [PathFillType.evenOdd]
  Path op(Path other, PathOperation operation) => Path.combine(
        operation,
        this,
        other,
      );

  /// 是否包含指定点
  bool contains(Offset offset) => this.contains(offset);

  /// 是否和矩形相交
  bool intersectsRect(Rect rect) => intersects(Path()..addRect(rect));

  /// 是否和另一个路径相交
  bool intersects(Path other) {
    final intersection = Path.combine(
      PathOperation.intersect,
      this,
      other,
    );
    return !intersection.isEmpty;
  }

  /// 判断当前路径是否完全包含另一个路径
  ///
  /// - 2个[Path]需要相交
  bool containsPath(Path other) {
    final diff = Path.combine(
      PathOperation.difference,
      other,
      this,
    );
    return diff.isEmpty;
  }

  /// 从当前路径中创建一个虚线[Path]路径
  Path dashPath(List<double> dashArray) {
    final Path dest = Path();
    final count = dashArray.length;
    var index = 0;
    for (final ui.PathMetric metric in computeMetrics()) {
      double distance = metric.length;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray[index++ % count];
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  /// 变换路径, 返回新的路径
  Path transformPath([Matrix4? matrix4]) {
    if (matrix4 == null) {
      return ui.Path.from(this);
    }
    return transform(matrix4.storage);
  }

  /// 获取[Path]路径上所有点的信息
  /// 有些[Path]可能具有多段, 一段上具有多个点
  /// [step] 步长
  /// [eachPathMetrics]
  /// [kPathAcceptableError]
  List<List<PathPointInfo>> toPointInfoList([@dp double? step = 1]) {
    List<List<PathPointInfo>> result = [];
    //一段
    List<PathPointInfo>? contour;
    int? lastContourIndex;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClose) {
      if (lastContourIndex != contourIndex) {
        //新的一段
        lastContourIndex = contourIndex;
        if (contour != null) {
          result.add(contour!);
        }
        contour = [];
      }
      contour?.add(PathPointInfo(
        posIndex: posIndex,
        ratio: ratio,
        contourIndex: contourIndex,
        position: position,
        angle: angle,
        isClosed: isClose,
      ));
    }, step);
    if (contour != null) {
      result.add(contour!);
    }
    return result;
  }

  /// 路径总长度
  double get length => computeMetrics().sum((e) => e.length);

  /// 从一个路径中(包含所有轮廓), 获取指定距离的位置
  /// 支持所有段落的
  /// [distance] 在所有轮廓中的距离
  ui.Tangent? getTangentForOffset(double distance) {
    final metrics = computeMetrics();
    double startLength = 0;
    for (final metric in metrics) {
      final length = metric.length;
      final endLength = startLength + length;

      if (distance >= startLength && distance <= endLength) {
        //到达开始位置
        final partStart = distance - startLength;
        return metric.getTangentForOffset(partStart);
      }
      startLength = endLength;
    }
    return null;
  }

  /// 从一个路径中(包含所有轮廓), 获取指定位置的路径路径
  /// 支持所有段落的
  /// [start].[end] 在所有轮廓中的距离
  Path extractPath(double start, double end, {bool startWithMoveTo = true}) {
    final path = Path();
    final extractLength = end - start;
    final metrics = computeMetrics();

    double startLength = 0;
    for (final metric in metrics) {
      final length = metric.length;
      final endLength = startLength + length;

      if (start >= startLength && start <= endLength) {
        //到达开始位置
        final partStart = start - startLength;
        path.addPath(
            metric.extractPath(
              partStart,
              partStart + min(extractLength, length - partStart),
              startWithMoveTo: startWithMoveTo,
            ),
            Offset.zero);
      } else if (end < startLength) {
        //到达结束位置
        break;
      } else {
        //还未到开始位置
      }
      startLength = endLength;
    }
    return path;
  }

  /// 按照指定的步长, 获取路径上的点
  ///
  /// ```
  /// M0 0 L100 0 L100 100 L0 100z -> 0° -90° -180° 90°
  /// ```
  ///
  /// [step] 步长
  /// [posIndex] 当前路径段上,点的索引, 0开始
  /// [ratio] 当前路径段上,点长度与路径段总长度的比例, [0-1]
  /// [contourIndex] 路径段的索引, 0开始. 一个路径中,可能包含多个路径段. 每次[moveTo],就是一个新的路径段
  /// [position] 当前点在路径上的位置, 关键数据
  /// [radians] 当前点在路径上的角度, 弧度单位, 关键数据
  /// [isClosed] 当前轮廓是否是闭合的
  ///
  /// [action] 返回true, 表示中断each
  /// [eachPathMetrics]
  /// [eachPathMetricsAsync]
  void eachPathMetrics(
    dynamic Function(
      int posIndex,
      double ratio,
      int contourIndex,
      Offset position,
      double angle,
      bool isClosed,
    ) action, [
    @dp double? step,
  ]) {
    final metrics = computeMetrics();
    int contourIndex = 0;

    //是否中断
    bool interrupt = false;
    for (final metric in metrics) {
      final length = metric.length;
      int posIndex = 0;
      double distance = 0;
      while (true) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final position = tangent.position;
          double angle = tangent.angle;
          final ratio = distance / length;
          if (angle == 0) {
            //水平方向
            angle = 0; //清除`-0.0`的情况
          } else if (angle > 0) {
            //切线指向Y轴下方
          } else {
            //切线指向Y轴上方
          }
          final result = action(
            posIndex,
            ratio,
            contourIndex,
            position,
            angle,
            metric.isClosed,
          );
          if (result is bool && result) {
            interrupt = true;
            break;
          }
        }
        posIndex++;
        if (distance >= length) {
          break;
        }
        distance += (step ?? kPathAcceptableError);
        if (distance > length) {
          distance = length; //处理最后一个点
        }
      }
      contourIndex++;
      if (interrupt) {
        break;
      }
    }
  }

  /// [eachPathMetrics]
  /// [eachPathMetricsAsync]
  Future eachPathMetricsAsync(
    FutureOr Function(
      int posIndex,
      double ratio,
      int contourIndex,
      Offset position,
      double angle,
      bool isClosed,
    ) action, [
    @dp double? step,
    int? contourInterval /*轮廓枚举延迟*/,
    int? stepInterval /*步长枚举延迟*/,
  ]) async {
    final metrics = computeMetrics();
    int contourIndex = 0;

    //是否中断
    bool interrupt = false;
    await for (final metric in metrics.stream) {
      final length = metric.length;
      int posIndex = 0;
      //--
      await for (final distance in length.loop(
        step: (step ?? kPathAcceptableError),
        interval: stepInterval,
      )) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final position = tangent.position;
          double angle = tangent.angle;
          final ratio = distance / length;
          if (angle == 0) {
            //水平方向
            angle = 0; //清除`-0.0`的情况
          } else if (angle > 0) {
            //切线指向Y轴下方
          } else {
            //切线指向Y轴上方
          }
          final result = await action(
            posIndex,
            ratio,
            contourIndex,
            position,
            angle,
            metric.isClosed,
          );
          if (result is bool && result) {
            interrupt = true;
            break;
          }
        }
        posIndex++;
      }
      contourIndex++;
      if (interrupt) {
        break;
      }
      if (contourInterval != null) {
        await Future.delayed(Duration(milliseconds: contourInterval));
      }
    }
  }

  /// 将路径平移到0,0的位置 并且指定缩放到的大小, 返回新路径
  /// [size].[width].[height] 指定的大小
  /// [PathEx.moveToZero]
  /// [ListPathEx.moveToZero]
  /// @return 返回新的路径
  @dp
  Path moveToZero({
    //--
    @dp Size? size,
    @dp double? width,
    @dp double? height,
    //--
    double? scale,
    double? sx,
    double? sy,
    //--
    Offset? scaleAnchor,
    bool? exact,
  }) {
    return ofList<Path>()
        .moveToZero(
          size: size,
          width: width,
          height: height,
          scale: scale,
          sx: sx,
          sy: sy,
          scaleAnchor: scaleAnchor,
          exact: exact,
        )
        .first;
  }

  /// 将路径缩放到指定大小
  /// [anchor] 缩放的锚点
  @dp
  Path scaleToSize({
    @dp Size? size,
    @dp double? width,
    @dp double? height,
    Offset? scaleAnchor = Offset.zero,
  }) {
    //debugger();
    final bounds = getExactBounds();

    width ??= size?.width.ensureValid();
    height ??= size?.height.ensureValid();

    if (width == null && height == null) {
      return this;
    }

    final boundsWidth = bounds.width.ensureValid();
    final boundsHeight = bounds.height.ensureValid();

    if (width == null && height != null) {
      //用高度等比缩放
      final sy = boundsHeight == 0.0 ? 1.0 : height / boundsHeight;
      final sx = sy;
      //debugger();
      final scale = createScaleMatrix(
        sx: sx,
        sy: sy,
        anchor: scaleAnchor ?? bounds.lt,
      );

      return transformPath(scale);
    } else if (width != null && height == null) {
      //用宽度等比缩放
      final sx = boundsWidth == 0.0 ? 1.0 : width / boundsWidth;
      final sy = sx;

      final scale = createScaleMatrix(
        sx: sx,
        sy: sy,
        anchor: scaleAnchor ?? bounds.lt,
      );

      return transformPath(scale);
    }

    width ??= boundsWidth;
    height ??= boundsHeight;

    final scale = createScaleMatrix(
      sx: boundsWidth == 0 ? 1 : width / boundsWidth,
      sy: boundsHeight == 0 ? 1 : height / boundsHeight,
      anchor: scaleAnchor ?? bounds.lt,
    );

    return transformPath(scale);
  }

  /// [scaleToMm]
  @mm
  Path toPathMm() => scaleToUnit(IUnit.mm);

  /// dp 单位的[Path] 转换成 mm 单位的[Path]
  /// [scaleToUnit]
  @mm
  Path scaleToMm() => scaleToUnit(IUnit.mm);

  /// 将路径缩放到指定的单位大小
  /// @return 返回新的路径
  @unit
  Path scaleToUnit([
    IUnit unit = IUnit.mm,
    Offset? scaleAnchor = Offset.zero,
  ]) {
    final scale = 1.toUnitFromDp(unit);
    final scaleMatrix = createScaleMatrix(scale: scale, anchor: scaleAnchor);
    return transformPath(scaleMatrix);
  }

  /// mm 单位的[Path] 转换成 dp 单位的[Path]
  @dp
  Path scaleToDp([
    IUnit unit = IUnit.mm,
    Offset? scaleAnchor = Offset.zero,
  ]) {
    final scale = IUnit.dp.toUnitFromUnit(unit, 1);
    final scaleMatrix = createScaleMatrix(scale: scale, anchor: scaleAnchor);
    return transformPath(scaleMatrix);
  }
}

extension ListPathEx on List<Path> {
  /// [PathEx.op]
  /// [operation] 如果为null, 则直接添加路径
  Path op([PathOperation? operation]) {
    Path result = firstOrNull ?? Path();
    for (int i = 1; i < length; i++) {
      if (operation == null) {
        result.addPath(this[i], Offset.zero);
      } else {
        result = result.op(this[i], operation);
      }
    }
    return result;
  }

  /// 变换路径, 返回新的路径
  List<Path> transformPath([Matrix4? matrix4]) {
    if (matrix4 == null) {
      return map((path) {
        return ui.Path.from(path);
      }).toList();
    }
    return map((path) {
      return path.transform(matrix4.storage);
    }).toList();
  }

  /// 获取包含所有路径的边界
  /// 当svg中包含`C` `Q` `A` 此时不使用[exact]模式会有很大的误差
  /// [PathEx.getExactBounds]
  /// [ListPathEx.getExactBounds]
  @dp
  Rect getExactBounds([
    bool? exact,
    double? pathAcceptableError,
  ]) {
    Rect? rect;
    for (final path in this) {
      final bounds = path.getExactBounds(exact, pathAcceptableError);
      if (rect == null) {
        rect = bounds;
      } else {
        rect = rect.expandToInclude(bounds);
      }
    }
    return rect ?? Rect.zero;
  }

  /// 将所有路径平移到0,0的位置, 并且可以指定需要缩放至的宽高大小
  /// [PathEx.moveToZero]
  /// [ListPathEx.moveToZero]
  List<Path> moveToZero({
    @dp Size? size,
    @dp double? width,
    @dp double? height,
    //--
    double? scale,
    double? sx,
    double? sy,
    //--
    Offset? scaleAnchor,
    //--
    bool? exact,
  }) {
    final bounds = getExactBounds(exact);
    final translate = Matrix4.identity();
    translate.translate(-bounds.left, -bounds.top);

    width ??= size?.width.ensureValid();
    height ??= size?.height.ensureValid();

    final boundsWidth = bounds.width.ensureValid();
    final boundsHeight = bounds.height.ensureValid();

    if (width == null && height != null) {
      //用高度等比缩放
      sy ??= scale ?? (boundsHeight == 0.0 ? 1.0 : height / boundsHeight);
      sx ??= scale ?? sy;
      //debugger();
    } else if (width != null && height == null) {
      //用宽度等比缩放
      sx ??= scale ?? (boundsWidth == 0.0 ? 1.0 : width / boundsWidth);
      sy ??= scale ?? sx;
    }

    width ??= boundsWidth;
    height ??= boundsHeight;

    sx ??= scale ?? (boundsWidth == 0 ? 1 : width / boundsWidth);
    sy ??= scale ?? (boundsHeight == 0 ? 1 : height / boundsHeight);
    final scaleMatrix = createScaleMatrix(
      sx: sx,
      sy: sy,
      anchor: scaleAnchor ?? bounds.topLeft,
    );

    return transformPath(translate * scaleMatrix);
  }

  /// 将路径绘制到[UiImage]中
  /// [ImageEx.toBase64]
  Future<UiImage> toUiImage({
    EdgeInsets padding = EdgeInsets.zero,
    Color color = Colors.black,
    double width = 1,
  }) async =>
      toUiImageSync(padding: padding, color: color, width: width);

  /// [toUiImage]
  /// [ImageEx.toBase64]
  Future<String?> toUiImageBase64({
    EdgeInsets padding = EdgeInsets.zero,
    Color color = Colors.black,
    double width = 1,
  }) async {
    final uiImage =
        await toUiImage(padding: padding, color: color, width: width);
    return uiImage.toBase64();
  }

  /// [toUiImage]
  /// [UiImage]
  UiImage toUiImageSync({
    EdgeInsets padding = EdgeInsets.zero,
    Color color = Colors.black,
    double width = 1,
  }) {
    final bounds = getExactBounds();
    final width = (bounds.width + padding.horizontal).ensureValid();
    final height = (bounds.height + padding.vertical).ensureValid();

    return drawImageSync(ui.Size(math.max(1, width), math.max(1, height)),
        (canvas) {
      final paint = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = width;
      canvas.translate(-bounds.left + padding.left, -bounds.top + padding.top);
      for (final path in this) {
        canvas.drawPath(path, paint);
      }
    });
  }
}

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
const double kPathAcceptableError = 0.025; //

/// 矢量拟合公差
/// 1.575dp = 0.25mm
/// 0.1dp 精度可以
/// 0.5dp 也还可以
@mm
const double kVectorTolerance = 0.02; //

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

  /// 获取精度更高的路径边界
  /// [exact] 是否获取精确计算的边界, 会有性能损耗
  /// [pathAcceptableError] 路径采样误差
  /// [PathEx.getExactBounds]
  /// [ListPathEx.getExactBounds]
  @dp
  Rect getExactBounds([
    bool? exact,
    double? pathAcceptableError,
  ]) {
    if (exact != true) {
      return getBounds();
    }
    Rect? rect;
    eachPathMetrics((posIndex, ratio, contourIndex, position, angle, isClosed) {
      if (rect == null) {
        rect = Rect.fromPoints(position, position);
      } else {
        rect = rect!.union(position);
      }
    }, pathAcceptableError);
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
  /// [angle] 当前点在路径上的角度, 弧度单位, 关键数据
  /// [isClosed] 当前轮廓是否是闭合的
  ///
  /// [action] 返回true, 表示中断each
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

  /// 将路径平移到0,0的位置 并且指定缩放到的大小, 返回新路径
  /// [size].[width].[height] 指定的大小
  /// [PathEx.moveToZero]
  /// [ListPathEx.moveToZero]
  @dp
  Path moveToZero({
    @dp Size? size,
    @dp double? width,
    @dp double? height,
  }) {
    return ofList<Path>()
        .moveToZero(size: size, width: width, height: height)
        .first;
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
  }) {
    //debugger();
    final bounds = getExactBounds();
    final translate = Matrix4.identity();
    translate.translate(-bounds.left, -bounds.top);

    width ??= size?.width.ensureValid();
    height ??= size?.height.ensureValid();

    if (width == null && height == null) {
      return transformPath(translate);
    }

    final boundsWidth = bounds.width.ensureValid();
    final boundsHeight = bounds.height.ensureValid();

    width ??= boundsWidth;
    height ??= boundsHeight;

    final scale = createScaleMatrix(
      sx: boundsWidth == 0 ? 1 : width / boundsWidth,
      sy: boundsHeight == 0 ? 1 : height / boundsHeight,
      anchor: bounds.topLeft,
    );

    return transformPath(translate * scale);
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

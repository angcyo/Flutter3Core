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

/// [Matrix4Ex.mapRect]
extension PathEx on Path {
  /// 判断路径是否为空
  bool get isEmpty {
    //return computeMetrics().isEmpty;
    return getBounds().isEmpty;
  }

  /// 获取精度更高的路径边界
  /// [exact] 是否获取精确计算的边界
  /// [pathAcceptableError] 路径采样误差
  @dp
  Rect getExactBounds([
    bool exact = true,
    double pathAcceptableError = kPathAcceptableError,
  ]) {
    if (!exact) {
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
    for (final PathMetric metric in computeMetrics()) {
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
  void eachPathMetrics(
    void Function(
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
    for (final metric in metrics) {
      final length = metric.length;
      int posIndex = 0;
      double distance = 0;
      while (true) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final position = tangent.position;
          final angle = tangent.angle;
          final ratio = distance / length;
          if (angle == 0) {
            //水平方向
          } else if (angle > 0) {
            //切线指向Y轴下方
          } else {
            //切线指向Y轴上方
          }
          action(
            posIndex,
            ratio,
            contourIndex,
            position,
            angle,
            metric.isClosed,
          );
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
    }
  }

  /// 将路径平移到0,0的位置 并且指定缩放到的大小
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
  /// 获取包含所有路径的边界
  @dp
  Rect getExactPathBounds([
    bool exact = true,
    double pathAcceptableError = kPathAcceptableError,
  ]) {
    Rect rect = Rect.zero;
    for (final path in this) {
      rect =
          rect.expandToInclude(path.getExactBounds(exact, pathAcceptableError));
    }
    return rect;
  }

  /// 将所有路径平移到0,0的位置
  /// [PathEx.moveToZero]
  /// [ListPathEx.moveToZero]
  List<Path> moveToZero({
    @dp Size? size,
    @dp double? width,
    @dp double? height,
  }) {
    final bounds = getExactPathBounds();
    final translate = Matrix4.identity();
    translate.translate(-bounds.left, -bounds.top);

    width ??= size?.width.ensureValid();
    height ??= size?.height.ensureValid();

    if (width == null && height == null) {
      return map((path) {
        return path.transformPath(translate);
      }).toList();
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

    return map((path) {
      return path.transformPath(translate * scale);
    }).toList();
  }
}

part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
///
/// 虚线
/// https://github.com/dnfield/flutter_path_drawing/blob/master/lib/src/dash_path.dart
///
/// [Matrix4Ex.mapRect]
extension PathEx on Path {
  /// 判断路径是否为空
  bool get isEmpty {
    //return computeMetrics().isEmpty;
    return getBounds().isEmpty;
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
  Path transformPath(Matrix4 matrix4) {
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
    @dp double step = 1,
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
        distance += step;
        if (distance > length) {
          distance = length; //处理最后一个点
        }
      }
      contourIndex++;
    }
  }

  void token() {
    //PathMe
    //final commands = this.commands;
  }
}

extension ListPathEx on List<Path> {
  /// 获取包含所有路径的边界
  Rect getPathBounds() {
    Rect rect = Rect.zero;
    for (final path in this) {
      rect = rect.expandToInclude(path.getBounds());
    }
    return rect;
  }
}

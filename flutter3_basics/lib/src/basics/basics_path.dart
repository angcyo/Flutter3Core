part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
///
/// 虚线
/// https://github.com/dnfield/flutter_path_drawing/blob/master/lib/src/dash_path.dart
///
/// [Matrix4Ex.mapRect]
extension PathEx on ui.Path {
  /// 判断路径是否为空
  bool get isEmpty {
    //return computeMetrics().isEmpty;
    return getBounds().isEmpty;
  }

  /// 是否包含指定点
  bool contains(Offset offset) => this.contains(offset);

  /// 是否和矩形相交
  bool intersectsRect(Rect rect) => intersects(ui.Path()..addRect(rect));

  /// 是否和另一个路径相交
  bool intersects(ui.Path other) {
    final intersection = Path.combine(
      PathOperation.intersect,
      this,
      other,
    );
    return !intersection.isEmpty;
  }

  /// 从当前路径中获取虚线[Path]
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
}

part of '../flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/29
///
final class Point {
  /// x坐标
  double x;

  /// y坐标
  double y;

  /// 角度,弧度单位
  double? a;

  Point(this.x, this.y, this.a);

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'a': a,
    };
  }

  @override
  String toString() {
    return 'Point{x:$x, y:$y a:$a}';
  }
}

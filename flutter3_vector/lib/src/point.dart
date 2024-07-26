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

  /// 短字符串
  String toShortString() {
    return '($x, $y)';
  }

  @override
  String toString() {
    return 'Point{x:$x, y:$y a:$a}';
  }
}

extension ListPointEx on List<Point> {
  /// 转换成一维数组点信息
  /// [x,y,x,y,x,y,x,y...]
  List<double> toPointList() {
    List<double> result = [];
    for (final point in this) {
      result.add(point.x);
      result.add(point.y);
    }
    return result;
  }

  /// x,y,x,y...
  String toPointText() {
    StringBuffer buffer = StringBuffer();
    for (final point in this) {
      buffer.write('${point.x},${point.y}');
    }
    return buffer.toString();
  }
}

extension ListListPointEx on List<List<Point>> {
  /// 转换成二维数组点信息
  List<List<double>> toPointListList() {
    List<List<double>> result = [];
    for (final pointList in this) {
      result.add(pointList.toPointList());
    }
    return result;
  }

  /// 用换行分割多段
  String toPointText() {
    StringBuffer buffer = StringBuffer();
    for (final pointList in this) {
      buffer.writeln(pointList.toPointText());
    }
    return buffer.toString();
  }
}

extension ListListStringEx on String {
  /// 反向解析
  List<Point> toPointList() {
    List<Point> result = [];
    List<String> points = split(',');
    for (int i = 0; i < points.length; i += 2) {
      try {
        result.add(
            Point(double.parse(points[i]), double.parse(points[i + 1]), null));
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
    return result;
  }

  /// 反向解析
  List<List<Point>> toPointListList() {
    List<List<Point>> result = [];
    List<String> lines = this.lines();
    for (final line in lines) {
      List<Point> pointList = line.toPointList();
      if (pointList.isNotEmpty) {
        result.add(pointList);
      }
    }
    return result;
  }
}

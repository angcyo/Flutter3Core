part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/29
///
/// 描述一个点的信息
final class Point {
  /// 使用[points]构建路径
  static Path? buildPath(List<Point>? points) {
    if (isNil(points)) {
      return null;
    }
    final Path path = Path();
    Point? lastPoint;
    for (final point in points!) {
      if (lastPoint == null) {
        //第一个点
        path.moveTo(point.x, point.y);
      } else {
        if (lastPoint.c == null && point.c == null) {
          //没有控制点, 则是直线
          path.lineTo(point.x, point.y);
        } else if (lastPoint.c != null && point.c != null) {
          //2个控制点, 则是三次贝塞尔曲线
          path.cubicTo(
            lastPoint.c!.x,
            lastPoint.c!.y,
            point.sc!.x,
            point.sc!.y,
            point.x,
            point.y,
          );
        } else {
          //1个控制点, 则是二次贝塞尔曲线
          final c = lastPoint.c ?? point.sc;
          if (c == null) {
            path.lineTo(point.x, point.y);
          } else {
            path.quadraticBezierTo(
              c.x,
              c.y,
              point.x,
              point.y,
            );
          }
        }
      }
      lastPoint = point;
    }
    return path;
  }

  /// 使用[points]构建svg path路径数据
  /// [digits] 小数位数
  /// [unit] 需要将数值转换成什么单位的
  static String? buildSvgPath(
    List<Point>? points, {
    String Function(double value)? formatValueAction,
    //
    int? digits,
    IUnit? unit,
  }) {
    if (isNil(points)) {
      return null;
    }

    // 格式化数值[formatValue]
    String fv(double value) {
      value = unit?.toUnitFromDp(value) ?? value;
      if (formatValueAction != null) {
        return formatValueAction(value);
      }
      if (digits != null) {
        return value.toDigits(digits: digits);
      }
      return "$value";
    }

    final StringBuffer pathBuilder = StringBuffer();
    Point? lastPoint;
    for (final point in points!) {
      if (lastPoint == null) {
        //第一个点
        pathBuilder.write('M${fv(point.x)} ${fv(point.y)}');
      } else {
        if (lastPoint.c == null && point.c == null) {
          //没有控制点, 则是直线
          pathBuilder.write('L${fv(point.x)} ${fv(point.y)}');
        } else if (lastPoint.c != null && point.c != null) {
          //2个控制点, 则是三次贝塞尔曲线
          pathBuilder.write('C${fv(lastPoint.c!.x)} ${fv(lastPoint.c!.y)}, '
              '${fv(point.sc!.x)} ${fv(point.sc!.y)}, '
              '${fv(point.x)} ${fv(point.y)}');
        } else {
          //1个控制点, 则是二次贝塞尔曲线
          final c = lastPoint.c ?? point.sc;
          if (c == null) {
            pathBuilder.write('L${fv(point.x)} ${fv(point.y)}');
          } else {
            pathBuilder.write('Q${fv(c.x)} ${fv(c.y)}, '
                '${fv(point.x)} ${fv(point.y)}');
          }
        }
      }
      lastPoint = point;
    }
    final String path = pathBuilder.toString();
    return path;
  }

  /// x坐标
  double x;

  /// y坐标
  double y;

  /// 角度,弧度单位
  double? a;

  /// 贝塞尔曲线控制点
  /// [Path.quadraticBezierTo] 二次贝塞尔曲线
  /// [Path.cubicTo] 三次贝塞尔曲线
  Point? c;

  /// 获取控制点[c],以[x].[y]对称的控制点
  Point? sc;

  Offset get offset => Offset(x, y);

  Point(
    this.x,
    this.y,
    this.a, {
    this.c,
  }) : sc = c == null
            ? null
            : Point(
                2 * x - c.x,
                2 * y - c.y,
                c.a,
              );

  /// 更新控制点[c], 顺带更新第一/第二控制点
  @api
  void updatePoint(double x, double y) {
    final dx = x - this.x;
    final dy = y - this.y;
    this.x = x;
    this.y = y;
    if (c != null) {
      c!.updatePoint(c!.x + dx, c!.y + dy);
    }
    if (sc != null) {
      sc!.updatePoint(sc!.x + dx, sc!.y + dy);
    }
  }

  /// 更新控制点[c], 顺带更新第二控制点
  @api
  void updateControlPoint(
    double x,
    double y, {
    double? a,
  }) {
    c ??= Point(x, y, a);
    c?.a = a;
    c?.x = x;
    c?.y = y;
    //--
    sc ??= Point(x, y, null);
    sc?.x = 2 * this.x - x;
    sc?.y = 2 * this.y - y;
  }

  /// 更新对撑控制点[sc], 顺带更新第一个控制点
  @api
  void updateSymmetryControlPoint(
    double x,
    double y, {
    double? a,
  }) {
    sc ??= Point(x, y, a);
    sc?.a = a;
    sc?.x = x;
    sc?.y = y;
    //--
    c ??= Point(x, y, null);
    c?.x = 2 * this.x - x;
    c?.y = 2 * this.y - y;
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'a': a,
      'c': c?.toJson(),
      'sc': sc?.toJson(),
    };
  }

  /// 短字符串
  String toShortString() {
    return '($x, $y)';
  }

  @override
  String toString() {
    return 'Point{x:$x, y:$y a:$a, c:$c, sc:$sc}';
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

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
/// 数学相关函数
/// [Matrix4Ex]

/// 数字类型
enum NumType {
  /// 浮点
  d,

  /// 整型
  i,
  ;

  static NumType? from(dynamic value) {
    if (value == null || value is! num) {
      return null;
    }
    if (value is int) {
      return NumType.i;
    }
    return NumType.d;
  }
}

/// 求2点之间的距离, 返回值正负数
double distance(Offset a, Offset b) {
  return math.sqrt(math.pow(a.dx - b.dx, 2) + math.pow(a.dy - b.dy, 2));
}

/// 求c边的长度
double cOffset(Offset a, Offset b) => distance(a, b);

/// c边的长度
double c(double x1, double y1, double x2, double y2) {
  return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));
}

/// 对角线的长度, c边的长度. 返回值正负数
double cl(double x, double y) {
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2));
}

/// 获取2个点之间的中心点
Offset center(Offset a, Offset b) {
  return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
}

/// 求2点之间的角度,与水平面的夹角, 弧度, 返回值正负弧度数
double angle(Offset a, Offset b) {
  //return math.atan2((b.dy - a.dy).abs(), (b.dx - a.dx).abs());
  return math.atan2(b.dy - a.dy, b.dx - a.dx);
}

/// 求2根线之间的角度, 夹角, 弧度
/// 返回的弧度有正负值
/// [fp1].[fp2] 第一根线的2个点
/// [sp1].[sp2] 第二根线的2个点
double angleBetween(Offset fp1, Offset fp2, Offset sp1, Offset sp2) {
  double angle1 = math.atan2(fp2.dy - fp1.dy, fp2.dx - fp1.dx);
  double angle2 = math.atan2(sp2.dy - sp1.dy, sp2.dx - sp1.dx);
  return angle2 - angle1;
}

/// 获取弧上指定角度的点坐标
/// [radians] 弧度
/// Gets the arc point by [radians] on an [oval].
///
/// The algorithm is from https://blog.csdn.net/chenlu5201314/article/details/99678398
Offset getArcPoint(Rect oval, double radians) {
  final a = oval.width / 2;
  final b = oval.height / 2;
  final yc = math.sin(radians);
  final xc = math.cos(radians);
  final radio = (a * b) / math.sqrt(math.pow(yc * a, 2) + math.pow(xc * b, 2));

  return oval.center.translate(radio * xc, radio * yc);
}

/// 获取圆上指定角度的点坐标
/// [center] 圆心坐标
/// [radius] 圆的半径
/// [radians] 弧度
/// https://blog.csdn.net/gongjianbo1992/article/details/107476030
Offset getCirclePoint(Offset center, double radius, double radians) {
  return center.translate(
    radius * math.cos(radians),
    radius * math.sin(radians),
  );
}

/// 3个点求圆心
/// https://www.cnblogs.com/jason-star/archive/2013/04/22/3036130.html
/// https://stackoverflow.com/questions/4103405/what-is-the-algorithm-for-finding-the-center-of-a-circle-from-three-points
Offset? centerOfCircle(Offset a, Offset b, Offset c) {
  final x1 = a.dx;
  final y1 = a.dy;
  final x2 = b.dx;
  final y2 = b.dy;
  final x3 = c.dx;
  final y3 = c.dy;

  final A = x1 - x2;
  final B = y1 - y2;
  final C = x1 - x3;
  final D = y1 - y3;
  final E = x1 * x1 - x2 * x2 + y1 * y1 - y2 * y2;
  final F = x1 * x1 - x3 * x3 + y1 * y1 - y3 * y3;

  final x = (E * D - B * F) / (2 * (A * D - B * C));
  final y = (A * F - E * C) / (2 * (A * D - B * C));

  if (x.isValid && y.isValid) {
    return Offset(x, y);
  }

  return null;
}

/// 2个点和半径, 求圆心
/// 会有2个圆心
List<Offset> centerOfCircleRadius(Offset p1, Offset p2, double dRadius) {
  double k = 0.0;
  double kVertical = 0.0;
  double midX = 0.0;
  double midY = 0.0;
  double a = 1.0;
  double b = 1.0;
  double c = 1.0;

  Offset center1;
  Offset center2;

  double p1x = p1.dx;
  double p1y = p1.dy;

  double p2x = p2.dx;
  double p2y = p2.dy;

  k = (p2y - p1y) / (p2x - p1x); // 斜率
  if (k == 0) {
    center1 = Offset((p1x + p2x) / 2.0,
        p1y + math.sqrt(dRadius * dRadius - (p1x - p2x) * (p1x - p2x) / 4.0));
    center2 = Offset((p1x + p2x) / 2.0,
        p1y - math.sqrt(dRadius * dRadius - (p1x - p2x) * (p1x - p2x) / 4.0));
  } else {
    kVertical = -1.0 / k;
    midX = (p1x + p2x) / 2.0;
    midY = (p1y + p2y) / 2.0;
    a = 1.0 + kVertical * kVertical;
    b = -2 * midX - kVertical * kVertical * (p1x + p2x);
    c = midX * midX +
        kVertical * kVertical * (p1x + p2x) * (p1x + p2x) / 4.0 -
        (dRadius * dRadius -
            ((midX - p1x) * (midX - p1x) + (midY - p1y) * (midY - p1y)));

    final c1x = (-1.0 * b + math.sqrt(b * b - 4 * a * c)) / (2 * a);
    final c2x = (-1.0 * b - math.sqrt(b * b - 4 * a * c)) / (2 * a);

    final c1y = kVertical * (c1x - midX) + midY;
    final c2y = kVertical * (c2x - midX) + midY;

    center1 = Offset(c1x, c1y);
    center2 = Offset(c2x, c2y);
  }
  return [center1, center2];
}

/// 取2个数中的最大值
T maxOf<T extends num>(T num1, T? num2) =>
    num2 == null ? num1 : math.max(num1, num2);

/// 取2个数中的最小值
T minOf<T extends num>(T num1, T? num2) =>
    num2 == null ? num1 : math.min(num1, num2);

/// [value] 是否 <= [num]
bool lessThan(num? value, num? num, {bool than = true, bool def = true}) {
  if (value == null || num == null) {
    return def;
  }
  return than ? value <= num : value < num;
}

/// [value] 是否 >= [num]
bool greaterThan(num? value, num? num, {bool than = true, bool def = true}) {
  if (value == null || num == null) {
    return def;
  }
  return than ? value >= num : value > num;
}

/// 获取一个值在首尾值中平分的值
/// - [left] 左边的值
/// - [right] 右边的值
/// - [index] 当前第几段数据, 从0开始
/// - [count] 总共的段数
/// - [lerpDuration]
/// - [lerpDouble]
/// - [lerpOffset]
double lerpNum(num left, num right, int index, int count) {
  final step = (right - left) / math.max(1, (count - 1));
  return left + step * index;
}

double lerpDouble(double begin, double end, double progress) {
  return begin + (end - begin) * progress;
}

/// [lerpOffset]
Offset lerpOffset(Offset from, Offset to, double progress) {
  return Offset(
    lerpDouble(from.dx, to.dx, progress),
    lerpDouble(from.dy, to.dy, progress),
  );
}

/*enum Direction {
  /// clockwise 顺时针
  CW, // must match enum in SkPath.h
  /// counter-clockwise 逆时针
  CCW; // ust match enum in SkPath.h
}*/

/// 判断2个点的运动趋势, 计算目标点是否在绕着锚点进行顺时针运动
/// [startAnchor] 第一个起点
/// [circleCenter] 圆心
/// [target] 测试目标点
/// ![](https://flutter.github.io/assets-for-api-docs/assets/dart-ui/path_add_arc_dark.png#gh-dark-mode-only)
@implementation
bool isClockwise(Offset startAnchor, Offset circleCenter, Offset target) {
  /*Offset v1 = circleCenter - startAnchor;
  Offset v2 = target - circleCenter;

  double crossProduct = v1.dx * v2.dy - v1.dy * v2.dx;
  return crossProduct > 0;*/

  /*return (target.dy >= anchor.dy && target.dx <= anchor.dx) ||
      (target.dy <= anchor.dy && target.dx >= anchor.dx);*/

  Offset v1 = startAnchor - circleCenter;
  Offset v2 = target - circleCenter;

  double crossProduct = v1.dx * v2.dy - v1.dy * v2.dx;
  return crossProduct > 0;
}

/// 格式化[number]数字成字符串
/// [round] 是否四舍五入
String formatNumber(
  num number, {
  NumType? numType,
  int digits = kDefaultDigits,
  bool round = true,
  bool ensureInt = true,
}) {
  numType ??= NumType.from(number);
  return switch (numType) {
    NumType.i => "${round ? number.round() : number.toInt()}",
    NumType.d => number.toDigits(digits: digits, ensureInt: ensureInt),
    _ => "$number",
  };
}

num formatDoubleNumber(
  double number,
  NumType? numType, {
  bool round = true,
}) {
  switch (numType) {
    case NumType.i:
      return round ? number.round() : number.toInt();
    case NumType.d:
      return number.toNumDouble();
    case null:
      return number;
  }
}

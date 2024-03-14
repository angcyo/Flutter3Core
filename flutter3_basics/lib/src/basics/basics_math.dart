part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
/// 数学相关函数
/// [Matrix4Ex]

/// 求2点之间的距离
double distance(Offset a, Offset b) {
  return math.sqrt(math.pow(a.dx - b.dx, 2) + math.pow(a.dy - b.dy, 2));
}

double c(double x1, double y1, double x2, double y2) {
  return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));
}

/// 获取2个点之间的中心点
Offset center(Offset a, Offset b) {
  return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
}

/// 求2点之间的角度, 弧度
double angle(Offset a, Offset b) {
  return math.atan2((b.dy - a.dy).abs(), (b.dx - a.dx).abs());
}

/// 求2根线之间的角度, 夹角, 弧度
/// [fp1].[fp2] 第一根线的2个点
/// [sp1].[sp2] 第二根线的2个点
double angleBetween(Offset fp1, Offset fp2, Offset sp1, Offset sp2) {
  double angle1 = math.atan2(fp2.dy - fp1.dy, fp2.dx - fp1.dx);
  double angle2 = math.atan2(sp2.dy - sp1.dy, sp2.dx - sp1.dx);
  return angle2 - angle1;
}

/// 获取弧上指定角度的点坐标
/// [angle] 弧度
/// Gets the arc point by [angle] on an [oval].
///
/// The algorithm is from https://blog.csdn.net/chenlu5201314/article/details/99678398
Offset getArcPoint(Rect oval, double angle) {
  final a = oval.width / 2;
  final b = oval.height / 2;
  final yc = math.sin(angle);
  final xc = math.cos(angle);
  final radio = (a * b) / math.sqrt(math.pow(yc * a, 2) + math.pow(xc * b, 2));

  return oval.center.translate(radio * xc, radio * yc);
}

/// 获取圆上指定角度的点坐标
/// [center] 圆心坐标
/// [radius] 圆的半径
/// [angle] 弧度
/// https://blog.csdn.net/gongjianbo1992/article/details/107476030
Offset getCirclePoint(Offset center, double radius, double angle) {
  return center.translate(radius * math.cos(angle), radius * math.sin(angle));
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

part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
/// 数学相关函数
/// [Matrix4Ex]

/// 求2点之间的距离
double distance(Offset a, Offset b) {
  return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
}

double c(double x1, double y1, double x2, double y2) {
  return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

/// 求2点之间的角度
double angle(Offset a, Offset b) {
  return atan2((b.dy - a.dy).abs(), (b.dx - a.dx).abs());
}

/// 获取弧上指定角度的点坐标
/// [angle] 弧度
/// Gets the arc point by [angle] on an [oval].
///
/// The algorithm is from https://blog.csdn.net/chenlu5201314/article/details/99678398
Offset getArcPoint(Rect oval, double angle) {
  final a = oval.width / 2;
  final b = oval.height / 2;
  final yc = sin(angle);
  final xc = cos(angle);
  final radio = (a * b) / sqrt(pow(yc * a, 2) + pow(xc * b, 2));

  return oval.center.translate(radio * xc, radio * yc);
}

/// 获取圆上指定角度的点坐标
/// [center] 圆心坐标
/// [radius] 圆的半径
/// [angle] 弧度
/// https://blog.csdn.net/gongjianbo1992/article/details/107476030
Offset getCirclePoint(Offset center, double radius, double angle) {
  return center.translate(radius * cos(angle), radius * sin(angle));
}

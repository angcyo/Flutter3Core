part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/17
/// 数学相关函数

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


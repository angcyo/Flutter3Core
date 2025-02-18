import 'dart:math';
import 'dart:ui';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/18
///
/// 公差测试
void main() {
  //ensureInitialized();
  final tolerance = 100.0;
  final p1 = Offset(100, 0);
  final p2 = Offset(300, 0);
  final p3 = Offset(200, 102);

  final path = Path();
  path.moveTo(p1.dx, p1.dy);
  path.lineTo(p2.dx, p2.dy);
  path.lineTo(p3.dx, p3.dy);
  //path.close();

  final p1a = -angle(p1, p1);
  final p2a = -angle(p2, p1);
  final p3a = -angle(p3, p2);

  path.eachPathMetrics(
      (posIndex, ratio, contourIndex, position, angle, isClose) {
    print("$position ${angle.jd}");
    print(
        "${hump(position, p1, angle, p1a, tolerance)} ${isPointInLine(position, p1, angle, p1a, tolerance)}");
  }, 10);
  //--
  print("$p1 ${p1a.jd}\n"
      "$p2 ${p2a.jd} ${hump(p2, p1, p2a, p1a, tolerance)} ${isPointInLine(p2, p1, p2a, p1a, tolerance)}\n"
      "$p3 ${p3a.jd} ${hump(p3, p1, p3a, p1a, tolerance)} ${isPointInLine(p3, p1, p3a, p1a, tolerance)}");
}

double hump(
  Offset point,
  Offset beforePoint,
  double angle,
  double beforeAngle,
  double vectorTolerance,
) {
  final c = distance(point, beforePoint);
  final h = tan((angle - beforeAngle).abs() / 4) * c / 2;
  return h.abs();
}

bool isPointInLine(
  Offset point,
  Offset beforePoint,
  double angle,
  double beforeAngle,
  double vectorTolerance,
) {
  final c = distance(point, beforePoint);
  final h = tan((angle - beforeAngle).abs() / 4) * c / 2;
  return h.abs() < vectorTolerance;
}

/// 求2点之间的距离, 返回值正负数
double distance(Offset a, Offset b) {
  return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
}

/// 求2点之间的角度,与水平面的夹角, 弧度
double angle(Offset a, Offset b) {
  //return atan2((b.dy - a.dy), (b.dx - a.dx));
  return atan2((a.dy - b.dy), (a.dx - b.dx));
  //return atan2(a.dx - b.dx, a.dy - b.dy);
}

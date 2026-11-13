import 'dart:ui';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/13
///
void main() {
  ensureInitialized();
  final width = 300.0;
  final height = 100.0;
  double rx = 30.0;
  double ry = 20.0;
  /*final rect = Rect.fromLTWH(0, 0, 300, 100);
  //--
  Path path = Path()..addRect(rect);
  fgPrint(path.toSvgPathString());
  path = Path()..addRRect(rect.toRRectFromXY(50, 50));
  fgPrint(path.toSvgPathString());*/

  Path path = Path();
  drawCornerRect(path, width, height, rx, ry, .round);
  fgPrint(path.toSvgPathString());
  path = Path();
  drawCornerRect(path, width, height, rx, ry, .inverse);
  fgPrint(path.toSvgPathString());
  path = Path();
  drawCornerRect(path, width, height, rx, ry, .chamfer);
  fgPrint(path.toSvgPathString());
  //--
  rx = 100.0;
  ry = rx;
  final Offset p1 = Offset(0, ry);
  final Offset p2 = Offset(rx, 0);
  path = Path();
  drawCornerPoint(path, p1, p2, rx, ry, .round);
  fgPrint(path.toSvgPathString());
  path = Path();
  drawCornerPoint(path, p1, p2, rx, ry, .inverse);
  fgPrint(path.toSvgPathString());
  path = Path();
  drawCornerPoint(path, p1, p2, rx, ry, .chamfer);
  fgPrint(path.toSvgPathString());
}

/// - 圆角（Round）：向图形内部切掉尖角，形成凸圆弧。
/// - 反向圆角（Inverse Round）：向图形内部凹进去，形成凹圆弧。
/// - 倒角（Chamfer）：使用直线切掉尖角。
enum CornerType {
  round, // 圆角
  inverse, // 反向圆角
  chamfer, // 倒角
}

/// - [width]、[height] 是矩形宽高，
/// - [rx]、[ry] 是圆角的水平和垂直半径
Path drawCornerRect(
  Path path,
  double width,
  double height,
  double rx,
  double ry,
  CornerType type, {
  bool? close,
}) {
  if (width <= 0 || height <= 0) return path;

  rx = rx.clamp(0.0, width / 2);
  ry = ry.clamp(0.0, height / 2);

  switch (type) {
    case .round:
      path
        ..moveTo(rx, 0)
        ..lineTo(width - rx, 0)
        ..quadraticBezierTo(width, 0, width, ry)
        ..lineTo(width, height - ry)
        ..quadraticBezierTo(width, height, width - rx, height)
        ..lineTo(rx, height)
        ..quadraticBezierTo(0, height, 0, height - ry)
        ..lineTo(0, ry)
        ..quadraticBezierTo(0, 0, rx, 0);
      break;

    case .inverse:
      path
        ..moveTo(rx, 0)
        ..lineTo(width - rx, 0)
        ..quadraticBezierTo(width - rx, ry, width, ry)
        ..lineTo(width, height - ry)
        ..quadraticBezierTo(width - rx, height - ry, width - rx, height)
        ..lineTo(rx, height)
        ..quadraticBezierTo(rx, height - ry, 0, height - ry)
        ..lineTo(0, ry)
        ..quadraticBezierTo(rx, ry, rx, 0);
      break;

    case .chamfer:
      path
        ..moveTo(rx, 0)
        ..lineTo(width - rx, 0)
        ..lineTo(width, ry)
        ..lineTo(width, height - ry)
        ..lineTo(width - rx, height)
        ..lineTo(rx, height)
        ..lineTo(0, height - ry)
        ..lineTo(0, ry)
        ..lineTo(rx, 0);
      break;
  }

  if (close == true) {
    path.close();
  }

  return path;
}

/// 在2个点之间绘制圆角
/// - [p1] 第一个点
/// - [p2] 第二个点
/// - [rx] 圆角的水平半径
/// - [ry] 圆角的垂直半径
/// - [type] 圆角类型
Path drawCornerPoint(
  Path path,
  Offset p1,
  Offset p2,
  double rx,
  double ry,
  CornerType type,
) {
  rx = rx.abs();
  ry = ry.abs();
  path.moveTo(p1.dx, p1.dy);
  switch (type) {
    case .round:
      path.arcToPoint(p2, radius: Radius.elliptical(rx, ry), clockwise: true);
      break;
    case .inverse:
      path.arcToPoint(p2, radius: Radius.elliptical(rx, ry), clockwise: false);
      break;
    case .chamfer:
      path.lineTo(p2.dx, p2.dy);
      break;
  }
  return path;
}

//--

/// 控制台前景颜色日志输出
void fgPrint(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg\x1B[0m');
}

/// 控制台背景颜色日志输出
void bgPrint(dynamic msg, [int col = 93]) {
  print('\x1B[48;5;${col}m$msg\x1B[0m');
}

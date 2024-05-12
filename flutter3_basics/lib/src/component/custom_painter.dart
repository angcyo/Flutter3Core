part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/23
///

/// [CustomPaint] widget
/// [CustomPainter] 绘制回调
class CustomPaintWrap extends CustomPainter {
  final PaintFn? paintIt;

  CustomPaintWrap(this.paintIt);

  @override
  void paint(Canvas canvas, Size size) {
    paintIt?.call(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPaintWrap oldDelegate) =>
      oldDelegate.paintIt != paintIt;
}

/// 快速创建[CustomPaint], 并指定绘制回调
/// 使用[CustomPaint]小组件, 使用[CustomPainter]绘制回调
CustomPaint paintWidget(
  PaintFn paint, {
  PaintFn? foregroundPaint,
  Size size = Size.zero,
  bool isComplex = false,
  bool willChange = false,
}) =>
    CustomPaint(
      painter: CustomPaintWrap(paint),
      foregroundPainter:
          foregroundPaint == null ? null : CustomPaintWrap(foregroundPaint),
      size: size,
      isComplex: isComplex,
      willChange: willChange,
    );

///  绘制一个三角形
class TrianglePainter extends CustomPainter {
  /// 三角形的颜色
  final Color color;

  const TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = color;

    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
        size.height * 1.05, size.width * 0.34, size.height * 0.86);
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
        size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
        size.height * 0.86, size.width * 0.66, size.height * 0.86);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

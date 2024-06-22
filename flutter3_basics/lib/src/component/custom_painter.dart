part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/23
///

/// [CustomPaint] widget
/// [CustomPainter] 绘制回调
/// [ProgressBarPainter]
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

/// [paintWidget]
/// [TrianglePainter]
/// [OvalPainter]
CustomPaint customPainter(
  CustomPainter? painter, {
  PaintFn? foregroundPaint,
  Size size = Size.zero,
  bool isComplex = false,
  bool willChange = false,
}) =>
    CustomPaint(
      painter: painter,
      foregroundPainter:
          foregroundPaint == null ? null : CustomPaintWrap(foregroundPaint),
      size: size,
      isComplex: isComplex,
      willChange: willChange,
    );

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

  /// 三角形的方向, 默认是箭头向下的
  final AxisDirection direction;

  const TrianglePainter({
    required this.color,
    this.direction = AxisDirection.down,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = color;

    switch (direction) {
      case AxisDirection.down:
        path.lineTo(size.width * 0.66, size.height * 0.86);
        path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
            size.height * 1.05, size.width * 0.34, size.height * 0.86);
        path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
        path.cubicTo(0, 0, size.width, 0, size.width, 0);
        path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
            size.width * 0.66, size.height * 0.86);
        path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
            size.height * 0.86, size.width * 0.66, size.height * 0.86);
        break;
      case AxisDirection.up:
        path.lineTo(size.width * 0.66, size.height * 0.14);
        path.cubicTo(size.width * 0.58, size.height * -0.05, size.width * 0.42,
            size.height * -0.05, size.width * 0.34, size.height * 0.14);
        path.cubicTo(size.width * 0.34, size.height * 0.14, 0, size.height, 0,
            size.height);
        path.cubicTo(
            0, size.height, size.width, size.height, size.width, size.height);
        path.cubicTo(size.width, size.height, size.width * 0.66,
            size.height * 0.14, size.width * 0.66, size.height * 0.14);
        path.cubicTo(size.width * 0.66, size.height * 0.14, size.width * 0.66,
            size.height * 0.14, size.width * 0.66, size.height * 0.14);
        break;
      case AxisDirection.left:
        path.lineTo(size.width * 0.14, size.height * 0.66);
        path.cubicTo(size.width * -0.05, size.height * 0.58, size.width * -0.05,
            size.height * 0.42, size.width * 0.14, size.height * 0.34);
        path.cubicTo(size.width * 0.14, size.height * 0.34, size.width, 0,
            size.width, 0);
        path.cubicTo(
            size.width, 0, size.width, size.height, size.width, size.height);
        path.cubicTo(size.width, size.height, size.width * 0.14,
            size.height * 0.66, size.width * 0.14, size.height * 0.66);
        path.cubicTo(size.width * 0.14, size.height * 0.66, size.width * 0.14,
            size.height * 0.66, size.width * 0.14, size.height * 0.66);
        break;
      case AxisDirection.right:
        path.lineTo(size.width * 0.86, size.height * 0.66);
        path.cubicTo(size.width * 1.05, size.height * 0.58, size.width * 1.05,
            size.height * 0.42, size.width * 0.86, size.height * 0.34);
        path.cubicTo(size.width * 0.86, size.height * 0.34, 0, 0, 0, 0);
        path.cubicTo(0, 0, 0, size.height, 0, size.height);
        path.cubicTo(0, size.height, size.width * 0.86, size.height * 0.66,
            size.width * 0.86, size.height * 0.66);
        path.cubicTo(size.width * 0.86, size.height * 0.66, size.width * 0.86,
            size.height * 0.66, size.width * 0.86, size.height * 0.66);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

///  绘制一个椭圆/圆形
class OvalPainter extends CustomPainter {
  /// 颜色
  final Color color;

  /// 线宽度
  final double strokeWidth;

  OvalPainter({
    super.repaint,
    this.color = Colors.green,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// 透明棋盘小部件
class PixelTransparentWidget extends StatelessWidget {
  final Widget? child;

  const PixelTransparentWidget({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary;
    final Color secondary;

    if (context.isThemeDark) {
      primary = const Color.fromARGB(255, 17, 17, 17);
      secondary = const Color.fromARGB(255, 36, 36, 37);
    } else {
      primary = const Color(-0x3d3d3e);
      secondary = const Color(-0xc0c0d);
    }

    return CustomPaint(
      painter: PixelTransparentPainter(primary: primary, secondary: secondary),
      size: const Size(double.infinity, double.infinity),
      child: child,
    );
  }
}

/// 绘制一个透明棋盘
class PixelTransparentPainter extends CustomPainter {
  final double cellSize;
  final Color primary;
  final Color secondary;

  const PixelTransparentPainter({
    this.cellSize = 20,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final numCellsX = size.width / cellSize;
    final numCellsY = size.height / cellSize;

    for (int row = 0; row < numCellsY; row++) {
      for (int col = 0; col < numCellsX; col++) {
        final color = (row + col) % 2 == 0 ? primary : secondary;

        final left = col * cellSize;
        final top = row * cellSize;
        final right = math.min(left + cellSize, size.width);
        final bottom = math.min(top + cellSize, size.height);

        canvas.drawRect(
          Rect.fromLTRB(left, top, right, bottom),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

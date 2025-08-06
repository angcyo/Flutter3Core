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
  Size? size,
  double? s,
  double? width,
  double? height,
  PaintFn? foregroundPaint,
  bool isComplex = false,
  bool willChange = false,
}) =>
    CustomPaint(
      painter: painter,
      foregroundPainter:
          foregroundPaint == null ? null : CustomPaintWrap(foregroundPaint),
      size: size ?? Size(s ?? width ?? 0, s ?? height ?? 0),
      isComplex: isComplex,
      willChange: willChange,
    );

/// 快速创建[CustomPaint], 并指定绘制回调
/// 使用[CustomPaint]小组件, 使用[CustomPainter]绘制回调
CustomPaint paintWidget(
  PaintFn paint, {
  PaintFn? foregroundPaint,
  Size size = Size.infinite,
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
/// [TrianglePainter]
/// [ArrowWidget]
class TrianglePainter extends CustomPainter {
  /// 创建一个三角形
  static Path createTrianglePath(
    Size size, {
    AxisDirection direction = AxisDirection.down,
    Offset? center,
  }) {
    Offset? offset;
    if (center != null) {
      offset = center - size.center(Offset.zero);
    }
    final Path path = Path();
    switch (direction) {
      case AxisDirection.down:
        path.moveTo(size.width * 0.66, size.height * 0.86);
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
        path.moveTo(size.width * 0.66, size.height * 0.14);
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
        path.moveTo(size.width * 0.14, size.height * 0.66);
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
        path.moveTo(size.width * 0.86, size.height * 0.66);
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

    if (offset != null) {
      return path.shift(offset);
    }
    return path;
  }

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
    paint.isAntiAlias = true;
    paint.color = color;
    canvas.drawPath(createTrianglePath(size, direction: direction), paint);
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
/// [PixelTransparentPainter] 棋盘画笔
class TransparentPixelWidget extends StatelessWidget {
  final double cellSize;

  final Widget? child;

  const TransparentPixelWidget({
    super.key,
    this.child,
    this.cellSize = 20,
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
      painter: PixelTransparentPainter(
        primary: primary,
        secondary: secondary,
        cellSize: cellSize,
      ),
      size: const Size(double.infinity, double.infinity),
      child: child,
    );
  }
}

/// 绘制一个透明棋盘
class PixelTransparentPainter extends CustomPainter {
  /// 格子大小
  final double cellSize;

  /// 格子间隙
  final double cellGap;

  /// 主色
  final Color primary;

  /// 次色
  final Color secondary;

  const PixelTransparentPainter({
    this.cellSize = 20,
    this.cellGap = 0,
    this.primary = const Color(-0x3d3d3e),
    this.secondary = const Color(-0xc0c0d),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final numCellsX = size.width / (cellSize + cellGap);
    final numCellsY = size.height / (cellSize + cellGap);

    for (int row = 0; row < numCellsY; row++) {
      for (int col = 0; col < numCellsX; col++) {
        final color = (row + col) % 2 == 0 ? primary : secondary;

        final left = col * cellSize + cellGap * col;
        final top = row * cellSize + cellGap * row;
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

/// 绘制一个指定大小的点
class PointPainter extends CustomPainter {
  /// 点的直径
  final double width;

  /// 颜色
  final Color color;

  const PointPainter(
    this.width, {
    this.color = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      width / 2,
      Paint()
        ..style = ui.PaintingStyle.fill
        ..color = color
        ..strokeWidth = width / 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// 虚线连接线
class DashLinkPainter extends CustomPainter {
  /// 需要[长度, 间隙, 长度, 间隙]
  final List<double> lineSizeList;

  /// 线的厚度
  final double thickness;

  /// 颜色
  final Color color;

  /// 方向
  final Axis axis;

  const DashLinkPainter(
    this.lineSizeList, {
    this.thickness = 1,
    this.color = Colors.grey,
    this.axis = Axis.horizontal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //线的总长度
    final lineLength = lineSizeList.reduce((value, element) => value + element);

    if (axis == Axis.horizontal) {
      //横向 虚线绘制
      double left = (size.width - lineLength) / 2;
      double top = size.height / 2;
      lineSizeList.forEachIndexed((index, length) {
        if (index % 2 != 0) {
          //gap
        } else {
          canvas.drawLine(
            Offset(left, top),
            Offset(left + length, top),
            Paint()
              ..strokeWidth = thickness
              ..color = color,
          );
        }
        left += length;
      });
    } else {
      //纵向 虚线绘制
      double left = size.width / 2;
      double top = (size.height - lineLength) / 2;
      lineSizeList.forEachIndexed((index, length) {
        if (index % 2 != 0) {
          //gap
        } else {
          canvas.drawLine(
            Offset(left, top),
            Offset(left, top + length),
            Paint()
              ..strokeWidth = thickness
              ..color = color,
          );
        }
        top += length;
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// 圆点+阴影的绘制
class CirclePointPainter extends CustomPainter {
  /// 圆的半径
  final double radius;

  /// 圆的颜色, 同时决定了阴影的颜色
  final Color color;

  /// 扩展半径
  final double extendRadius;

  /// 扩展圆的颜色
  final Color extendColor;

  /// 阴影偏移
  final Offset offset;

  /// 是否绘制阴影
  final bool drawShadow;

  const CirclePointPainter({
    this.radius = 8,
    this.extendRadius = 2,
    this.offset = const Offset(0, 1.24),
    this.color = Colors.green,
    this.extendColor = Colors.white,
    this.drawShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final br = math.min(s, radius + extendRadius);
    final sr = math.min(s, br - extendRadius);
    final bounds = Offset.zero & size;
    //绘制模糊阴影
    if (drawShadow) {
      canvas.drawCircle(
        bounds.center + offset,
        br,
        Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    //绘制白色圆内容
    canvas.drawCircle(
      bounds.center,
      br,
      Paint()..color = extendColor,
    );
    //绘制绿色圆内容
    canvas.drawCircle(
      bounds.center,
      sr,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(CirclePointPainter oldDelegate) {
    return false;
  }
}

part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 绘制元素数据
class GraffitiPainter extends IPainter
    with DiagnosticableTreeMixin, DiagnosticsMixin {
  Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {}

  /// 添加一个数据
  @property
  void addPointEventMeta(PointEventMeta point) {}

  //region ---canvas---

  GraffitiDelegate? graffitiDelegate;

  /// 附加到[GraffitiDelegate]
  @mustCallSuper
  void attachToGraffitiDelegate(GraffitiDelegate graffitiDelegate) {
    final old = this.graffitiDelegate;
    if (old != null && old != graffitiDelegate) {
      detachFromGraffitiDelegate(old);
    }
    this.graffitiDelegate = graffitiDelegate;
  }

  /// 从[GraffitiDelegate]中移除
  @mustCallSuper
  void detachFromGraffitiDelegate(GraffitiDelegate graffitiDelegate) {
    this.graffitiDelegate = null;
  }

  /// 刷新画布
  @mustCallSuper
  void refresh() {
    graffitiDelegate?.refresh();
  }

  //endregion ---canvas---

  //region ---output---

  /// 是否支持矢量数据输出
  bool supportVectorOutput = false;

  /// 输出的矢量数据
  @output
  Path? outputPath;

  @output
  String? outputPathString;

//endregion ---output---
}

/// 铅笔数据绘制, 宽度一致
class GraffitiPencilPainter extends GraffitiFountainPenPainter {
  GraffitiPencilPainter() {
    supportVectorOutput = false;
  }
}

/// 橡皮擦数据绘制
class GraffitiEraserPainter extends GraffitiPencilPainter {
  GraffitiEraserPainter() {
    paint.blendMode = BlendMode.clear;
    supportVectorOutput = false;
  }
}

/// 钢笔数据绘制
class GraffitiFountainPenPainter extends GraffitiPainter
    with CurvePointEventMixin {
  final List<PointEventMeta> pointListCache = [];

  /// 绘制的对象
  Path? path;

  /// 输出的矢量数据
  StringBuffer? pathBuffer;

  GraffitiFountainPenPainter() {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    supportVectorOutput = true;
  }

  @override
  String? get outputPathString => pathBuffer?.toString();

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    //canvas.drawPoints(ui.PointMode.polygon, points, paint);
    if (path != null) {
      canvas.drawPath(path!, paint);
    }
  }

  /// 添加一个数据
  @override
  @property
  void addPointEventMeta(PointEventMeta point) {
    pointListCache.add(point);
    if (pointListCache.size() == 1) {
      // To reduce the initial lag make it work with 3 mPoints
      // by duplicating the first point
      pointListCache.add(point.copyWith());
    }
    final curveBezierMeta = calculateCurveBezierMeta(pointListCache);
    if (curveBezierMeta != null) {
      //--
      if (path == null) {
        path = Path();
        path?.moveTo(curveBezierMeta.start.x, curveBezierMeta.start.y);
        pathBuffer = StringBuffer();
        pathBuffer
            ?.write('M ${curveBezierMeta.start.x} ${curveBezierMeta.start.y}');
      }

      //--
      path?.cubicTo(
          curveBezierMeta.c1.x,
          curveBezierMeta.c1.y,
          curveBezierMeta.c2.x,
          curveBezierMeta.c2.y,
          curveBezierMeta.end.x,
          curveBezierMeta.end.y);
      pathBuffer?.write(
          'C ${curveBezierMeta.c1.x} ${curveBezierMeta.c1.y} ${curveBezierMeta.c2.x} ${curveBezierMeta.c2.y} ${curveBezierMeta.end.x} ${curveBezierMeta.end.y}');

      //--
      pointListCache.removeFirstIfNotEmpty();
    }
  }
}

/// 毛笔数据绘制, 宽度不等
class GraffitiBrushPenPainter extends GraffitiPainter
    with CurvePointEventMixin {
  final List<PointEventMeta> pointListCache = [];
  final List<PointEventMeta> points = [];
  final List<Offset> pointsTail = [];

  double velocityFilterWeight = 0.8;
  double minWidth = 3;
  double maxWidth = 20;

  double _lastWidth = (3 + 20) / 2;
  double _lastVelocity = 0;

  /// 是否使用尾部粗细算法
  bool brushTailArithmetic = false;

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    /*assert(() {
      paint.strokeWidth = 10;
      return true;
    }());*/
    if (brushTailArithmetic) {
      _paintBrushTail(canvas, pointsTail);
    } else {
      for (final point in points) {
        paint.strokeWidth = point.width ?? paint.strokeWidth;
        canvas.drawPoints(ui.PointMode.points, [point.position], paint);
      }
    }
  }

  /// 尾部粗细算法效果
  void _paintBrushTail(Canvas canvas, List<Offset> points) {
    double originalWidth = maxWidth;
    if (points.isNotEmpty) {
      // 绘制椭圆
      final Rect rect = Rect.fromCenter(
          center: Offset(points[0].dx, points[0].dy),
          width: originalWidth - 1,
          height: originalWidth + 2);

      paint.strokeWidth = 0;
      paint.style = PaintingStyle.fill;
      canvas.drawOval(rect, paint);

      //
      Path path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length - 1; i++) {
        var mid = Offset(
          (points[i].dx + points[i + 1].dx) / 2,
          (points[i].dy + points[i + 1].dy) / 2,
        );
        path.quadraticBezierTo(
          points[i].dx,
          points[i].dy,
          mid.dx,
          mid.dy,
        );
      }
      path.lineTo(points.last.dx, points.last.dy);

      //--
      paint.strokeWidth = originalWidth;
      paint.style = PaintingStyle.stroke;
      ui.PathMetrics metrics = path.computeMetrics();
      for (ui.PathMetric metric in metrics) {
        double segmentLength = metric.length;

        // 不超过60的时候，从segmentLength - 2开始逐渐变细
        double startPosition =
            segmentLength - min(segmentLength - 2, 60); // 从长度减去60的位置开始逐渐变细
        Path startPath = Path();
        startPath.addPath(metric.extractPath(0, startPosition), Offset.zero);
        canvas.drawPath(startPath, paint);

        for (double i = startPosition; i < segmentLength; i += 1.0) {
          // 计算 segmentLength - 60开始的宽度递减
          double width = originalWidth -
              ((i - startPosition) / (segmentLength - startPosition)) *
                  (originalWidth - minWidth);
          width = width.clamp(minWidth, originalWidth);
          final ui.Tangent? tangent = metric.getTangentForOffset(i);

          if (tangent != null) {
            paint.strokeWidth = width;

            // 绘制一个点
            final Path segmentPath = Path()
              ..moveTo(tangent.position.dx, tangent.position.dy)
              ..lineTo(tangent.position.dx, tangent.position.dy);

            canvas.drawPath(segmentPath, paint);
          }
        }
      }
    }
  }

  /// 添加一个数据
  @override
  @property
  void addPointEventMeta(PointEventMeta point) {
    if (brushTailArithmetic) {
      pointsTail.add(point.position);
      return;
    }

    pointListCache.add(point);
    if (pointListCache.size() == 1) {
      // To reduce the initial lag make it work with 3 mPoints
      // by duplicating the first point
      pointListCache.add(point.copyWith());
    }
    final curveBezierMeta = calculateCurveBezierMeta(pointListCache);
    if (curveBezierMeta != null) {
      final startPoint = curveBezierMeta.start;
      final endPoint = curveBezierMeta.end;

      double velocity = endPoint.velocityFrom(startPoint);

      velocity = velocityFilterWeight * velocity +
          (1 - velocityFilterWeight) * _lastVelocity;
      velocity = velocity.ensureValid();

      // The new width is a function of the velocity. Higher velocities
      // correspond to thinner strokes.
      double startWidth = _lastWidth;
      double endWidth = velocityStrokeWidth(velocity);

      //--
      double originalWidth = paint.strokeWidth;
      double widthDelta = endWidth - startWidth;
      double drawSteps = curveBezierMeta.length().floorToDouble();

      //l.d("velocity:$velocity drawSteps:$drawSteps");

      /*final linePath = Path()
        ..moveTo(startPoint.x, startPoint.y)
        ..lineTo(endPoint.x, endPoint.y);
      linePath.eachPathMetrics((
        posIndex,
        ratio,
        contourIndex,
        position,
        angle,
        isClosed,
      ) {
        final pointMeta = PointEventMeta(position, nowTimestamp(),
            width: startWidth + (endWidth - startWidth) * ratio);
        points.add(pointMeta);
      }, 0.5);*/

      for (int i = 0; i < drawSteps; i++) {
        // Calculate the Bezier (x, y) coordinate for this step.
        double t = i.toDouble() / drawSteps;
        double tt = t * t;
        double ttt = tt * t;
        double u = 1 - t;
        double uu = u * u;
        double uuu = uu * u;

        double x = uuu * curveBezierMeta.start.x;
        x += 3 * uu * t * curveBezierMeta.c1.x;
        x += 3 * u * tt * curveBezierMeta.c2.x;
        x += ttt * curveBezierMeta.end.x;

        double y = uuu * curveBezierMeta.start.y;
        y += 3 * uu * t * curveBezierMeta.c1.y;
        y += 3 * u * tt * curveBezierMeta.c2.y;
        y += ttt * curveBezierMeta.end.y;

        // Set the incremental stroke width and draw.
        final pointMeta = PointEventMeta(ui.Offset(x, y), nowTimestamp(),
            width: startWidth + ttt * widthDelta);
        points.add(pointMeta);
      }

      paint.strokeWidth = originalWidth;

      //--
      _lastVelocity = velocity;
      _lastWidth = endWidth;

      //--
      pointListCache.removeFirstIfNotEmpty();
    }
  }

  double velocityStrokeWidth(double velocity) {
    return max(maxWidth / (velocity + 1), minWidth);
  }

  void updateMaxWidth(double width) {
    maxWidth = width;
    _lastWidth = (minWidth + maxWidth) / 2;
  }
}

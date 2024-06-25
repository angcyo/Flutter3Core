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
}

/// 铅笔数据绘制, 宽度一致
class GraffitiPencilPainter extends GraffitiPainter {
  final List<Offset> points = [];

  GraffitiPencilPainter();

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    canvas.drawPoints(ui.PointMode.polygon, points, paint);
  }

  /// 添加一个数据
  @override
  @property
  void addPointEventMeta(PointEventMeta point) {
    points.add(point.position);
  }
}

/// 橡皮擦数据绘制
class GraffitiEraserPainter extends GraffitiPencilPainter {
  GraffitiEraserPainter() {
    paint.blendMode = BlendMode.clear;
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
  }

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

  double mVelocityFilterWeight = 0.8;
  double mMinWidth = 3;
  double mMaxWidth = 20;

  double mLastWidth = (3 + 20) / 2;
  double mLastVelocity = 0;

  @override
  void painting(Canvas canvas, PaintMeta paintMeta) {
    assert(() {
      paint.strokeWidth = 10;
      return true;
    }());
    for (final point in points) {
      paint.strokeWidth = point.width ?? paint.strokeWidth;
      canvas.drawPoints(ui.PointMode.points, [point.position], paint);
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
      final startPoint = curveBezierMeta.start;
      final endPoint = curveBezierMeta.end;

      double velocity = endPoint.velocityFrom(startPoint);

      velocity = mVelocityFilterWeight * velocity +
          (1 - mVelocityFilterWeight) * mLastVelocity;
      velocity = velocity.ensureValid();

      // The new width is a function of the velocity. Higher velocities
      // correspond to thinner strokes.
      double startWidth = mLastWidth;
      double endWidth = strokeWidth(velocity);

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
      mLastVelocity = velocity;
      mLastWidth = endWidth;

      //--
      pointListCache.removeFirstIfNotEmpty();
    }
  }

  double strokeWidth(double velocity) {
    return max(mMaxWidth / (velocity + 1), mMinWidth);
  }
}

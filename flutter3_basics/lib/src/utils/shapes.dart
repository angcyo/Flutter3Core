part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/04
///
/// 一些基础几何图形创建
/// - [generateCrossPath]
class Shapes {
  Shapes._();

  /// - 线: [1.0, slope, intercept]
  /// - 圆: [2.0, cx, cy, radius]
  /// - 三角形: [3.0, p1, p2, p3]
  /// - 矩形: [4.0, min_x, min_y, max_x, max_y, max_x]
  /// - OBB矩形: [5.0, p1, p2, p3, p4]
  /// - 椭圆: [6.0, center_x, center_y, axis_a, axis_b, angle]
  /// - 五边形: [7.0, cx, cy, radius, angle, p...]
  /// - 五角星: [8.0, center_x, center_y, outer_radius, inner_radius, angle,]
  /// - 心形: [9.0, cx, cy, width, height]
  /// - 箭头: [10.0, sx, sy, tx, ty, lx, ly, rx, ry]
  /// - V箭头: [11.0, tx, ty, lx, ly, rx, ry]
  /// - 多边形: [12.0, p...]
  /// - 其它: [0.0]
  static Path? buildFromValues(
    List<double>? values, {
    double? lineX1,
    double? lineX2,
    //--
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    if (values == null || values.isEmpty || values.length < 2) {
      return null;
    }
    final type = values.first;
    if (type == 1 && values.length >= 3) {
      return buildLinePath(
        slope: values[1],
        intercept: values[2],
        x1: lineX1 ?? 0,
        x2: lineX2 ?? 0,
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 2 && values.length >= 4) {
      return buildCirclePath(
        cx: values[1],
        cy: values[2],
        radius: values[3],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 3 && values.length >= 7) {
      return buildTrianglePath(
        x1: values[1],
        y1: values[2],
        x2: values[3],
        y2: values[4],
        x3: values[5],
        y3: values[6],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 4 && values.length >= 5) {
      return buildRectPath(
        minX: values[1],
        minY: values[2],
        maxX: values[3],
        maxY: values[4],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 5 && values.length >= 9) {
      return buildOBBPath(
        x1: values[1],
        y1: values[2],
        x2: values[3],
        y2: values[4],
        x3: values[5],
        y3: values[6],
        x4: values[7],
        y4: values[8],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 6 && values.length >= 6) {
      return buildEllipsePath(
        cx: values[1],
        cy: values[2],
        axisA: values[3],
        axisB: values[4],
        angle: values[5],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 7 && values.length >= 5) {
      return buildPentagonPath(
        points: values.sublist(1),
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 8 && values.length >= 6) {
      return buildStarPath(
        cx: values[1],
        cy: values[2],
        outerRadius: values[3],
        innerRadius: values[4],
        angle: values[5],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 9 && values.length >= 5) {
      return buildHeartPath(
        cx: values[1],
        cy: values[2],
        w: values[3],
        h: values[4],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 10 && values.length >= 9) {
      return buildArrowPath(
        sx: values[1],
        sy: values[2],
        tx: values[3],
        ty: values[4],
        lx: values[5],
        ly: values[6],
        rx: values[7],
        ry: values[8],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 11 && values.length >= 7) {
      return buildVArrowPath(
        tx: values[1],
        ty: values[2],
        lx: values[3],
        ly: values[4],
        rx: values[5],
        ry: values[6],
        pathBuilder: pathBuilder,
        digits: digits,
      );
    } else if (type == 12 && values.length >= 5) {
      return buildPolygonPath(
        points: values.sublist(1),
        pathBuilder: pathBuilder,
        digits: digits,
      );
    }
    return null;
  }

  /// 根据斜率, 偏移创建一条线 y = slope * x + intercept
  /// - [slope] 斜率
  /// - [intercept] 截距
  /// - [x1] 起点x
  /// - [x2] 终点x
  static Path buildLinePath({
    required double slope,
    required double intercept,
    required double x1,
    required double x2,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    final p1x = x1;
    final p1y = slope * p1x + intercept;
    final p2x = x2;
    final p2y = slope * p2x + intercept;
    pathBuilder?.write(
      'M${p1x.toDigits(digits: digits)} ${p1y.toDigits(digits: digits)} '
      'L${p2x.toDigits(digits: digits)} ${p2y.toDigits(digits: digits)}',
    );
    return (path ?? Path())
      ..moveTo(p1x, p1y)
      ..lineTo(p2x, p2y);
  }

  /// 创建一个圆
  static Path buildCirclePath({
    required double cx,
    required double cy,
    required double radius,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    if (pathBuilder != null) {
      // 逼近圆弧的贝塞尔神奇常数 Kappa
      final kappa = 0.5522847498307933;
      final offset = radius * kappa;

      // 定义圆的四个极值点坐标（右、下、左、上）
      final rX = cx + radius;
      final rY = cy;
      final bX = cx;
      final bY = cy + radius;
      final lX = cx - radius;
      final lY = cy;
      final uX = cx;
      final uY = cy - radius;

      // 1. 移至起点：右顶点 (rX, rY)
      pathBuilder.write(
        'M${rX.toDigits(digits: digits)} ${rY.toDigits(digits: digits)} ',
      );

      // 2. 第一段：右顶点 -> 下顶点
      pathBuilder.write(
        'C${rX.toDigits(digits: digits)} ${(rY + offset).toDigits(digits: digits)} ' // 控制点 1（从右顶点向下延伸）
        '${(bX + offset).toDigits(digits: digits)} ${bY.toDigits(digits: digits)} ' // 控制点 2（向自由端右侧延伸）
        '${bX.toDigits(digits: digits)} ${bY.toDigits(digits: digits)} ', // 终点：下顶点
      );

      // 3. 第二段：下顶点 -> 左顶点
      pathBuilder.write(
        'C${(bX - offset).toDigits(digits: digits)} ${bY.toDigits(digits: digits)} ' // 终点：左顶点'
        '${lX.toDigits(digits: digits)} ${(lY + offset).toDigits(digits: digits)} ' // 控制点 1（向自由端左侧延伸）
        '${lX.toDigits(digits: digits)} ${(lY).toDigits(digits: digits)} ', // 控制点 2（从左顶点向上延伸）
      );

      // 4. 第三段：左顶点 -> 上顶点
      pathBuilder.write(
        'C${lX.toDigits(digits: digits)} ${(lY - offset).toDigits(digits: digits)} ' // 终点：右顶点
        '${(uX - offset).toDigits(digits: digits)} ${uY.toDigits(digits: digits)} '
        '${uX.toDigits(digits: digits)} ${uY.toDigits(digits: digits)} ',
      );

      // 5. 第四段：上顶点 -> 回到右顶点起点闭合
      pathBuilder.write(
        'C${(uX + offset).toDigits(digits: digits)} ${uY.toDigits(digits: digits)} '
        '${rX.toDigits(digits: digits)} ${(rY - offset).toDigits(digits: digits)} '
        '${rX.toDigits(digits: digits)} ${rY.toDigits(digits: digits)}',
      );

      pathBuilder.write('Z');
    }

    return (path ?? Path())..addCircle(Offset(cx, cy), radius);
  }

  /// 创建一个矩形
  static Path buildRectPath({
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    pathBuilder?.write(
      'M${minX.toDigits(digits: digits)} ${minY.toDigits(digits: digits)} '
      'L${maxX.toDigits(digits: digits)} ${minY.toDigits(digits: digits)} '
      'L${maxX.toDigits(digits: digits)} ${maxY.toDigits(digits: digits)} '
      'L${minX.toDigits(digits: digits)} ${maxY.toDigits(digits: digits)} '
      'L${minX.toDigits(digits: digits)} ${minY.toDigits(digits: digits)} '
      'Z',
    );
    return (path ?? Path())..addRect(Rect.fromLTRB(minX, minY, maxX, maxY));
  }

  /// 创建一个OBB矩形
  static Path buildOBBPath({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double x3,
    required double y3,
    required double x4,
    required double y4,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    pathBuilder?.write(
      'M${x1.toDigits(digits: digits)} ${y1.toDigits(digits: digits)} '
      'L${x2.toDigits(digits: digits)} ${y2.toDigits(digits: digits)} '
      'L${x3.toDigits(digits: digits)} ${y3.toDigits(digits: digits)} '
      'L${x4.toDigits(digits: digits)} ${y4.toDigits(digits: digits)} '
      'L${x1.toDigits(digits: digits)} ${y1.toDigits(digits: digits)} '
      'Z',
    );
    return (path ?? Path())..addPolygon([
      Offset(x1, y1),
      Offset(x2, y2),
      Offset(x3, y3),
      Offset(x4, y4),
    ], true);
  }

  /// 创建一个三角形
  static Path buildTrianglePath({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double x3,
    required double y3,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    pathBuilder?.write(
      'M${x1.toDigits(digits: digits)} ${y1.toDigits(digits: digits)} '
      'L${x2.toDigits(digits: digits)} ${y2.toDigits(digits: digits)} '
      'L${x3.toDigits(digits: digits)} ${y3.toDigits(digits: digits)} '
      'L${x1.toDigits(digits: digits)} ${y1.toDigits(digits: digits)} '
      'Z',
    );
    return (path ?? Path())
      ..addPolygon([Offset(x1, y1), Offset(x2, y2), Offset(x3, y3)], true);
  }

  /// 创建一个椭圆
  /// 利用 4 段三阶贝塞尔曲线完美还原旋转椭圆（屏幕坐标系）
  static Path buildEllipsePath({
    required double cx,
    required double cy,
    required double axisA, // 半长轴 a (Local X 半径)
    required double axisB, // 半短轴 b (Local Y 半径)
    required double angle, // 旋转弧度 (Radians)
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();

    // 逼近圆弧的贝塞尔神奇常数 Kappa
    final kappa = 0.5522847498307933;

    final cosA = angle.cos();
    final sinA = angle.sin();

    // 闭包工具：将局部坐标系 (lx, ly) 投影并平移至世界坐标系 (wx, wy)
    (double, double) transform(double lx, double ly) {
      final wx = lx * cosA - ly * sinA + cx;
      final wy = lx * sinA + ly * cosA + cy;
      return (wx, wy);
    }

    // 1. 确定起点 (位于局部坐标系的右顶点 [axis_a, 0])
    final (sx, sy) = transform(axisA, 0.0);
    path.moveTo(sx, sy);
    pathBuilder?.write(
      'M${sx.toDigits(digits: digits)} ${sy.toDigits(digits: digits)} ',
    );

    // 2. 第一象限弧线 (右顶点 -> 下顶点 [0, axis_b])
    final (cp1X, cp1Y) = transform(axisA, axisB * kappa);
    final (cp2X, cp2Y) = transform(axisA * kappa, axisB);
    final (epX, epY) = transform(0.0, axisB);
    path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, epX, epY);
    pathBuilder?.write(
      'C${cp1X.toDigits(digits: digits)} ${cp1Y.toDigits(digits: digits)} '
      '${cp2X.toDigits(digits: digits)} ${cp2Y.toDigits(digits: digits)} '
      '${epX.toDigits(digits: digits)} ${epY.toDigits(digits: digits)} ',
    );

    // 3. 第二象限弧线 (下顶点 -> 左顶点 [-axis_a, 0])
    final (cp3X, cp3Y) = transform(-axisA * kappa, axisB);
    final (cp4X, cp4Y) = transform(-axisA, axisB * kappa);
    final (ep2X, ep2Y) = transform(-axisA, 0.0);
    path.cubicTo(cp3X, cp3Y, cp4X, cp4Y, ep2X, ep2Y);
    pathBuilder?.write(
      'C${cp3X.toDigits(digits: digits)} ${cp3Y.toDigits(digits: digits)} '
      '${cp4X.toDigits(digits: digits)} ${cp4Y.toDigits(digits: digits)} '
      '${ep2X.toDigits(digits: digits)} ${ep2Y.toDigits(digits: digits)} ',
    );

    // 4. 第三象限弧线 (左顶点 -> 上顶点 [0, -axis_b])
    final (cp5X, cp5Y) = transform(-axisA, -axisB * kappa);
    final (cp6X, cp6Y) = transform(-axisA * kappa, -axisB);
    final (ep3X, ep3Y) = transform(0.0, -axisB);
    path.cubicTo(cp5X, cp5Y, cp6X, cp6Y, ep3X, ep3Y);
    pathBuilder?.write(
      'C${cp5X.toDigits(digits: digits)} ${cp5Y.toDigits(digits: digits)} '
      '${cp6X.toDigits(digits: digits)} ${cp6Y.toDigits(digits: digits)} '
      '${ep3X.toDigits(digits: digits)} ${ep3Y.toDigits(digits: digits)} ',
    );

    // 5. 第四象限弧线 (上顶点 -> 回到右顶点起点的闭合)
    final (cp7X, cp7Y) = transform(axisA * kappa, -axisB);
    final (cp8X, cp8Y) = transform(axisA, -axisB * kappa);
    path.cubicTo(cp7X, cp7Y, cp8X, cp8Y, sx, sy);
    pathBuilder?.write(
      'C${cp7X.toDigits(digits: digits)} ${cp7Y.toDigits(digits: digits)} '
      '${cp8X.toDigits(digits: digits)} ${cp8Y.toDigits(digits: digits)} '
      '${sx.toDigits(digits: digits)} ${sy.toDigits(digits: digits)} ',
    );

    path.close();
    pathBuilder?.write('Z');

    /*final ellipse = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: axisA * 2,
          height: axisB * 2,
        ),
      );
    ellipse.transformPath(createRotateMatrix(angle, anchorX: cx, anchorY: cy));*/

    return path;
  }

  /// 创建一个心形, 爱心
  /// 使用 4段三阶贝塞尔曲线（Cubic Bezier） 来完美拟合一个平滑且数据量极小的心形路径
  static Path buildHeartPath({
    required double cx,
    required double cy,
    required double w,
    required double h,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    final left = cx - w / 2.0;
    final right = cx + w / 2.0;
    final top = cy - h / 2.0;
    final bottom = cy + h / 2.0;

    path ??= Path();

    // 起点：心形最下方的尖角 (底部中点)
    path.moveTo(cx, bottom);
    pathBuilder?.write(
      'M${cx.toDigits(digits: digits)} ${bottom.toDigits(digits: digits)} ',
    );

    // 1. 左下弧线：从底部尖角绘制到左侧最宽处
    path.cubicTo(
      cx,
      bottom - h * 0.15, // 控制点 1
      left,
      bottom - h * 0.35, // 控制点 2
      left,
      top + h * 0.35, // 终点 (左侧半圆边缘)
    );
    pathBuilder?.write(
      'C${cx.toDigits(digits: digits)} ${(bottom - h * 0.15).toDigits(digits: digits)} '
      '${left.toDigits(digits: digits)} ${(bottom - h * 0.35).toDigits(digits: digits)} '
      '${left.toDigits(digits: digits)} ${(top + h * 0.35).toDigits(digits: digits)} ',
    );
    // 2. 左上弧线：从左侧最宽处绕到顶部中间的凹陷点
    path.cubicTo(
      left,
      top + h * 0.05,
      cx - w * 0.15,
      top,
      cx,
      top + h * 0.20, // 终点 (顶部中心凹陷)
    );
    pathBuilder?.write(
      'C${left.toDigits(digits: digits)} ${(top + h * 0.05).toDigits(digits: digits)} '
      '${(cx - w * 0.15).toDigits(digits: digits)} ${top.toDigits(digits: digits)} '
      '${cx.toDigits(digits: digits)} ${(top + h * 0.20).toDigits(digits: digits)} ',
    );
    // 3. 右上弧线：从顶部凹陷点绕到右侧最宽处
    path.cubicTo(
      cx + w * 0.15,
      top,
      right,
      top + h * 0.05,
      right,
      top + h * 0.35, // 终点 (右侧半圆边缘)
    );
    pathBuilder?.write(
      'C${(cx + w * 0.15).toDigits(digits: digits)} ${top.toDigits(digits: digits)} '
      '${right.toDigits(digits: digits)} ${(top + h * 0.05).toDigits(digits: digits)} '
      '${right.toDigits(digits: digits)} ${(top + h * 0.35).toDigits(digits: digits)} ',
    );
    // 4. 右下弧线：从右侧最宽处收敛回底部尖角
    path.cubicTo(
      right,
      bottom - h * 0.35,
      cx,
      bottom - h * 0.15,
      cx,
      bottom, // 终点 (回到原点)
    );
    pathBuilder?.write(
      'C${right.toDigits(digits: digits)} ${(bottom - h * 0.35).toDigits(digits: digits)} '
      '${cx.toDigits(digits: digits)} ${(bottom - h * 0.15).toDigits(digits: digits)} '
      '${cx.toDigits(digits: digits)} ${bottom.toDigits(digits: digits)} ',
    );
    path.close();
    pathBuilder?.write('Z');
    return path;
  }

  /// 创建箭头→
  static Path buildArrowPath({
    //起始点
    required double sx,
    required double sy,
    //尖头点
    required double tx,
    required double ty,
    //左翼点
    required double lx,
    required double ly,
    //右翼点
    required double rx,
    required double ry,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();
    //--主干线
    path.moveTo(sx, sy);
    pathBuilder?.write(
      'M${sx.toDigits(digits: digits)} ${sy.toDigits(digits: digits)} ',
    );
    path.lineTo(tx, ty);
    pathBuilder?.write(
      'L${tx.toDigits(digits: digits)} ${ty.toDigits(digits: digits)} ',
    );
    //--
    path.moveTo(lx, ly);
    pathBuilder?.write(
      'M${lx.toDigits(digits: digits)} ${ly.toDigits(digits: digits)} ',
    );
    path.lineTo(tx, ty);
    pathBuilder?.write(
      'L${tx.toDigits(digits: digits)} ${ty.toDigits(digits: digits)} ',
    );
    path.lineTo(rx, ry);
    pathBuilder?.write(
      'L${rx.toDigits(digits: digits)} ${ry.toDigits(digits: digits)} ',
    );
    return path;
  }

  /// 创建V箭头
  static Path buildVArrowPath({
    //尖头点
    required double tx,
    required double ty,
    //左翼点
    required double lx,
    required double ly,
    //右翼点
    required double rx,
    required double ry,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();
    path.moveTo(lx, ly);
    pathBuilder?.write(
      'M${lx.toDigits(digits: digits)} ${ly.toDigits(digits: digits)} ',
    );
    path.lineTo(tx, ty);
    pathBuilder?.write(
      'L${tx.toDigits(digits: digits)} ${ty.toDigits(digits: digits)} ',
    );
    path.lineTo(rx, ry);
    pathBuilder?.write(
      'L${rx.toDigits(digits: digits)} ${ry.toDigits(digits: digits)} ',
    );
    return path;
  }

  /// 创建五边形
  static Path buildPentagonPath({
    required List<double> points,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();
    if (points.length == 10) {
      //5个点, 五边形
      final x = points[0];
      final y = points[1];
      path.moveTo(x, y.toDouble());
      pathBuilder?.write(
        'M${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
      );
      for (var i = 2; i < points.length; i += 2) {
        final x = points.getOrNull(i);
        final y = points.getOrNull(i + 1);
        if (x == null || y == null) {
          continue;
        }
        path.lineTo(x, y);
        pathBuilder?.write(
          'L${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
        );
      }
    } else if (points.length >= 4) {
      final cx = points[0];
      final cy = points[1];
      final radius = points[2];
      final angle = points[3];
      for (var i = 0; i <= 5; i += 1) {
        final currentAngle = angle + i * (2.0 * pi / 5.0);
        final x = cx + radius * currentAngle.cos();
        final y = cy + radius * currentAngle.sin();
        if (i == 0) {
          path.moveTo(x, y);
          pathBuilder?.write(
            'M${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
          );
        } else {
          path.lineTo(x, y);
          pathBuilder?.write(
            'L${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
          );
        }
      }
    }
    return path;
  }

  /// 创建多边形
  static Path buildPolygonPath({
    required List<double> points,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();
    if (points.length >= 4) {
      final x = points[0];
      final y = points[1];
      path.moveTo(x, y);
      pathBuilder?.write(
        'M${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
      );
      for (var i = 2; i < points.length; i += 2) {
        final x = points.getOrNull(i);
        final y = points.getOrNull(i + 1);
        if (x == null || y == null) {
          continue;
        }
        path.lineTo(x, y);
        pathBuilder?.write(
          'L${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
        );
      }
    }
    return path;
  }

  /// 创建五角星
  /// 五角星（Star / Pentagram）
  static Path buildStarPath({
    required double cx,
    required double cy,
    required double outerRadius,
    required double innerRadius,
    required double angle,
    //--
    Path? path,
    StringBuffer? pathBuilder,
    int digits = 6,
  }) {
    path ??= Path();

    // 五角星有 10 个顶点（5个尖角，5个凹角）
    for (var i = 0; i <= 10; i += 1) {
      // 每个点之间的夹角为 36度 (2 * PI / 10)
      final currentAngle = angle + i * (pi / 5.0);

      // 奇数点读内半径，偶数点读外半径
      final r = i % 2 == 0 ? outerRadius : innerRadius;

      final x = cx + r * currentAngle.cos();
      final y = cy + r * currentAngle.sin();

      if (i == 0) {
        path.moveTo(x, y);
        pathBuilder?.write(
          'M${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
        );
      } else {
        path.lineTo(x, y);
        pathBuilder?.write(
          'L${x.toDigits(digits: digits)} ${y.toDigits(digits: digits)} ',
        );
      }
    }

    path.close();
    pathBuilder?.write('Z');

    return path;
  }
}

part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/25
///
/// 绘制元数据
class PaintMeta {
  /// 宿主对象, 标识当前的绘制操作是由哪个对象发起的
  /// [rasterizeElementHost]
  /// [elementOutputHost]
  @flagProperty
  final dynamic host;

  /// 默认情况下[ElementSelectComponent]并不会绘制[ElementGroupPainter.children]
  /// 可以通过此属性, 强制绘制[ElementGroupPainter.children]
  @flagProperty
  final bool? groupPaintChildren;

  /// 坐标系原点偏移
  /// [CanvasViewBox.originMatrix]
  final Matrix4? originMatrix;

  /// 画布缩放/平移/旋转/倾斜
  /// [CanvasViewBox.canvasMatrix]
  final Matrix4? canvasMatrix;

  /// 画布用于参考的缩放系数
  /// [canvasMatrix]
  /// [canvasScale]
  @flagProperty
  final double? refCanvasScale;

  //final CanvasViewBox? viewBox;

  const PaintMeta({
    this.host,
    this.originMatrix,
    this.canvasMatrix,
    this.refCanvasScale,
    this.groupPaintChildren,
  });

  /// 获取画布缩放的系数
  double get canvasScale => refCanvasScale ?? canvasMatrix?.scaleX ?? 1.0;

  /// [groupPaintChildren]
  /// [ElementGroupPainter.painting]
  @CallFrom("ElementGroupPainter.painting")
  bool get paintChildren => groupPaintChildren == null
      ? (host == rasterizeElementHost || host == elementOutputHost)
      : groupPaintChildren!;

  /// 组合[originMatrix] 和 [canvasMatrix]
  @api
  void withPaintMatrix(Canvas canvas, VoidCallback action) {
    //debugger();
    canvas.withMatrix(originMatrix, () {
      canvas.withMatrix(canvasMatrix, action);
    });
  }
}

/// 绘制接口
/// [Canvas]
abstract class IPainter with Diagnosticable {
  /// 调试时用得的标签
  String? debugLabel;

  /// 绘制入口
  @entryPoint
  void painting(Canvas canvas, PaintMeta paintMeta);
}

/// [PointerEvent]事件相关信息
class PointEventMeta {
  /// 手势的坐标
  @sceneCoordinate
  final Offset position;

  /// 13位 时间戳
  final int timestamp;

  /// 当前点的线宽, 如果有.
  final double? width;

  double get x => position.dx;

  double get y => position.dy;

  const PointEventMeta(
    this.position,
    this.timestamp, {
    this.width,
  });

  ///copyWith
  PointEventMeta copyWith({
    Offset? position,
    int? timestamp,
  }) {
    return PointEventMeta(
      position ?? this.position,
      timestamp ?? this.timestamp,
    );
  }

  /// 开始点[start]到当前点的速度
  double velocityFrom(PointEventMeta start) {
    double velocity = distanceTo(start) / (timestamp - start.timestamp);
    if (velocity != velocity) return 0;
    return velocity;
  }

  /// 距离
  double distanceTo(PointEventMeta point) {
    /*final x2 = math.pow((point.x - x) * dpr, 2);
    final y2 = math.pow((point.y - y) * dpr, 2);*/
    final x2 = math.pow(point.x - x, 2);
    final y2 = math.pow(point.y - y, 2);
    return math.sqrt(x2 + y2);
  }

  @override
  String toString() {
    return '{x: $x, y: $y, width: $width, timestamp: $timestamp}';
  }
}

/// 三阶贝塞尔曲线的4个点信息
/// 起点 2个控制 终点
/// [ui.Path]
/// [ui.Path.quadraticBezierTo]
/// [ui.Path.cubicTo]
class CurveBezierMeta {
  final PointEventMeta start;
  final PointEventMeta c1;
  final PointEventMeta c2;
  final PointEventMeta end;

  const CurveBezierMeta(
    this.start,
    this.c1,
    this.c2,
    this.end,
  );

  /// 曲线大概的长度
  double length([int steps = 10]) {
    double length = 0;
    double cx, cy, px = 0, py = 0, xDiff, yDiff;
    for (int i = 0; i <= steps; i++) {
      double t = i.toDouble() / steps;
      cx = point(t, start.x, c1.x, c2.x, end.x);
      cy = point(t, start.y, c1.y, c2.y, end.y);
      if (i > 0) {
        xDiff = cx - px;
        yDiff = cy - py;
        length += math.sqrt(xDiff * xDiff + yDiff * yDiff);
      }
      px = cx;
      py = cy;
    }
    return length;
  }

  double point(double t, double start, double c1, double c2, double end) {
    return start * (1.0 - t) * (1.0 - t) * (1.0 - t) +
        3.0 * c1 * (1.0 - t) * (1.0 - t) * t +
        3.0 * c2 * (1.0 - t) * t * t +
        end * t * t * t;
  }
}

/// 贝塞尔曲线[PointEventMeta]点位数据收集和处理
mixin CurvePointEventMixin {
  /// 输入3个点, 输出2个控制点
  static List<PointEventMeta> calculateCurveControlPoints(
      PointEventMeta s1, PointEventMeta s2, PointEventMeta s3) {
    double dx1 = s1.x - s2.x;
    double dy1 = s1.y - s2.y;
    double dx2 = s2.x - s3.x;
    double dy2 = s2.y - s3.y;

    double m1X = (s1.x + s2.x) / 2.0;
    double m1Y = (s1.y + s2.y) / 2.0;
    double m2X = (s2.x + s3.x) / 2.0;
    double m2Y = (s2.y + s3.y) / 2.0;

    double l1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
    double l2 = math.sqrt(dx2 * dx2 + dy2 * dy2);

    double dxm = (m1X - m2X);
    double dym = (m1Y - m2Y);
    double k = (l2 / (l1 + l2)).ensureValid();

    double cmX = m2X + dxm * k;
    double cmY = m2Y + dym * k;

    double tx = s2.x - cmX;
    double ty = s2.y - cmY;

    return [
      PointEventMeta(
        Offset(m1X + tx, m1Y + ty),
        nowTimestamp(),
      ),
      PointEventMeta(
        Offset(m2X + tx, m2Y + ty),
        nowTimestamp(),
      )
    ];
  }

  /// 用3阶贝塞尔, 连接4个点的收尾
  @api
  CurveBezierMeta? calculateCurveBezierMeta(List<PointEventMeta> pointList) {
    if (pointList.size() > 3) {
      final p0 = pointList[0];
      final p1 = pointList[1];
      final p2 = pointList[2];
      final p3 = pointList[3];
      List<PointEventMeta> cList = calculateCurveControlPoints(p0, p1, p2);
      PointEventMeta c2 = cList[1];
      cList = calculateCurveControlPoints(p1, p2, p3);
      PointEventMeta c3 = cList[0];
      return CurveBezierMeta(p1, c2, c3, p2);
    }
    return null;
  }
}

/// 坐标系
const viewCoordinate = AnnotationMeta('视图坐标的值, 以屏幕左上角为原点');
const sceneCoordinate = AnnotationMeta('场景坐标的值, 以内容坐标中心为原点');

/// [PaintMeta]
const rasterizeElementHost = AnnotationMeta('栅格化元素, 栅格化时, 不应该绘制额外的干扰信息');
const elementOutputHost = AnnotationMeta('元素数据输出, 此时数据应该足够真实');

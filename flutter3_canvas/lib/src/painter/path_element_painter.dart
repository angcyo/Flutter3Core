part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
/// 矢量路径绘制
class PathElementPainter extends ElementPainter {
  /// 当前绘制的路径
  @dp
  Path? paintPath;

  PathElementPainter();

  @property
  void initFromPath(Path? path) {
    paintPath = path;
    final bounds = path?.getExactBounds() ?? Rect.zero;
    if (paintProperty == null) {
      paintProperty = PaintProperty()
        ..width = bounds.width
        ..height = bounds.height;
    } else {
      paintProperty?.let((it) {
        it.width = bounds.width;
        it.height = bounds.height;
      });
    }
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    if (paintMeta.host is CanvasDelegate) {
      paint.color = Colors.black;
      paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
      //debugger();
    }
    paintPath?.let((it) =>
        canvas.drawPath(it.transformPath(paintProperty?.operateMatrix), paint));
    super.onPaintingSelf(canvas, paintMeta);
  }
}

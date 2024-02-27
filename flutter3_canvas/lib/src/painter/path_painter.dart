part of flutter3_canvas;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
///
class PathElementPainter extends ElementPainter {
  Path? path;

  PathElementPainter();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    if (path != null) {
      paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
      canvas.drawPath(path!, paint);
    }
  }
}

part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
///
class PathElementPainter extends ElementPainter {
  Path? path;

  PathElementPainter();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paint.color = Colors.black;
    paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
    //debugger();
    path?.let((it) =>
        canvas.drawPath(it.transformPath(paintProperty?.paintMatrix), paint));

    //paint.color = Colors.black;
    //paintProperty?.paintPath.let((it) => canvas.drawPath(it, paint));
    paint.color = canvasStyle?.canvasAccentColor ?? paint.color;
    paintPropertyRect(canvas, paintMeta, paint);

    paint.color = Colors.red;
    paintPropertyBounds(canvas, paintMeta, paint);
  }
}

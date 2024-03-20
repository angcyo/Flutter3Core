part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
/// 矢量路径绘制
class PathElementPainter extends ElementPainter {
  Path? path;

  PathElementPainter();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paint.color = Colors.black;
    paint.strokeWidth = 1.toDpFromPx() / paintMeta.canvasScale;
    //debugger();
    path?.let((it) =>
        canvas.drawPath(it.transformPath(paintProperty?.operateMatrix), paint));
    super.onPaintingSelf(canvas, paintMeta);
  }
}

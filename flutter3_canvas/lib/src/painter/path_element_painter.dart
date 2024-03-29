part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/02/22
/// 矢量路径绘制
class PathElementPainter extends ElementPainter {
  /// 当前绘制的路径, 请主动调用
  /// [PathEx.moveToZero]
  @dp
  Path? paintPath;

  /// 获取操作后的图片
  @dp
  Path? get operatePath => getElementOutputPath(paintPath);

  PathElementPainter();

  @property
  void initFromPath(Path? path) {
    paintPath = path?.moveToZero();
    final bounds = paintPath?.getExactBounds() ?? Rect.zero;
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
    paintPath?.let((it) =>
        canvas.drawPath(it.transformPath(paintProperty?.operateMatrix), paint));
    if (paintPath == null) {
      assert(() {
        l.w('no data painting.');
        return true;
      }());
    }
    super.onPaintingSelf(canvas, paintMeta);
  }
}

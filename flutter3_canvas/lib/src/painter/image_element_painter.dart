part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/22
///
class ImageElementPainter extends ElementPainter {
  /// 当前绘制的图片
  UiImage? _paintImage;

  /// 当前绘制的图片
  UiImage? get paintImage => _paintImage;

  set paintImage(UiImage? image) {
    _paintImage = image;
    paintProperty?.width = image?.width.toDouble() ?? 0;
    paintProperty?.height = image?.height.toDouble() ?? 0;
  }

  ImageElementPainter() {
    debug = false;
  }

  @property
  void initFromImage(UiImage? image) {
    paintImage = image;
    paintProperty = PaintProperty()
      ..width = image?.width.toDouble() ?? 0
      ..height = image?.height.toDouble() ?? 0;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paintImage?.let((it) {
      canvas.withMatrix(
        paintProperty?.operateMatrix,
        () {
          canvas.drawImage(it, Offset.zero, paint);
        },
      );
    });
    super.onPaintingSelf(canvas, paintMeta);
  }
}

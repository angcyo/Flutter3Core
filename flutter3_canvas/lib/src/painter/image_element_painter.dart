part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/22
///
class ImageElementPainter extends ElementPainter {
  /// 当前绘制的图片
  UiImage? paintImage;

  ImageElementPainter() {
    debug = false;
  }

  @property
  void initFromImage(UiImage? image) {
    paintImage = image;
    if (paintProperty == null) {
      paintProperty = PaintProperty()
        ..width = image?.width.toDouble() ?? 0
        ..height = image?.height.toDouble() ?? 0;
    } else {
      paintProperty?.let((it) {
        it.width = image?.width.toDouble() ?? 0;
        it.height = image?.height.toDouble() ?? 0;
      });
    }
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    onPaintingImage(canvas, paintMeta);
    super.onPaintingSelf(canvas, paintMeta);
  }

  @property
  void onPaintingImage(Canvas canvas, PaintMeta paintMeta) {
    paintImage?.let((image) {
      canvas.withMatrix(
        paintProperty?.operateMatrix,
        () {
          canvas.drawImage(image, Offset.zero, paint);
        },
      );
    });
  }
}

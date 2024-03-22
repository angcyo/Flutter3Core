part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/22
///
class ImageElementPainter extends ElementPainter {
  UiImage? image;

  ImageElementPainter() {
    debug = false;
  }

  void initFromImage(UiImage? image) {
    this.image = image;
    paintProperty = PaintProperty()
      ..width = image?.width.toDouble() ?? 0
      ..height = image?.height.toDouble() ?? 0;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    image?.let((it) {
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

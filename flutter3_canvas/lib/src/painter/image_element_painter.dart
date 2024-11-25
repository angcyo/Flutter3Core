part of '../../flutter3_canvas.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/22
///
/// 图片元素绘制对象
class ImageElementPainter extends ElementPainter {
  /// 当前绘制的图片, 此图片有可能进行了滤镜处理
  UiImage? painterImage;

  /// 获取操作后的图片
  UiImage? get operateImage => elementOutputImage;

  ImageElementPainter() {
    debug = false;
  }

  @property
  void initFromImage(UiImage? image) {
    painterImage = image;
    if (paintProperty == null) {
      updatePaintProperty(PaintProperty()
        ..width = image?.width.toDouble() ?? 0
        ..height = image?.height.toDouble() ?? 0);
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
    painterImage?.let((image) {
      //debugger();
      //将图片缩放至描述的大小
      final scale = Matrix4.identity();
      final sx = (paintProperty?.width ?? image.width) / image.width;
      final sy = (paintProperty?.height ?? image.height) / image.height;
      scale.scale(sx, sy);

      canvas.withMatrix(
        paintProperty?.operateMatrix.let((it) => it * scale),
        () {
          canvas.drawImage(image, Offset.zero, paint);
        },
      );
    });
  }
}

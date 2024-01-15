part of flutter3_app;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024/01/15
/// Android iOS 通用扩展

extension ImageGalleryEx on ui.Image {
  /// 保存图片到相册
  /// https://pub.dev/packages/image_gallery_saver
  /// https://juejin.cn/post/7249347871564300345
  FutureOr<dynamic> saveToGallery({
    String? albumName,
    String? fileName,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final Uint8List bytes = await toBytes(format);
    return ImageGallerySaver.saveImage(bytes, name: fileName);
  }
}

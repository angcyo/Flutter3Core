part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/16
///
///

extension ByteDataEx on ByteData {
  /// [Uint8List]
  /// [ImageByteFormat.rawRgba]
  /// [Uint8List.sublistView]
  Uint8List get bytes => buffer.asUint8List();

  /// ```
  /// // 接收方
  /// final received = (message as TransferableTypedData).materialize().asUint8List();
  /// ```
  TransferableTypedData get transferable => bytes.transferable;

  /// [Image].[StatefulWidget]
  /// `class Image extends StatefulWidget`
  Image toImageWidget() => bytes.toImageWidget();

  /// [ui.Image]
  /// [ImageEx.toBytes]
  Future<ui.Image> toImage() => bytes.toImage();

  /// [MemoryImage]
  MemoryImage toMemoryImage() => bytes.toMemoryImage();

  /// 转换成base64字符串图片, 带协议头
  /// [ImageStringEx.toImageFromBase64]
  String toBase64Image([UiImageByteFormat format = UiImageByteFormat.png]) =>
      bytes.toBase64Image(format);
}

/// [UiImageEx]
/// [Uint8ListImageEx]
extension Uint8ListImageEx on Uint8List {
  /// 转换成文本字符串
  String toTextString([bool allowMalformed = true]) =>
      utf8.decode(this, allowMalformed: allowMalformed);

  /// [ByteDataEx.bytes]
  ByteData get byteData => buffer.asByteData();

  /// ```
  /// // 接收方
  /// final received = (message as TransferableTypedData).materialize().asUint8List();
  /// ```
  TransferableTypedData get transferable =>
      TransferableTypedData.fromList([this]);

  /// 使用[MemoryImage]显示内存字节图片数据
  /// [Image].[StatefulWidget]
  /// `class Image extends StatefulWidget`
  Image toImageWidget({
    double scale = 1.0,
    BoxFit? fit = BoxFit.cover,
    double? width,
    double? height,
    Color? tintColor,
    int? memCacheWidth,
    int? memCacheHeight,
  }) => Image.memory(
    this,
    scale: scale,
    fit: fit,
    width: width,
    height: height,
    color: tintColor,
    cacheWidth: memCacheWidth,
    cacheHeight: memCacheHeight,
    errorBuilder: (context, error, stackTrace) =>
        GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
  );

  /// 解码图片字节数据
  /// [ui.Image]
  /// [ui.Codec.getNextFrame]
  /// [FlutterVectorGraphicsListener.onImage]
  ///
  /// ```
  /// final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
  /// final Codec codec = await descriptor.instantiateCodec();
  /// final FrameInfo info = await codec.getNextFrame();
  /// info.image;
  /// ```
  ///
  /// [ImageEx.toBytes]
  Future<ui.Image> toImage() => decodeImageFromList(this);

  /// 将[PixelFormat.rgba8888]颜色格式的像素数据转换成图片
  /// [ImageEx.toPixels]
  Future<ui.Image> toImageFromPixels(
    int width,
    int height, [
    ui.PixelFormat format = ui.PixelFormat.rgba8888,
  ]) {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(this, width, height, format, completer.complete);
    return completer.future;
  }

  /// [MemoryImage]
  MemoryImage toMemoryImage() => MemoryImage(this);

  /// 转换成base64字符串图片, 带协议头
  /// [ImageStringEx.toImageFromBase64]
  String toBase64Image([UiImageByteFormat format = UiImageByteFormat.png]) =>
      'data:image/${format == UiImageByteFormat.png ? "png" : "jpeg"};base64,${base64Encode(this)}';
}

extension TransferableTypedDataEx on TransferableTypedData {
  /// - [ByteBuffer]
  Uint8List get bytes => materialize().asUint8List();
}

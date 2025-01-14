part of '../flutter3_code.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/01/14
///
/// image图片操作库扩展
/// https://pub.dev/packages/image

/// 图片对象别名
typedef LImage = img.Image;
typedef LImageFormat = img.ImageFormat;
typedef LImageDecoder = img.Decoder;
typedef LImagePixel = img.Pixel;
typedef LImageColor = img.Color;

extension ImageLibEx on List<int> {
  /// Find the [ImageFormat] for the given file data.
  img.ImageFormat get imageFormatForData => img.findFormatForData(this);

  /// Find a [Decoder] that is able to decode the given image [data].
  img.Decoder? get imageDecoderForData => img.findDecoderForData(this);

  /// 解码图片
  /// # Read/Write
  ///   JPEG
  ///   PNG + Animated APNG
  ///   GIF + Animated GIF
  ///   TIFF
  ///   BMP
  ///   TGA
  ///   ICO
  ///   PVRTC
  /// # Read Only
  ///   WebP + Animated WebP
  ///   Photoshop PSD
  ///   OpenEXR
  ///   PNM (PBM, PGM, PPM)
  /// # Write Only
  ///   CUR
  img.Image? get image => img.decodeImage(bytes);
}

extension ImageColorEx on LImageColor {
  /// 颜色对象转ui颜色对象
  UiColor get uiColor =>
      Color.fromARGB(a.round(), r.round(), g.round(), b.round());
}

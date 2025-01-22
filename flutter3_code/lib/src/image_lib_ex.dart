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

/// [LImage] 支持写入的图片格式
const List<LImageFormat> imageEncodeFormatList = [
  LImageFormat.jpg,
  LImageFormat.png,
  LImageFormat.gif,
  LImageFormat.bmp,
  LImageFormat.tiff,
  LImageFormat.tga,
  LImageFormat.pvr,
  LImageFormat.ico,
];

extension ImageLibEx on List<int> {
  /// Find the [ImageFormat] for the given file data.
  img.ImageFormat get imageFormatForData => img.findFormatForData(this);

  /// Find a [Decoder] that is able to decode the given image [data].
  img.Decoder? get imageDecoderForData => img.findDecoderForData(this);

  /// 图片字节数据/解码图片
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

extension ImageEx on LImage {
  /// 图片转ui图片
  Future<UiImage> get uiImage {
    final image = this;
    final bytes = image.encode(LImageFormat.png);
    return bytes.toImage();
  }

  /// 按照指定格式编码图片
  /// [resize] 调整大小
  Uint8List encode(
    LImageFormat? format, {
    //--
    Size? resize,
    LImageColor? backgroundColor,
    //--
    bool singleFrame = false,
    //--jpg
    int quality = 100,
    img.JpegChroma chroma = img.JpegChroma.yuv444,
    //--png
    int level = 6,
    img.PngFilter filter = img.PngFilter.paeth,
    //--gif
    int repeat = 0,
    int samplingFactor = 10,
    img.DitherKernel dither = img.DitherKernel.floydSteinberg,
    bool ditherSerpentine = false,
  }) {
    LImage image = this;
    if (resize != null) {
      image = img.copyResize(
        image,
        width: resize.width.round(),
        height: resize.height.round(),
        maintainAspect: true,
        backgroundColor: backgroundColor,
      );
    }

    return switch (format) {
      LImageFormat.jpg =>
        img.encodeJpg(image, quality: quality, chroma: chroma),
      LImageFormat.png => img.encodePng(
          image,
          level: level,
          filter: filter,
          singleFrame: singleFrame,
        ),
      LImageFormat.gif => img.encodeGif(
          image,
          singleFrame: singleFrame,
          repeat: repeat,
          samplingFactor: samplingFactor,
          dither: dither,
          ditherSerpentine: ditherSerpentine,
        ),
      LImageFormat.bmp => img.encodeBmp(image),
      LImageFormat.tiff => img.encodeTiff(image, singleFrame: singleFrame),
      LImageFormat.tga => img.encodeTga(image),
      LImageFormat.pvr => img.encodePvr(image, singleFrame: singleFrame),
      LImageFormat.ico => img.encodeIco(image, singleFrame: singleFrame),
      _ => img.encodePng(
          image,
          level: level,
          filter: filter,
          singleFrame: singleFrame,
        ),
    };
  }
}

extension ImageColorEx on LImageColor {
  /// 颜色对象转ui颜色对象
  UiColor get uiColor =>
      Color.fromARGB(a.round(), r.round(), g.round(), b.round());
}

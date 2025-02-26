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
  /// 获取指定索引位置的颜色色值
  /// ARGB
  int getPixelColor(int index) {
    final int x = index % width;
    final int y = index ~/ width;
    final pixel = getPixel(x, y);
    return pixel.argbValue;
  }

  /// 获取对应的像素数据
  Uint8List get pixelBytes {
    final pixels = List<int>.filled(width * height, 0);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = getPixel(x, y);
        pixels[y * width + x] = pixel.argbValue;
      }
    }
    return Uint8List.fromList(pixels);
  }

  /// 获取对应的png格式字节数据
  Uint8List get pngBytes {
    return encode(LImageFormat.png);
  }

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

  /// 将图片转成svg格式的xml字符串
  String? toSvgXml({
    int grayThreshold = 128 /*小于这个值, 视为黑色*/,
    String turnpolicy = "minority",
    int turdsize = 2,
    bool optcurve = true /*是否输出曲线*/,
    num alphamax = 1,
    num opttolerance = 0.2 /*公差*/,
  }) =>
      potrace(
        this,
        grayThreshold: grayThreshold,
        turnpolicy: turnpolicy,
        turdsize: turdsize,
        optcurve: optcurve,
        alphamax: alphamax,
        opttolerance: opttolerance,
      );

  /// 将图片转成[Path]路径对象
  Path? toUiPath({
    int grayThreshold = 128 /*小于这个值, 视为黑色*/,
    String turnpolicy = "minority",
    int turdsize = 2,
    bool optcurve = true,
    num alphamax = 1,
    num opttolerance = 0.2,
  }) =>
      potracePath(
        this,
        grayThreshold: grayThreshold,
        turnpolicy: turnpolicy,
        turdsize: turdsize,
        optcurve: optcurve,
        alphamax: alphamax,
        opttolerance: opttolerance,
      );
}

extension ImageColorEx on LImageColor {
  /// ARGB 颜色值
  int get argbValue =>
      (a.round() << 24) | (r.round() << 16) | (g.round() << 8) | b.round();

  /// 颜色对象转ui颜色对象
  UiColor get uiColor =>
      Color.fromARGB(a.round(), r.round(), g.round(), b.round());
}

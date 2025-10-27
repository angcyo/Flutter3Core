part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

/// 图片元数据
class ImageMeta {
  /// 图片对象
  final UiImage image;

  /// 图片的字节数据
  final Uint8List? bytes;

  /// 图片的像素数据, rgba格式 u8 u8 u8 u8 ... [r g b a ...]
  /// [UiImageByteFormat.rawRgba]
  final Uint8List? pixels;

  /// 图片的字节格式
  final UiImageByteFormat imageFormat;

  /// 图片的颜色格式
  final UiPixelFormat pixelsFormat;

  //---

  /// 图片字节数据的长度
  int get length =>
      bytes?.lengthInBytes ??
      width *
          height *
          (imageFormat == UiImageByteFormat.rawExtendedRgba128 ? 16 : 4);

  int get width => image.width;

  int get height => image.height;

  ImageMeta(
    this.image,
    this.bytes,
    this.pixels, {
    this.imageFormat = UiImageByteFormat.rawRgba,
    this.pixelsFormat = UiPixelFormat.rgba8888,
  });

  /// [UiImage]转[ImageMeta]
  /// 此方法比较耗时: 292ms
  static Future<ImageMeta> fromImage(
    UiImage image, [
    UiImageByteFormat byteFormat = UiImageByteFormat.rawRgba,
  ]) async {
    //lTime.tick();
    final pixels = await image.toPixels(byteFormat);
    //l.d(lTime.time());
    return ImageMeta(image, null, pixels, imageFormat: byteFormat);
  }

  /// [Uint8List]像素转[ImageMeta]
  /// 此方法相对好一点: 51ms, 就是内存消耗大
  /// 解码图片[3.60 MB]耗时:147ms
  static Future<ImageMeta> fromPixel(
    Uint8List pixels,
    int width,
    int height, [
    UiPixelFormat pixelsFormat = UiPixelFormat.rgba8888,
  ]) async {
    //lTime.tick();
    final image = await pixels.toImageFromPixels(width, height);
    //l.d(lTime.time());
    return ImageMeta(image, null, pixels, pixelsFormat: pixelsFormat);
  }

  /// [Uint8List]字节转[ImageMeta]
  /// 解码图片[3.60 MB]耗时:429ms
  /// 相较于[fromPixel]内存占用小, 但是因为需要编解码, 所以耗时长
  static Future<ImageMeta> fromBytes(
    Uint8List bytes, [
    UiImageByteFormat imageFormat = UiImageByteFormat.rawRgba,
  ]) async {
    //lTime.tick();
    final image = await bytes.toImage();
    //l.d(lTime.time());
    return ImageMeta(image, bytes, null, imageFormat: imageFormat);
  }
}

///[MemoryImage]
class ImageMetaProvider extends ImageProvider<ImageMetaProvider> {
  final ImageMeta imageMeta;
  final double scale;
  late final MemoryImage? memoryImage;

  ImageMetaProvider(this.imageMeta, {this.scale = 1.0}) {
    if (imageMeta.bytes != null) {
      memoryImage = MemoryImage(imageMeta.bytes!, scale: scale);
    } else {
      memoryImage = null;
    }
  }

  @override
  ImageStreamCompleter loadBuffer(
    ImageMetaProvider key,
    DecoderBufferCallback decode,
  ) {
    return memoryImage?.loadBuffer(memoryImage!, decode) ??
        imageStreamCompleter();
  }

  @override
  ImageStreamCompleter loadImage(
    ImageMetaProvider key,
    ImageDecoderCallback decode,
  ) {
    return memoryImage?.loadImage(memoryImage!, decode) ??
        imageStreamCompleter();
  }

  ImageStreamCompleter imageStreamCompleter() {
    return OneFrameImageStreamCompleter(
      SynchronousFuture<ImageInfo>(
        ImageInfo(image: imageMeta.image.clone(), scale: scale),
      ),
    );
  }

  @override
  Future<ImageMetaProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ImageMetaProvider>(this);
  }
}

extension ImageMetaEx on ImageMeta {
  ///[Image]
  Widget toImageWidget({
    double scale = 1.0,
    BoxFit? fit = BoxFit.cover,
    double? width,
    double? height,
    Color? tintColor,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    return Image(
      image: ResizeImage.resizeIfNeeded(
        memCacheWidth,
        memCacheHeight,
        ImageMetaProvider(this, scale: scale),
      ),
      fit: fit,
      width: width,
      height: height,
      color: tintColor,
      errorBuilder: (context, error, stackTrace) =>
          GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
    );
  }
}

/// 图片提供者
/// [ImageProvider]
class UiImageProvider extends ImageProvider<UiImageProvider> {
  const UiImageProvider(this.image, {this.scale = 1.0});

  final UiImage image;
  final double scale;

  @override
  ImageStreamCompleter loadImage(
    UiImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(UiImageProvider key) async {
    assert(key == this);
    //image转ByteData
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
      byteData!.bytes,
    );
    var codec = await PaintingBinding.instance.instantiateImageCodecWithSize(
      buffer,
    );
    return codec;
  }

  @override
  Future<UiImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<UiImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    if (other is! UiImageProvider) {
      return false;
    }
    final UiImageProvider typedOther = other;
    return image == typedOther.image && scale == typedOther.scale;
  }

  @override
  int get hashCode => Object.hash(image.hashCode, scale);

  @override
  String toString() =>
      '$runtimeType(${describeIdentity(image)}, scale: $scale)';
}

extension ByteDataEx on ByteData {
  /// [Uint8List]
  /// [ImageByteFormat.rawRgba]
  /// [Uint8List.sublistView]
  Uint8List get bytes => buffer.asUint8List();

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

/// [UiImageEx]
/// [Uint8ListImageEx]
extension ImageEx on UiImage {
  double get cx => width / 2;

  double get cy => height / 2;

  /// [UiImageProvider]
  /// [ImageProviderEx.toImage]
  UiImageProvider toImageProvider([double scale = 1]) =>
      UiImageProvider(this, scale: scale);

  /// 将图片转换成base64字符串图片, 带协议头
  Future<String?> toBase64([
    UiImageByteFormat format = UiImageByteFormat.png,
  ]) async {
    final bytes = await toBytes(format);
    return bytes?.toBase64Image(format);
  }

  /// 获取图片的字节数据(非像素数据)
  /// [ImageByteFormat.rawRgba]
  /// [ImageByteFormat.png]
  /// [ImageEx.toPixels]
  Future<Uint8List?> toBytes([
    UiImageByteFormat format = UiImageByteFormat.png,
  ]) async {
    final ByteData? byteData = await toByteData(format: format);
    return byteData?.buffer.asUint8List();
  }

  /// 获取图片的颜色数据
  /// [Uint8ListImageEx.toImageFromPixels]
  /// [ImageEx.toBytes]
  Future<Uint8List?> toPixels([
    UiImageByteFormat format = UiImageByteFormat.rawRgba,
  ]) => toBytes(format);

  /// 获取图片中的像素值
  Future<int?> getPixelColor(int x, int y) async {
    final pixels = await toPixels();

    int bytesPerPixel = 4; // RGBA
    int byteOffset = (y * width + x) * bytesPerPixel;

    final r = pixels?.getOrNull(byteOffset);
    final g = pixels?.getOrNull(byteOffset + 1);
    final b = pixels?.getOrNull(byteOffset + 2);
    final a = pixels?.getOrNull(byteOffset + 3);

    if (r == null || g == null || b == null || a == null) {
      return null;
    }
    return Color.fromARGB(a, r, g, b).value;
  }

  /// 保存图片到文件
  /// [saveToFile]
  Future<File?> saveToFilePath(
    String? filePath, {
    UiImageByteFormat format = UiImageByteFormat.png,
  }) async {
    if (isNil(filePath)) {
      return null;
    }
    return saveToFile(File(filePath!), format: format);
  }

  /// 保存图片到文件
  Future<File?> saveToFile(
    File? file, {
    UiImageByteFormat format = UiImageByteFormat.png,
  }) async {
    final Uint8List? bytes = await toBytes(format);
    if (bytes == null) {
      return null;
    }
    return file?.writeAsBytes(bytes);
  }

  /// 转换成[Widget]
  /// - [BoxFit.contain] 等比显示全部内容
  Widget toImageWidget({
    double scale = 1.0,
    BoxFit? fit = BoxFit.contain,
    double? width,
    double? height,
    Color? tintColor,
    BlendMode? colorBlendMode = BlendMode.srcIn,
    int? memCacheWidth,
    int? memCacheHeight,
  }) => RawImage(
    image: this,
    fit: fit,
    scale: scale,
    colorBlendMode: colorBlendMode,
    width: width,
    height: height,
    color: tintColor,
  );

  /// 将图片进行一次[matrix]变换,得到一张新的图片
  /// - [keepOriginSize] 是否保持原图片大小
  /// - [keepAnchor] 需要保持的锚点,默认是图片中心
  ///
  /// - [transformSync]
  Future<UiImage> transform(
    Matrix4 matrix, {
    bool keepOriginSize = false,
    @defInjectMark Offset? keepAnchor,
    //--
    Paint? paint,
    FilterQuality filterQuality = FilterQuality.low,
  }) async {
    final bounds = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final anchor = keepAnchor ?? bounds.center;

    final newBounds = matrix.mapRect(bounds);
    final newAnchor = keepOriginSize
        ? matrix.mapPoint(anchor)
        : newBounds.center;

    //debugger();

    final image = await drawImage(
      keepOriginSize ? bounds.size : newBounds.size,
      (canvas) {
        final translate = Matrix4.identity()
          ..translate(
            keepOriginSize ? -(newAnchor.dx - anchor.dx) : -newBounds.left,
            keepOriginSize ? -(newAnchor.dy - anchor.dy) : -newBounds.top,
          );
        canvas.transform((translate * matrix).storage);
        canvas.drawImage(
          this,
          Offset.zero,
          paint ?? Paint()
            ..filterQuality = filterQuality,
        );
      },
    );
    return image;
  }

  /// - [transform]
  /// - [transformSync]
  UiImage transformSync(
    Matrix4 matrix, {
    bool keepOriginSize = false,
    @defInjectMark Offset? keepAnchor,
    //--
    Paint? paint,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    final bounds = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final anchor = keepAnchor ?? bounds.center;

    final newBounds = matrix.mapRect(bounds);
    final newAnchor = keepOriginSize
        ? matrix.mapPoint(anchor)
        : newBounds.center;

    //debugger();

    final image = drawImageSync(keepOriginSize ? bounds.size : newBounds.size, (
      canvas,
    ) {
      final translate = Matrix4.identity()
        ..translate(
          keepOriginSize ? -(newAnchor.dx - anchor.dx) : -newBounds.left,
          keepOriginSize ? -(newAnchor.dy - anchor.dy) : -newBounds.top,
        );
      canvas.transform((translate * matrix).storage);
      canvas.drawImage(
        this,
        Offset.zero,
        paint ?? Paint()
          ..filterQuality = filterQuality,
      );
    });
    return image;
  }

  //--

  /// 缩放图片
  /// [transformSync]
  Future<UiImage> scale({
    //--
    double? scale,
    double sx = 1,
    double sy = 1,
    //--
    Matrix4? scaleMatrix,
  }) {
    return transform(
      scaleMatrix ?? createScaleMatrix(sx: scale ?? sx, sy: scale ?? sy),
    );
  }

  /// 缩放图片到指定大小, 如果只指定了一个参数, 则等比缩
  Future<UiImage> scaleTo({double? width, double? height}) async {
    if (width == null && height == null) {
      return this;
    }
    final w = this.width.toDouble();
    final h = this.height.toDouble();

    if (width != null && height != null) {
      return scale(sx: width / w, sy: height / h);
    } else if (width != null) {
      final scale = width / w;
      return this.scale(scale: scale);
    } else if (height != null) {
      final scale = height / h;
      return this.scale(scale: scale);
    }
    return this;
  }

  /// 缩放图片
  /// [transformSync]
  UiImage scaleSync({double sx = 1, double sy = 1, Matrix4? scaleMatrix}) {
    return transformSync(scaleMatrix ?? createScaleMatrix(sx: sx, sy: sy));
  }

  //--

  /// 裁剪图片, 获取图片指定区域的图片
  /// - [clipRect] 剪切区域, 以及输出的图片大小
  /// - [clip] 需要裁剪的区域, 在图片中的1:1坐标系
  /// - [matrix] 图片绘制的矩阵
  ///
  /// - [transformSync]
  Future<UiImage> crop(
    Rect clipRect,
    Path? clip, {
    Matrix4? matrix,
    Paint? paint,
  }) async {
    final image = await drawImage(clipRect.size, (canvas) {
      canvas.withTranslate(-clipRect.left, -clipRect.top, () {
        canvas.withClipPath(clip, () {
          canvas.withMatrix(matrix, () {
            canvas.drawImage(this, Offset.zero, paint ?? Paint());
          });
        });
      });
    });
    return image;
  }

  /// [crop]
  UiImage cropSync(Rect clipRect, Path? clip, {Matrix4? matrix, Paint? paint}) {
    final image = drawImageSync(clipRect.size, (canvas) {
      canvas.withTranslate(-clipRect.left, -clipRect.top, () {
        canvas.withClipPath(clip, () {
          canvas.withMatrix(matrix, () {
            canvas.drawImage(this, Offset.zero, paint ?? Paint());
          });
        });
      });
    });
    return image;
  }
}

extension ImageStringEx on String {
  /// 从Base64字符串中读取图片
  /// [ByteDataEx.toBase64Image]
  Future<ui.Image> toImageFromBase64() async {
    const c = ",";
    final Uint8List bytes = contains(c)
        ? base64Decode(this)
        : base64Decode(split(c).last);
    return decodeImageFromList(bytes);
  }

  /// [toImageFromFile]
  Future<ImageMeta> toImageMetaFromFile({
    UiImageByteFormat pixelsFormat = UiImageByteFormat.rawRgba,
    bool toPixels = false,
  }) async {
    final Uint8List bytes = await File(this).readAsBytes();
    final uiImage = await decodeImageFromList(bytes);
    final pixels = toPixels ? await uiImage.toPixels(pixelsFormat) : null;
    //final pngBytes = toBytes ? await uiImage.toBytes(bytesFormat) : null;
    return ImageMeta(
      uiImage,
      bytes,
      pixels,
      imageFormat: pixelsFormat,
      pixelsFormat: UiPixelFormat.rgba8888,
    );
  }

  /// 从文件路径中读取图片
  /// [FileImage._loadAsync]
  /// [FileEx.toImage]
  Future<ui.Image> toImageFromFile() => File(this).toImage();

  /// 从网络路径中读取图片
  Future<ui.Image> toImageFromHttp() async {
    /*final Uint8List bytes = await http.get(Uri.parse(this)).then((value) => value.bodyBytes);
    return decodeImageFromList(bytes);*/
    final Completer<ui.Image> completer = Completer();
    final img = NetworkImage(this);
    img
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (info, bool _) => completer.complete(info.image),
            onError: (exception, stackTrace) {
              completer.completeError(exception, stackTrace);
            },
          ),
        );
    return completer.future;
  }
}

extension WidgetImageEx on Widget {
  /// 截图[Widget]
  /// [captureImage]
  Future<ui.Image> toBuildImage({
    Duration? wait,
    double? pixelRatio,
    ViewConfiguration? configuration,
    Size imageSize = Size.infinite,
  }) => captureImage(
    wait: wait,
    pixelRatio: pixelRatio,
    configuration: configuration,
    imageSize: imageSize,
  );

  /// 获取小部件的截图, 此方式可以获取没有显示的小部件的截图
  /// 可以是直接创建的小部件.
  /// [widget] 需要获取截图的widget
  /// [pixelRatio] 像素比例, 1dp输出多少px
  /// [imageSize] widget的size，推荐使用dp
  /// [wait] widget截屏延时，widget构建时如果有耗时操作，可以添加延时防止截屏时耗时操作尚未完成
  ///
  /// ```
  /// final image = await Text("test1234567890" * 30).captureImage();
  /// final path = await cacheFilePath("test.png");
  /// await image.saveToFilePath(path);
  /// buildContext?.showWidgetDialog(SinglePhotoDialog(
  ///   content: image,
  /// ));
  /// l.d(path);
  /// ```
  Future<ui.Image> captureImage({
    Duration? wait,
    double? pixelRatio,
    ViewConfiguration? configuration,
    Size imageSize = Size.infinite,
  }) async {
    pixelRatio ??= platformMediaQueryData.devicePixelRatio;
    final repaintBoundary = RenderRepaintBoundary();
    final view =
        ui.PlatformDispatcher.instance.implicitView ??
        RendererBinding.instance.renderView.flutterView;

    //渲染树根
    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration:
          configuration ?? ViewConfiguration.fromView(view), //flutter 3.22.0
      /*configuration: ViewConfiguration(
        size: imageSize,
        devicePixelRatio: pixelRatio,
      ),*/
      //flutter 3.19.6
    );

    //管道
    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    //管道对象
    final buildOwner = BuildOwner(focusManager: FocusManager());

    //根元素
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: this),
    ).attachToRenderTree(buildOwner);

    //end...
    if (wait != null) {
      await Future.delayed(wait);
    }

    //构建树
    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    //渲染树
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    return image;
  }
}

extension ContextImageEx on BuildContext {
  /// [RenderObjectImageEx.captureImage]
  Future<ui.Image?> captureImage({double? pixelRatio = 1.0}) {
    RenderObject? renderObject = findRenderObject();
    while (renderObject != null && !renderObject.isRepaintBoundary) {
      renderObject = renderObject.parent;
    }
    if (renderObject == null) {
      return Future.value(null);
    }
    return renderObject.captureImage(pixelRatio: pixelRatio);
  }
}

/*
extension ElementImageEx on Element {
  /// 获取元素的截图
  /// [RenderObjectImageEx.captureImage]
  Future<ui.Image> captureImage() {
    assert(this.renderObject != null);
    RenderObject renderObject = this.renderObject!;
    while (!renderObject.isRepaintBoundary) {
      renderObject = renderObject.parent!;
    }
    return renderObject.captureImage();
  }
}
*/

extension RenderObjectImageEx on RenderObject {
  /// 获取元素的截图
  /// https://pub.dev/packages/image_gallery_saver
  Future<ui.Image?> captureImage({double? pixelRatio = 1.0}) async {
    //assert(!debugNeedsPaint);
    try {
      final devicePixelRatio = platformMediaQueryData.devicePixelRatio;
      pixelRatio ??= devicePixelRatio;
      final OffsetLayer? layer = this.layer as OffsetLayer?;
      //这里的[paintBounds]就是屏幕大小, 所以[pixelRatio]应该为1
      //但是如果使用[size]那么[pixelRatio]应该为[devicePixelRatio]
      ui.Image? result = await layer?.toImage(
        paintBounds,
        pixelRatio: pixelRatio,
      );
      if (result == null && this is RenderRepaintBoundary) {
        final RenderRepaintBoundary boundary = this as RenderRepaintBoundary;
        //因为[RenderRepaintBoundary]里面用的是[size]
        //所以这里的[pixelRatio]应该为[devicePixelRatio]
        return boundary.toImage(pixelRatio: devicePixelRatio);
      }
      return result;
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    }
    return null;
  }

  /// [captureImage]同步方法
  ui.Image? captureImageSync({double pixelRatio = 1.0}) {
    //assert(!debugNeedsPaint);
    try {
      final OffsetLayer? layer = this.layer as OffsetLayer?;
      //这里的[paintBounds]就是屏幕大小, 所以[pixelRatio]应该为1
      //但是如果使用[size]那么[pixelRatio]应该为[devicePixelRatio]
      ui.Image? result = layer?.toImageSync(
        paintBounds,
        pixelRatio: pixelRatio,
      );
      if (result == null && this is RenderRepaintBoundary) {
        final devicePixelRatio = platformMediaQueryData.devicePixelRatio;
        final RenderRepaintBoundary boundary = this as RenderRepaintBoundary;
        //因为[RenderRepaintBoundary]里面用的是[size]
        //所以这里的[pixelRatio]应该为[devicePixelRatio]
        return boundary.toImageSync(pixelRatio: devicePixelRatio);
      }
      return result;
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    }
    return null;
  }
}

extension ImageProviderEx<T extends Object> on ImageProvider<T> {
  /// 获取图片的字节数据
  Future<ui.Image> toImage([
    ImageConfiguration configuration = const ImageConfiguration(),
  ]) async {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream = resolve(configuration);
    final listener = ImageStreamListener((
      ImageInfo info,
      bool synchronousCall,
    ) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    stream.removeListener(listener);
    return image;
  }
}

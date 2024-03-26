part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

/// 图片元数据
class ImageMeta {
  /// 图片对象
  final ui.Image image;

  /// 图片的字节数据
  final Uint8List? bytes;

  /// 图片的像素数据
  /// [ui.ImageByteFormat.rawRgba]
  final Uint8List? pixels;

  /// 图片像素的格式
  final ui.ImageByteFormat pixelsFormat;

  int get width => image.width;

  int get height => image.height;

  ImageMeta(this.image, this.bytes, this.pixels,
      {this.pixelsFormat = ui.ImageByteFormat.rawRgba});
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
      ImageMetaProvider key, DecoderBufferCallback decode) {
    return memoryImage?.loadBuffer(memoryImage!, decode) ??
        imageStreamCompleter();
  }

  @override
  ImageStreamCompleter loadImage(
      ImageMetaProvider key, ImageDecoderCallback decode) {
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

extension ByteDataEx on ByteData {
  /// [Uint8List]
  /// [ImageByteFormat.rawRgba]
  /// [Uint8List.sublistView]
  Uint8List get bytes => buffer.asUint8List();

  /// [Image].[StatefulWidget]
  /// `class Image extends StatefulWidget`
  Image toImageWidget() => bytes.toImageWidget();

  /// [ui.Image]
  Future<ui.Image> toImage() => bytes.toImage();

  /// [MemoryImage]
  MemoryImage toMemoryImage() => bytes.toMemoryImage();

  /// 转换成base64字符串图片, 带协议头
  /// [ImageStringEx.toImageFromBase64]
  String toBase64Image([
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  ]) =>
      bytes.toBase64Image(format);
}

extension Uint8ListImageEx on Uint8List {
  /// 转换成文本字符串
  String toTextString() => utf8.decode(this);

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
  }) =>
      Image.memory(this,
          scale: scale,
          fit: fit,
          width: width,
          height: height,
          color: tintColor,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              GlobalConfig.of(context).errorPlaceholderBuilder(context, error));

  /// [ui.Image]
  Future<ui.Image> toImage() => decodeImageFromList(this);

  /// 将[PixelFormat.rgba8888]颜色格式的像素数据转换成图片
  Future<ui.Image> toImageFromPixels(int width, int height,
      [PixelFormat format = PixelFormat.rgba8888]) {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    decodeImageFromPixels(
      this,
      width,
      height,
      format,
      completer.complete,
    );
    return completer.future;
  }

  /// [MemoryImage]
  MemoryImage toMemoryImage() => MemoryImage(this);

  /// 转换成base64字符串图片, 带协议头
  /// [ImageStringEx.toImageFromBase64]
  String toBase64Image([
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  ]) =>
      'data:image/${format == ui.ImageByteFormat.png ? "png" : "jpeg"};base64,${base64Encode(this)}';
}

extension ImageEx on ui.Image {
  /// 将图片转换成base64字符串图片, 带协议头
  Future<String?> toBase64([
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  ]) async {
    final bytes = await toBytes(format);
    return bytes?.toBase64Image(format);
  }

  /// 获取图片的字节数据
  /// [ImageByteFormat.rawRgba]
  /// [ImageByteFormat.png]
  Future<Uint8List?> toBytes([
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  ]) async {
    final ByteData? byteData = await toByteData(format: format);
    return byteData?.buffer.asUint8List();
  }

  /// 获取图片的颜色数据
  Future<Uint8List?> toPixels(
          [ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba]) =>
      toBytes(format);

  /// 保存图片到文件
  Future<File?> saveToFile(
    File? file, {
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final Uint8List? bytes = await toBytes(format);
    if (bytes == null) {
      return null;
    }
    return file?.writeAsBytes(bytes);
  }

  /// 转换成[Widget]
  Widget toImageWidget({
    double scale = 1.0,
    BoxFit? fit,
    double? width,
    double? height,
    Color? tintColor,
    BlendMode? colorBlendMode = BlendMode.srcIn,
    int? memCacheWidth,
    int? memCacheHeight,
  }) =>
      RawImage(
          image: this,
          fit: fit,
          scale: scale,
          colorBlendMode: colorBlendMode,
          width: width,
          height: height,
          color: tintColor);
}

extension ImageStringEx on String {
  /// 从Base64字符串中读取图片
  /// [ByteDataEx.toBase64Image]
  Future<ui.Image> toImageFromBase64() async {
    const c = ",";
    final Uint8List bytes =
        contains(c) ? base64Decode(this) : base64Decode(split(c).last);
    return decodeImageFromList(bytes);
  }

  /// [toImageFromFile]
  Future<ImageMeta> toImageMetaFromFile(
      [ui.ImageByteFormat pixelsFormat = ui.ImageByteFormat.rawRgba]) async {
    final Uint8List bytes = await File(this).readAsBytes();
    final uiImage = await decodeImageFromList(bytes);
    final pixels = await uiImage.toPixels(pixelsFormat);
    return ImageMeta(uiImage, bytes, pixels, pixelsFormat: pixelsFormat);
  }

  /// 从文件路径中读取图片
  /// [FileImage._loadAsync]
  Future<ui.Image> toImageFromFile() async {
    final Uint8List bytes = await File(this).readAsBytes();

    /*final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromFilePath(this);
    final ui.Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;*/

    return decodeImageFromList(bytes);
  }

  /// 从网络路径中读取图片
  Future<ui.Image> toImageFromNetwork() async {
    /*final Uint8List bytes = await http.get(Uri.parse(this)).then((value) => value.bodyBytes);
    return decodeImageFromList(bytes);*/
    final Completer<ui.Image> completer = Completer();
    final img = NetworkImage(this);
    img.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, bool _) => completer.complete(info.image)),
        );
    return completer.future;
  }
}

extension WidgetImageEx on Widget {
  /// 获取小部件的截图
  /// [widget] 需要获取截图的widget
  /// [imageSize] widget的size，推荐使用dp
  /// [wait] widget截屏延时，widget构建时如果有耗时操作，可以添加延时防止截屏时耗时操作尚未完成
  ///
  Future<ui.Image> captureImage({
    Duration? wait,
    Size imageSize = Size.infinite,
  }) async {
    var devicePixelRatio = platformMediaQueryData.devicePixelRatio;
    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.implicitView ??
          RendererBinding.instance.renderView.flutterView,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        size: imageSize,
        devicePixelRatio: devicePixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner();

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: this,
            )).attachToRenderTree(buildOwner);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: devicePixelRatio);
    return image;
  }
}

extension ContextImageEx on BuildContext {
  /// [RenderObjectImageEx.captureImage]
  Future<ui.Image?> captureImage() {
    RenderObject? renderObject = findRenderObject();
    while (renderObject != null && !renderObject.isRepaintBoundary) {
      renderObject = renderObject.parent;
    }
    if (renderObject == null) {
      return Future.value(null);
    }
    return renderObject.captureImage();
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
  Future<ui.Image> captureImage() {
    assert(this is RenderRepaintBoundary);
    final devicePixelRatio = platformMediaQueryData.devicePixelRatio;
    final RenderRepaintBoundary boundary = this as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: devicePixelRatio);
    /*assert(!debugNeedsPaint);
    final OffsetLayer layer = this.layer! as OffsetLayer;
    return layer.toImage(paintBounds, pixelRatio: devicePixelRatio);*/
  }
}

extension ImageProviderEx<T extends Object> on ImageProvider<T> {
  /// 获取图片的字节数据
  Future<ui.Image> toImage([
    ImageConfiguration configuration = const ImageConfiguration(),
  ]) async {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream = resolve(configuration);
    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
      },
    );
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    stream.removeListener(listener);
    return image;
  }
}

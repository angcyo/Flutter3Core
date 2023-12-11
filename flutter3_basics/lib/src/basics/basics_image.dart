part of flutter3_basics;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/04
///

typedef CanvasCallback = void Function(Canvas canvas);

/// 使用[Canvas]绘制图片
Picture drawPicture(
  Size size,
  CanvasCallback callback,
) {
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas =
      Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
  callback(canvas);
  return recorder.endRecording();
}

extension ImageEx on ui.Image {
  /// 获取图片的字节数据
  Future<Uint8List> toBytes([
    ImageByteFormat format = ImageByteFormat.png,
  ]) async {
    final ByteData? byteData = await toByteData(format: format);
    return byteData!.buffer.asUint8List();
  }

  /// 保存图片到相册
  /// https://pub.dev/packages/image_gallery_saver
  /*Future<bool> saveToGallery({
    String? albumName,
    String? fileName,
    ImageByteFormat format = ImageByteFormat.png,
  }) async {
    final Uint8List bytes = await toBytes(format);
    return ImageGallerySaver.saveImage(bytes,
        albumName: albumName, name: fileName);
  }*/

  /// 保存图片到文件
  Future<File?> saveToFile(
    File? file, {
    ImageByteFormat format = ImageByteFormat.png,
  }) async {
    final Uint8List bytes = await toBytes(format);
    return file?.writeAsBytes(bytes);
  }
}

extension ImageStringEx on String {
  /// 从文件路径中读取图片
  Future<ui.Image?> toImage() async {
    final Uint8List bytes = await File(this).readAsBytes();
    return decodeImageFromList(bytes);
  }

  /// 从网络路径中读取图片
  Future<ui.Image?> toImageFromNetwork() async {
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
  Future<ui.Image?> captureImage({
    Duration? wait,
    Size imageSize = Size.infinite,
  }) async {
    var devicePixelRatio = platformMediaQueryData.devicePixelRatio;
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
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

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner();

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
    final ui.Image image =
        await repaintBoundary.toImage(pixelRatio: devicePixelRatio);
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
  Future<ui.Image> captureImage() {
    /*assert(this is RenderRepaintBoundary);
    final RenderRepaintBoundary boundary = this as RenderRepaintBoundary;
    return boundary.toImage();*/
    assert(!debugNeedsPaint);
    final OffsetLayer layer = debugLayer! as OffsetLayer;
    return layer.toImage(paintBounds);
  }
}

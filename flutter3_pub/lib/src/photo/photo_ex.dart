part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/14
///

/// 图片大图预览界面, 支持单图/多图
/// [PhotoView]
/// [PhotoViewGallery]
class PhotoPreviewPage extends StatefulWidget {
  /// [Hero]
  static String getHeroTagFrom(ImageProvider? imageProvider) {
    if (imageProvider is AssetImage) {
      return imageProvider.assetName;
    }
    if (imageProvider is FileImage) {
      return imageProvider.file.path;
    }
    if (imageProvider is NetworkImage) {
      return imageProvider.url;
    }
    if (imageProvider is CachedNetworkImageProvider) {
      return imageProvider.url;
    }
    return imageProvider.toString();
  }

  /// 所有的图片, 如果只有一张图片, 则显示单图预览
  final List<PhotoViewGalleryPageOptions> photoItems;

  /// 背景装饰
  final BoxDecoration? backgroundDecoration;

  /// 初始显示的图片索引
  final int initialIndex;

  /// 是否支持旋转
  final bool enableRotation;

  /// 点击后, 自动销毁
  final bool tapDismiss;

  const PhotoPreviewPage({
    super.key,
    required this.photoItems,
    this.initialIndex = 0,
    this.enableRotation = false,
    this.tapDismiss = true,
    this.backgroundDecoration,
  });

  @override
  State<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  late int currentIndex = widget.initialIndex;

  /// 页面控制, 左右翻页
  late final PageController pageController =
      PageController(initialPage: currentIndex);

  /// photo 状态控制, 比如缩放/平移等操作
  late PhotoViewController photoStateController;

  /// photo 当前缩放的状态控制
  late PhotoViewScaleStateController photoScaleStateController;

  /// 上一次设置的状态栏样式
  SystemUiOverlayStyle? lastStyle = SystemChrome.latestStyle;

  PhotoViewScaleStateController _buildScaleStateController() {
    return PhotoViewScaleStateController()
      ..outputScaleStateStream.listen(_onPhotoScaleStateChanged);
  }

  PhotoViewController _buildPhotoStateController() {
    return PhotoViewController()
      ..outputStateStream.listen(_onPhotoStateChanged);
  }

  PhotoViewGalleryPageOptions _wrapPhotoViewPageOptions(int index) {
    PhotoViewGalleryPageOptions item = widget.photoItems[index];
    if (item.scaleStateController == null) {
      item = PhotoViewGalleryPageOptions(
        imageProvider: item.imageProvider,
        heroAttributes: item.heroAttributes,
        scaleStateController: _buildScaleStateController(),
        controller: _buildPhotoStateController(),
      );
      widget.photoItems[index] = item;
    }
    return item;
  }

  @override
  void initState() {
    //获取状态栏样式
    /*SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    );*/
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    photoStateController = _buildPhotoStateController();
    photoScaleStateController = _buildScaleStateController();
    super.initState();
  }

  @override
  void dispose() {
    if (lastStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(lastStyle!);
    }
    super.dispose();
  }

  Widget _buildLoading(BuildContext context, ImageChunkEvent? event) {
    double? progressValue;
    if (event != null && event.expectedTotalBytes != null) {
      progressValue = event.cumulativeBytesLoaded / event.expectedTotalBytes!;
    }
    return GlobalConfig.of(context)
        .loadingIndicatorBuilder(context, progressValue)
        .center();
  }

  /// 翻页通知
  void _onPhotoPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  /// photo 缩放值状态改变通知
  void _onPhotoStateChanged(PhotoViewControllerValue value) {
    //debugger();
  }

  /// 缩放状态改变通知
  void _onPhotoScaleStateChanged(PhotoViewScaleState scaleState) {
    //debugger();
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.photoItems.isEmpty) {
      result = Container(
        decoration: widget.backgroundDecoration,
      );
    } else if (widget.photoItems.length <= 1) {
      var first = _wrapPhotoViewPageOptions(0);
      result = PhotoView(
        imageProvider: first.imageProvider,
        loadingBuilder: _buildLoading,
        controller: photoStateController,
        scaleStateController: photoScaleStateController,
        backgroundDecoration: widget.backgroundDecoration,
        enableRotation: widget.enableRotation,
        heroAttributes: first.heroAttributes,
      );
      if (widget.backgroundDecoration != null) {
        result = Container(
          decoration: widget.backgroundDecoration,
          child: result,
        );
      }
    } else {
      result = PhotoViewGallery.builder(
        itemCount: widget.photoItems.length,
        builder: (context, index) {
          var item = _wrapPhotoViewPageOptions(index);
          return item;
        },
        //pageOptions: widget.photoItems,
        loadingBuilder: _buildLoading,
        onPageChanged: _onPhotoPageChanged,
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: pageController,
        backgroundDecoration: widget.backgroundDecoration,
        enableRotation: widget.enableRotation,
      );
      result = [
        result,
        material.Text(
          "${currentIndex + 1}/${widget.photoItems.length}",
          style: const TextStyle(color: Colors.white),
        ).align(alignment: Alignment.bottomCenter).padding(kXh),
      ].stack();
    }
    if (widget.tapDismiss) {
      result = GestureDetector(
        onTap: () {
          //pageController;
          //photoScaleStateController;
          //debugger();
          context.pop();
        },
        child: result,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: result,
    );
  }
}

extension PhotoViewOptionsEx on ImageProvider {
  /// [PhotoViewGalleryPageOptions]
  PhotoViewGalleryPageOptions toPhotoPageOptions() =>
      PhotoViewGalleryPageOptions(
        imageProvider: this,
        heroAttributes: PhotoViewHeroAttributes(
          tag: PhotoPreviewPage.getHeroTagFrom(this),
        ),
      );
}

extension PhotoViewEx on BuildContext {
  /// 显示图片预览界面
  /// [PhotoPreviewPage]
  void showPhotoPage({
    ImageProvider? imageProvider,
    int initialIndex = 0,
    List<ImageProvider>? imageProviders,
  }) {
    push(MaterialPageRoute(
      builder: (context) => PhotoPreviewPage(
        initialIndex: initialIndex,
        photoItems: [
          if (imageProvider != null) imageProvider.toPhotoPageOptions(),
          if (imageProviders != null)
            ...imageProviders.map((element) => element.toPhotoPageOptions()),
        ],
      ),
    ));
  }
}

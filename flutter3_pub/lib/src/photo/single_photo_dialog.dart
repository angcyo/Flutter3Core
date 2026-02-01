part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/04
///
/// 支持图片放大缩小的查看对话框, 使用[PhotoView]实现
/// - [SingleImageDialog] 不支持放大缩小
/// - [SinglePhotoDialog] 支持放大缩小
class SinglePhotoDialog extends StatefulWidget {
  /// 图片提供者
  final ImageProvider? imageProvider;

  /// 指定文件路径
  final String? filePath;

  /// 强行指定图片内容
  final UiImage? content;

  //--

  /// [Hero] 动画属性
  final PhotoViewHeroAttributes? heroAttributes;

  /// 是否模糊背景
  final bool blur;

  /// 点击后, 自动销毁
  final bool tapDismiss;

  const SinglePhotoDialog({
    super.key,
    this.imageProvider,
    this.filePath,
    this.content,
    //--
    this.heroAttributes,
    this.blur = true,
    this.tapDismiss = true,
  });

  @override
  State<SinglePhotoDialog> createState() => _SinglePhotoDialogState();
}

class _SinglePhotoDialogState extends State<SinglePhotoDialog> {
  /// photo 状态控制, 比如缩放/平移等操作
  PhotoViewController? photoStateController = PhotoViewController();

  /// photo 当前缩放的状态控制
  PhotoViewScaleStateController? photoScaleStateController =
      PhotoViewScaleStateController();

  @property
  ImageProvider? _imageProvider;

  /// 临时图片
  @tempFlag
  UiImage? _debugImage;

  @override
  void initState() {
    super.initState();
    _imageProvider ??= widget.imageProvider;
    if (widget.content != null) {
      _imageProvider = widget.content!.toImageProvider();
    }
    if (widget.filePath != null) {
      _imageProvider = FileImage(File(widget.filePath!));
    }
    if (isDebug) {
      _imageProvider?.toImage().then((image) {
        _debugImage = image;
        if (image != null) {
          updateState();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = PhotoView(
      imageProvider: _imageProvider,
      loadingBuilder: _buildLoading,
      controller: photoStateController,
      scaleStateController: photoScaleStateController,
      backgroundDecoration: fillDecoration(color: Colors.transparent),
      enableRotation: false,
      heroAttributes:
          widget.heroAttributes ??
          widget.content?.toPhotoViewHeroAttributes() ??
          widget.filePath?.toPhotoViewHeroAttributes(),
    );

    if (isDebug) {
      final image = _debugImage ?? widget.content;
      final imageLog = image == null
          ? ''
          : "${image.width}*${image.height} (${(image.width * image.height * 4).toSizeStr()})";
      result = result.stackOf(
        isDebug
            ? "$imageLog ${widget.filePath == null ? '' : '\n$filePath'}"
                  .text(textColor: Colors.white, fontSize: 8)
                  .paddingAll(kH)
                  .position(left: 0, top: 0)
            : null,
      );
    }

    result = result.blur(sigma: widget.blur ? kM : 0.0);

    if (widget.tapDismiss) {
      result = GestureDetector(
        onTap: () {
          //pageController;
          //photoScaleStateController;
          //debugger();
          /*if (photoStateController?.scale != null ||
              photoStateController?.scale != 1.0) {
            photoStateController?.reset();
            return;
          }*/
          if (photoScaleStateController?.scaleState !=
              PhotoViewScaleState.initial) {
            photoScaleStateController?.reset();
            return;
          }
          context.pop();
        },
        child: result,
      );
    }

    /*return [
      AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: "angcyo".text(),
      ),
      result,
    ].stack()!.material();*/
    return result.material().systemUiOverlay(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    );
  }

  Widget _buildLoading(BuildContext context, ImageChunkEvent? event) {
    double? progressValue;
    if (event != null && event.expectedTotalBytes != null) {
      progressValue = event.cumulativeBytesLoaded / event.expectedTotalBytes!;
    }
    return GlobalConfig.of(
      context,
    ).loadingIndicatorBuilder(context, this, progressValue, null).center();
  }
}

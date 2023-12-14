part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

const Size kAvatarSize = Size(40, 40);

/// 圆形网络图片小部件
class CircleNetworkImage extends StatefulWidget {
  /// 网络图片地址
  final String? url;

  /// 大小
  final Size size;

  const CircleNetworkImage({
    super.key,
    required this.url,
    this.size = kAvatarSize,
  });

  @override
  State<CircleNetworkImage> createState() => _CircleNetworkImageState();
}

class _CircleNetworkImageState extends State<CircleNetworkImage> {
  @override
  Widget build(BuildContext context) {
    Widget result;
    var url = widget.url;
    if (url == null || url.isEmpty) {
      result = "".toNetworkImageWidget(usePlaceholder: true);
    } else {
      result = url.toNetworkImageWidget(
        usePlaceholder: false,
        memCacheWidth: widget.size.width.toInt(),
        memCacheHeight: widget.size.height.toInt(),
      );
    }
    return result.clipOval();
  }
}

extension ImagePubEx on String {
  /// 网络图片提供器
  /// [ImageProvider]
  CachedNetworkImageProvider toCacheNetworkImageProvider() =>
      CachedNetworkImageProvider(this);

  /// 文件图片提供器
  /// [FileImage]
  /// [AssetImage]
  /// [MemoryImage]
  /// [NetworkImage]
  FileImage toFileImageProvider({double scale = 1}) =>
      FileImage(file(), scale: scale);

  /// [toFileImageProvider]
  /// [Image.network]
  NetworkImage toNetworkImageProvider(
          {double scale = 1, Map<String, String>? headers}) =>
      NetworkImage(this, scale: scale, headers: headers);

  /// [loadAssetImageWidget]
  /// [placeholder] [progressIndicatorBuilder] 只能设置一个
  Widget toNetworkImageWidget({
    BoxFit? fit = BoxFit.cover,
    bool usePlaceholder = false,
    PlaceholderWidgetBuilder? placeholder,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    var url = this;
    var needPlaceholder = (usePlaceholder || placeholder != null);
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: needPlaceholder
          ? placeholder ??
              (context, url) =>
                  GlobalConfig.of(context).imagePlaceholderBuilder(context, url)
          : null,
      progressIndicatorBuilder: needPlaceholder
          ? null
          : (context, url, downloadProgress) =>
              GlobalConfig.of(context).loadingIndicatorBuilder(context),
      errorWidget: (context, url, error) =>
          GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
    );
  }
}

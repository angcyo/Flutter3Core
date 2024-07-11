part of '../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

const Size kAvatarSize = Size(40, 40);

/// 圆形网络图片小部件
/// [CircleAvatar]
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
      result = url.toImageWidget(
        usePlaceholder: false,
        memCacheWidth: widget.size.width.toInt(),
        memCacheHeight: widget.size.height.toInt(),
      );
    }
    return result.clipOval();
  }
}

extension ImagePubEx on String {
  /// 根据类型, 自动转换成对应的图片提供器
  /// [ImageProvider]
  /// [toImageWidget]
  ImageProvider toImageProvider() => isHttpUrl
      ? toCacheNetworkImageProvider()
      : (isLocalUrl || isFilePath
          ? toFileImageProvider()
          : toAssetImageProvider()) as ImageProvider;

  /// 根据类型, 自动转换成对应的图片小部件
  /// 支持http/file
  /// 支持svg/image
  /// [toImageProvider]
  Widget toImageWidget({
    BoxFit? fit = BoxFit.cover,
    bool usePlaceholder = false,
    PlaceholderWidgetBuilder? placeholder,
    double? size,
    double? width,
    double? height,
    int? memCacheWidth,
    int? memCacheHeight,
    Color? tintColor,
  }) {
    //debugger();
    //memCacheHeight ??= memCacheWidth; //变成了正方形了
    final type = mimeType();
    if (type?.isImageMimeType == true) {
      //图片类型
      if (isSvg) {
        //svg图片
        fit ??= BoxFit.contain;
        if (isHttpUrl) {
          return loadHttpSvgWidget(
            this,
            tintColor: tintColor,
            fit: fit,
            size: size,
            width: width,
            height: height,
          );
        } else if (isFilePath) {
          return loadFileSvgWidget(
            this,
            tintColor: tintColor,
            fit: fit,
            size: size,
            width: width,
            height: height,
          );
        } else {
          return loadStringSvgWidget(
            this,
            tintColor: tintColor,
            fit: fit,
            size: size,
            width: width,
            height: height,
          );
        }
      } else {
        //普通图片
        if (isHttpUrl) {
          return toNetworkImageWidget(
            fit: fit,
            usePlaceholder: usePlaceholder,
            placeholder: placeholder,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            width: size ?? width,
            height: size ?? height,
            tintColor: tintColor,
          );
        } else if (isFilePath) {
          return Image.file(
            file(),
            fit: fit,
            cacheWidth: memCacheWidth,
            cacheHeight: memCacheHeight,
            width: size ?? width,
            height: size ?? height,
            color: tintColor,
            errorBuilder: (context, error, stackTrace) =>
                GlobalConfig.of(context)
                    .errorPlaceholderBuilder(context, error),
          );
        } else {
          return Image.asset(
            this,
            fit: fit,
            cacheWidth: memCacheWidth,
            cacheHeight: memCacheHeight,
            width: size ?? width,
            height: size ?? height,
            color: tintColor,
            errorBuilder: (context, error, stackTrace) =>
                GlobalConfig.of(context)
                    .errorPlaceholderBuilder(context, error),
          );
        }
      }
    }
    //debugger();
    l.w("不支持的图片类型:$type\n$this");
    return "不支持的图片类型:$type\n${basename()}".text(
      textAlign: TextAlign.center,
      textColor: Colors.red,
    );
  }

  /// 网络图片提供器
  /// [ImageProvider]
  /// [toNetworkImageWidget]
  CachedNetworkImageProvider toCacheNetworkImageProvider() =>
      CachedNetworkImageProvider(this);

  /// 文件图片提供器
  /// [FileImage]
  /// [AssetImage]
  /// [MemoryImage]
  /// [NetworkImage]
  FileImage toFileImageProvider({double scale = 1}) =>
      FileImage(file(), scale: scale);

  /// Asset图片提供器
  /// [AssetImage]
  AssetImage toAssetImageProvider({
    AssetBundle? bundle,
    String? package,
  }) =>
      AssetImage(this, bundle: bundle, package: package);

  /// [toFileImageProvider]
  /// [Image.network]
  NetworkImage toNetworkImageProvider({
    double scale = 1,
    Map<String, String>? headers,
  }) =>
      NetworkImage(this, scale: scale, headers: headers);

  /// [loadAssetImageWidget]
  /// [placeholder].[progressIndicatorBuilder] 只能设置一个
  /// [usePlaceholder] 是否使用默认的占位图, 否则使用进度指示器
  /// [toCacheNetworkImageProvider]
  /// [toNetworkImageWidget]
  Widget toNetworkImageWidget({
    BoxFit? fit = BoxFit.cover,
    bool usePlaceholder = false,
    PlaceholderWidgetBuilder? placeholder,
    int? memCacheWidth,
    int? memCacheHeight,
    double? width,
    double? height,
    Color? tintColor,
  }) {
    //debugger();
    var url = this;
    var needPlaceholder = (usePlaceholder || placeholder != null);
    if (url.isHttpUrl) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        width: width,
        height: height,
        color: tintColor,
        placeholder: needPlaceholder
            ? placeholder ??
                (context, url) => GlobalConfig.of(context)
                    .imagePlaceholderBuilder(context, url)
            : null,
        progressIndicatorBuilder: needPlaceholder
            ? null
            : (context, url, downloadProgress) => GlobalConfig.of(context)
                .loadingIndicatorBuilder(
                    context, url, downloadProgress.progress),
        errorWidget: (context, url, error) =>
            GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
      );
    } else {
      return OctoImage(
        image: url.toImageProvider(),
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        width: width,
        height: height,
        color: tintColor,
        placeholderBuilder: needPlaceholder
            ? (context) => placeholder == null
                ? GlobalConfig.of(context).imagePlaceholderBuilder(context, url)
                : placeholder(context, url)
            : null,
        progressIndicatorBuilder: needPlaceholder
            ? null
            : (context, progress) => GlobalConfig.of(context)
                .loadingIndicatorBuilder(
                    context,
                    this,
                    (progress == null || progress.expectedTotalBytes == null)
                        ? null
                        : progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!),
        errorBuilder: (context, url, error) =>
            GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
      );
      /*return Image.file(
        url.file(),
        fit: fit,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
      );*/
    }
  }
}

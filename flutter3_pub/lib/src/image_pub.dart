part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

extension ImagePubEx on String {
  /// [loadAssetImageWidget]
  /// [placeholder] [progressIndicatorBuilder] 只能设置一个
  Widget toNetworkImageWidget({
    BoxFit? fit = BoxFit.cover,
    bool usePlaceholder = false,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    var url = this;
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: usePlaceholder
          ? (context, url) =>
              GlobalConfig.of(context).imagePlaceholderBuilder(context, url)
          : null,
      progressIndicatorBuilder: usePlaceholder
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

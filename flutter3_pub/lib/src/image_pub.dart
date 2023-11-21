part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/21
///

extension ImagePubEx on String {
  /// [loadAssetImageWidget]
  Widget toNetworkImageWidget({
    BoxFit? fit = BoxFit.cover,
  }) {
    var url = this;
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) =>
          GlobalConfig.of(context).imagePlaceholderBuilder(context, url),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          GlobalConfig.of(context).loadingIndicatorBuilder(context),
      errorWidget: (context, url, error) =>
          GlobalConfig.of(context).errorPlaceholderBuilder(context, error),
      fit: fit,
    );
  }
}

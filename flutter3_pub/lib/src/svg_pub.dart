part of flutter3_pub;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///

//region Asset

/// [loadAssetImageWidget]
SvgPicture loadAssetSvgWidget(
  String key, {
  String? prefix = 'assets/',
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.asset(
      key.ensurePrefix(prefix),
      semanticsLabel: key,
      colorFilter: colorFilter,
      width: width,
      height: height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

SvgPicture loadHttpSvgWidget(
  String url, {
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.network(
      url,
      semanticsLabel: url,
      colorFilter: colorFilter,
      width: width,
      height: height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

//endregion Asset

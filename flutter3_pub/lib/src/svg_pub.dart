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
  String prefix = 'assets/',
  UiColorFilter? colorFilter,
}) =>
    SvgPicture.asset(
      key.ensurePrefix(prefix),
      semanticsLabel: key,
      colorFilter: colorFilter,
    );

//endregion Asset

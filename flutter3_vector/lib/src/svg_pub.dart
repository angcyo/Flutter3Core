part of flutter3_vector;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///

//region Asset

const kDefAssetsSvgPrefix = 'assets/svg/';

/// [loadAssetImageWidget]
/// [package] 如果资源不在当前项目中, 需要指定package才能访问
SvgPicture loadAssetSvgWidget(
  String key, {
  Color? tintColor,
  String? prefix = kDefAssetsSvgPrefix,
  String? package,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  ColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.asset(
      key.ensurePackagePrefix(package, prefix),
      semanticsLabel: key,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

SvgPicture loadHttpSvgWidget(
  String url, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.network(
      url,
      semanticsLabel: url,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: width,
      height: height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

SvgPicture loadFileSvgWidget(
  String path, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.file(
      path.file(),
      semanticsLabel: path,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: width,
      height: height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

SvgPicture loadStringSvgWidget(
  String string, {
  Color? tintColor,
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
  UiColorFilter? colorFilter,
  WidgetBuilder? placeholderBuilder,
}) =>
    SvgPicture.string(
      string,
      semanticsLabel: string,
      fit: fit,
      colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      width: width,
      height: height,
      placeholderBuilder: placeholderBuilder ??
          (context) => LoadingWrapWidget(
                width: width,
                height: height,
              ),
    );

//endregion Asset

//region svg

extension SvgStringEx on String {
  /// 将svg中的path路径字符串转换成[Path]对象
  /// https://github.com/dnfield/dart_path_parsing
  ///
  /// [https://pub.dev/packages/svg_path_parser]
  /// ```
  /// Path path = parseSvgPath('m.29 47.85 14.58 14.57 62.2-62.2h-29.02z');
  /// ```
  ///
  /// [vector_graphics_compiler.parse]
  Path toPath([bool failSilently = false]) =>
      parseSvgPath(this, failSilently: failSilently);
}

//endregion svg

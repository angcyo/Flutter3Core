part of flutter3_vector;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///

const kDefAssetsSvgPrefix = 'assets/svg/';

//region svg

/// 加载svg图片
/// ```
/// "packages/flutter3_canvas/assets_canvas/svg/canvas_delete_point.svg".
/// ```
/// [SvgPicture]
/// [createCompatVectorGraphic]
/// [VectorGraphic]
/// [RenderPictureVectorGraphic]
/// [decodeVectorGraphics]
///
/// [RenderingStrategy.raster].[_RawVectorGraphicWidget].[RenderVectorGraphic]
/// [RenderingStrategy.picture].[_RawPictureVectorGraphicWidget].[RenderPictureVectorGraphic]
Future<PictureInfo> loadAssetSvgPicture(
  String key, {
  String? prefix = kDefAssetsSvgPrefix,
  String? package,
  BuildContext? context,
  bool clipViewBox = true,
  AssetBundle? bundle,
  SvgTheme? theme,
}) =>
    vg.loadPicture(
        SvgAssetLoader(
          key.ensurePackagePrefix(package, prefix),
          packageName: package,
          assetBundle: bundle,
          theme: theme,
        ),
        context);

extension SvgStringEx on String {
  /// 将svg中的path路径字符串转换成[Path]对象
  /// https://github.com/dnfield/dart_path_parsing
  ///
  /// [https://pub.dev/packages/svg_path_parser]
  /// ```
  /// #大写: 绝对坐标 小写: 相对坐标
  /// Path path = parseSvgPath('m.29 47.85 14.58 14.57 62.2-62.2h-29.02z');
  /// ```
  /// [failSilently] 是否忽略解析错误, 否则会抛出异常
  /// [vector_graphics_compiler.parse]
  ///
  /// [VectorGraphicsCodec]
  /// [decodeVectorGraphics] 解析svg格式文档字符
  ///
  Path toUiPath([bool failSilently = false]) =>
      parseSvgPath(this, failSilently: failSilently);
}

//endregion svg

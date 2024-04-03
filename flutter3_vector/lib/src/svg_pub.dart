part of '../flutter3_vector.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///

const kDefAssetsSvgPrefix = 'assets/svg/';

extension SvgImageFormatTypesEx on int {
  /// [ImageFormatTypes.values]
  String get imageFormatTypeString =>
      ["png", "jpeg", "webp", "gif", "bmp"].getOrNull(this, 'unknown')!;
}

//region svg

/// 加载svg图片
/// ```
/// "packages/flutter3_canvas/assets/svg/canvas_delete_point.svg".
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

//region parse

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// [FlutterVectorGraphicsListener]
class SvgListener extends VectorGraphicsCodecListener {
  @override
  void onClipPath(int pathId) {
    l.d('onClipPath $pathId');
  }

  @override
  void onDrawImage(int imageId, double x, double y, double width, double height,
      Float64List? transform) {
    l.d('onDrawImage $imageId $x $y $width $height $transform');
  }

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {
    l.d('onDrawPath $pathId $paintId $patternId');
  }

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    l.d('onDrawText $textId $fillId $strokeId $patternId');
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    l.d('onDrawVertices $vertices $indices $paintId');
  }

  @override
  void onImage(int imageId, int format, Uint8List data,
      {VectorGraphicsErrorListener? onError}) {
    l.d('onImage[$imageId] $format:${format.imageFormatTypeString} ${data.lengthInBytes.toFileSizeStr()}');
  }

  @override
  void onLinearGradient(double fromX, double fromY, double toX, double toY,
      Int32List colors, Float32List? offsets, int tileMode, int id) {
    l.d('onLinearGradient $fromX $fromY $toX $toY $colors $offsets $tileMode $id');
  }

  @override
  void onMask() {
    l.d('onMask');
  }

  /// 有绘制对象被解码
  /// 在此方法中应该通过[id]创建对应绘制对象的[Paint]对象,
  /// 以便在后续绘制对象时读取[Paint]对象
  /// [FlutterVectorGraphicsListener.onPaintObject]
  @override
  void onPaintObject(
      {required int id,
      required int color,
      required int? strokeCap,
      required int? strokeJoin,
      required int blendMode,
      required double? strokeMiterLimit,
      required double? strokeWidth,
      required int paintStyle,
      required int? shaderId}) {
    BlendMode mode = BlendMode.srcOver;
    if (blendMode != 0) {
      mode = BlendMode.values[blendMode];
    }
    l.d('onPaintObject[$id] ${color.toHexColor()} $strokeCap $strokeJoin $blendMode:$mode $strokeMiterLimit $strokeWidth $paintStyle:${PaintingStyle.values[paintStyle]} $shaderId');
  }

  @override
  void onPathClose() {
    l.d('onPathClose');
  }

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    l.d('onPathCubicTo $x1 $y1 $x2 $y2 $x3 $y3');
  }

  @override
  void onPathFinished() {
    l.d('onPathFinished');
  }

  @override
  void onPathLineTo(double x, double y) {
    l.d('onPathLineTo $x $y');
  }

  @override
  void onPathMoveTo(double x, double y) {
    //debugger();
    l.d('onPathMoveTo $x $y');
  }

  /// 路径中的坐标全部被解析过了
  /// 因此不用考虑svg中的[transform]属性
  @override
  void onPathStart(int id, int fillType) {
    l.d('onPathStart[$id] $fillType:${PathFillType.values[fillType]}');
  }

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {
    l.d('onPatternStart[$patternId] $x $y $width $height $transform');
  }

  @override
  void onRadialGradient(
      double centerX,
      double centerY,
      double radius,
      double? focalX,
      double? focalY,
      Int32List colors,
      Float32List? offsets,
      Float64List? transform,
      int tileMode,
      int id) {
    l.d('onRadialGradient $centerX $centerY $radius $focalX $focalY $colors $offsets $transform $tileMode $id');
  }

  @override
  void onRestoreLayer() {
    l.d('onRestoreLayer');
  }

  @override
  void onSaveLayer(int paintId) {
    l.d('onSaveLayer $paintId');
  }

  /// 这里的宽高, 只会返回`viewBox="0 0 1024 1024"`中的大小
  @override
  void onSize(double width, double height) {
    l.d('onSize $width $height');
  }

  @override
  void onTextConfig(
      String text,
      String? fontFamily,
      double xAnchorMultiplier,
      int fontWeight,
      double fontSize,
      int decoration,
      int decorationStyle,
      int decorationColor,
      int id) {
    //debugger();
    l.d('onTextConfig[$id] $text $fontFamily $xAnchorMultiplier $fontWeight $fontSize $decoration $decorationStyle ${decorationColor.toHexColor()}');
  }

  @override
  void onTextPosition(int textPositionId, double? x, double? y, double? dx,
      double? dy, bool reset, Float64List? transform) {
    l.d('onTextPosition[$textPositionId] $x $y $dx $dy $reset $transform');
  }

  @override
  void onUpdateTextPosition(int textPositionId) {
    l.d('onUpdateTextPosition $textPositionId');
  }
}

/// 解析svg格式文档
Future<DecodeResponse> decodeSvgString(
  String svg, {
  SvgTheme? theme,
  BuildContext? context,
}) async {
  final loader = SvgStringLoader(svg, theme: theme);
  final byteData = await loader.loadBytes(context);
  return _codec.decode(byteData, SvgListener());
}

//endregion parse

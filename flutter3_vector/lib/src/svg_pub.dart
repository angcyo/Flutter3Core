part of '../flutter3_vector.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/19
///

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
  AssetBundle? bundle,
  SvgTheme? theme,
  bool clipViewBox = true,
  VectorGraphicsErrorListener? onError,
}) =>
    vg.loadPicture(
      SvgAssetLoader(
        key.ensurePackagePrefix(package, prefix).transformKey(),
        packageName: package,
        assetBundle: bundle,
        theme: theme,
      ),
      context,
      clipViewbox: clipViewBox,
      onError: onError,
    );

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
  /// [scale] 缩放比例
  /// [isMmUnit] 是否要放大到mm单位的数值
  ///
  /// [GCodeStringEx.toUiPathFromGCode]
  ///
  @dp
  Path toUiPath({
    bool failSilently = false,
    double? scale,
    bool isMmUnit = false,
  }) {
    final path = parseSvgPath(this, failSilently: failSilently);
    scale ??= isMmUnit ? 1.toDpFromMm() : 1.0;
    if (scale != 1.0) {
      final scaleMatrix = Matrix4.identity()..scale(scale);
      return path.transformPath(scaleMatrix);
    }
    return path..fillType = PathFillType.evenOdd;
  }

  /// 将svg的xml文档转换成[Path]对象
  /// [mergePath] 是否将多个[Path]合并到一个[Path]中?
  Future<List<Path>> toUiPathFromXml({bool mergePath = false}) async {
    List<Path> result = [];
    await decodeSvgString(
      this,
      listener: SvgListener()
        ..onDrawElement = (element, data, paint, bounds, matrix) {
          //consoleLog('${element.runtimeType} $bounds $data');
          if (element is Path) {
            element.fillType = PathFillType.evenOdd;
            final first = result.firstOrNull;
            if (first == null) {
              result.add(element);
            } else if (mergePath) {
              //合并到一个Path
              first.addPath(element, Offset.zero);
            } else {
              result.add(element);
            }
          }
        },
    );
    return result;
  }

  /// 将svg xml字符串转换成[PictureInfo]对象
  Future<PictureInfo> toStringSvgPicture({
    BuildContext? context,
    SvgTheme? theme,
    ColorMapper? colorMapper,
    bool clipViewBox = true,
    VectorGraphicsErrorListener? onError,
  }) =>
      vg.loadPicture(
        SvgStringLoader(
          this,
          theme: theme,
          colorMapper: colorMapper,
        ),
        context,
        clipViewbox: clipViewBox,
        onError: onError,
      );

  /// 将svg xml字符串转换成[UiImage]对象
  Future<UiImage> toSvgPictureImage({
    BuildContext? context,
    SvgTheme? theme,
    ColorMapper? colorMapper,
    bool clipViewBox = true,
    VectorGraphicsErrorListener? onError,
  }) async =>
      (await toStringSvgPicture(
        context: context,
        theme: theme,
        colorMapper: colorMapper,
        clipViewBox: clipViewBox,
        onError: onError,
      ))
          .let((it) => it.picture
              .toImage(it.size.width.toInt(), it.size.height.toInt()));
}

//endregion svg

//region parse

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// [FlutterVectorGraphicsListener]
class SvgListener extends VectorGraphicsCodecListener {
  static final Paint _emptyPaint = Paint();

  /// canvasBox 中的宽高
  Size size = Size.zero;

  /// 绘制元素的回调
  /// [element]支持的类型有:
  /// 矢量数据: [Path]. [data]里面存储了svg path的字符串, 无[bounds]
  /// 文本数据: [SvgTextConfig] 文本对象, 有[bounds]
  /// 图片数据: [Uint8List] 图片, 绘制图片不需要paint对象. 有[bounds]
  ///
  /// [bounds] 绘制的区域, 如果有. [Path]数据可能需要手动计算边界
  void Function(
    dynamic element,
    String? data,
    Paint? paint,
    Rect? bounds,
    Matrix4? matrix,
  )? onDrawElement;

  /// 存储所有的paint对象
  final List<Paint> _paints = <Paint>[];
  final List<Path> _paths = <Path>[];
  final List<StringBuffer> _pathStringList = <StringBuffer>[];

  Path? _currentPath;
  StringBuffer? _currentPathBuffer;

  final List<SvgTextConfig> _textConfig = <SvgTextConfig>[];
  final List<SvgTextPosition> _textPositions = <SvgTextPosition>[];

  Locale? _locale;
  TextDirection? _textDirection;

  final Map<int, Uint8List> _images = <int, Uint8List>{};

  /// [onImage]
  @override
  void onDrawImage(
    int imageId,
    double x, //图片绘制的偏移
    double y,
    double width, //图片的宽高
    double height,
    Float64List? transform,
  ) {
    //debugger();

    assert(() {
      //l.d('onDrawImage $imageId $x $y $width $height $transform');
      return true;
    }());

    final Uint8List image = _images[imageId]!;
    Rect bounds = Rect.fromLTWH(x, y, width, height);

    /*if (transform != null) {
      final matrix4 = Matrix4.fromFloat64List(transform);
      bounds = matrix4.mapRect(bounds);
    }*/
    //image
    onDrawElement?.call(
      image,
      null,
      null,
      bounds,
      transform == null ? null : Matrix4.fromFloat64List(transform),
    );
  }

  /// [onPaintObject].[onPathStart].[onPathMoveTo].[onPathLineTo].[onPathFinished].[onDrawPath]
  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {
    assert(() {
      //l.d('onDrawPath $pathId $paintId $patternId');
      return true;
    }());

    final Path path = _paths[pathId];
    final StringBuffer pathString = _pathStringList[pathId];
    Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    if (patternId != null) {
      if (paintId != null) {
        //paint!.shader = _patterns[patternId]!.shader;
      } else {
        final Paint newPaint = Paint();
        //newPaint.shader = _patterns[patternId]!.shader;
        paint = newPaint;
      }
    }
    onDrawElement?.call(
      path,
      pathString.toString(),
      paint ?? _emptyPaint,
      null,
      null,
    );
  }

  /// [onTextConfig]
  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    assert(() {
      //l.d('onDrawText $textId $fillId $strokeId $patternId');
      return true;
    }());

    final SvgTextConfig textConfig = _textConfig[textId];
    final double dx = _accumulatedTextPositionX ?? 0;
    final double dy = _textPositionY;
    double paragraphWidth = 0;

    void draw(int paintId) {
      final Paint paint = _paints[paintId];
      if (patternId != null) {
        //paint.shader = _patterns[patternId]!.shader;
      }
      final ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle(
        textDirection: _textDirection,
      ));
      builder.pushStyle(UiTextStyle(
        locale: _locale,
        foreground: paint,
        fontWeight: textConfig.fontWeight,
        fontSize: textConfig.fontSize,
        fontFamily: textConfig.fontFamily,
        decoration: textConfig.decoration,
        decorationStyle: textConfig.decorationStyle,
        decorationColor: textConfig.decorationColor,
      ));

      builder.addText(textConfig.text);

      final Paragraph paragraph = builder.build();
      paragraph.layout(const ParagraphConstraints(
        width: double.infinity,
      ));
      paragraphWidth = paragraph.maxIntrinsicWidth;

      Offset offset = Offset(
        dx - paragraph.maxIntrinsicWidth * textConfig.xAnchorMultiplier,
        dy - paragraph.alphabeticBaseline,
      );
      /*if (_textTransform != null) {
        final matrix4 = Matrix4.fromFloat64List(_textTransform!);
        offset = matrix4.mapPoint(offset);
      }*/
      Rect bounds = offset & Size(paragraph.width, paragraph.height);

      //text
      onDrawElement?.call(
        textConfig,
        null,
        paint,
        bounds,
        _textTransform == null
            ? null
            : Matrix4.fromFloat64List(_textTransform!),
      );
    }

    if (fillId != null) {
      draw(fillId);
    }
    if (strokeId != null) {
      draw(strokeId);
    }
    _accumulatedTextPositionX = dx + paragraphWidth;
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    assert(() {
      //l.d('onDrawVertices $vertices $indices $paintId');
      return true;
    }());
  }

  @override
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  }) async {
    assert(() {
      //l.d('onImage[$imageId] $format:${format.imageFormatTypeString} ${data.lengthInBytes.toSizeStr()}');
      return true;
    }());
    _images[imageId] = data;
  }

  @override
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  ) {
    assert(() {
      //l.d('onLinearGradient $fromX $fromY $toX $toY $colors $offsets $tileMode $id');
      return true;
    }());
  }

  @override
  void onMask() {
    assert(() {
      //l.d('onMask');
      return true;
    }());
  }

  @override
  void onClipPath(int pathId) {
    assert(() {
      //l.d('onClipPath $pathId');
      return true;
    }());
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
    //l.d('onPaintObject[$id] ${color.toHexColor()} $strokeCap $strokeJoin $blendMode:$mode $strokeMiterLimit $strokeWidth $paintStyle:${PaintingStyle.values[paintStyle]} $shaderId');

    assert(_paints.length == id, 'Expect ID to be ${_paints.length}');
    final Paint paint = Paint()..color = Color(color);
    if (blendMode != 0) {
      paint.blendMode = BlendMode.values[blendMode];
    }

    /*if (shaderId != null) {
      paint.shader = _shaders[shaderId];
    }*/

    if (paintStyle == 1) {
      paint.style = PaintingStyle.stroke;
      if (strokeCap != null && strokeCap != 0) {
        paint.strokeCap = StrokeCap.values[strokeCap];
      }
      if (strokeJoin != null && strokeJoin != 0) {
        paint.strokeJoin = StrokeJoin.values[strokeJoin];
      }
      if (strokeMiterLimit != null && strokeMiterLimit != 4.0) {
        paint.strokeMiterLimit = strokeMiterLimit;
      }
      // SVG's default stroke width is 1.0. Flutter's default is 0.0.
      if (strokeWidth != null && strokeWidth != 0.0) {
        paint.strokeWidth = strokeWidth;
      }
    }
    _paints.add(paint);
  }

  @override
  void onPathClose() {
    assert(() {
      //l.d('onPathClose');
      return true;
    }());
    _currentPath?.close();
    _currentPathBuffer?.write('z');
  }

  @override
  void onPathCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    assert(() {
      //l.d('onPathCubicTo $x1 $y1 $x2 $y2 $x3 $y3');
      return true;
    }());
    _currentPath?.cubicTo(x1, y1, x2, y2, x3, y3);
    _currentPathBuffer?.write('C$x1 $y1 $x2 $y2 $x3 $y3');
  }

  @override
  void onPathFinished() {
    assert(() {
      //l.d('onPathFinished');
      return true;
    }());
    _currentPath = null;
    _currentPathBuffer = null;
  }

  @override
  void onPathLineTo(double x, double y) {
    assert(() {
      ////l.d('onPathLineTo $x $y');
      return true;
    }());
    _currentPath?.lineTo(x, y);
    _currentPathBuffer?.write('L$x $y');
  }

  @override
  void onPathMoveTo(double x, double y) {
    //debugger();
    assert(() {
      //l.d('onPathMoveTo $x $y');
      return true;
    }());
    _currentPath?.moveTo(x, y);
    _currentPathBuffer?.write('M$x $y');
  }

  /// 路径中的坐标全部被解析过了
  /// 因此不用考虑svg中的[transform]属性
  @override
  void onPathStart(int id, int fillType) {
    assert(() {
      //l.d('onPathStart[$id] $fillType:${PathFillType.values[fillType]}');
      return true;
    }());
    final Path path = Path();
    path.fillType = PathFillType.values[fillType];
    _paths.add(path);
    _currentPath = path;

    final buffer = StringBuffer();
    _currentPathBuffer = buffer;
    _pathStringList.add(buffer);
  }

  @override
  void onPatternStart(
    int patternId,
    double x,
    double y,
    double width,
    double height,
    Float64List transform,
  ) {
    assert(() {
      //l.d('onPatternStart[$patternId] $x $y $width $height $transform');
      return true;
    }());
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
    assert(() {
      //l.d('onRadialGradient $centerX $centerY $radius $focalX $focalY $colors $offsets $transform $tileMode $id');
      return true;
    }());
  }

  @override
  void onRestoreLayer() {
    assert(() {
      //l.d('onRestoreLayer');
      return true;
    }());
  }

  @override
  void onSaveLayer(int paintId) {
    assert(() {
      //l.d('onSaveLayer $paintId');
      return true;
    }());
  }

  /// 这里的宽高, 只会返回`viewBox="0 0 1024 1024"`中的大小
  @override
  void onSize(double width, double height) {
    assert(() {
      //l.d('onSize $width $height');
      return true;
    }());
    size = Size(width, height);
  }

  /// [onTextPosition]
  /// [onUpdateTextPosition]
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
    assert(() {
      //l.d('onTextConfig[$id] $text $fontFamily $xAnchorMultiplier $fontWeight $fontSize $decoration $decorationStyle ${decorationColor.toHexColor()}');
      return true;
    }());

    final List<TextDecoration> decorations = <TextDecoration>[];
    if (decoration & kUnderlineMask != 0) {
      decorations.add(TextDecoration.underline);
    }
    if (decoration & kOverlineMask != 0) {
      decorations.add(TextDecoration.overline);
    }
    if (decoration & kLineThroughMask != 0) {
      decorations.add(TextDecoration.lineThrough);
    }

    _textConfig.add(SvgTextConfig(
      text,
      fontFamily,
      xAnchorMultiplier,
      FontWeight.values[fontWeight],
      fontSize,
      TextDecoration.combine(decorations),
      TextDecorationStyle.values[decorationStyle],
      Color(decorationColor),
    ));
  }

  @override
  void onTextPosition(
    int textPositionId,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {
    assert(() {
      //l.d('onTextPosition[$textPositionId] $x $y $dx $dy $reset $transform');
      return true;
    }());
    _textPositions.add(SvgTextPosition(x, y, dx, dy, reset, transform));
  }

  double? _accumulatedTextPositionX;
  double _textPositionY = 0;
  Float64List? _textTransform;

  @override
  void onUpdateTextPosition(int textPositionId) {
    assert(() {
      //l.d('onUpdateTextPosition $textPositionId');
      return true;
    }());
    final SvgTextPosition position = _textPositions[textPositionId];
    if (position.reset) {
      _accumulatedTextPositionX = 0;
      _textPositionY = 0;
    }

    if (position.x != null) {
      _accumulatedTextPositionX = position.x;
    }
    if (position.y != null) {
      _textPositionY = position.y ?? _textPositionY;
    }

    if (position.dx != null) {
      _accumulatedTextPositionX =
          (_accumulatedTextPositionX ?? 0) + position.dx!;
    }
    if (position.dy != null) {
      _textPositionY = _textPositionY + position.dy!;
    }

    _textTransform = position.transform;
  }
}

/// [SvgListener.onTextPosition]
/// [SvgListener.onUpdateTextPosition]
class SvgTextPosition {
  const SvgTextPosition(
    this.x,
    this.y,
    this.dx,
    this.dy,
    this.reset,
    this.transform,
  );

  final double? x;
  final double? y;
  final double? dx;
  final double? dy;
  final bool reset;
  final Float64List? transform;
}

/// [SvgListener.onTextConfig]
/// [SvgListener.onDrawText]
class SvgTextConfig {
  const SvgTextConfig(
    this.text,
    this.fontFamily,
    this.xAnchorMultiplier,
    this.fontWeight,
    this.fontSize,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
  );

  final String text;
  final String? fontFamily;
  final double fontSize;
  final double xAnchorMultiplier;
  final FontWeight fontWeight;
  final TextDecoration decoration;
  final TextDecorationStyle decorationStyle;
  final Color decorationColor;
}

/// 解析svg格式文档
Future<DecodeResponse> decodeSvgString(
  String svg, {
  SvgTheme? theme,
  BuildContext? context,
  SvgListener? listener,
}) async {
  final loader = SvgStringLoader(svg, theme: theme);
  final byteData = await loader.loadBytes(context);
  listener ??= SvgListener();
  DecodeResponse response = _codec.decode(byteData, listener);
  while (!response.complete) {
    response = _codec.decode(byteData, listener, response: response);
  }
  return response;
}

//endregion parse

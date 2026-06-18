part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/11/18
///

/// 基础文本绘制
/// - [NormalTextPainter] 系统绘制
/// - [SingleCharTextPainter] 逐字绘制
abstract class BaseTextPainter {
  /// 调试模式下, 是否绘制文本的边界
  bool debugPaintBounds = false;

  //region ---属性---

  /// 需要绘制的文本
  String? text;

  /// 文本字体
  String? fontFamily;

  /// 绘制方向
  int orientation = kHorizontal;

  /// 文本是否要在[orientation]方向上顺时针旋转90°
  bool orientationRotate = false;

  /// 文本的颜色
  Color textColor = Colors.black;

  /// 文本的样式
  PaintingStyle paintingStyle = PaintingStyle.fill;

  @dp
  @implementation
  double strokeWidth = 1;

  /// 文本的字体大小
  @dp
  double fontSize = 14;

  /// 字间距, 支持负数
  @dp
  double? letterSpacing;

  /// 行间距, 支持负数
  /// 普通文本绘制模式下间距使用[strutHeight]实现
  @dp
  double? lineSpacing;

  /// 粗体
  bool isBold = false;

  /// 斜体, 宽度计算无法包含斜体值, 需要额外增加一点宽度
  bool isItalic = false;

  /// 下划线
  bool isUnderline = false;

  /// 删除线
  bool isLineThrough = false;

  /// 对齐方式, 在多行文本时, 会影响每行的对齐方式
  /// ~~~[TextAlign.justify] 矢量文本的极限对齐~~~
  TextAlign textAlign = TextAlign.start;

  /// 交叉轴上文本对齐的方式
  /// - 在垂直排列时, 效果明显
  /// ~~~[TextAlign.justify] 矢量文本的极限对齐~~~
  TextAlign crossTextAlign = TextAlign.center;

  /// 文本方向
  TextDirection? textDirection = TextDirection.ltr;

  /// 行高倍数, 间接控制了行高
  /// 优先于[lineSpacing] 属性
  double? strutHeight;

  /// 强制行高
  bool forceStrutHeight = false;

  //MARK: vector

  /// 是否使用矢量字符绘制
  @configProperty
  bool useVectorText = false;

  /// 矢量字符对应的矢量路径, 适量文本的核心. 需要要外部提供处理好
  /// - 每个字符对应的原始字形数据
  @configProperty
  Map<String, Path?>? vectorTextPathMap;

  //endregion ---属性---

  /// 计算出来的绘制对象的边界
  /// [initPainter]
  Rect _painterBounds = Rect.zero;

  /// 当前绘制对象占用的大小
  /// 如果是曲线文本, left/top 可能是负值
  @output
  Rect get painterBounds => Rect.zero;

  /// 包含了基线, 行高, 宽度
  @output
  UiLineMetrics? get lineMetrics => null;

  /// 必要的初始化方法
  /// - 测量所有文本的大小
  /// - 可以进行额外的变换
  /// - 决定文本的布局位置
  /// - 返回整体的边界大小
  @initialize
  @entryPoint
  void initPainter() {
    if (useVectorText) {
      scaleVectorCharPathToFontSize();
    }
  }

  /// 核心绘制入口, 绘制文本, 相对于左上角0,0锚点绘制
  @api
  @overridePoint
  @entryPoint
  void painterText(Canvas canvas, Offset offset);

  //MARK: base

  /// 缩放所有矢量文本路径, 以便适应字体大小
  /// 字体库中用的pt单位, 所以需要缩放到指定的dp字体大小值
  void scaleVectorCharPathToFontSize() {
    final pathMap = vectorTextPathMap;
    if (pathMap != null) {
      final scale = fontSize / (1160 + 288);

      //final scale = 1.toUnitFromDp(IUnit.pt);
      //final scale = 1 / fontSize / 1.toDpFromUnit(IUnit.pt);
      //final scale = 1 / fontSize / 1.toUnitFromDp(IUnit.pt);
      final scaleMatrix = createScaleMatrix(sx: scale, sy: scale);
      //debugger();
      pathMap.forEach((key, path) {
        if (path != null) {
          //final bounds = path.getExactBounds();
          //final translate = createTranslateMatrix(ty: bounds.height * 0.1);
          //final scale = createScaleMatrix(sx: 0.1, sy: 0.1);
          //vectorTextPathMap?[key] = path.transformPath(translate * scale);
          //pathMap[key] = path.moveToZero(scale: scale, scaleAnchor: Offset.zero);
          pathMap[key] = path.transformPath(scaleMatrix);
        }
      });
    }
  }

  /// 移动矢量文本路径, 以便对齐行内基线
  /// [crossTextAlign] 和这个属性有冲突
  @implementation
  void translateVectorCharPathToBaseline(
    List<List<BaseCharPainter>>? charPainterList,
  ) {
    final list = charPainterList;
    if (list != null) {
      for (final line in list) {
        for (final char in line) {
          if (char is CharPathPainter) {
            final charPath = vectorTextPathMap?[char.char];
            if (charPath != null) {
              //final scale = createScaleMatrix(sx: 0.1, sy: 0.1);
              //vectorTextPathMap?[char.char] = charPath.transformPath(scale);
              //char.charPath = charPath.transformPath(scale);
              final bounds = char.charBounds;
              final translate = createTranslateMatrix(
                tx: -bounds.left,
                //ty: char.lineHeight - char.lineDescender /* - bounds.bottom*/,
                ty: -bounds.top,
              );
              //debugger();
              //char.charPath = charPath.transformPath(translate);
              //char.charPathBounds = char.charPath.getBounds(); //需要重新赋值吗?
            }
          }
        }
      }
    }
  }

  /// 动态更新文本颜色
  @api
  @overridePoint
  void updateTextProperty({
    Color? textColor,
    PaintingStyle? textPaintingStyle,
    double? textStrokeWidth,
  }) {
    //debugger();
    this.textColor = textColor ?? this.textColor;
    paintingStyle = textPaintingStyle ?? paintingStyle;
    strokeWidth = textStrokeWidth ?? strokeWidth;
  }

  //MARK: base

  /// 创建基础画笔, 用来绘制装饰线
  /// [Paint]
  Paint createBasePaint() => Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = textColor
    ..style = paintingStyle
    ..strokeWidth = isBold ? 1 : 0;

  /// 创建单字符的文本绘制对象/系统文本绘制对象
  /// [TextPainter]
  TextPainter createBaseTextPainter(
    String? text, {
    double? letterSpacing,
    double? lineSpacing,
  }) {
    letterSpacing ??= this.letterSpacing;
    lineSpacing ??= this.lineSpacing;
    return createTextPainter(
      text: text,
      fontFamily: fontFamily,
      textColor: textColor,
      textAlign: textAlign,
      paintingStyle: paintingStyle,
      strokeWidth: strokeWidth,
      fontSize: fontSize,
      letterSpacing: letterSpacing ?? 0,
      isBold: isBold,
      isItalic: isItalic,
      isUnderline: isUnderline,
      isLineThrough: isLineThrough,
      textDirection: textDirection,
      strutHeight:
          strutHeight ??
          ((lineSpacing != null && lineSpacing != 0)
              ? (1 + lineSpacing / fontSize)
              : null),
      forceStrutHeight: forceStrutHeight,
    );
  }

  //MARK: static

  /// 更新[TextPainter]对应的文本颜色
  /// [createTextPainter]
  static void updateTextPainterProperty(
    TextPainter? painter, {
    Color? textColor,
    PaintingStyle? textStyle,
    double? textStrokeWidth,
  }) {
    final text = painter?.text;
    if (text != null) {
      if (updatePaintProperty(
        text.style?.foreground,
        textColor: textColor,
        textStyle: textStyle,
        textStrokeWidth: textStrokeWidth,
      )) {
        painter?.markNeedsLayout();
        painter?.layout();
      }
    }
  }

  /// 返回是否更新过属性
  static bool updatePaintProperty(
    Paint? paint, {
    Color? textColor,
    PaintingStyle? textStyle,
    double? textStrokeWidth,
  }) {
    bool isSet = false;
    if (paint != null) {
      //--
      final oldTextColor = paint.color;
      if (oldTextColor != textColor) {
        paint.color = textColor ?? oldTextColor;
        isSet = true;
      }

      final oldStyle = paint.style;
      if (oldStyle != textStyle) {
        paint.style = textStyle ?? oldStyle;
        isSet = true;
      }

      final oldStrokeWidth = paint.strokeWidth;
      if (oldStrokeWidth != textStrokeWidth) {
        paint.strokeWidth = textStrokeWidth ?? oldStrokeWidth;
        isSet = true;
      }
    }
    return isSet;
  }

  /// 通过给定的属性, 创建对应的[TextPainter]文本绘制对象
  /// [text]生成[InlineSpan]对象
  ///
  /// - 自动执行[TextPainter.layout]
  static TextPainter createTextPainter({
    String? text,
    String? fontFamily,
    InlineSpan? textSpan,
    Color textColor = Colors.black,
    PaintingStyle paintingStyle = PaintingStyle.fill,
    @dp double strokeWidth = 0,
    @dp double? fontSize = 14,
    @dp double? letterSpacing = 0, //字间距, 支持负数
    bool isBold = false, //粗体
    bool isItalic = false, //斜体, 宽度计算无法包含斜体值
    bool isUnderline = false, //下划线
    bool isLineThrough = false, //删除线
    TextAlign textAlign = TextAlign.start, //对齐方式, 在多行文本时, 会影响每行的对齐方式
    TextDirection? textDirection = TextDirection.ltr, //文本方向
    UiLocale? locale,
    double? strutHeight, //行高倍数, 间接控制行间距
    bool forceStrutHeight = false, //强制行高
    double? lineLeading = 0, //每行领头的距离倍数
  }) {
    locale ??= platformLocale;
    if (textSpan == null) {
      final style = TextStyle(
        fontSize: fontSize,
        locale: locale,
        height: strutHeight,
        fontFamily: fontFamily,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
        /*leadingDistribution: ,*/
        decoration: TextDecoration.combine([
          if (isUnderline) TextDecoration.underline,
          if (isLineThrough) TextDecoration.lineThrough,
        ]),
        decorationStyle: isBold
            ? TextDecorationStyle.double
            : TextDecorationStyle.solid,
        decorationColor: textColor,
        /*decorationThickness: 1,*/
        foreground: Paint()
          ..color = textColor
          ..strokeWidth = strokeWidth
          /*..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round*/
          ..style = paintingStyle,
        /*background: Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.fill,*/
      );
      textSpan = TextSpan(text: text, style: style);
    }
    return TextPainter(
      text: textSpan,
      textAlign: textAlign,
      locale: locale,
      textDirection: textDirection,
      strutStyle: forceStrutHeight || strutHeight != null
          ? StrutStyle(
              fontSize: fontSize,
              height: strutHeight,
              forceStrutHeight: forceStrutHeight,
              leading: lineLeading,
              leadingDistribution: TextLeadingDistribution.proportional,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            )
          : null,
    )..layout();
  }
}

/// 普通文本绘制, 整体一起绘制, 否则单字符绘制
/// [TextPainter]
class NormalTextPainter extends BaseTextPainter {
  NormalTextPainter();

  @override
  Rect get painterBounds => _painterBounds;

  @override
  UiLineMetrics? get lineMetrics =>
      _textPainter?.computeLineMetrics().firstOrNull;

  /// 普通文本使用[TextPainter]绘制
  TextPainter? _textPainter;

  /// 垂直绘制时, 需要进行的旋转矩阵
  @autoInjectMark
  Matrix4? paintMatrix;

  @override
  void updateTextProperty({
    Color? textColor,
    PaintingStyle? textPaintingStyle,
    double? textStrokeWidth,
  }) {
    super.updateTextProperty(
      textColor: textColor,
      textPaintingStyle: textPaintingStyle,
      textStrokeWidth: textStrokeWidth,
    );
    BaseTextPainter.updateTextPainterProperty(
      _textPainter,
      textColor: textColor,
      textStrokeWidth: textStrokeWidth,
      textStyle: textPaintingStyle,
    );
  }

  /// 初始化文本绘制对象
  @initialize
  @override
  void initPainter() {
    super.initPainter();
    _textPainter = createBaseTextPainter(text);
    double left = 2147483648;
    double top = 2147483648;
    double right = -2147483648;
    double bottom = -2147483648;
    for (final line in _textPainter!.computeLineMetrics()) {
      left = min(left, line.left);
      top = min(top, 0);
      right = max(right, line.left + line.width);
      bottom = max(bottom, line.height);
    }
    //_painterBounds = Offset.zero & _textPainter!.size;
    _painterBounds = Rect.fromLTWH(
      0,
      0,
      right - left,
      _textPainter!.size.height,
    );
    if (orientation.isVertical) {
      final rotateMatrix = Matrix4.identity()
        ..rotateBy(90.hd, anchor: _painterBounds.center);
      paintMatrix = rotateMatrix;
      _painterBounds = rotateMatrix.mapRect(_painterBounds);
    }
  }

  @override
  void painterText(Canvas canvas, Offset offset) {
    assert(() {
      if (debugPaintBounds) {
        canvas.drawRect(
          offset & painterBounds.size /*painterBounds*/,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.redAccent,
        );
      }
      return true;
    }());
    if (_textPainter == null) {
      initPainter();
    }
    if (_textPainter != null) {
      final anchor = _painterBounds.lt;
      canvas.withTranslate(-anchor.dx + offset.dx, -anchor.dy + offset.dy, () {
        canvas.withMatrix(paintMatrix, () {
          _textPainter?.paint(canvas, Offset.zero);
        });
      });
    }
  }
}

/// 单字符逐个绘制
/// [TextPainter]
/// [NormalTextPainter]
class SingleCharTextPainter extends BaseTextPainter {
  /// 是否使用自定义的删除线/下划线样式
  @configProperty
  bool useCustomLineStyle = false;

  /// 自定义样式时的线高
  /// [useCustomLineStyle]
  @configProperty
  double customLineStyleHeight = 6;

  /// 下划线底部的偏移距离
  @configProperty
  double underlineOffsetBottom = 4;

  SingleCharTextPainter();

  //---

  @override
  Rect get painterBounds => _painterBounds;

  /// 斜体宽度补偿方案
  /// 是否使用整行补偿宽度的方案
  @configProperty
  bool italicWidthWithLine = true;

  /// 斜体补偿的单字符宽度
  /// 方案1: 每个字符都补偿
  double get italicCharWidth => useVectorText
      ? 0
      : (isItalic && !italicWidthWithLine ? fontSize * 0.2 : 0);

  /// 斜体补偿的整个行的宽度
  /// 方案2: 只在整行中补偿一次
  double get italicLineWidth => useVectorText
      ? 0
      : (isItalic && italicWidthWithLine ? fontSize * 0.2 : 0);

  /// 文本绘制对象, 每个字符一个对象
  @output
  List<List<BaseCharPainter>>? charPainterList;

  /*  void test() {
    final list = charPainterList;
    final painter = list?.firstOrNull?.firstOrNull?.charPainter;
    final charDescent = list?.firstOrNull?.firstOrNull?.charDescent;
    final a = painter?.computeLineMetrics();
    debugger();
  }*/

  /// 将字符串按照换行符分解成一行行一个个的单字符
  List<List<String>> _splitText(String? text) {
    if (text == null) {
      return [];
    }
    final list = text.split('\n');
    return list.map((e) => e.characters.clone()).clone();
  }

  @override
  TextPainter createBaseTextPainter(
    String? text, {
    double? letterSpacing,
    double? lineSpacing,
  }) {
    final oldIsUnderline = isUnderline;
    final oldIsLineThrough = isLineThrough;

    if (useCustomLineStyle) {
      isUnderline = false;
      isLineThrough = false;
    }
    final painter = super.createBaseTextPainter(
      text,
      letterSpacing: letterSpacing,
      lineSpacing: lineSpacing,
    );

    isUnderline = oldIsUnderline;
    isLineThrough = oldIsLineThrough;
    return painter;
  }

  @override
  void updateTextProperty({
    Color? textColor,
    PaintingStyle? textPaintingStyle,
    double? textStrokeWidth,
  }) {
    super.updateTextProperty(
      textColor: textColor,
      textPaintingStyle: textPaintingStyle,
      textStrokeWidth: textStrokeWidth,
    );
    //debugger();
    charPainterList?.forEach((line) {
      for (final char in line) {
        //debugger();
        if (char is CharTextPainter) {
          BaseTextPainter.updateTextPainterProperty(
            char.charPainter,
            textColor: textColor,
            textStrokeWidth: textStrokeWidth,
            textStyle: textPaintingStyle,
          );
        } else if (char is CharPathPainter) {
          BaseTextPainter.updatePaintProperty(
            char.charPaint,
            textColor: textColor,
            //矢量文本画笔宽度恒为0
            textStrokeWidth: 0 /*textStrokeWidth*/,
            textStyle: textPaintingStyle,
          );
        }
      }
    });
  }

  /// 单字符自定义绘制初始化
  /// 初始化文本绘制对象
  @initialize
  @override
  void initPainter() {
    super.initPainter();
    final List<List<BaseCharPainter>> charPainterList = [];
    final charList = _splitText(text);
    //矢量文本画笔
    final vectorPaint = useVectorText ? createBasePaint() : null;
    vectorPaint?.strokeWidth = 0; //矢量文本画笔宽度恒为0

    //当出现空行时, 使用此对象的宽高占位
    String? placeholderChar;
    TextPainter? placeholderPainter;

    //MARK: 1. 初始化每一个char以及基础信息
    for (final line in charList) {
      List<BaseCharPainter> lineList = [];
      double lineBaseline = 0;
      //上升距离, 负值
      double? lineAscender;
      //下降距离, 正值
      double? lineDescender;
      if (line.isEmpty) {
        //空行
        placeholderChar ??= "中";
        placeholderPainter ??= createBaseTextPainter(placeholderChar);
        final charWidth = placeholderPainter.width + italicCharWidth;
        final charHeight = placeholderPainter.height;
        lineAscender ??= -charHeight;
        lineDescender ??= 0;
        lineBaseline = lineDescender - lineAscender;
        lineList.add(
          CharTextPainter(
            placeholderChar,
            null,
            charBounds: Rect.fromLTWH(
              0,
              lineAscender,
              charWidth,
              lineDescender,
            ),
          ),
        );
      } else {
        //有效数据行
        for (final char in line) {
          if (useVectorText) {
            //矢量文本
            if (char == " ") {
              //空字符
              final charWidth = fontSize / 4 + italicCharWidth;
              final charHeight = fontSize / 4;

              lineBaseline = max(lineBaseline, charHeight);
              lineAscender ??= -charHeight;
              lineDescender ??= 0;
              lineAscender = min(lineAscender, -charHeight);
              lineDescender = max(lineDescender, 0);

              lineList.add(
                CharPathPainter(
                  char,
                  kEmptyPath,
                  vectorPaint,
                  charBounds: Rect.fromLTWH(0, -charHeight, charWidth, 0),
                ),
              );
            } else {
              //正常矢量字符
              final charPath = vectorTextPathMap?[char];
              if (charPath != null) {
                //矢量字符
                //如果需要变换字符, 应该是在这里进行.
                @dp
                final pathBounds = charPath.getBounds();

                lineBaseline = max(lineBaseline, -pathBounds.top);
                final ascender = pathBounds.top;
                final descender = pathBounds.bottom;
                lineAscender ??= ascender;
                lineDescender ??= descender;
                lineAscender = min(lineAscender, ascender);
                lineDescender = max(lineDescender, descender);

                lineList.add(
                  CharPathPainter(
                    char,
                    charPath,
                    vectorPaint,
                    charBounds: pathBounds,
                  ),
                );
              } else {
                //字体不支持的矢量字符
                debugger();
              }
            }
          } else {
            //普通文本
            final charPainter = createBaseTextPainter(
              char,
              letterSpacing: 0,
              lineSpacing: 0,
            );
            //debugger();
            final lineMetrics = charPainter.computeLineMetrics().first;
            final charWidth = lineMetrics.width + italicCharWidth;
            final charHeight = lineMetrics.height;

            final ascent = -lineMetrics.ascent;
            final descent = lineMetrics.descent;
            lineBaseline = max(lineBaseline, -ascent);
            lineAscender ??= ascent;
            lineDescender ??= lineMetrics.descent;
            lineAscender = min(lineAscender, ascent);
            lineDescender = max(lineDescender, descent);

            final charBounds = Rect.fromLTWH(
              lineMetrics.left,
              ascent,
              charWidth,
              charHeight,
            );
            lineList.add(
              CharTextPainter(char, charPainter, charBounds: charBounds),
            );
          }
        }
      }
      //result
      if (lineList.isNotEmpty) {
        for (final char in lineList) {
          char
            ..debugPaintBounds = debugPaintBounds
            ..lineBaseline = lineBaseline
            ..lineAscender = lineAscender ?? 0
            ..lineDescender = lineDescender ?? 0;
        }
        charPainterList.add(lineList);
      }
    }

    //MARK: 2. 对齐lineBaseline, 计算charOriginBounds
    for (final line in charPainterList) {
      double? lineHeight;
      for (final char in line) {
        lineHeight ??= char.lineDescender - char.lineAscender;
        final charWidth = char.charBounds.width;
        final charHeight = char.charBounds.height;
        lineHeight = max(charHeight, lineHeight);

        //相对于这一行, 每个char需要偏移多少才对齐baseline
        final dy =
            ((orientation.isHorizontal && !orientationRotate) ||
                (orientation.isVertical && orientationRotate))
            ? char.lineBaseline + char.ascender
            : 0.0;
        char.charBaselineOffset = Offset(0, dy);
        char.charOriginBounds = Rect.fromLTWH(
          0,
          0,
          charWidth,
          ((orientation.isHorizontal && !orientationRotate) ||
                  (orientation.isVertical && orientationRotate))
              ? lineHeight
              : charHeight + dy,
        );
      }
    }

    //MARK: 3. 作用变换
    if (orientationRotate) {
      for (final line in charPainterList) {
        for (final char in line) {
          final matrix = createRotateMatrix(
            90.hd,
            /*anchorX: char.charBounds.width / 2,
            anchorY: char.charBounds.height / 2,*/
            /*anchor: char.charBounds.center,*/
            /*anchor: char.charOriginBounds.center,*/
          );
          //char.charBounds = matrix.mapRect(char.charBounds);
          char.charRotateMatrix = matrix
            ..postConcat(
              createTranslateMatrix(tx: char.charOriginBounds.height),
            );
        }
      }
    }

    //MARK: 4. 计算行边界, 行开始的偏移
    double lineStartLeft = 0;
    double lineStartTop = 0;
    double lineMaxWidth = 0; //最大行宽
    double lineMaxHeight = 0; //最大行高
    for (final line in charPainterList) {
      if (orientation.isVertical) {
        lineStartTop = 0;
      } else {
        lineStartLeft = 0;
      }
      double? lineWidth;
      double? lineHeight;
      //计算行尺寸
      for (final char in line) {
        //下一个字符
        final charOriginBoundsRotate = char.charOriginBoundsRotate;
        final charWidth = charOriginBoundsRotate.width;
        final charHeight = charOriginBoundsRotate.height;
        if (orientation.isVertical) {
          final w = charWidth;
          lineWidth ??= w;
          lineWidth = max(lineWidth, w);
          if (lineHeight == null) {
            lineHeight = charHeight;
          } else {
            lineHeight += (letterSpacing ?? 0) + charHeight;
          }
          lineHeight = max(lineHeight, charHeight); //防止间隙负值, 坍塌
        } else {
          final h = charHeight;
          if (lineWidth == null) {
            lineWidth ??= charWidth;
          } else {
            lineWidth += (letterSpacing ?? 0) + charWidth;
          }
          lineWidth = max(lineWidth, charWidth); //防止间隙负值, 坍塌
          lineHeight ??= h;
          lineHeight = max(lineHeight, h);
        }
      }
      //result 赋值行尺寸
      for (final char in line) {
        char.lineStartOffset = Offset(lineStartLeft, lineStartTop);
        char.lineWidth = lineWidth ?? 0;
        char.lineHeight = lineHeight ?? 0;
      }
      if (orientation.isVertical) {
        lineStartLeft += (lineSpacing ?? 0) + (lineWidth ?? 0);
        lineStartLeft = max(lineStartLeft, 0); //防止间隙负值, 坍塌
      } else {
        lineStartTop += (lineSpacing ?? 0) + (lineHeight ?? 0);
        lineStartTop = max(lineStartTop, 0); //防止间隙负值, 坍塌
      }
      lineMaxWidth = max(lineMaxWidth, lineWidth ?? 0);
      lineMaxHeight = max(lineMaxHeight, lineHeight ?? 0);
    }

    //MARK: 5. 计算对齐方式的偏移量
    for (final line in charPainterList) {
      double left = 0;
      double top = 0;
      for (final char in line) {
        final charOriginBoundsRotate = char.charOriginBoundsRotate;
        final charWidth = charOriginBoundsRotate.width;
        final charHeight = charOriginBoundsRotate.height;
        double dx = 0;
        double dy = 0;
        if (orientation.isVertical) {
          if (textAlign == TextAlign.center) {
            dy = (lineMaxHeight - char.lineHeight) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dy = lineMaxHeight - char.lineHeight;
          }
          if (crossTextAlign == TextAlign.center) {
            dx = (lineMaxWidth - charWidth) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dx = lineMaxWidth - charWidth;
          }
        } else {
          if (textAlign == TextAlign.center) {
            dx = (lineMaxWidth - char.lineWidth) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dx = lineMaxWidth - char.lineWidth;
            //debugger();
          }
          /*if (crossTextAlign == TextAlign.center) {
            dy += (lineMaxHeight - charHeight) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dy += lineMaxHeight - charHeight;
          }*/
        }
        char.alignOffset = Offset(left + dx, top + dy);
        //end char
        if (orientation.isVertical) {
          top += (letterSpacing ?? 0) + charHeight;
          top = max(top, 0); //防止间隙负值, 坍塌
        } else {
          left += (letterSpacing ?? 0) + charWidth;
          left = max(left, 0); //防止间隙负值, 坍塌
        }
      }
    }
    //result
    if (charPainterList.isEmpty) {
      _painterBounds = Rect.zero;
    } else {
      final last = charPainterList.last.last;
      final startOffset = last.lineStartOffset;
      final lineWidth = last.lineWidth;
      final lineHeight = last.lineHeight;
      _painterBounds = Rect.fromLTWH(
        0,
        0,
        startOffset.dx + lineWidth,
        startOffset.dy + lineHeight,
      );
    }
    this.charPainterList = charPainterList;
  }

  @override
  void painterText(Canvas canvas, Offset offset) {
    assert(() {
      if (debugPaintBounds) {
        canvas.drawRect(
          offset & painterBounds.size /*painterBounds*/,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.redAccent,
        );
      }
      return true;
    }());
    if (charPainterList == null) {
      initPainter();
    }
    if (charPainterList == null) {
      return;
    }

    //paint
    final anchor = _painterBounds.lt;
    canvas.withTranslate(-anchor.dx + offset.dx, -anchor.dy + offset.dy, () {
      for (final line in charPainterList!) {
        for (final char in line) {
          char.paint(canvas, Offset.zero);
        }
      }
    });
    //custom style
    if (!useVectorText && useCustomLineStyle && !isNil(charPainterList)) {
      painterCustomLineStyle(canvas, offset);
    }
  }

  /// 绘制自定义的线样式
  /// [painterText]
  @overridePoint
  void painterCustomLineStyle(Canvas canvas, Offset offset) {
    canvas.withTranslate(offset.dx, offset.dy, () {
      final paint = createBasePaint();
      double offsetLineTop = 0;
      for (final line in charPainterList!) {
        if (isUnderline || isLineThrough) {
          final first = line.firstOrNull;
          final last = line.lastOrNull;
          final left = first?.charBounds.left;
          final right = last?.charBounds.right;
          if (left != null && right != null) {
            if (isUnderline) {
              //绘制下划线
              final top =
                  offsetLineTop +
                  first!.lineHeight -
                  customLineStyleHeight -
                  underlineOffsetBottom;
              canvas.drawRect(
                Rect.fromLTWH(left, top, right, customLineStyleHeight),
                paint,
              );
            }
            if (isLineThrough) {
              //绘制删除线
              final top = offsetLineTop + first!.lineHeight / 2;
              canvas.drawRect(
                Rect.fromLTWH(left, top, right, customLineStyleHeight),
                paint,
              );
            }
            offsetLineTop += first!.lineHeight;
          }
        }
      }
    });
  }

  /// 使用[BaseCharPainter.outputPaintMatrix]作用下, 重新测量整体的边界
  /// [painterBounds]
  /// @return 返回中心位置的偏移量
  Offset _measureCharTextOutputBounds() {
    final list = charPainterList;
    if (list == null) {
      return .zero;
    }
    double left = 2147483648;
    double top = 2147483648;
    double right = -2147483648;
    double bottom = -2147483648;
    for (final line in list) {
      for (final char in line) {
        final bounds = char.outputPaintMatrix.mapRect(char.charBounds);
        //计算整体边界
        left = min(left, bounds.left);
        top = min(top, bounds.top);
        right = max(right, bounds.right);
        bottom = max(bottom, bounds.bottom);
      }
    }
    final oldCenter = painterBounds.center;
    _painterBounds = Rect.fromLTRB(left, top, right, bottom);
    final newCenter = _painterBounds.center;
    return newCenter - oldCenter;
  }
}

/// 曲线文本, 单字符绘制
/// [SingleCharTextPainter]
class SingleCurveCharTextPainter extends SingleCharTextPainter {
  //MARK: - config

  /// 曲线文本的半径, 支持正负数
  @configProperty
  double curveRadius = 0;

  /// 曲线位置
  /// - [Alignment.center] 元素整体的居中放置, 整体被圆上下平分切割 (文本放置在中间)
  /// - [Alignment.topCenter] 元素整体的顶部放置, 整体放在圆的内部 (文本放置在里面)
  /// - [Alignment.bottomCenter] 元素整体的底部放置, 整体放在圆的外部. (文本放置在外面) 默认效果
  @configProperty
  Alignment curvePlacementAlign = .center;

  /// 是否绘制曲线提示圆
  @configProperty
  bool paintCurveCircle = false;

  @configProperty
  Paint curveCirclePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.purpleAccent
  /*kNewElementTipColor*/;

  //MARK: - get

  /// 是否是反向的曲线
  bool get isReverseCurve => curveRadius < 0;

  /// 整体参考的曲线半径
  @tempFlag
  double refCurveRadius = 0;

  /// 曲线圆参考的中心点
  @output
  Offset refCurveCenter = .zero;

  //MARK: - temp

  /// 曲线文本初始化
  @override
  void initPainter() {
    super.initPainter();
    final charList = charPainterList;
    if (charList == null) {
      return;
    }

    // 整体参考的曲线半径
    refCurveRadius = curveRadius.abs();
    // 曲线圆中心参考的开始位置
    // - 横向就是Y值
    // - 纵向就是X值
    double curveCenterOffset = 0;

    // 曲线参考的开始位置
    if (orientation.isVertical) {
      double offset = isReverseCurve ? painterBounds.width : 0;
      switch (curvePlacementAlign) {
        case .topCenter:
          offset = isReverseCurve ? 0 : painterBounds.width;
          break;
        case .center:
          offset = painterBounds.width / 2;
          break;
        default:
          break;
      }
      curveCenterOffset = offset;
    } else {
      double offset = isReverseCurve ? 0 : painterBounds.height;
      switch (curvePlacementAlign) {
        case .topCenter:
          offset = isReverseCurve ? painterBounds.height : 0;
          break;
        case .center:
          offset = painterBounds.height / 2;
          break;
        default:
          break;
      }
      curveCenterOffset = offset;
    }
    // 曲线参考的中心位置
    refCurveCenter = orientation.isVertical
        ? (isReverseCurve
              ? Offset(
                  curveCenterOffset + refCurveRadius,
                  painterBounds.height / 2,
                )
              : Offset(
                  curveCenterOffset - refCurveRadius,
                  painterBounds.height / 2,
                ))
        : (isReverseCurve
              ? Offset(
                  painterBounds.width / 2,
                  curveCenterOffset - refCurveRadius,
                )
              : Offset(
                  painterBounds.width / 2,
                  curveCenterOffset + refCurveRadius,
                ));

    //MARK: 1. 计算出每一行的曲线半径, 以及每个字符对应的旋转弧度和总的弧度
    for (final line in charList) {
      //每一行都对应不同的曲线半径
      double lineSweepAngle = 0; //总共扫过的弧度
      double lineLastValue = 0; //用于计算lineSweepAngle
      for (final char in line) {
        final charOriginBoundsRotate = char.charOriginBoundsRotate;
        final charWidth = charOriginBoundsRotate.width;
        final charHeight = charOriginBoundsRotate.height;

        double lineCurveRadius = refCurveRadius;

        //每一行都使用不同的半径
        switch (curvePlacementAlign) {
          //文本放置在里面
          case .topCenter:
            if (orientation.isVertical) {
              lineCurveRadius += isReverseCurve
                  ? curveCenterOffset - char.lineLeft
                  : char.lineLeft - curveCenterOffset;
            } else {
              lineCurveRadius += isReverseCurve
                  ? char.lineBottom - curveCenterOffset
                  : curveCenterOffset - char.lineTop;
            }
            break;
          case .center:
            if (orientation.isVertical) {
              lineCurveRadius -= curveCenterOffset - char.lineCenterX;
            } else {
              lineCurveRadius -= curveCenterOffset - char.lineCenterY;
            }
            break;
          //文本放置在外面
          default:
            if (orientation.isVertical) {
              lineCurveRadius += isReverseCurve
                  ? curveCenterOffset - char.lineRight
                  : char.lineLeft - curveCenterOffset;
            } else {
              lineCurveRadius += isReverseCurve
                  ? char.lineTop - curveCenterOffset
                  : curveCenterOffset - char.lineBottom;
            }
            break;
        }
        //曲线半径
        char.lineCurveRadius = lineCurveRadius;
        if (orientation.isVertical) {
          //间隙也占弧度
          final charTop = char.chartOffsetBounds.top;
          char.charCurveGapAngle = _chordAngle(
            charTop - lineLastValue,
            lineCurveRadius,
          );
          lineLastValue = charTop + charHeight;
          //字符占的弧度
          char.charCurveAngle = _chordAngle(charHeight, lineCurveRadius);
        } else {
          //间隙也占弧度
          final charLeft = char.chartOffsetBounds.left;
          char.charCurveGapAngle = _chordAngle(
            charLeft - lineLastValue,
            lineCurveRadius,
          );
          lineLastValue = charLeft + charWidth;
          //字符占的弧度
          char.charCurveAngle = _chordAngle(charWidth, lineCurveRadius);
        }
        //字符的弧度
        lineSweepAngle += char.charCurveGapAngle! + char.charCurveAngle!;
      } //..end line
      //MARK: 2. 计算每个字符的旋转矩阵
      double startAngle = isReverseCurve
          ? lineSweepAngle / 2
          : -lineSweepAngle / 2; //行开始的弧度
      for (final char in line) {
        final radians = isReverseCurve
            ? startAngle - char.charCurveGapAngle! - char.charCurveAngle! / 2
            : startAngle + char.charCurveGapAngle! + char.charCurveAngle! / 2;
        char.charCurveMatrix = createTranslateMatrix(
          tx: orientation.isVertical
              ? 0
              : refCurveCenter.dx - char.chartOffsetBounds.cx,
          ty: orientation.isVertical
              ? refCurveCenter.dy - char.chartOffsetBounds.cy
              : 0,
        )..postConcat(createRotateMatrix(radians, anchor: refCurveCenter));
        /*assert(() {
          l.i(
            "字符[${(char as CharPathPainter).char}] "
            "间隙角度:${char.charCurveGapAngle?.jd} "
            "自身角度:${char.charCurveAngle?.jd} "
            "旋转角度:${radians.jd} "
            "tx:${refCurveCenter.dx - char.chartOffsetBounds.cx} ",
          );
          return true;
        }());*/
        if (isReverseCurve) {
          startAngle -= char.charCurveAngle! + char.charCurveGapAngle!;
        } else {
          startAngle += char.charCurveAngle! + char.charCurveGapAngle!;
        }
      }
    }
    //result, 宽高变化之后, 需要重新偏移中心点位置
    _measureCharTextOutputBounds();
    final offset = painterBounds.lt;
    refCurveCenter -= offset;
  }

  @override
  void painterText(Canvas canvas, Offset offset) {
    super.painterText(canvas, offset);
    assert(() {
      if (debugPaintBounds) {
        //--
        final charList = charPainterList;
        if (charList != null) {
          for (final line in charList) {
            for (final char in line) {
              canvas.drawCircle(
                refCurveCenter,
                char.lineCurveRadius ?? 0,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..color = Colors.blueAccent,
              );
              /*final rect = Rect.fromLTWH(
                refCurveCenter.dx - 10,
                0,
                20,
                refCurveCenter.dy - refCurveRadius,
              );
              canvas.drawRect(
                rect,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..color = Colors.greenAccent,
              );
              canvas.withMatrix(
                createRotateMatrix(-45.hd, anchor: refCurveCenter),
                () {
                  canvas.drawRect(
                    rect,
                    Paint()
                      ..style = PaintingStyle.stroke
                      ..color = Colors.greenAccent,
                  );
                },
              );*/
              break;
            }
          }
        }
      }
      return true;
    }());
    if (paintCurveCircle) {
      canvas.drawCircle(refCurveCenter, refCurveRadius, curveCirclePaint);
    }
  }

  @override
  void painterCustomLineStyle(Canvas canvas, Offset offset) {
    //绘制曲线上的删除线/下划线
    /*if (isUnderline || isLineThrough) {
      canvas.withTranslate(offset.dx, offset.dy, () {
        final paint = createBasePaint();
        double offsetLineBottom = 0;
        for (final line
            in (isReverseCurve
                ? charPainterList!
                : charPainterList!.reversed)) {
          final first = line.firstOrNull;
          final last = line.lastOrNull;

          final firstAngle = first?.charCurveStartAngle;
          final endAngle = last?.charCurveEndAngle;
          if (firstAngle != null && endAngle != null) {
            if (isUnderline) {
              //绘制下划线
              final path = Path()
                ..addFanShaped(
                  curveCenter,
                  curveRadius + underlineOffsetBottom + offsetLineBottom,
                  startAngle: firstAngle,
                  sweepAngle: endAngle - firstAngle,
                  size: customLineStyleHeight,
                );
              canvas.drawPath(path, paint);
            }
            if (isLineThrough) {
              //绘制删除线
              final path = Path()
                ..addFanShaped(
                  curveCenter,
                  curveRadius + offsetLineBottom + first!.lineHeight / 2,
                  startAngle: firstAngle,
                  sweepAngle: endAngle - firstAngle,
                  size: customLineStyleHeight,
                );
              canvas.drawPath(path, paint);
            }

            //offset
            offsetLineBottom += first!.lineHeight;
          }
        }
      });
    }*/
  }

  //MARK: - base

  /// 计算弦长在指定半径圆上对应的角度(弧度)
  double _chordAngle(double chordLength, double radius) {
    final angle = asin(chordLength / (2 * radius));
    if (angle.isNaN) {
      return 0;
    }
    return 2 * angle;
  }
}

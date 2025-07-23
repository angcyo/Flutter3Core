part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/11/18
///

/// 基础文本绘制
/// [NormalTextPainter]
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
  /// [TextAlign.justify] 矢量文本的极限对齐
  TextAlign textAlign = TextAlign.start;

  /// 交叉轴上文本对齐的方式
  /// [TextAlign.justify] 矢量文本的极限对齐
  TextAlign crossTextAlign = TextAlign.center;

  ///
  TextDirection? textDirection = TextDirection.ltr; //文本方向

  /// 行高倍数, 间接控制了行高
  /// 优先于[lineSpacing] 属性
  double? strutHeight;

  /// 强制行高
  bool forceStrutHeight = false;

  //--

  /// 是否使用矢量字符绘制
  bool useVectorText = false;

  /// 矢量字符对应的矢量路径, 适量文本的核心
  Map<String, Path?>? vectorTextPathMap;

  //endregion ---属性---

  /// 计算出来的绘制对象的边界
  /// [initPainter]
  Rect _painterBounds = Rect.zero;

  /// 当前绘制对象占用的大小
  /// 如果是曲线文本, left/top可能是负值
  @output
  Rect get painterBounds => Rect.zero;

  /// 包含了基线, 行高, 宽度
  @output
  UiLineMetrics? get lineMetrics => null;

  /// 必要的初始化方法
  @initialize
  @entryPoint
  void initPainter() {
    if (useVectorText) {
      scaleVectorCharPathToFontSize();
    }
  }

  /// 绘制文本, 相对于左上角0,0锚点绘制
  @api
  @overridePoint
  @entryPoint
  void painterText(Canvas canvas, Offset offset);

  //--

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
      List<List<BaseCharPainter>>? charPainterList) {
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
              final bounds = char.charPathBounds;
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

  /// 创建基础画笔, 用来绘制装饰线
  /// [Paint]
  Paint createBasePaint() => Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = textColor
    ..style = paintingStyle
    ..strokeWidth = isBold ? 1 : 0;

  /// 创建单字符的文本绘制对象
  /// [TextPainter]
  TextPainter createBaseTextPainter(String? text) {
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
      strutHeight: strutHeight ??
          (lineSpacing != null ? (1 + lineSpacing! / fontSize) : null),
      forceStrutHeight: forceStrutHeight,
    );
  }

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
        decorationStyle:
            isBold ? TextDecorationStyle.double : TextDecorationStyle.solid,
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
    _painterBounds = Offset.zero & _textPainter!.size;
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
  bool useCustomLineStyle = false;

  /// 自定义样式时的线高
  /// [useCustomLineStyle]
  double customLineStyleHeight = 6;

  /// 下划线底部的偏移距离
  double underlineOffsetBottom = 4;

  SingleCharTextPainter();

  //---

  @override
  Rect get painterBounds => _painterBounds;

  @override
  UiLineMetrics? get lineMetrics =>
      charPainterList?.firstOrNull?.firstOrNull?.lineMetrics;

  /// 斜体宽度补偿方案
  /// 是否使用整行补偿宽度的方案
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

  /// 测量总体的大小
  /// 最终缓存在[_painterBounds]中
  void _measureCharPainterSize() {
    final list = charPainterList;
    if (list == null || list.isEmpty) {
      _painterBounds = Rect.zero;
    } else {
      double width = -2147483648;
      double height = -2147483648;

      double left = 2147483648;
      double top = 2147483648;
      double right = -2147483648;
      double bottom = -2147483648;

      for (final line in list) {
        if (line.isEmpty) {
          continue;
        }
        final first = line.first.bounds;
        final last = line.last.bounds;

        double lineWidth = -2147483648;
        double lineHeight = -2147483648;
        double lineAscender = 0;
        double lineDescender = 0;

        if (orientation.isVertical) {
          height = max(height, last.bottom - first.top);

          for (final char in line) {
            left = min(left, char.bounds.left);
            right = max(right, char.bounds.right);

            lineWidth = max(lineWidth, char.bounds.width + italicLineWidth);
            lineHeight = last.bottom - first.top;
            lineAscender = min(char.ascender, lineAscender);
            lineDescender = max(char.descender, lineDescender);
          }
          width = right - left + italicLineWidth;

          //line 对齐
          for (final char in line) {
            char.lineWidth = lineWidth;
            char.lineHeight = lineHeight;
            char.lineAscender = lineAscender;
            char.lineDescender = lineDescender;
          }
        } else {
          //横向
          width = max(width, last.right - first.left + italicLineWidth);

          double lineHeight = -2147483648;
          for (final char in line) {
            top = min(top, char.bounds.top);
            bottom = max(bottom, char.bounds.bottom);

            lineWidth = last.right - first.left + italicLineWidth;
            lineHeight = max(lineHeight, char.bounds.height);
            lineAscender = min(char.ascender, lineAscender);
            lineDescender = max(char.descender, lineDescender);
            //debugger();
          }
          height = bottom - top;

          //line 对齐
          for (final char in line) {
            char.lineWidth = lineWidth;
            char.lineHeight = lineHeight;
            char.lineAscender = lineAscender;
            char.lineDescender = lineDescender;
          }
        }
      }
      _painterBounds = Offset.zero & Size(width, height);
      //debugger();
    }
  }

  /// 测量每个字符的对齐偏移
  /// [orientation]
  /// [textAlign]
  /// [crossTextAlign]
  void _measureCharPainterOffset() {
    final list = charPainterList;
    if (list == null || list.isEmpty) {
      return;
    }
    for (final line in list) {
      if (line.isEmpty) {
        continue;
      }
      for (final char in line) {
        double dx = 0;
        double dy = 0;

        if (orientation.isVertical) {
          //纵向
          if (crossTextAlign == TextAlign.center) {
            dx = (char.lineWidth - char.charWidth) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dx = char.lineWidth - char.charWidth;
          }

          if (textAlign == TextAlign.center) {
            dy = (painterBounds.height - char.lineHeight) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end ||
              textAlign == TextAlign.justify) {
            dy = painterBounds.height - char.lineHeight;
            if (crossTextAlign == TextAlign.justify) {
              dy -= char.lineDescender - char.descender;
            }
          }
        } else {
          //横向
          if (crossTextAlign == TextAlign.center) {
            dy = (char.lineHeight - char.charHeight) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end ||
              crossTextAlign == TextAlign.justify) {
            dy = char.lineHeight - char.charHeight;
            if (crossTextAlign == TextAlign.justify) {
              dy -= char.lineDescender - char.descender;
            }
          }

          if (textAlign == TextAlign.center) {
            dx = (painterBounds.width - char.lineWidth) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dx = painterBounds.width - char.lineWidth;
            //debugger();
          }
        }
        //l.d("${char.char} :${char.charDescent} :${char.charUnscaledAscent}");
        char.alignOffset = Offset(dx, dy);
      }
    }
  }

  @override
  TextPainter createBaseTextPainter(String? text) {
    final oldIsUnderline = isUnderline;
    final oldIsLineThrough = isLineThrough;

    if (useCustomLineStyle) {
      isUnderline = false;
      isLineThrough = false;
    }
    final painter = super.createBaseTextPainter(text);

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
            textStrokeWidth: textStrokeWidth,
            textStyle: textPaintingStyle,
          );
        }
      }
    });
  }

  /// 初始化文本绘制对象
  @initialize
  @override
  void initPainter() {
    super.initPainter();
    List<List<BaseCharPainter>> charPainterList = [];
    final list = _splitText(text);

    //每个字符左上角的位置
    double left = 0;
    double top = 0;

    //矢量文本画笔
    final vectorPaint = useVectorText ? createBasePaint() : null;
    vectorPaint?.strokeWidth = 0; //矢量文本画笔宽度恒为0

    //当出现空行时, 使用此对象的宽高占位
    const placeholderChar = "中";
    final placeholderPainter = createBaseTextPainter(placeholderChar);
    for (final line in list) {
      //每一行的开始
      List<BaseCharPainter> lineCharPainterList = [];
      if (orientation.isVertical) {
        top = 0;
      } else {
        left = 0;
      }

      //--
      double lineMaxWidth = 0;
      double lineMaxHeight = 0;

      if (line.isEmpty) {
        //空行
        final charWidth = placeholderPainter.width + italicCharWidth;
        final charHeight = placeholderPainter.height;
        lineCharPainterList.add(
          CharTextPainter(
            placeholderChar,
            null,
            Rect.fromLTWH(
              left,
              top,
              charWidth,
              charHeight,
            ),
          )..debugPaintBounds = debugPaintBounds,
        );
        lineMaxWidth = charWidth;
        lineMaxHeight = charHeight;
      } else {
        //有效数据行
        for (final char in line) {
          double charWidth = 0;
          double charHeight = 0;

          if (useVectorText) {
            //矢量文本
            if (char == " ") {
              //空字符
              charWidth = fontSize / 4 + italicCharWidth;
              charHeight = fontSize / 4;

              lineCharPainterList.add(
                CharPathPainter(
                  char,
                  kEmptyPath,
                  Rect.zero,
                  vectorPaint,
                  kEmptyPath,
                  Rect.fromLTWH(left, top, charWidth, charHeight),
                )..debugPaintBounds = debugPaintBounds,
              );
            } else {
              final charPath = vectorTextPathMap?[char];
              if (charPath != null) {
                @dp
                final charPathBounds = charPath.getBounds();
                charWidth = charPathBounds.width;
                charHeight = charPathBounds.height;

                lineCharPainterList.add(
                  CharPathPainter(
                    char,
                    charPath,
                    charPathBounds,
                    vectorPaint,
                    charPath.moveToZero(scaleAnchor: Offset.zero),
                    Rect.fromLTWH(left, top, charWidth, charHeight),
                  )..debugPaintBounds = debugPaintBounds,
                );
              }
            }
          } else {
            //普通文本
            final charPainter = createBaseTextPainter(char);
            //debugger();
            charWidth = charPainter.width + italicCharWidth;
            charHeight = charPainter.height;

            lineCharPainterList.add(
              CharTextPainter(
                char,
                charPainter,
                Rect.fromLTWH(left, top, charWidth, charHeight),
              )..debugPaintBounds = debugPaintBounds,
            );
          }

          lineMaxWidth = max(lineMaxWidth, charWidth);
          lineMaxHeight = max(lineMaxHeight, charHeight);

          //下一个字符
          if (orientation.isVertical) {
            top += (letterSpacing ?? 0) + charHeight;
          } else {
            left += (letterSpacing ?? 0) + charWidth;
          }
        }
      }

      //result
      if (lineCharPainterList.isNotEmpty) {
        charPainterList.add(lineCharPainterList);
      }

      //下一行
      if (orientation.isVertical) {
        left += (lineSpacing ?? 0) + lineMaxWidth;
      } else {
        top += (lineSpacing ?? 0) + lineMaxHeight;
      }
    }
    this.charPainterList = charPainterList;
    _measureCharPainterSize();
    _measureCharPainterOffset();
    //translateVectorCharPathToBaseline(charPainterList);
    //debugger();
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

    final anchor = _painterBounds.lt;
    canvas.withTranslate(-anchor.dx + offset.dx, -anchor.dy + offset.dy, () {
      for (final line in charPainterList!) {
        for (final char in line) {
          char.paint(canvas, Offset.zero);
        }
      }
    });
    if (!useVectorText && useCustomLineStyle && !isNil(charPainterList)) {
      painterCustomLine(canvas, offset);
    }
  }

  /// 绘制自定义的线样式
  /// [painterText]
  @overridePoint
  void painterCustomLine(Canvas canvas, Offset offset) {
    canvas.withTranslate(offset.dx, offset.dy, () {
      final paint = createBasePaint();
      double offsetLineTop = 0;
      for (final line in charPainterList!) {
        if (isUnderline || isLineThrough) {
          final first = line.firstOrNull;
          final last = line.lastOrNull;
          final left = first?.bounds.left;
          final right = last?.bounds.right;
          if (left != null && right != null) {
            if (isUnderline) {
              //绘制下划线
              final top = offsetLineTop +
                  first!.lineHeight -
                  customLineStyleHeight -
                  underlineOffsetBottom;
              canvas.drawRect(
                  Rect.fromLTWH(left, top, right, customLineStyleHeight),
                  paint);
            }
            if (isLineThrough) {
              //绘制删除线
              final top = offsetLineTop + first!.lineHeight / 2;
              canvas.drawRect(
                  Rect.fromLTWH(left, top, right, customLineStyleHeight),
                  paint);
            }
            offsetLineTop += first!.lineHeight;
          }
        }
      }
    });
  }
}

/// 曲线文本
/// [SingleCharTextPainter]
class SingleCurveCharTextPainter extends SingleCharTextPainter {
  /// 曲线文本曲率[-360°~360°]; 0表示正常文本
  double curvature = 0;

  /// 曲线的中心点坐标
  @output
  Offset curveCenter = Offset.zero;

  /// 曲线的半径
  @output
  double curveRadius = 0;

  /// 是否是反向的曲线
  bool get isReverseCurve => curvature < 0;

  /// 曲线的周长
  double get _curvePerimeter {
    final angle = curvature.abs() % 360;
    if (angle == 0) {
      return _painterBounds.width;
    }
    return _painterBounds.width / angle * 360;
  }

  /// 曲线文本的理论参考的中心点, 这个参考点不准确, 仅用于计算矩阵
  Offset get _curveRefCenter {
    //半径
    final bounds = _painterBounds;
    final radius = _curvePerimeter / (2 * pi);
    curveRadius = radius;
    if (isReverseCurve) {
      return Offset(bounds.width / 2, -radius);
    }
    return Offset(bounds.width / 2, bounds.height + radius);
  }

  /// 曲线的锚点角度, 一般是上90° 下-90°
  double get _curveAnchorAngle => isReverseCurve ? 90 : -90;

  /// 曲线开始的角度
  double get _curveStartAngle {
    final angle = curvature.abs().jdm;
    //debugger();
    return isReverseCurve
        ? min(270, _curveAnchorAngle + angle / 2)
        : max(-270, _curveAnchorAngle - angle / 2);
  }

  /// 测量每个字符绕着曲线中心点需要进行的曲线变换
  void _measureCharTextCurvature() {
    final list = charPainterList;
    if (list == null || curvature == 0 || isNil(list)) {
      return;
    }
    curveCenter = _curveRefCenter;

    final startAngle = _curveStartAngle;
    final painterWidth = _painterBounds.width;

    //l.d("参考宽度:${_size.width} 曲线直径:$_curvePerimeter 曲线中心:$_curveRefCenter 开始角度:$startAngle");

    double left = 2147483648;
    double top = 2147483648;
    double right = -2147483648;
    double bottom = -2147483648;

    //1px对应的角度值
    final factor = curvature.jdm / painterWidth;
    for (final line in list) {
      for (final char in line) {
        char.isInCurve = true;
        final bounds = char.bounds + char.alignOffset;
        final charAngle = startAngle + bounds.center.dx * factor;

        final offsetCx = bounds.width * 1 / 6;
        char.charCurveStartAngle =
            startAngle + (bounds.center.dx - offsetCx) * factor;
        char.charCurveEndAngle =
            startAngle + (bounds.center.dx + offsetCx) * factor;
        //debugger();

        //曲线文本时, bounds就是字符的大小
        //然后通过平移到锚点中心, 再旋转到目标位置
        char.bounds = Rect.fromLTWH(0, 0, bounds.width, bounds.height);

        //1: 先将元素移至锚点中心
        final translateMatrix = Matrix4.identity()
          ..translate(
            _curveRefCenter.dx - bounds.width / 2,
            bounds.top,
          );

        //2: 再旋转到目标位置
        final rotateAngle = charAngle - _curveAnchorAngle;
        final rotateMatrix = Matrix4.identity()
          ..rotateBy(rotateAngle.hd, anchor: _curveRefCenter);

        final Matrix4 matrix = rotateMatrix * translateMatrix;

        char.paintBounds = matrix.mapRect(char.bounds);
        char.paintMatrix = matrix;

        //计算整体边界
        left = min(left, char.paintBounds.left);
        top = min(top, char.paintBounds.top);
        right = max(right, char.paintBounds.right);
        bottom = max(bottom, char.paintBounds.bottom);
        //l.d("字符[${char.char}] 目标角度:$charAngle 旋转角度:$rotateAngle");
      }
    }
    _painterBounds = Rect.fromLTRB(left, top, right, bottom);

    //中心点移至锚点为0,0参考的曲线中心位置
    curveCenter = curveCenter - _painterBounds.lt;
  }

  @override
  void initPainter() {
    super.initPainter();
    _measureCharTextCurvature();
  }

  @override
  void painterCustomLine(Canvas canvas, Offset offset) {
    //绘制曲线上的删除线/下划线
    if (isUnderline || isLineThrough) {
      canvas.withTranslate(offset.dx, offset.dy, () {
        final paint = createBasePaint();
        double offsetLineBottom = 0;
        for (final line in (isReverseCurve
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
                ..addFanShaped(curveCenter,
                    curveRadius + underlineOffsetBottom + offsetLineBottom,
                    startAngle: firstAngle,
                    sweepAngle: endAngle - firstAngle,
                    size: customLineStyleHeight);
              canvas.drawPath(path, paint);
            }
            if (isLineThrough) {
              //绘制删除线
              final path = Path()
                ..addFanShaped(curveCenter,
                    curveRadius + offsetLineBottom + first!.lineHeight / 2,
                    startAngle: firstAngle,
                    sweepAngle: endAngle - firstAngle,
                    size: customLineStyleHeight);
              canvas.drawPath(path, paint);
            }

            //offset
            offsetLineBottom += first!.lineHeight;
          }
        }
      });
    }
  }
}

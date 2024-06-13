part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
/// 文本绘制元素对象
class TextElementPainter extends ElementPainter {
  /// 当前绘制的文本对象
  TextPainter? paintTextPainter;

  /// 获取绘制文本的字符串
  String? get text {
    final span = paintTextPainter?.text;
    if (span is TextSpan) {
      return span.text;
    }
    return null;
  }

  TextElementPainter() {
    debug = false;
  }

  void initFromText(String? text) {
    final textPainter = createTextPainter(text);
    final size = textPainter.size;
    paintProperty = PaintProperty()
      ..width = size.width
      ..height = size.height;
    paintTextPainter = textPainter;
  }

  /// [TextPainter]
  TextPainter createTextPainter(String? text) => TextPainter(
        textAlign: TextAlign.right,
        locale: platformLocale,
        text: TextSpan(
          text: text,
          style: TextStyle(
            /*color: paint.color,*/
            fontSize: 12,
            // 斜体
            fontStyle: FontStyle.italic,
            // 粗体, 字宽
            fontWeight: FontWeight.normal,
            // 下划线
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.redAccent /*paint.color*/,
            foreground: Paint()
              /*..strokeWidth = 1*/
              ..color = paint.color
              ..style = PaintingStyle.stroke,
            /*background: Paint()
              ..color = Colors.redAccent
              ..style = PaintingStyle.stroke,*/
          ),
        ),
        textDirection: TextDirection.ltr,
        textHeightBehavior: TextHeightBehavior(
            /*applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,*/
            ),
      )..layout();

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paintItTextPainter(canvas, paintMeta, paintTextPainter);
    super.onPaintingSelf(canvas, paintMeta);
  }

  void _testPaintingText(Canvas canvas, PaintMeta paintMeta) {
    //debugger();
    paint.color = Colors.black;
    text?.let((it) {
      final textPainter = createTextPainter(text);
      final size = textPainter.size;
      final metrics = textPainter.computeLineMetrics();
      final boxes = textPainter.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: it.length),
      );
      final textHeightBehavior = textPainter.textHeightBehavior;

      //debugger();

      final rect = Rect.fromLTWH(0, 0, 100, 100);

      final matrix = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
        );

      final matrix2 = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
          pivotX: 10,
          pivotY: 10,
        );

      /*final matrix2 = Matrix4.identity()
        ..translate(10.0, 10.0)  // 指定锚点为 (50, 50)
        ..scale(-1.0, 1.0, 1.0)
        ..translate(-10.0, -10.0);  // 将矩阵平移回原点*/

      final r2 = matrix.mapRect(rect);
      final r3 = matrix2.mapRect(rect);

      //debugger();

      final pp = paintProperty!;

      final ppRect = Rect.fromLTWH(0, 0, pp.width, pp.height);
      //final anchor = Offset.zero;
      final anchor = ppRect.center;

      final translation = Vector3(anchor.dx, anchor.dy, 0);

      final flipMatrix = Matrix4.identity()
        ..postFlip(
          flipX: true,
          flipY: false,
          anchor: anchor,
        );

      final skewMatrix = Matrix4.identity()
        /*..translate(translation)*/
        ..postConcat(Matrix4.skew(45.hd, 0)) /*..translate(-translation)*/;
      /*..skewBy(
          kx: 45.hd,
          ky: 0,
          anchor: anchor,
        );*/
      final scaleMatrix = Matrix4.identity()
        ..scaleBy(
          sx: 2,
          sy: 2,
          anchor: anchor,
        );

      final rotateMatrix = Matrix4.identity()
        ..rotateBy(
          30.hd,
          anchor: anchor,
        );

      final x = rotateMatrix.rotationX;
      final y = rotateMatrix.rotationY;
      final z = rotateMatrix.rotationZ;
      final r = rotateMatrix.rotation;

      //Quaternion.fromRotation(rotateMatrix.getRotation()).z;

      //debugger();

      final translateMatrix = Matrix4.identity()..translate(100.0, 100.0);

      /*canvas.withMatrix(
        translateMatrix   * rotateMatrix  *  scaleMatrix   *  skewMatrix
        */ /*pp.paintFlipMatrix*/ /*
        */ /*translateMatrix **/ /*
        */ /*rotateMatrix * scaleMatrix */ /*
        */ /** rotateMatrix*/ /* */ /* * flipMatrix * skewMatrix*/ /*,
        () {
          textPainter.paint(canvas, Offset.zero);
        },
      );*/

      // 真实的缩放矩阵
      final skewMatrix1 = Matrix4.skew(45.hd, 0);
      final skewMatrix12 = Matrix4.identity()
        ..translate(translation)
        ..postConcat(skewMatrix)
        ..translate(-translation);

      //debugger();

      canvas.withMatrix(
        pp.operateMatrix,
        () {
          textPainter.paint(canvas, Offset.zero);
        },
      );
    });
  }
}

/// 文本绘制混入
mixin TextPainterMixin {
  /// 当前绘制对象占用的大小
  Size get painterSize => Size.zero;

  /// 绘制文本
  @api
  @overridePoint
  void painterText(Canvas canvas) {}

  /// 通过给定的属性, 创建对应的[TextPainter]文本绘制对象
  /// [text]生成[InlineSpan]对象
  TextPainter createTextPainter({
    String? text,
    InlineSpan? textSpan,
    Color textColor = Colors.black,
    PaintingStyle paintingStyle = PaintingStyle.fill,
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
  }) {
    locale ??= platformLocale;
    if (textSpan == null) {
      final style = TextStyle(
        fontSize: fontSize,
        locale: locale,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: letterSpacing,
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
              leading: 0,
              leadingDistribution: TextLeadingDistribution.proportional,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            )
          : null,
    )..layout();
  }
}

/// 普通文本绘制
/// [TextPainter]
class NormalTextPainter with TextPainterMixin {
  /// 要绘制的文本
  String? text;

  /// 文本的颜色
  Color textColor;

  /// 文本的字体大小
  @dp
  double fontSize;

  /// 字间距
  @dp
  double letterSpacing;

  /// 行间距
  @dp
  double? lineSpacing;

  NormalTextPainter({
    this.text,
    this.textColor = Colors.black,
    this.fontSize = 14,
    this.letterSpacing = 0,
    this.lineSpacing,
  }) {
    initPainter();
  }

  Size _size = Size.zero;

  @override
  Size get painterSize => _size;

  TextPainter? _textPainter;

  /// 初始化文本绘制对象
  @initialize
  void initPainter() {
    _textPainter = createTextPainter(
      text: text,
      textColor: textColor,
      fontSize: fontSize,
      strutHeight: lineSpacing != null ? (1 + lineSpacing! / fontSize) : null,
    );
    _size = _textPainter!.size;
  }

  @override
  void painterText(Canvas canvas) {
    if (_textPainter == null) {
      initPainter();
    }
    _textPainter?.paint(canvas, Offset.zero);

    /*const text = "aGg jEh \najPgFf中赢";
    //const text = "a";
    //const text = "چاچی";
    final painter = createTextPainter(
      text: text,
      fontSize: 40,
      isBold: false,
      isItalic: true,
      isUnderline: true,
      isLineThrough: false,
    );
    final painter2 = createTextPainter(
      text: text,
      textAlign: TextAlign.end,
      fontSize: 40,
      isBold: false,
      isItalic: true,
      isUnderline: true,
      isLineThrough: false,
      strutHeight: 1.2,
      forceStrutHeight: true,
    );
    _size = painter.size;

    final boxList = painter.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: text.length));
    final metricsList = painter.computeLineMetrics();

    */ /*text.forEach((str){
      debugger();
    });*/ /*

    //debugger();

    canvas.drawRect(
      Offset.zero & painterSize,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.redAccent,
    );
    painter.paint(canvas, Offset.zero);

    canvas.drawRect(
      Offset(0, _size.height) & painter2.size,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.redAccent,
    );
    painter2.paint(canvas, Offset(0, _size.height));*/
  }
}

/// 单字符逐个绘制
/// [TextPainter]
/// [NormalTextPainter]
class SingleCharTextPainter with TextPainterMixin {
  /// 需要绘制的文本
  String? text;

  /// 绘制方向
  int orientation = kHorizontal;

  /// 文本的颜色
  Color textColor = Colors.black;

  /// 文本的样式
  PaintingStyle paintingStyle = PaintingStyle.fill;

  /// 文本的字体大小
  @dp
  double fontSize = 14;

  /// 字间距, 支持负数
  @dp
  double letterSpacing = 0;

  /// 行间距, 支持负数
  @dp
  double lineSpacing = 0;

  /// 粗体
  bool isBold = false;

  /// 斜体, 宽度计算无法包含斜体值, 需要额外增加一点宽度
  bool isItalic = false;

  /// 下划线
  bool isUnderline = false;

  /// 删除线
  bool isLineThrough = false;

  /// 对齐方式, 在多行文本时, 会影响每行的对齐方式
  TextAlign textAlign = TextAlign.start;

  /// 交叉轴上文本对齐的方式
  TextAlign crossTextAlign = TextAlign.center;

  ///
  TextDirection? textDirection = TextDirection.ltr; //文本方向

  /// 行高倍数, 间接控制了行高
  double? strutHeight;

  /// 强制行高
  bool forceStrutHeight = false;

  SingleCharTextPainter();

  //---

  Size _size = Size.zero;

  @override
  Size get painterSize => _size;

  /// 斜体宽度补偿方案
  /// 是否使用整行补偿宽度的方案
  bool italicWidthWithLine = true;

  /// 斜体补偿的单字符宽度
  /// 方案1: 每个字符都补偿
  double get italicCharWidth =>
      isItalic && !italicWidthWithLine ? fontSize * 0.2 : 0;

  /// 斜体补偿的整个行的宽度
  /// 方案2: 只在整行中补偿一次
  double get italicLineWidth =>
      isItalic && italicWidthWithLine ? fontSize * 0.2 : 0;

  /// 文本绘制对象, 每个字符一个对象
  List<List<CharTextPainter>>? _charPainterList;

  /// 将字符串按照换行符分解成一行行一个个的单字符
  List<List<String>> _splitText(String? text) {
    if (text == null) {
      return [];
    }
    final list = text.split('\n');
    return list.map((e) => e.split('')).toList();
  }

  /// 创建单字符的文本绘制对象
  TextPainter _createCharTextPainter(String char) {
    return createTextPainter(
      text: char,
      textColor: textColor,
      paintingStyle: paintingStyle,
      fontSize: fontSize,
      isBold: isBold,
      isItalic: isItalic,
      isUnderline: isUnderline,
      isLineThrough: isLineThrough,
      textDirection: textDirection,
      strutHeight: strutHeight,
      forceStrutHeight: forceStrutHeight,
    );
  }

  /// 测量总体的大小
  /// 最终缓存在[_size]中
  void _measureCharTextPainterSize() {
    final list = _charPainterList;
    if (list == null) {
      _size = Size.zero;
    } else {
      double width = -2147483648;
      double height = -2147483648;

      double left = 2147483648;
      double right = -2147483648;
      double top = 2147483648;
      double bottom = -2147483648;

      for (final line in list) {
        final first = line.first.bounds;
        final last = line.last.bounds;

        double lineWidth = -2147483648;
        double lineHeight = -2147483648;

        if (orientation.isVertical) {
          height = max(height, last.bottom - first.top);

          for (final char in line) {
            left = min(left, char.bounds.left);
            right = max(right, char.bounds.right);

            lineWidth = max(lineWidth, char.bounds.width + italicLineWidth);
            lineHeight = last.bottom - first.top;
          }
          width = right - left + italicLineWidth;

          //line 对齐
          for (final char in line) {
            char.lineWidth = lineWidth;
            char.lineHeight = lineHeight;
          }
        } else {
          width = max(width, last.right - first.left + italicLineWidth);

          double lineHeight = -2147483648;
          for (final char in line) {
            top = min(top, char.bounds.top);
            bottom = max(bottom, char.bounds.bottom);

            lineWidth = last.right - first.left + italicLineWidth;
            lineHeight = max(lineHeight, char.bounds.height);
          }
          height = bottom - top;

          //line 对齐
          for (final char in line) {
            char.lineWidth = lineWidth;
            char.lineHeight = lineHeight;
          }
        }
      }
      _size = Size(width, height);
      //debugger();
    }
  }

  /// 测量每个字符的对齐偏移
  /// [orientation]
  /// [textAlign]
  /// [crossTextAlign]
  void _measureCharTextPainterOffset() {
    final list = _charPainterList;
    if (list == null) {
      return;
    }
    for (final line in list) {
      for (final char in line) {
        double dx = 0;
        double dy = 0;

        if (orientation.isVertical) {
          if (crossTextAlign == TextAlign.center) {
            dx = (char.lineWidth - char.charWidth) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dx = char.lineWidth - char.charWidth;
          }

          if (textAlign == TextAlign.center) {
            dy = (painterSize.height - char.lineHeight) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dy = painterSize.height - char.lineHeight;
          }
        } else {
          if (crossTextAlign == TextAlign.center) {
            dy = (char.lineHeight - char.charHeight) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dy = char.lineHeight - char.charHeight;
          }

          if (textAlign == TextAlign.center) {
            dx = (painterSize.width - char.lineWidth) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dx = painterSize.width - char.lineWidth;
            //debugger();
          }
        }
        //l.d("${char.char} :${char.charDescent} :${char.charUnscaledAscent}");
        char.alignOffset = Offset(dx, dy);
      }
    }
  }

  /// 初始化文本绘制对象
  @initialize
  void initPainter() {
    List<List<CharTextPainter>> charPainterList = [];
    final list = _splitText(text);

    //每个字符左上角的位置
    double left = 0;
    double top = 0;

    //当出现空行时, 使用此对象的宽高占位
    const placeholderChar = "中";
    final placeholderPainter = _createCharTextPainter(placeholderChar);
    for (final line in list) {
      //每一行的开始
      List<CharTextPainter> lineCharPainterList = [];
      if (orientation.isVertical) {
        top = 0;
      } else {
        left = 0;
      }

      //--
      double lineMaxWidth = 0;
      double lineMaxHeight = 0;

      if (line.isEmpty) {
        final charWidth = placeholderPainter.width + italicCharWidth;
        final charHeight = placeholderPainter.height;
        lineCharPainterList.add(
          CharTextPainter(
            placeholderChar,
            Rect.fromLTWH(
              left,
              top,
              charWidth,
              charHeight,
            ),
            null,
          ),
        );
        lineMaxWidth = charWidth;
        lineMaxHeight = charHeight;
      } else {
        for (final char in line) {
          final charPainter = _createCharTextPainter(char);
          //debugger();
          final charWidth = charPainter.width + italicCharWidth;
          final charHeight = charPainter.height;

          lineMaxWidth = max(lineMaxWidth, charWidth);
          lineMaxHeight = max(lineMaxHeight, charHeight);

          lineCharPainterList.add(
            CharTextPainter(
              char,
              Rect.fromLTWH(left, top, charWidth, charHeight),
              charPainter,
            ),
          );

          //下一个字符
          if (orientation.isVertical) {
            top += letterSpacing + charHeight;
          } else {
            left += letterSpacing + charWidth;
          }
        }
      }

      //result
      charPainterList.add(lineCharPainterList);

      //下一行
      if (orientation.isVertical) {
        left += lineSpacing + lineMaxWidth;
      } else {
        top += lineSpacing + lineMaxHeight;
      }
    }
    _charPainterList = charPainterList;
    _measureCharTextPainterSize();
    _measureCharTextPainterOffset();
    //debugger();
  }

  @override
  void painterText(Canvas canvas) {
    assert(() {
      canvas.drawRect(
        Offset.zero & painterSize,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.redAccent,
      );
      return true;
    }());
    if (_charPainterList == null) {
      initPainter();
    }
    if (_charPainterList == null) {
      return;
    }
    for (final line in _charPainterList!) {
      for (final char in line) {
        char.paint(canvas, Offset.zero);
      }
    }
  }
}

/// 单字符逐个绘制
class CharTextPainter {
  /// 绘制的字符
  final String char;

  /// 绘制的区域
  final Rect bounds;

  /// 文本绘制对象
  final TextPainter? charPainter;

  /// 当前所在行的宽度, 用来实现对齐
  @autoInjectMark
  double lineWidth = 0;

  /// 当前所在行的高度, 用来实现对齐
  @autoInjectMark
  double lineHeight = 0;

  /// 对齐偏移
  @autoInjectMark
  Offset alignOffset = Offset.zero;

  double get charWidth => bounds.width;

  double get charHeight => bounds.height;

  /// 下降的高度
  double get charDescent {
    return charPainter?.computeLineMetrics().firstOrNull?.descent ?? 0;
  }

  double get charUnscaledAscent {
    return charPainter?.computeLineMetrics().firstOrNull?.unscaledAscent ?? 0;
  }

  CharTextPainter(this.char, this.bounds, this.charPainter);

  /// 绘制
  @api
  void paint(Canvas canvas, Offset offset) {
    assert(() {
      canvas.drawRect(
        bounds + offset + alignOffset,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.purpleAccent,
      );
      return true;
    }());
    /*canvas.save();
    canvas.translate(bounds.left, bounds.top);*/
    charPainter?.paint(canvas, offset + alignOffset + bounds.lt);
    /*canvas.restore();*/
  }
}

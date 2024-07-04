part of '../../flutter3_canvas.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/19
///
/// 文本绘制元素对象
class TextElementPainter extends ElementPainter {
  /// 当前绘制文本的对象
  BaseTextPainter? textPainter;

  TextElementPainter() {
    debug = false;
  }

  /// 使用一个文本初始化[textPainter]对象,
  /// 并确认[TextElementPainter]元素的大小, 位置默认是0,0
  @initialize
  void initElementFromText(
    String? text, {
    void Function(BaseTextPainter textPainter)? onInitTextPainter,
  }) {
    final textPainter = NormalTextPainter()
      ..debugPaintBounds = debug
      ..text = text;
    onInitTextPainter?.call(textPainter);
    textPainter.initPainter();
    this.textPainter = textPainter;
    final size = textPainter.painterBounds;
    paintProperty = PaintProperty()
      ..width = size.width
      ..height = size.height;
    //paintTextPainter = textPainter;
  }

  @override
  void onPaintingSelf(Canvas canvas, PaintMeta paintMeta) {
    paintItTextPainter(canvas, paintMeta, textPainter);
    super.onPaintingSelf(canvas, paintMeta);
  }
}

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
  TextAlign textAlign = TextAlign.start;

  ///
  TextDirection? textDirection = TextDirection.ltr; //文本方向

  /// 行高倍数, 间接控制了行高
  /// 优先于[lineSpacing] 属性
  double? strutHeight;

  /// 强制行高
  bool forceStrutHeight = false;

  //endregion ---属性---

  /// 计算出来的绘制对象的边界
  Rect _painterBounds = Rect.zero;

  /// 当前绘制对象占用的大小
  /// 如果是曲线文本, left/top可能是负值
  @output
  Rect get painterBounds => Rect.zero;

  /// 必要的初始化方法
  @initialize
  void initPainter() {}

  /// 绘制文本, 相对于左上角0,0锚点绘制
  @api
  @overridePoint
  void painterText(Canvas canvas, Offset offset);

  /// 创建画笔
  /// [Paint]
  Paint createBasePaint() => Paint()
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = textColor
    ..style = paintingStyle
    ..strokeWidth = isBold ? 1 : 0;

  /// 创建单字符的文本绘制对象
  TextPainter createBaseTextPainter(String? text) {
    return createTextPainter(
      text: text,
      fontFamily: fontFamily,
      textColor: textColor,
      textAlign: textAlign,
      paintingStyle: paintingStyle,
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

  /// 通过给定的属性, 创建对应的[TextPainter]文本绘制对象
  /// [text]生成[InlineSpan]对象
  static TextPainter createTextPainter({
    String? text,
    String? fontFamily,
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

/// 普通文本绘制
/// [TextPainter]
class NormalTextPainter extends BaseTextPainter {
  NormalTextPainter();

  @override
  Rect get painterBounds => _painterBounds;

  /// 普通文本使用[TextPainter]绘制
  TextPainter? _textPainter;

  /// 垂直绘制时, 需要进行的旋转矩阵
  @autoInjectMark
  Matrix4? paintMatrix;

  /// 初始化文本绘制对象
  @initialize
  @override
  void initPainter() {
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
  /// 交叉轴上文本对齐的方式
  TextAlign crossTextAlign = TextAlign.center;

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

  /// 测量总体的大小
  /// 最终缓存在[_painterBounds]中
  void _measureCharTextPainterSize() {
    final list = _charPainterList;
    if (list == null) {
      _painterBounds = Rect.zero;
    } else {
      double width = -2147483648;
      double height = -2147483648;

      double left = 2147483648;
      double top = 2147483648;
      double right = -2147483648;
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
      _painterBounds = Offset.zero & Size(width, height);
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
            dy = (painterBounds.height - char.lineHeight) / 2;
          } else if (textAlign == TextAlign.right ||
              textAlign == TextAlign.end) {
            dy = painterBounds.height - char.lineHeight;
          }
        } else {
          if (crossTextAlign == TextAlign.center) {
            dy = (char.lineHeight - char.charHeight) / 2;
          } else if (crossTextAlign == TextAlign.right ||
              crossTextAlign == TextAlign.end) {
            dy = char.lineHeight - char.charHeight;
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

  /// 初始化文本绘制对象
  @initialize
  @override
  void initPainter() {
    List<List<CharTextPainter>> charPainterList = [];
    final list = _splitText(text);

    //每个字符左上角的位置
    double left = 0;
    double top = 0;

    //当出现空行时, 使用此对象的宽高占位
    const placeholderChar = "中";
    final placeholderPainter = createBaseTextPainter(placeholderChar);
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
          )..debugPaintBounds = debugPaintBounds,
        );
        lineMaxWidth = charWidth;
        lineMaxHeight = charHeight;
      } else {
        for (final char in line) {
          final charPainter = createBaseTextPainter(char);
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
            )..debugPaintBounds = debugPaintBounds,
          );

          //下一个字符
          if (orientation.isVertical) {
            top += (letterSpacing ?? 0) + charHeight;
          } else {
            left += (letterSpacing ?? 0) + charWidth;
          }
        }
      }

      //result
      charPainterList.add(lineCharPainterList);

      //下一行
      if (orientation.isVertical) {
        left += (lineSpacing ?? 0) + lineMaxWidth;
      } else {
        top += (lineSpacing ?? 0) + lineMaxHeight;
      }
    }
    _charPainterList = charPainterList;
    _measureCharTextPainterSize();
    _measureCharTextPainterOffset();
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
    if (_charPainterList == null) {
      initPainter();
    }
    if (_charPainterList == null) {
      return;
    }

    final anchor = _painterBounds.lt;
    canvas.withTranslate(-anchor.dx + offset.dx, -anchor.dy + offset.dy, () {
      for (final line in _charPainterList!) {
        for (final char in line) {
          char.paint(canvas, Offset.zero);
        }
      }
    });
    if (useCustomLineStyle && !isNil(_charPainterList)) {
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
      for (final line in _charPainterList!) {
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

/// 单字符逐个绘制
class CharTextPainter {
  /// 调试模式下, 是否绘制文本的边界
  bool debugPaintBounds = false;

  /// 绘制的字符
  final String char;

  /// 文本绘制对象
  final TextPainter? charPainter;

  /// 绘制的区域, 不包含[alignOffset]
  @autoInjectMark
  Rect bounds = Rect.zero;

  /// 当前所在行的宽度, 用来实现对齐
  @autoInjectMark
  double lineWidth = 0;

  /// 当前所在行的高度, 用来实现对齐
  @autoInjectMark
  double lineHeight = 0;

  /// 对齐偏移
  @autoInjectMark
  Offset alignOffset = Offset.zero;

  /// 绘制矩阵, 通常用来实现文本的曲线绘制
  @autoInjectMark
  Matrix4? paintMatrix;

  /// [bounds]与[paintMatrix]的集合, 通常在曲线文本中使用
  @autoInjectMark
  Rect paintBounds = Rect.zero;

  /// 是否是绘制在曲线上
  /// 标识当前对象是在曲线文本上绘制
  @autoInjectMark
  @flagProperty
  bool isInCurve = false;

  /// 在曲线上左边线的角度
  @autoInjectMark
  @flagProperty
  double? charCurveStartAngle;

  /// 在曲线上右边线的角度
  @autoInjectMark
  @flagProperty
  double? charCurveEndAngle;

  double get charWidth => bounds.width;

  double get charHeight => bounds.height;

  /// 下降的高度
  @implementation
  double get charDescent {
    return charPainter?.computeLineMetrics().firstOrNull?.descent ?? 0;
  }

  @implementation
  double get charUnscaledAscent {
    return charPainter?.computeLineMetrics().firstOrNull?.unscaledAscent ?? 0;
  }

  CharTextPainter(this.char, this.bounds, this.charPainter);

  /// 绘制
  @api
  void paint(Canvas canvas, Offset offset) {
    canvas.withMatrix(paintMatrix, () {
      assert(() {
        if (debugPaintBounds) {
          final rect = isInCurve ? bounds : bounds + alignOffset;
          canvas.drawRect(
            rect + offset,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.purpleAccent,
          );
        }
        return true;
      }());
      if (isInCurve) {
        charPainter?.paint(canvas, offset);
      } else {
        charPainter?.paint(canvas, offset + alignOffset + bounds.lt);
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
    final list = _charPainterList;
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
            ? _charPainterList!
            : _charPainterList!.reversed)) {
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

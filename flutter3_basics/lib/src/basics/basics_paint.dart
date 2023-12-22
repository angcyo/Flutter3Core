part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/16
///

/// 自定义的绘制方法
/// [childRect] 当前元素的绘制区域
/// [parentRect] 父元素的绘制区域
typedef PainterFn = void Function(
    Canvas canvas, Rect childRect, Rect parentRect);

/// [CustomPaint]
/// [CustomPainter]
typedef PaintFn = void Function(Canvas canvas, Size size);

extension StringPaintEx on String {
  /// [TextSpanPaintEx.textSize]
  Size textSize({double? fontSize, TextStyle? style}) => TextSpan(
        text: this,
        style: style ?? TextStyle(fontSize: fontSize),
      ).textSize();

  /// [TextSpanPaintEx.textWidth]
  double textWidth({double? fontSize, TextStyle? style}) =>
      textSize(fontSize: fontSize, style: style).width;

  /// [TextSpanPaintEx.textSize]
  double textHeight({double? fontSize, TextStyle? style}) => textSize(
        fontSize: fontSize,
        style: style,
      ).height;
}

extension TextSpanPaintEx on InlineSpan {
  /// 获取文本的大小
  Size textSize() {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      text: this,
    );
    textPainter.layout();
    return textPainter.size;
  }

  /// 获取文本的宽度
  double textWidth() => textSize().width;

  /// 获取文本的高度
  double textHeight() => textSize().height;
}

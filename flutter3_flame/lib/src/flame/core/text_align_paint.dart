import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/11/10
///
/// 文本对齐绘制
/// - [TextPaint.defaultTextStyle]
class TextAlignPaint extends TextPaint {
  final TextAlign textAlign;

  TextAlignPaint({
    this.textAlign = .start,
    super.textDirection,
    //--
    TextStyle? style,
    Color? textColor,
    double? fontSize = 18,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? wordSpacing,
    List<Shadow>? shadows,
  }) : super(
         style: (style ?? TextPaint.defaultTextStyle).copyWith(
           color: textColor,
           fontSize: fontSize,
           fontWeight: fontWeight,
           letterSpacing: letterSpacing,
           wordSpacing: wordSpacing,
           shadows: shadows,
         ),
       );

  final MemoryCache<String, TextPainter> _textPainterCache = MemoryCache();

  @override
  TextPainter toTextPainter(String text) {
    //return super.toTextPainter(text);
    if (!_textPainterCache.containsKey(text)) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: textDirection,
        textAlign: textAlign,
      );
      tp.layout();
      _textPainterCache.setValue(text, tp);
    }
    return _textPainterCache.getValue(text)!;
  }

  /* @override
  TextPainterTextElement format(String text) {
    final element = super.format(text);
    element.textPainter.textAlign = textAlign;
    return element;
  }*/

  ///
  @override
  void render(
    Canvas canvas,
    String text,
    Vector2 position, {
    Anchor anchor = .topLeft,
  }) {
    super.render(canvas, text, position, anchor: anchor);
  }
}

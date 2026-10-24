import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/23
///
/// 文本组件
/// - [TextComponent]
class FlameTextComponent extends TextComponent {
  /// 文本样式
  final TextStyle? textStyle;

  /// 文本字体大小
  final double? fontSize;

  /// 文本颜色
  final Color? textColor;

  /// 构造函数
  FlameTextComponent({
    this.textStyle,
    this.fontSize,
    this.textColor,
    super.text,
    super.position,
    super.size,
    super.scale,
    super.angle,
  }) {
    _initTextPainter();
  }

  /// 更新文本绘制边界 / 样式
  @override
  void updateBounds() {
    _initTextPainter();
  }

  TextPainter? _textPainter;

  void _initTextPainter() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style:
            textStyle ??
            TextStyle(color: textColor ?? Colors.white, fontSize: fontSize),
      ),
      textDirection: .ltr,
    );
    _textPainter!.layout();
    size = _textPainter!.size.toVector2();
  }

  @override
  void render(Canvas canvas) {
    _textPainter?.paint(canvas, .zero);
  }
}

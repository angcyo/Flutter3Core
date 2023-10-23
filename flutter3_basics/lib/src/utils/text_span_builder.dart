import 'package:flutter/widgets.dart';

///
/// https://guoshuyu.cn/home/wx/Flutter-TWHP.html
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

class TextSpanBuilder {
  final List<InlineSpan> _textSpans = <InlineSpan>[];

  TextSpanBuilder addText(String text, {TextStyle? style}) {
    _textSpans.add(TextSpan(text: text, style: style));
    return this;
  }

  TextSpanBuilder addWidget(Widget widget) {
    _textSpans.add(WidgetSpan(child: widget) as TextSpan);
    return this;
  }

  TextSpanBuilder addTextSpan(TextSpan textSpan) {
    _textSpans.add(textSpan);
    return this;
  }

  TextSpanBuilder addTextSpans(List<TextSpan> textSpans) {
    _textSpans.addAll(textSpans);
    return this;
  }

  /// 构建
  Text build() {
    return Text.rich(TextSpan(children: _textSpans));
  }
}

/// 构建Text
Text textSpanBuilder(void Function(TextSpanBuilder builder) action) {
  TextSpanBuilder textSpanBuilder = TextSpanBuilder();
  action(textSpanBuilder);
  return textSpanBuilder.build();
}

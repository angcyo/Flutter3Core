part of flutter3_basics;

///
/// https://guoshuyu.cn/home/wx/Flutter-TWHP.html
///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/10/23
///

class TextSpanBuilder {
  final List<InlineSpan> _textSpans = <InlineSpan>[];

  /// 换行
  TextSpanBuilder newLine() {
    _textSpans.add(TextSpan(text: lineSeparator));
    return this;
  }

  /// 简单的添加一个文本样式的字符串
  /// [addTextSpan]
  /// [addTextSpans]
  /// [addTextStyle]
  TextSpanBuilder addText(String text, {TextStyle? style}) {
    _textSpans.add(TextSpan(
      text: text,
      style: style,
    ));
    return this;
  }

  TextSpanBuilder addTextStyle(
    String text, {
    Color? color,
    double? fontSize,
  }) {
    addText(text, style: TextStyle(color: color, fontSize: fontSize));
    return this;
  }

  TextSpanBuilder addTextColor(String text, Color color) {
    addTextStyle(text, color: color);
    return this;
  }

  TextSpanBuilder addTextBackgroundColor(String text, Color color) {
    _textSpans.add(TextSpan(
      text: text,
      style: TextStyle(backgroundColor: color),
    ));
    return this;
  }

  /// 添加一个[widget]可以是图片,也可以是点击事件的小部件等
  TextSpanBuilder addWidget(Widget widget) {
    _textSpans.add(WidgetSpan(child: widget));
    return this;
  }

  /// [addText]
  TextSpanBuilder addTextSpan(TextSpan textSpan) {
    _textSpans.add(textSpan);
    return this;
  }

  /// [addText]
  TextSpanBuilder addTextSpans(List<TextSpan> textSpans) {
    _textSpans.addAll(textSpans);
    return this;
  }

  /// 高级组合的方法
  /// [text]-[textStyle]文本
  /// [addText] - [addTextSpan] - [addTextSpans] - [addWidget]
  TextSpanBuilder $({
    String? text,
    TextStyle? textStyle,
    Widget? widget,
    TextSpan? textSpan,
    List<TextSpan>? textSpans,
  }) {
    if (text != null) {
      addText(text, style: textStyle);
    }
    if (widget != null) {
      addWidget(widget);
    }
    if (textSpan != null) {
      addTextSpan(textSpan);
    }
    if (textSpans != null) {
      addTextSpans(textSpans);
    }
    return this;
  }

  /// [InlineSpan]
  /// -> [TextSpan]
  /// -> [WidgetSpan]
  TextSpan buildTextSpan() => TextSpan(children: _textSpans);

  /// 构建
  Text build({
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) {
    return Text.rich(
      buildTextSpan(),
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

/// 构建[InlineSpan]
@dsl
TextSpan inlineSpanBuilder(void Function(TextSpanBuilder builder) action) {
  TextSpanBuilder textSpanBuilder = TextSpanBuilder();
  action(textSpanBuilder);
  return textSpanBuilder.buildTextSpan();
}

/// 构建[Text]
/// `class Text extends StatelessWidget`
@dsl
Text textSpanBuilder(
  void Function(TextSpanBuilder builder) action, {
  Key? key,
  TextStyle? style,
  StrutStyle? strutStyle,
  TextAlign? textAlign,
  TextDirection? textDirection,
  Locale? locale,
  bool? softWrap,
  TextOverflow? overflow,
  double? textScaleFactor,
  int? maxLines,
  String? semanticsLabel,
  TextWidthBasis? textWidthBasis,
  TextHeightBehavior? textHeightBehavior,
  Color? selectionColor,
}) {
  TextSpanBuilder textSpanBuilder = TextSpanBuilder();
  action(textSpanBuilder);
  return textSpanBuilder.build(
    key: key,
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaleFactor: textScaleFactor,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    selectionColor: selectionColor,
  );
}

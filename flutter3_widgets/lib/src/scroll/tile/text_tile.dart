part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 单文本显示tile
class TextTile extends StatelessWidget {
  /// 文本
  final String? text;
  final TextStyleType? textStyle;
  final Widget? textWidget;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  const TextTile({
    super.key,
    this.text,
    this.textStyle = TextStyleType.des,
    this.textWidget,
    this.padding = const EdgeInsets.only(
        left: kXh + kX, top: kL, right: kXh + kX, bottom: kL),
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    var result = textWidget ??
        Text(text ?? "",
            style: textStyle == TextStyleType.title
                ? globalTheme.textTitleStyle
                : textStyle == TextStyleType.subTitle
                    ? globalTheme.textSubTitleStyle
                    : textStyle == TextStyleType.des
                        ? globalTheme.textDesStyle
                        : textStyle == TextStyleType.body
                            ? globalTheme.textBodyStyle
                            : textStyle == TextStyleType.sub
                                ? globalTheme.textSubStyle
                                : textStyle == TextStyleType.label
                                    ? globalTheme.textLabelStyle
                                    : textStyle == TextStyleType.info
                                        ? globalTheme.textInfoStyle
                                        : null);
    if (padding != null) {
      result = Padding(
        padding: padding!,
        child: result,
      );
    }
    return result;
  }
}

enum TextStyleType {
  /// 标题
  title,

  /// 副标题
  subTitle,

  /// 标签
  label,

  /// 信息
  info,

  /// 描述
  des,

  /// 子描述
  sub,

  /// 内容
  body,
}

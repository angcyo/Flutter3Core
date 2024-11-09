part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/21
///
/// 单文本[text]显示的tile
class TextTile extends StatelessWidget {
  /// 文本
  final String? text;
  final TextStyle? textStyle;
  final TextStyleType? textStyleType;
  final Widget? textWidget;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 简单的文本显示
  const TextTile({
    super.key,
    this.text,
    this.textStyle,
    this.textStyleType = TextStyleType.body,
    this.textWidget,
    this.padding = const EdgeInsets.symmetric(
      horizontal: kX,
      vertical: kH,
    ),
  });

  /// 副文本, 内边距更大
  const TextTile.subText({
    super.key,
    this.text,
    this.textStyle,
    this.textStyleType = TextStyleType.des,
    this.textWidget,
    this.padding = const EdgeInsets.only(
      left: kXh + kX,
      top: kL,
      right: kXh + kX,
      bottom: kL,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    var result = textWidget ??
        Text(text ?? "",
            style: textStyle ??
                (textStyleType == TextStyleType.title
                    ? globalTheme.textTitleStyle
                    : textStyleType == TextStyleType.subTitle
                        ? globalTheme.textSubTitleStyle
                        : textStyleType == TextStyleType.des
                            ? globalTheme.textDesStyle
                            : textStyleType == TextStyleType.body
                                ? globalTheme.textBodyStyle
                                : textStyleType == TextStyleType.sub
                                    ? globalTheme.textSubStyle
                                    : textStyleType == TextStyleType.label
                                        ? globalTheme.textLabelStyle
                                        : textStyleType == TextStyleType.info
                                            ? globalTheme.textInfoStyle
                                            : null));
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

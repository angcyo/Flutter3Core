part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/22
///

extension RichReadMoreEx on String {
  /// 有个问题: 显示全部 会被切行
  Widget toRichReadMore({
    int? trimLines = 2,
    int? trimLength,
    String trimCollapsedText = '...显示全部',
    String trimExpandedText = ' 收起',
    TextStyle? textStyle,
    BuildContext? context,
    TextStyle? moreStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    TextStyle? lessStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    ),
  }) =>
      RichReadMoreText(
        toTextSpan(style: textStyle),
        settings: trimLines != null
            ? LineModeSettings(
                trimLines: trimLines,
                trimExpandedText: trimExpandedText,
                trimCollapsedText: trimCollapsedText,
                moreStyle: moreStyle,
                lessStyle: lessStyle,
                textScaler: TextScaler.noScaling,
              )
            : LengthModeSettings(
                trimLength: trimLength!,
                trimExpandedText: trimExpandedText,
                trimCollapsedText: trimCollapsedText,
                moreStyle: moreStyle,
                lessStyle: lessStyle,
                textScaler: TextScaler.noScaling,
              ),
      );
}

extension PubWidgetEx on Widget {}

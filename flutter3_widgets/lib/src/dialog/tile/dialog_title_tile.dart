part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/23
///
/// 对话框的标题布局tile
///  [leading]...[title]...[trailing]
///  [line]
///
/// [CoreDialogTitle] 带控制
class DialogTitleTile extends StatelessWidget with TileMixin {
  ///
  final Widget? leading;
  final Widget? trailing;

  ///
  final bool enableLeading;
  final bool enableTrailing;

  ///
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleTextStyle;

  final String? subTitle;
  final Widget? subTitleWidget;
  final TextStyle? subTitleTextStyle;

  ///
  final bool enableLine;
  final Widget? line;

  const DialogTitleTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subTitle,
    this.subTitleWidget,
    this.leading,
    this.trailing,
    this.enableLeading = true,
    this.enableTrailing = true,
    this.line,
    this.enableLine = true,
    this.titleTextStyle,
    this.subTitleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final titleWidget = buildTextWidget(
      context,
      text: title ?? "",
      textAlign: TextAlign.center,
      textWidget: this.titleWidget,
      textStyle: titleTextStyle ??
          globalTheme.textTitleStyle.copyWith(fontWeight: FontWeight.bold),
    );
    final subTitleWidget = buildTextWidget(
      context,
      text: subTitle,
      textWidget: this.subTitleWidget,
      textStyle: subTitleTextStyle ?? globalTheme.textDesStyle,
    );
    final titleColumn = [
      titleWidget,
      subTitleWidget,
    ].column(crossAxisAlignment: CrossAxisAlignment.center);

    return [
      leading?.colorFiltered(
          color: enableLeading ? null : globalTheme.disableColor),
      titleColumn?.expanded(),
      trailing?.colorFiltered(
          color: enableTrailing ? null : globalTheme.disableColor),
    ]
        .row()!
        .constrainedMin(minHeight: kTitleHeight)
        .columnOf(enableLine ? (line ?? horizontalLine(context)) : null);
  }
}

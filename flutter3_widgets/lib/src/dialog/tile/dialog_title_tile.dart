part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/23
///
/// 对话框的标题布局tile
///  [leading]...[title]...[trailing]
///  [bottomLine]
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
  final bool enableTopLine;
  final Widget? topLine;

  ///
  final bool enableBottomLine;
  final Widget? bottomLine;

  /// 填充内边距
  final EdgeInsetsGeometry? padding;

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
    this.bottomLine,
    this.enableBottomLine = true,
    this.enableTopLine = false,
    this.topLine,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.padding,
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

    final body = [
      leading?.colorFiltered(
          color: enableLeading ? null : globalTheme.disableColor),
      titleColumn?.expanded(),
      trailing?.colorFiltered(
          color: enableTrailing ? null : globalTheme.disableColor),
    ].row()!.constrainedMin(minHeight: kTitleHeight).paddingInsets(padding);
    if (enableTopLine != true && enableBottomLine != true) {
      return body;
    }
    return [
      if (enableTopLine) topLine ?? horizontalLine(context),
      body,
      if (enableBottomLine) bottomLine ?? horizontalLine(context),
    ].column()!;
  }
}

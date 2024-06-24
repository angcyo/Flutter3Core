part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 对话框标题
///
/// [DialogTitleTile] 布局
class CoreDialogTitle extends StatelessWidget {
  ///
  final Widget? leading;
  final bool enableLeading;
  final bool showLeading;
  final bool invisibleLeading;
  final String? leadingSvgIconKey;

  ///
  final Widget? trailing;
  final bool enableTrailing;
  final bool showTrailing;
  final bool invisibleTrailing;
  final String? trailingSvgIconKey;

  ///
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleTextStyle;

  final String? subTitle;
  final Widget? subTitleWidget;
  final TextStyle? subTitleTextStyle;

  /// 点击取消后的回调
  final ClickAction? onLeadingTap;

  /// 点击确认后的返回值
  final ClickAction? onTrailingTap;

  /// 拦截返回值
  final ResultCallback? onPop;

  //--

  /// 是否显示分割线
  final bool enableLine;
  final Widget? line;

  const CoreDialogTitle({
    super.key,
    this.title,
    this.titleWidget,
    this.subTitle,
    this.subTitleWidget,
    this.leading,
    this.leadingSvgIconKey,
    this.trailing,
    this.trailingSvgIconKey,
    this.enableLeading = true,
    this.showLeading = true,
    this.invisibleLeading = false,
    this.enableTrailing = true,
    this.showTrailing = true,
    this.invisibleTrailing = false,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.onLeadingTap,
    this.onTrailingTap,
    this.onPop,
    this.enableLine = true,
    this.line,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final leading = !showLeading
        ? null
        : this.leading ??
            InkButton(
              loadCoreAssetSvgPicture(
                leadingSvgIconKey ?? Assets.svg.coreBack,
                tintColor: context.isThemeDark
                    ? globalTheme.textTitleStyle.color
                    : null,
              ),
              enable: enableLeading,
              onTap: () {
                if (onLeadingTap == null) {
                  context.pop();
                } else {
                  onLeadingTap?.call(context);
                }
              },
            );

    final trailing = !showTrailing
        ? null
        : this.trailing ??
            InkButton(
              loadCoreAssetSvgPicture(
                trailingSvgIconKey ?? Assets.svg.coreConfirm,
                tintColor: context.isThemeDark
                    ? globalTheme.textTitleStyle.color
                    : null,
              ),
              enable: enableTrailing,
              onTap: () {
                if (onTrailingTap == null) {
                  context.pop(onPop == null ? true : onPop?.call());
                } else {
                  onTrailingTap?.call(context);
                }
              },
            );

    return DialogTitleTile(
      leading: leading?.invisible(invisible: invisibleLeading),
      trailing: trailing?.invisible(invisible: invisibleTrailing),
      title: title,
      titleWidget: titleWidget,
      titleTextStyle: titleTextStyle,
      subTitle: subTitle,
      subTitleWidget: subTitleWidget,
      subTitleTextStyle: subTitleTextStyle,
      enableLine: enableLine,
      line: line,
    );
  }
}

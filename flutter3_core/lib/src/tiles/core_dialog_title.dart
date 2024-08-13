part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 对话框标题
/// [back.icon]..[title]..[confirm.icon]
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

  ///
  final EdgeInsetsGeometry? padding;

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
    this.padding,
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
      enableBottomLine: enableLine,
      bottomLine: line,
      padding: padding,
    );
  }
}

/// 对话框显示在底部的标题
/// Decoration[close.icon]..[title]..Decoration[confirm.icon]
///
/// [DialogTitleTile] 布局
class CoreDialogBottomTitle extends StatelessWidget {
  /// 领头的配置
  final Widget? leading;
  final bool enableLeading;
  final bool showLeading;
  final bool invisibleLeading;
  final String? leadingSvgIconKey;

  /// 尾部的配置
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

  /// 显示[leading].[trailing]按钮的背景装饰?
  final bool showDecoration;

  /// 装饰
  final Decoration? decoration;

  /// 是否显示分割线
  final bool enableLine;
  final Widget? line;

  ///
  final EdgeInsetsGeometry? padding;

  const CoreDialogBottomTitle({
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
    this.enableLine = false,
    this.line,
    this.showDecoration = true,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: kX),
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    const decorationButtonPadding =
        EdgeInsets.symmetric(horizontal: kX, vertical: kM);
    const buttonPadding = EdgeInsets.symmetric(horizontal: kX, vertical: kH);
    final fillDecorationColor = globalTheme.itemWhiteBgColor;
    Widget? leading = !showLeading
        ? null
        : this.leading ??
            InkButton(
              loadCoreAssetSvgPicture(
                leadingSvgIconKey ?? Assets.svg.coreClose,
                tintColor: context.isThemeDark
                    ? globalTheme.textTitleStyle.color
                    : null,
              ),
              enable: enableLeading,
              splashColor: showDecoration ? fillDecorationColor : null,
              minWidth: showDecoration ? null : kInteractiveHeight,
              minHeight: showDecoration ? null : kInteractiveHeight,
              padding: showDecoration ? decorationButtonPadding : buttonPadding,
              onTap: () {
                if (onLeadingTap == null) {
                  context.maybePop();
                } else {
                  onLeadingTap?.call(context);
                }
              },
            );

    Widget? trailing = !showTrailing
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
              splashColor: showDecoration ? fillDecorationColor : null,
              minWidth: showDecoration ? null : kInteractiveHeight,
              minHeight: showDecoration ? null : kInteractiveHeight,
              padding: showDecoration ? decorationButtonPadding : buttonPadding,
              onTap: () {
                if (onTrailingTap == null) {
                  context.maybePop(onPop == null ? true : onPop?.call());
                } else {
                  onTrailingTap?.call(context);
                }
              },
            );

    if (showDecoration) {
      final decoration = this.decoration ??
          fillDecoration(
            color: fillDecorationColor,
            borderRadius: kDefaultBorderRadiusX,
          );
      leading = leading?.backgroundDecoration(decoration);
      trailing = trailing?.backgroundDecoration(decoration);
    }

    return DialogTitleTile(
      leading: leading?.invisible(invisible: invisibleLeading),
      trailing: trailing?.invisible(invisible: invisibleTrailing),
      title: title,
      titleWidget: titleWidget,
      titleTextStyle: titleTextStyle,
      subTitle: subTitle,
      subTitleWidget: subTitleWidget,
      subTitleTextStyle: subTitleTextStyle,
      enableBottomLine: false,
      enableTopLine: enableLine,
      topLine: line,
      padding: padding,
    );
  }
}

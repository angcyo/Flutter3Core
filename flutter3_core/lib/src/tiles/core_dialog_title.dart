part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 对话框标题
class CoreDialogTitle extends StatelessWidget {
  ///
  final Widget? leading;
  final bool enableLeading;

  ///
  final Widget? trailing;
  final bool enableTrailing;

  ///
  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleTextStyle;

  final String? subTitle;
  final Widget? subTitleWidget;
  final TextStyle? subTitleTextStyle;

  /// 点击确认后的返回值
  final ResultCallback? onPop;

  const CoreDialogTitle({
    super.key,
    this.title,
    this.titleWidget,
    this.subTitle,
    this.subTitleWidget,
    this.leading,
    this.trailing,
    this.enableLeading = true,
    this.enableTrailing = true,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    final leading = this.leading ??
        InkButton(
          loadCoreAssetSvgPicture(Assets.svg.coreBack),
          enable: enableLeading,
          onTap: () {
            context.pop();
          },
        );

    final trailing = this.trailing ??
        InkButton(
          loadCoreAssetSvgPicture(Assets.svg.coreConfirm),
          enable: enableTrailing,
          onTap: () {
            context.pop(onPop == null ? true : onPop?.call());
          },
        );

    return DialogTitleTile(
      leading: leading,
      trailing: trailing,
      title: title,
      titleWidget: titleWidget,
      titleTextStyle: titleTextStyle,
      subTitle: subTitle,
      subTitleWidget: subTitleWidget,
      subTitleTextStyle: subTitleTextStyle,
    );
  }
}

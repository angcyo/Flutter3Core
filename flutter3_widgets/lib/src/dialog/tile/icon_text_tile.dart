part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/21
///
/// 左[icon],接着[text]的tile
/// 或
/// 上[icon],接着[text]的tile
class IconTextTile extends StatelessWidget with TileMixin {
  /// 布局方向
  final Axis direction;

  //---

  /// 直接指定icon小部件
  final Widget? iconWidget;

  /// 通过icon, 自动创建一个[Widget]
  final IconData? icon;

  /// 文本的内边距
  final EdgeInsets? iconPadding;

  //---

  /// 直接指定text小部件
  final Widget? textWidget;

  /// 通过文本, 自动创建一个[Widget]
  final String? text;

  /// 文本的内边距
  final EdgeInsets? textPadding;

  //---

  /// 右边的小部件, 只在[Axis.horizontal]时有效
  final Widget? rightWidget;

  /// 所有小组件需要的着色
  final Color? tintColor;

  /// 禁用时的着色
  final Color? disableTintColor;

  /// 是否激活
  final bool enable;

  /// 是否激活点击
  final bool enableTap;

  /// 点击事件
  final GestureTapCallback? onTap;

  const IconTextTile({
    super.key,
    this.iconWidget,
    this.textWidget,
    this.icon,
    this.text,
    this.iconPadding,
    this.textPadding,
    this.tintColor,
    this.disableTintColor,
    this.rightWidget,
    this.enable = true,
    this.direction = Axis.horizontal,
    this.enableTap = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final disableTintColor = this.disableTintColor ?? globalTheme.disableColor;
    const gap = kX;
    const padding = EdgeInsets.symmetric(vertical: gap / 2, horizontal: gap);
    final iconWidget = buildIconWidget(
      context,
      iconWidget: this.iconWidget,
      icon: icon,
      padding: iconPadding,
    );
    final textWidget = buildTextWidget(
      context,
      textWidget: this.textWidget,
      text: text,
      padding: textPadding,
    );

    Widget result;
    if (direction == Axis.vertical) {
      result = [iconWidget, textWidget].column(gap: gap)!;
    } else {
      result = [
        iconWidget,
        textWidget?.expanded(enable: iconWidget != null || rightWidget != null),
        rightWidget
      ].row(gap: gap)!;
    }

    result = result
        .colorFiltered(color: enable ? tintColor : disableTintColor)
        .paddingInsets(padding)
        .constrainedMin(minHeight: kMinItemInteractiveHeight)
        .ink(onTap: enable && enableTap ? onTap : null)
        .material();

    return result;
  }
}

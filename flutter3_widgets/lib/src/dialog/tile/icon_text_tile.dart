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

  /// 直接指定icon小部件
  final Widget? iconWidget;

  /// 通过icon, 自动创建一个[Widget]
  final IconData? icon;

  /// 文本的内边距
  final EdgeInsets? iconPadding;

  /// 直接指定text小部件
  final Widget? textWidget;

  /// 通过文本, 自动创建一个[Widget]
  final String? text;

  /// 文本的内边距
  final EdgeInsets? textPadding;

  const IconTextTile({
    super.key,
    this.iconWidget,
    this.textWidget,
    this.icon,
    this.text,
    this.iconPadding,
    this.textPadding,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    const gap = kX;
    const padding = EdgeInsets.symmetric(vertical: gap, horizontal: gap);
    final iconWidget = buildIconWidget(
      context,
      this.iconWidget,
      icon: icon,
      padding: iconPadding,
    );
    final textWidget = buildTextWidget(
      context,
      this.textWidget,
      text: text,
      padding: textPadding,
    );

    Widget result;
    if (direction == Axis.vertical) {
      result = [iconWidget, textWidget].column(gap: gap)!;
    } else {
      result = [iconWidget, textWidget?.expanded()].row(gap: gap)!;
    }

    result = result.paddingInsets(padding).ink(
      onTap: () {
        toastInfo("...");
      },
    ).material();

    return result;
  }
}

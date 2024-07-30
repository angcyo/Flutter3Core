part of '../dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// 底部菜单tile
/// [BottomMenuItemsDialog]
class BottomMenuItemTile extends StatelessWidget {
  /// children
  final WidgetNullList children;

  /// 背景色, 不指定使用默认
  final Color? backgroundColor;

  /// 是否可用
  final bool enable;

  /// 禁用时的背景色, 不指定使用默认
  /// 可用, 则使用原色
  final Color? disableColor;

  /// 点击事件
  final GestureTapCallback? onTap;

  /// 点击后, 关闭对话框
  final bool closeAfterTap;

  const BottomMenuItemTile(
    this.children, {
    super.key,
    this.onTap,
    this.enable = true,
    this.closeAfterTap = true,
    this.backgroundColor,
    this.disableColor,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return children
        .row(gap: kH, mainAxisAlignment: MainAxisAlignment.center)!
        .colorFiltered(
            color: enable ? null : disableColor ?? globalTheme.disableColor)
        .paddingAll(kX)
        .constrainedMin(minHeight: kMinInteractiveDimension)
        .ink(
      () {
        if (closeAfterTap) {
          context.pop();
        }
        onTap?.call();
      },
      enable: enable,
    ).material(color: backgroundColor ?? globalTheme.surfaceBgColor);
  }
}

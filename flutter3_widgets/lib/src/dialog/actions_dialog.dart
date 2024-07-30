part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/03
///
/// 提供一些动作的对话框
/// [item]
/// [item]
/// [item]
///
/// [BottomMenuItemsDialog]
class ActionsDialog extends StatelessWidget with DialogMixin {
  /// 动作列表
  final WidgetNullList actions;

  /// 点击后, 关闭对话框
  @implementation
  final bool closeAfterTap;

  /// 上半部的圆角
  final double? clipTopRadius;

  const ActionsDialog(
    this.actions, {
    super.key,
    this.closeAfterTap = false,
    this.clipTopRadius = kDefaultBorderRadiusXX,
  });

  @override
  Widget build(BuildContext context) {
    return buildBottomChildrenDialog(
      context,
      actions,
      clipTopRadius: clipTopRadius,
    );
  }
}

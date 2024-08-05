part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// ```
/// [item]
/// [item]
/// [item]
///
/// [cancel]
/// ```
/// [BottomMenuItemTile]
///
/// [ActionsDialog]
class BottomMenuItemsDialog extends StatelessWidget with DialogMixin {
  /// 菜单列表
  final WidgetNullList items;

  /// 圆角
  final double? clipRadius;

  /// 是否显示取消按钮
  final bool showCancelItem;

  const BottomMenuItemsDialog(
    this.items, {
    super.key,
    this.showCancelItem = true,
    this.clipRadius = kDefaultBorderRadiusXX,
  });

  @override
  Widget build(BuildContext context) {
    return buildBottomChildrenDialog(
      context,
      [
        items
            .column(gapWidget: kHorizontalLine)
            ?.clipRadius(radius: clipRadius),
        Empty.height(kX),
        if (showCancelItem)
          BottomMenuItemTile(
            [LibRes.of(context).libCancel.text()],
            onTap: () {
              //no op
            },
            closeAfterTap: true,
          ).clipRadius(radius: clipRadius)
      ],
      showDragHandle: false,
      bgColor: Colors.transparent,
      clipTopRadius: null,
    ).paddingAll(kX);
  }
}

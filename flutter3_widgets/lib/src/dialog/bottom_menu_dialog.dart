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
  /// 菜单列表,
  /// [BottomMenuItemTile]
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
            onTap: () {
              //no op
            },
            closeAfterTap: true,
            child: LibRes.of(context).libCancel.text(),
          ).clipRadius(radius: clipRadius)
      ],
      showDragHandle: false,
      bgColor: Colors.transparent,
      clipTopRadius: null,
    ).paddingAll(kX);
  }
}

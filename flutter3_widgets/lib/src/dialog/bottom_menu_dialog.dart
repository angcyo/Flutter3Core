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
///
/// @return 点击取消按钮时, 返回false, 其它情况自行返回
class BottomMenuItemsDialog extends StatelessWidget with DialogMixin {
  /// 菜单列表,
  /// [BottomMenuItemTile]
  final WidgetNullList items;

  /// 圆角
  final double? clipRadius;

  //--

  /// 是否显示取消按钮
  final bool showCancelItem;

  /// 取消按钮的文本
  @defInjectMark
  final String? cancelText;

  /// 指定取消按钮
  /// [BottomMenuItemTile]
  @defInjectMark
  final Widget? cancelItem;

  const BottomMenuItemsDialog(
    this.items, {
    super.key,
    this.showCancelItem = true,
    this.clipRadius = kDefaultBorderRadiusXX,
    this.cancelItem,
    this.cancelText,
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
          (cancelItem ??
                  BottomMenuItemTile(
                    onTap: () {
                      //no op
                    },
                    closeAfterTap: true,
                    popResult: false,
                    child: (cancelText ?? LibRes.of(context).libCancel).text(),
                  ))
              .clipRadius(radius: clipRadius)
      ],
      showDragHandle: false,
      bgColor: Colors.transparent,
      clipTopRadius: null,
    ).paddingAll(kX);
  }
}

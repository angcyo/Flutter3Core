part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/30
///
/// 如果[surfaceColor]是透明颜色, 则整体带padding.
/// 否则就是全屏背景样式的弹窗
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

  //--

  /// 背景色
  final Color surfaceColor;

  /// 取消按钮的分割线颜色
  @defInjectMark
  final Color? cancelGapColor;

  /// 奸细的高度
  final double cancelGap;

  const BottomMenuItemsDialog(
    this.items, {
    super.key,
    this.showCancelItem = true,
    this.clipRadius = kDefaultBorderRadiusXX,
    this.cancelItem,
    this.cancelText,
    //--
    this.surfaceColor = Colors.transparent,
    this.cancelGapColor,
    this.cancelGap = kH,
  });

  /// 是否是透明背景样式
  bool get isTransparentStyle => surfaceColor == Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    Widget? body = items.column(gapWidget: horizontalLine(context));
    if (isTransparentStyle) {
      body = body?.clipRadius(radius: clipRadius);
    }

    Widget? cancel;
    if (showCancelItem) {
      cancel =
          (cancelItem ??
          BottomMenuItemTile(
            onTap: () {
              //no op
            },
            closeAfterTap: true,
            popResult: false,
            child: (cancelText ?? LibRes.of(context).libCancel).text(),
          ));
    }
    if (isTransparentStyle) {
      cancel = cancel?.clipRadius(radius: clipRadius);
    }

    return buildBottomChildrenDialog(
      context,
      [
        body,
        if (cancel != null)
          isTransparentStyle
              ? Empty.height(kX)
              : hLine(
                  context,
                  thickness: cancelGap,
                  color:
                      cancelGapColor ??
                      context.darkOr(
                        globalTheme.lineDarkColor,
                        globalTheme.lineColor,
                      ),
                ),
        if (cancel != null) cancel,
      ],
      showDragHandle: false,
      bgColor: surfaceColor,
      clipTopRadius: isTransparentStyle ? null : clipRadius,
    ).paddingAll(isTransparentStyle ? kX : 0);
  }
}

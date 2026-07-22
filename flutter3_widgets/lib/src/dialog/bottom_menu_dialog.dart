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
///
class BottomMenuItemsDialog extends StatelessWidget with DialogMixin {
  /// 菜单列表,
  /// ```
  /// BottomMenuItemTile( /*标题*/
  ///   enable: false,
  ///   child: LibRes.of(
  ///     context,
  ///   ).libDeleteTip.text(style: globalTheme.textDesStyle),
  /// ),
  /// ```
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

  /// 取消按钮的文本样式
  final TextStyle? cancelTextStyle;

  //--

  /// 是否在弹窗中显示当前的对话框
  /// - 影响样式
  final bool? isInPopup;

  final dynamic popResult;

  const BottomMenuItemsDialog(
    this.items, {
    super.key,
    this.showCancelItem = true,
    this.clipRadius = kDefaultBorderRadiusXX,
    this.cancelItem,
    this.cancelText,
    this.cancelTextStyle,
    //--
    this.surfaceColor = Colors.transparent,
    this.cancelGapColor,
    this.cancelGap = kH,
    this.isInPopup,
    this.popResult = false,
  });

  /// 是否是透明背景样式
  bool get isTransparentStyle => surfaceColor == Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final isInPopup = this.isInPopup ?? isDesktopOrWeb;

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
            popResult: popResult,
            child: (cancelText ?? LibRes.of(context).libCancel).text(
              textStyle: cancelTextStyle,
            ),
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
            ?cancel,
          ],
          enablePullBack: isInPopup != true,
          showDragHandle: false,
          bgColor: surfaceColor,
          clipTopRadius: isTransparentStyle ? 0 : clipRadius,
          isPopupStyle: isInPopup,
        )
        .paddingAll(isTransparentStyle ? kX : 0)
        .desktopConstrained(
          enable: isInPopup,
          maxWidth: isDesktopOrWeb ? kDesktopDialogMinWidth : kDialogMinWidth,
        )
        .align(.bottomCenter, enable: isInPopup);
  }
}

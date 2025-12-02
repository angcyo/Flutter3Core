part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/05
///
/// 消息提示对话框
///
/// - [MessageDialog]
/// - [DesktopMessageDialog]
///
/// @return 是否点击了确认按钮
///
class MessageDialog extends AndroidNormalDialog {
  const MessageDialog({
    super.key,
    super.title,
    super.titleWidget,
    super.message,
    super.messageWidget,
    super.messageTextAlign,
    super.confirm,
    super.showConfirm = true,
    super.confirmWidget,
    super.onInterceptCancelTap,
    super.onCancelTap,
    super.onInterceptConfirmTap,
    super.onConfirmTap,
    super.cancel,
    super.cancelWidget,
    super.showCancel = false,
    super.neutral,
    super.neutralWidget,
    super.showNeutral,
    super.useIcon = false,
    super.interceptPop = false,
    super.useBlur = true,
    super.contentRadius = kDefaultBorderRadiusXX,
    super.controlRadius = 0,
    super.controlAxis = Axis.vertical,
    super.dialogBarrierDismissible,
  });
}

/// 桌面布局, 消息提示对话框
///
/// - [MessageDialog]
/// - [DesktopMessageDialog]
@desktopLayout
class DesktopMessageDialog extends AndroidNormalDialog {
  const DesktopMessageDialog({
    super.key,
    super.title,
    super.titleWidget,
    super.message,
    super.messageWidget,
    super.messageTextAlign,
    super.confirm,
    super.showConfirm = true,
    super.confirmWidget,
    super.onInterceptConfirmTap,
    super.onCancelTap,
    super.onConfirmTap,
    super.cancel,
    super.cancelWidget,
    super.showCancel = true,
    /*super.neutral,
    super.neutralWidget,
    super.showNeutral,
    super.useIcon = false,*/
    super.interceptPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final lRes = libRes(context);
    final globalTheme = GlobalTheme.of(context);

    // 标题 / 内容
    Widget? title =
        (titleWidget ??
                (this.title == null
                    ? null
                    : DesktopDialogTitleTile(
                        title: this.title,
                        enableBottomLine: false,
                      )))
            ?.paddingOnly(top: kX);
    Widget? message = _buildMessage(
      context,
      textAlign: messageTextAlign ?? TextAlign.start,
      padding: 0,
    )?.paddingOnly(horizontal: kX, bottom: kXx, top: kX);

    final bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        if (message != null) message,
        //--
        [
              if (showCancel == true)
                cancelWidget ??
                    GradientButton.stroke(
                      minWidth: 0,
                      minHeight: kMinInteractiveHeight,
                      padding: const EdgeInsets.symmetric(
                        vertical: kM,
                        horizontal: kX,
                      ),
                      child: lRes?.libCancel.text(),
                      onTap: () {
                        context.pop();
                      },
                    ),
              if (showConfirm == true)
                confirmWidget ??
                    GradientButton(
                      minWidth: 0,
                      minHeight: kMinInteractiveHeight,
                      padding: const EdgeInsets.symmetric(
                        vertical: kM,
                        horizontal: kX,
                      ),
                      child: lRes?.libConfirm.text(),
                      onTap: () {
                        _doConfirmTap(context);
                      },
                    ),
            ]
            .row(mainAxisAlignment: MainAxisAlignment.end, gap: kX)!
            .paddingOnly(right: kX, bottom: kX),
      ],
    );

    return buildCenterDialog(
      context,
      bodyColumn,
      padding: EdgeInsets.zero,
      blur: true,
    ).interceptPop(interceptPop);
  }
}

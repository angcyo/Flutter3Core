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
    super.onConfirmTap,
    super.cancel,
    super.cancelWidget,
    super.showCancel = false,
    super.neutral,
    super.neutralWidget,
    super.showNeutral,
    super.useIcon = false,
    super.interceptPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    // 标题 / 内容
    Widget? title = _buildTitle(context, textAlign: TextAlign.center);
    Widget? message = _buildMessage(
      context,
      textAlign: messageTextAlign ?? TextAlign.center,
    );

    // 取消 / 中立 / 确定
    Widget? cancel = _buildCancelButton(
      context,
    )?.matchParent(matchHeight: false);
    Widget? neutral = _buildNeutralButton(
      context,
    )?.matchParent(matchHeight: false);
    Widget? confirm = _buildConfirmButton(
      context,
    )?.matchParent(matchHeight: false);

    //line
    final Widget hLine = Line(
      axis: Axis.horizontal,
      color: globalTheme.lineDarkColor,
    );

    final bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        if (message != null) message,
        if (confirm != null) ...[hLine, confirm],
        if (neutral != null) ...[hLine, neutral],
        if (cancel != null) ...[hLine, cancel],
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

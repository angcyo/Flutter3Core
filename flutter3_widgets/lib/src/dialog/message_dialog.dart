part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/05
///
/// 消息提示对话框
class MessageDialog extends AndroidNormalDialog {
  const MessageDialog({
    super.key,
    super.title,
    super.titleWidget,
    super.message,
    super.messageWidget,
    super.confirm = kDialogConfirm,
    super.confirmWidget,
    super.onConfirmTap,
    super.cancel = null,
    super.cancelWidget,
    super.neutral,
    super.neutralWidget,
    super.useIcon = false,
    super.interceptPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    // 标题 / 内容
    Widget? title = _buildTitle(context, textAlign: TextAlign.center);
    Widget? message = _buildMessage(context, textAlign: TextAlign.center);

    // 取消 / 中立 / 确定
    Widget? cancel =
        _buildCancelButton(context)?.matchParent(matchHeight: false);
    Widget? neutral =
        _buildNeutralButton(context)?.matchParent(matchHeight: false);
    Widget? confirm =
        _buildConfirmButton(context)?.matchParent(matchHeight: false);

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

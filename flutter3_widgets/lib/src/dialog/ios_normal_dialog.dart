part of './dialog.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///
/// ios 风格的对话框, 居中显示
/// [showDialogWidget]
class IosNormalDialog extends AndroidNormalDialog {
  const IosNormalDialog({
    super.key,
    super.title,
    super.titleWidget,
    super.message,
    super.messageWidget,
    //--
    super.cancel,
    super.showCancel = true,
    super.cancelWidget,
    //--
    super.confirm,
    super.showConfirm = true,
    super.confirmWidget,
    //--
    super.neutral,
    super.neutralWidget,
    super.showNeutral,
    //--
    super.onCancelTap,
    super.onConfirmTap,
    super.useIcon = false,
    super.contentConstraints,
    super.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    // 标题 / 内容
    Widget? title = _buildTitle(context, textAlign: TextAlign.center);
    Widget? message = _buildMessage(context, textAlign: TextAlign.center);

    // 取消 / 中立 / 确定
    Widget? cancel = _buildCancelButton(context);
    Widget? neutral = _buildNeutralButton(context);
    Widget? confirm = _buildConfirmButton(context);

    //line
    final Widget? hLine = (cancel != null || neutral != null || confirm != null)
        ? Line(
            axis: Axis.horizontal,
            color: globalTheme.lineDarkColor,
          )
        : null;
    final Widget vLine = Line(
      axis: Axis.vertical,
      color: globalTheme.lineDarkColor,
    );

    final controlRow = [
      if (cancel != null) cancel.expanded(),
      if (neutral != null) neutral.expanded(),
      if (confirm != null) confirm.expanded(),
    ].row(
      gapWidget: vLine,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
    );

    final bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        if (message != null) message,
        if (hLine != null) hLine,
        if (controlRow != null) controlRow,
      ],
    );

    return buildCenterDialog(
      context,
      bodyColumn,
      padding: EdgeInsets.zero,
      contentConstraints: contentConstraints,
      blur: true,
    );
  }
}

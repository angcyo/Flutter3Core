part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///
///
/// ios 风格的对话框, 居中显示
class IosNormalDialog extends StatelessWidget with DialogConstraintMixin {
  /// 是否使用图标按钮
  final bool useIcon;

  final String? title;
  final Widget? titleWidget;
  final String? message;
  final Widget? messageWidget;
  final String? cancel;
  final Widget? cancelWidget;
  final String? confirm;
  final Widget? confirmWidget;

  /// 确定按钮点击回调, 返回true, 表示拦截默认处理
  final FutureResultCallback<bool, bool>? onConfirmTap;

  const IosNormalDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.message,
    this.messageWidget,
    this.cancel = kDialogCancel,
    this.cancelWidget,
    this.confirm = kDialogConfirm,
    this.confirmWidget,
    this.onConfirmTap,
    this.useIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);

    //标题 和 内容
    Widget? title = titleWidget ??
        this
            .title
            ?.text(
                style: globalTheme.textTitleStyle
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)
            .paddingAll(kX);
    Widget? message = messageWidget ??
        this
            .message
            ?.text(
                style: globalTheme.textInfoStyle, textAlign: TextAlign.center)
            .paddingAll(kX);

    // 取消 和 确定
    Widget? cancel = (cancelWidget == null && this.cancel == null)
        ? null
        : CancelButton(
            widget: cancelWidget,
            text: this.cancel,
            useIcon: useIcon,
            onTap: () {
              Navigator.pop(context, false);
            });

    Widget? confirm = (confirmWidget == null && this.confirm == null)
        ? null
        : ConfirmButton(
            widget: confirmWidget,
            text: this.confirm,
            useIcon: useIcon,
            onTap: () async {
              if (onConfirmTap == null) {
                Navigator.pop(context, true);
              } else {
                var intercept = await onConfirmTap!(true) == true;
                if (!intercept) {
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              }
            });

    //line
    Widget? hLine = (cancel != null || confirm != null)
        ? Line(
            axis: Axis.horizontal,
            color: globalTheme.lineDarkColor,
            margin: const EdgeInsets.only(top: kL),
          )
        : null;
    Widget? vLine = (cancel != null && confirm != null)
        ? Line(
            axis: Axis.vertical,
            color: globalTheme.lineDarkColor,
          )
        : null;

    var controlRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (cancel != null) cancel.expanded(),
        if (vLine != null) vLine,
        if (confirm != null) confirm.expanded(),
      ],
    );

    var bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        if (message != null) message,
        if (hLine != null) hLine,
        controlRow,
      ],
    );

    return dialogCenterContainer(
      context: context,
      child: bodyColumn,
    );
  }
}

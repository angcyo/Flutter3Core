part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/15
///

/// ios 风格的对话框
class IosNormalDialog extends StatelessWidget with DialogConstraintMixin {
  final String? title;
  final Widget? titleWidget;
  final String? message;
  final Widget? messageWidget;
  final String? cancel;
  final Widget? cancelWidget;
  final String? confirm;
  final Widget? confirmWidget;

  /// 确定按钮点击回调, 返回true, 表示拦截默认处理
  final FutureResultCallback<bool>? onConfirmTap;

  const IosNormalDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.message,
    this.messageWidget,
    this.cancel = '取消',
    this.cancelWidget,
    this.confirm = '确定',
    this.confirmWidget,
    this.onConfirmTap,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);

    //标题 和 内容
    Widget? t = titleWidget ??
        title
            ?.text(
                style: globalTheme.textTitleStyle
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)
            .paddingAll(kX);
    Widget? m = messageWidget ??
        message
            ?.text(
                style: globalTheme.textInfoStyle, textAlign: TextAlign.center)
            .paddingAll(kX);

    // 取消 和 确定
    Widget? c = cancelWidget ??
        cancel
            ?.text(
                style: globalTheme.textLabelStyle, textAlign: TextAlign.center)
            .paddingAll(kXh);

    c = c?.ink(onTap: () {
      Navigator.pop(context, false);
    }).material();

    Widget? f = confirmWidget ??
        confirm
            ?.text(
                style: globalTheme.textLabelStyle
                    .copyWith(color: globalTheme.accentColor),
                textAlign: TextAlign.center)
            .paddingAll(kXh);
    f = f?.ink(onTap: () async {
      if (onConfirmTap == null) {
        Navigator.pop(context, true);
      } else {
        var intercept = await onConfirmTap!() == true;
        if (!intercept) {
          if (context.mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    }).material();

    //line
    Widget? hLine = (c != null || f != null)
        ? Line(
            axis: Axis.horizontal,
            color: globalTheme.lineDarkColor,
            margin: const EdgeInsets.only(top: kL),
          )
        : null;
    Widget? vLine = (c != null && f != null)
        ? Line(
            axis: Axis.vertical,
            color: globalTheme.lineDarkColor,
          )
        : null;

    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (c != null) c.expanded(),
        if (vLine != null) vLine,
        if (f != null) f.expanded(),
      ],
    );

    var column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (t != null) t,
        if (m != null) m,
        if (hLine != null) hLine,
        row,
      ],
    );

    return Center(
      child: dialogContainer(
        context: context,
        child: column.matchParent(matchHeight: false),
      ).material(),
    );
  }
}

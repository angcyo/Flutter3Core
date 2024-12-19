part of './dialog.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/05
///
/// Android 风格的普通对话框
/// 点击[confirm], 返回true
/// 点击[cancel], 返回false
/// 点击[neutral], 返回null
class AndroidNormalDialog extends StatelessWidget with DialogMixin {
  /// 是否使用图标按钮
  final bool useIcon;

  /// 标题
  final String? title;
  final Widget? titleWidget;

  /// 内容
  final String? message;
  final Widget? messageWidget;
  final TextAlign? messageTextAlign;

  /// 取消按钮
  final String? cancel;
  final Widget? cancelWidget;
  final bool? showCancel;

  /// 确定按钮
  final String? confirm;
  final Widget? confirmWidget;
  final bool? showConfirm;

  ///中立按钮
  final String? neutral;
  final Widget? neutralWidget;
  final bool? showNeutral;

  /// 确定按钮点击回调, 参数始终为true
  /// 返回true, 表示拦截默认处理
  final FutureOrResultCallback<bool, bool>? onConfirmTap;

  /// 是否拦截Pop
  final bool interceptPop;

  @override
  EdgeInsets get contentPadding => EdgeInsets.zero;

  @override
  TranslationType get translationType => TranslationType.scaleFade;

  final double gap = kX;

  const AndroidNormalDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.message,
    this.messageWidget,
    this.messageTextAlign,
    this.cancel,
    this.showCancel = true,
    this.cancelWidget,
    this.confirm,
    this.confirmWidget,
    this.showConfirm = true,
    this.neutral,
    this.neutralWidget,
    this.showNeutral,
    this.onConfirmTap,
    this.useIcon = false,
    this.interceptPop = false,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    // 标题 / 内容
    Widget? title = _buildTitle(context);
    Widget? message =
        _buildMessage(context, textAlign: messageTextAlign ?? TextAlign.left);

    // 取消 / 中立 / 确定
    Widget? cancel = _buildCancelButton(context);
    Widget? neutral = _buildNeutralButton(context);
    Widget? confirm = _buildConfirmButton(context);

    final controlRow = [
      cancel,
      neutral,
      confirm,
    ].row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      gap: gap,
    );

    final bodyColumn = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) title,
        if (message != null) message,
        if (controlRow != null) controlRow,
      ],
    );

    return buildCenterDialog(
      context,
      bodyColumn,
      padding: EdgeInsets.zero,
      radius: kDefaultBorderRadiusL,
    ).interceptPop(interceptPop);
  }

  /// 构建内容
  Widget? _buildMessage(
    BuildContext context, {
    TextAlign textAlign = TextAlign.left,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return messageWidget ??
        message
            ?.text(
              style: globalTheme.textBodyStyle,
              textAlign: textAlign,
            )
            .paddingAll(gap);
  }

  /// 构建标题
  Widget? _buildTitle(
    BuildContext context, {
    TextAlign textAlign = TextAlign.left,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return titleWidget ??
        title
            ?.text(
              style: globalTheme.textTitleStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: textAlign,
            )
            .padding(gap, gap, gap,
                (message == null && messageWidget == null) ? gap : 0);
  }

  /// 构建取消按钮
  Widget? _buildCancelButton(BuildContext context) {
    String? cancelText = cancel;
    if (showCancel == false) {
      return null;
    } else if (showCancel == true) {
      cancelText ??= LibRes.of(context).libCancel;
    }
    return (cancelWidget == null && cancelText == null)
        ? null
        : CancelButton(
            widget: cancelWidget,
            text: cancelText,
            useIcon: useIcon,
            onTap: () {
              Navigator.pop(context, false);
            });
  }

  /// 构建中立按钮
  Widget? _buildNeutralButton(BuildContext context) {
    String? neutralText = neutral;
    if (showNeutral == false) {
      return null;
    } else if (showNeutral == true) {
      //neutralText ??= LibRes.of(context).libNeutral;
    }
    return (neutralWidget == null && neutralText == null)
        ? null
        : NeutralButton(
            widget: neutralWidget,
            text: neutralText,
            useIcon: useIcon,
            onTap: () {
              Navigator.pop(context, null);
            });
  }

  /// 构建确定按钮
  Widget? _buildConfirmButton(BuildContext context) {
    String? confirmText = confirm;
    if (showConfirm == false) {
      return null;
    } else if (showConfirm == true) {
      confirmText ??= LibRes.of(context).libConfirm;
    }
    return (confirmWidget == null && confirmText == null)
        ? null
        : ConfirmButton(
            widget: confirmWidget,
            text: confirmText,
            useIcon: useIcon,
            onTap: () async {
              if (onConfirmTap == null) {
                Navigator.pop(context, true);
              } else {
                final intercept = await onConfirmTap!(true) == true;
                if (!intercept) {
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              }
            });
  }
}

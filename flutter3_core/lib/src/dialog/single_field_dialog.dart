part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/06/03
///
/// 简单的文本编辑输入框对话框
/// - [SingleInputWidget]
///
/// - [SingleTextDialog]
/// - [SingleFieldDialog]
/// - [SingleImageDialog]
///
/// @return 返回输入的字符串
class SingleFieldDialog extends StatefulWidget with InputMixin {
  /// 强行指定文本内容
  @override
  final String? inputText;

  @override
  final int? inputMaxLines;

  @override
  final InputBorderType inputBorderType;

  //--

  /// 是否显示标题
  final bool showTitle;

  /// 包裹输入框的回调
  final WidgetNullList Function(BuildContext context, Widget input)?
  wrapInputAction;

  final bool trailingUseThemeColor;

  //--dialog

  final String? title;
  final Widget? titleWidget;

  @defInjectMark
  final EdgeInsets? inputMargin;

  /// 是否可以输入空文本
  final bool enableInputEmpty;

  /// 是否可以输入默认值, 也就是默认值时, 右边的确认按钮也是可以点击的
  final bool enableInputDefault;

  const SingleFieldDialog({
    super.key,
    this.inputText,
    this.inputMaxLines = 10_000,
    this.inputBorderType = .outline,
    //--
    this.showTitle = true,
    this.wrapInputAction,
    this.trailingUseThemeColor = false,
    //--dialog
    this.title,
    this.titleWidget,
    this.inputMargin = const EdgeInsets.all(kX),
    this.enableInputEmpty = false,
    this.enableInputDefault = false,
  });

  @override
  State<SingleFieldDialog> createState() => _SingleFieldDialogState();
}

class _SingleFieldDialogState extends State<SingleFieldDialog>
    with InputStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalConfig = GlobalConfig.of(context);
    //l.d("input->$textMixin");
    final globalTheme = GlobalTheme.of(context);
    //input
    final input = buildInputWidgetMixin(
      context,
      textInputAction: (widget.inputMaxLines ?? 0) > 1 ? .newline : null,
    );
    //
    return [
          if (widget.showTitle)
            CoreDialogTitle(
              title: widget.title,
              titleWidget: widget.titleWidget,
              enableTrailing:
                  (isInputChanged ||
                      (isInputDefault && widget.enableInputDefault)) &&
                  (widget.enableInputEmpty ||
                      (!widget.enableInputEmpty && !isInputEmpty)),
              onTrailingTap: (context) {
                onSelfInputTextResult(context);
              },
              trailingUseThemeColor: widget.trailingUseThemeColor,
            ),
          if (widget.wrapInputAction == null)
            input
                .paddingInsets(
                  widget.inputMargin /*?? widget.dialogContentPadding*/,
                )
                .expanded(),
          if (widget.wrapInputAction != null)
            ...widget.wrapInputAction!(
              context,
              input
                  .paddingInsets(
                    widget.inputMargin /*?? widget.dialogContentPadding*/,
                  )
                  .expanded(),
            ),
        ]
        .column()!
        .container(color: globalConfig.globalTheme.whiteBgColor)
        .clipRadius(radius: kDefaultBorderRadiusXX)
        .material()
        .scaffold()
        .autoCloseDialog(context, onResultAction: () => currentInputText);
  }
}

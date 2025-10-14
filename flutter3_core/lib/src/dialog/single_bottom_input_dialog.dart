part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/11
///
/// 简单的底部弹窗输入对话框
/// [showDialogWidget]
/// [SingleInputDialog]
/// [SingleBottomInputDialog]
/// @return 返回输入的字符串
class SingleBottomInputDialog extends StatefulWidget
    with DialogMixin, InputMixin {
  //--dialog

  final String? title;
  final Widget? titleWidget;

  @defInjectMark
  final EdgeInsets? inputMargin;

  /// 是否可以输入空文本
  final bool enableInputEmpty;

  /// 是否可以输入默认值, 也就是默认值时, 右边的确认按钮也是可以点击的
  final bool enableInputDefault;

  //--input

  /// 输入框/InputMixin
  @override
  final TextFieldConfig? inputFieldConfig;

  /// 提示
  @override
  final String? inputHint;

  @override
  final String? inputText;

  @override
  final bool? autofocus;

  @override
  final EdgeInsets? inputPadding;

  @override
  final TextAlign inputTextAlign;

  /// 并不需要在此方法中更新界面
  @override
  final ValueChanged<String>? onInputTextChanged;

  @override
  final ValueCallback<String?>? onInputTextResult;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  @override
  final FutureValueCallback<String>? onInputTextConfirmChange;

  /// 下划线的输入框样式
  @override
  final InputBorderType inputBorderType;

  @override
  final int? inputMaxLines;

  @override
  final int? inputMaxLength;

  @override
  final bool? showInputCounter;

  @override
  final List<TextInputFormatter>? inputFormatters;
  @override
  final TextInputType? inputKeyboardType;

  //--

  /// 是否显示标题
  final bool showTitle;

  /// 包裹输入框的回调
  final WidgetNullList Function(BuildContext context, Widget input)?
  wrapInputAction;

  //--
  final bool trailingUseThemeColor;

  //--

  @defInjectMark
  final double? dialogClipTopRadius;

  const SingleBottomInputDialog({
    super.key,
    //--dialog
    this.title,
    this.titleWidget,
    this.inputMargin = const EdgeInsets.only(bottom: kH),
    this.enableInputEmpty = false,
    this.enableInputDefault = false,
    //--input
    this.inputFieldConfig,
    this.inputHint,
    this.inputText,
    this.autofocus = true,
    this.onInputTextChanged,
    this.onInputTextResult,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.underline,
    this.inputTextAlign = TextAlign.start,
    this.inputMaxLines = 1,
    this.inputMaxLength = kDefaultInputLength,
    this.showInputCounter,
    this.inputFormatters,
    this.inputPadding = kInputPadding,
    this.inputKeyboardType,
    //--
    this.showTitle = true,
    this.wrapInputAction,
    //--
    this.trailingUseThemeColor = false,
    this.dialogClipTopRadius,
  });

  const SingleBottomInputDialog.wrapInput(
    this.wrapInputAction, {
    super.key,
    //--dialog
    this.title,
    this.titleWidget,
    this.inputMargin = EdgeInsets.zero,
    this.enableInputEmpty = false,
    this.enableInputDefault = false,
    //--input
    this.inputFieldConfig,
    this.inputHint,
    this.inputText,
    this.autofocus = true,
    this.onInputTextChanged,
    this.onInputTextResult,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.none,
    this.inputTextAlign = TextAlign.start,
    this.inputMaxLines = 1,
    this.inputMaxLength = kDefaultInputLength,
    this.showInputCounter = false,
    this.inputFormatters,
    this.inputPadding = kInputPadding,
    this.inputKeyboardType,
    //--
    this.showTitle = true,
    //--
    this.trailingUseThemeColor = false,
    this.dialogClipTopRadius,
  });

  @override
  State<SingleBottomInputDialog> createState() =>
      _SingleBottomInputDialogState();
}

class _SingleBottomInputDialogState extends State<SingleBottomInputDialog>
    with InputStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //input
    final input = buildInputWidgetMixin(context);
    //
    return widget.buildBottomChildrenDialog(
      context,
      [
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
          input.paddingInsets(
            widget.inputMargin ?? widget.dialogContentPadding,
          ),
        if (widget.wrapInputAction != null)
          ...widget.wrapInputAction!(
            context,
            input.paddingInsets(
              widget.inputMargin ?? widget.dialogContentPadding,
            ),
          ),
      ],
      clipTopRadius: widget.dialogClipTopRadius ?? globalTheme.dialogRadius,
    ).scaffold();
  }
}

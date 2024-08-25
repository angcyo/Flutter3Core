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
  final List<TextInputFormatter>? inputFormatters;
  @override
  final TextInputType? inputKeyboardType;

  //--

  /// 是否显示标题
  final bool showTitle;

  /// 包裹输入框的回调
  final WidgetNullList Function(BuildContext context, Widget input)?
      wrapInputAction;

  const SingleBottomInputDialog({
    super.key,
    //--dialog
    this.title,
    this.titleWidget,
    this.inputMargin = const EdgeInsets.only(bottom: kH),
    this.enableInputEmpty = false,
    //--input
    this.inputFieldConfig,
    this.inputHint,
    this.inputText,
    this.autofocus = true,
    this.onInputTextChanged,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.underline,
    this.inputTextAlign = TextAlign.start,
    this.inputMaxLines = 1,
    this.inputMaxLength,
    this.inputFormatters,
    this.inputPadding = kInputPadding,
    this.inputKeyboardType,
    //--
    this.showTitle = true,
    this.wrapInputAction,
  });

  const SingleBottomInputDialog.wrapInput(
    this.wrapInputAction, {
    super.key,
    //--dialog
    this.title,
    this.titleWidget,
    this.inputMargin = EdgeInsets.zero,
    this.enableInputEmpty = false,
    //--input
    this.inputFieldConfig,
    this.inputHint,
    this.inputText,
    this.autofocus = true,
    this.onInputTextChanged,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.none,
    this.inputTextAlign = TextAlign.start,
    this.inputMaxLines = 1,
    this.inputMaxLength,
    this.inputFormatters,
    this.inputPadding = kInputPadding,
    this.inputKeyboardType,
    //--
    this.showTitle = true,
  });

  @override
  State<SingleBottomInputDialog> createState() =>
      _SingleBottomInputDialogState();
}

class _SingleBottomInputDialogState extends State<SingleBottomInputDialog>
    with InputStateMixin {
  @override
  Widget build(BuildContext context) {
    //input
    Widget input = buildInputWidgetMixin(context);

    return widget
        .buildBottomChildrenDialog(
          context,
          [
            if (widget.showTitle)
              CoreDialogTitle(
                title: widget.title,
                titleWidget: widget.titleWidget,
                enableTrailing: isInputChanged &&
                    (widget.enableInputEmpty ||
                        (!widget.enableInputEmpty && !isInputEmpty)),
                onTrailingTap: (context) {
                  buildContext?.pop(currentInputText);
                },
              ),
            if (widget.wrapInputAction == null)
              input.paddingInsets(widget.inputMargin ?? widget.contentPadding),
            if (widget.wrapInputAction != null)
              ...widget.wrapInputAction!(
                  context,
                  input.paddingInsets(
                      widget.inputMargin ?? widget.contentPadding)),
          ],
          clipTopRadius: kDefaultBorderRadiusXX,
        )
        .scaffold();
  }
}

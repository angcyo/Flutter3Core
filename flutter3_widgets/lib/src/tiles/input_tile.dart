part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/10
///
/// 输入框tile
/// 上[label]
/// 下input hint(des)
class LabelSingleInputTile extends StatefulWidget with LabelMixin, InputMixin {
  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  /// 标签右边的小部件
  final WidgetNullList? labelActions;

  //--input

  /// 输入框/InputMixin
  /// 提示
  @override
  final String? inputHint;

  @override
  final String? inputText;

  @override
  final EdgeInsets? inputPadding;

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

  /// tile的填充
  final EdgeInsets? tilePadding;

  const LabelSingleInputTile({
    super.key,
    //--
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints,
    this.labelActions,
    //--
    this.inputHint,
    this.inputText,
    this.onInputTextChanged,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.underline,
    this.inputMaxLines = 1,
    this.inputMaxLength,
    this.inputFormatters,
    this.inputPadding = kInputPadding,
    this.inputKeyboardType,
    //--
    this.tilePadding = kTilePadding,
  });

  @override
  State<LabelSingleInputTile> createState() => _LabelSingleInputTileState();
}

class _LabelSingleInputTileState extends State<LabelSingleInputTile>
    with TileMixin, InputStateMixin {
  @override
  Widget build(BuildContext context) {
    //build label
    Widget? label = widget.buildLabelWidgetMixin(context);
    if (label != null && !isNil(widget.labelActions)) {
      label = [
        label,
        ...?widget.labelActions,
      ].row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center);
    }

    //input
    Widget input = buildInputWidgetMixin(context)
        .paddingOnly(left: widget.labelPadding?.left ?? 0);

    return [label, input]
        .column(crossAxisAlignment: CrossAxisAlignment.start)!
        .paddingInsets(widget.tilePadding);
  }
}

/// 左[label] 右[input] 的输入tile
class SingleLabelInputTile extends StatefulWidget with LabelMixin, InputMixin {
  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  /// 输入框/InputMixin
  /// 提示
  @override
  final String? inputHint;
  @override
  final String? inputText;
  @override
  final EdgeInsets? inputPadding;
  @override
  final ValueChanged<String>? onInputTextChanged;
  @override
  final FutureValueCallback<String>? onInputTextConfirmChange;
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

  ///
  final double? inputWidth;

  const SingleLabelInputTile({
    super.key,
    //LabelMixin
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints = kLabelConstraints,
    //InputMixin
    this.inputHint,
    this.inputText,
    this.onInputTextChanged,
    this.onInputTextConfirmChange,
    this.inputBorderType = InputBorderType.none,
    this.inputMaxLines = 1,
    this.inputMaxLength,
    this.inputFormatters,
    this.inputPadding = const EdgeInsets.only(
      left: kH,
      right: kH,
      top: kL,
      bottom: kL,
    ),
    this.inputKeyboardType,
    //--
    this.inputWidth,
  });

  @override
  State<SingleLabelInputTile> createState() => _SingleLabelInputTileState();
}

class _SingleLabelInputTileState extends State<SingleLabelInputTile>
    with InputStateMixin {
  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //label
    Widget? label = widget.buildLabelWidgetMixin(context);

    //input
    const iconSize = 16.0;
    const iconPadding = 4.0;
    const iconConstraints = BoxConstraints(
      minWidth: iconSize,
      minHeight: iconSize,
      maxWidth: iconSize + iconPadding * 2,
      maxHeight: iconSize + iconPadding,
    );
    Widget input = buildInputWidgetMixin(
      context,
      inputBuildCounter: noneInputBuildCounter,
      prefixIconSize: iconSize,
      suffixIconSize: iconSize,
      prefixIconConstraints: iconConstraints,
      suffixIconConstraints: iconConstraints,
      suffixIconPadding: const EdgeInsets.all(iconPadding),
    );
    return [
      label,
      input
          .container(
            color: globalTheme.itemWhiteBgColor,
            radius: kDefaultBorderRadiusX,
            constraints: BoxConstraints(
              minWidth: widget.inputWidth ?? 0,
              maxWidth: widget.inputWidth ?? double.infinity,
            ),
          )
          .paddingSymmetric(horizontal: kX, vertical: kL)
          .align(Alignment.centerRight)
          .expanded(),
    ].row()!;
  }
}

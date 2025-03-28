part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/10
///
/// 输入框tile
/// 上[label]
/// 下[inputHint]](des)
class LabelSingleInputTile extends StatefulWidget with LabelMixin, InputMixin {
  //--label

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
  @override
  final TextFieldConfig? inputFieldConfig;

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

  //--tile

  /// tile的填充
  final EdgeInsets? tilePadding;

  const LabelSingleInputTile({
    super.key,
    //--label
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints,
    this.labelActions,
    //--input
    this.inputFieldConfig,
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
  @override
  final TextFieldConfig? inputFieldConfig;

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

  /// 输入框的宽度
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
    this.inputFieldConfig,
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

/// 数字输入框
/// - 取消删除icon
/// - 默认不带背景/输入装饰
class NumberInputWidget extends StatefulWidget {
  /// 输入的文本
  /// - 支持小数
  /// - 支持整数
  /// - 支持字符串
  final dynamic inputText;

  /// 输入的数字类型, 不指定就是字符串
  final NumType? inputNumType;

  /// 输入提示
  final String? hintText;

  /// 最大输入长度
  final int inputMaxLength;

  /// 如果是小数, 那么小数后最多显示几位
  final int inputMaxDigits;

  /// 最大值, 只在数字类型时有效
  final num? inputMaxValue;

  /// 最小值, 只在数字类型时有效
  final num? inputMinValue;

  /// 输入格式化器, 不指定会有默认值
  @defInjectMark
  final List<TextInputFormatter>? inputFormatters;

  /// 文本对齐
  final TextAlign textAlign;

  /// 文本样式
  final TextStyle? textStyle;

  /// 请求焦点
  final FocusNode? inputFocusNode;

  //--

  /// 输入框的边距
  final EdgeInsetsGeometry? contentPadding;

  //--

  /// 改变时的回调, 自动根据[inputNumType]返回对应类型的数据
  final ValueChanged<dynamic>? onChanged;

  /// 提交时的回调, 自动根据[inputNumType]返回对应类型的数据
  final ValueChanged<dynamic>? onSubmitted;

  /// 自动提交
  final bool autoSubmitOnUnFocus;

  const NumberInputWidget({
    super.key,
    this.inputText,
    this.hintText,
    this.inputMinValue,
    this.inputMaxValue,
    this.inputNumType,
    this.inputMaxDigits = 2,
    this.inputMaxLength = 9,
    this.inputFormatters,
    this.textStyle,
    this.inputFocusNode,
    this.textAlign = TextAlign.center,
    this.contentPadding = kNumberInputPadding,
    this.onChanged,
    this.onSubmitted,
    this.autoSubmitOnUnFocus = true,
  });

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  /// 输入配置信息
  final inputConfig = TextFieldConfig();

  //--

  NumType? get _inputNumType =>
      widget.inputNumType ??
      (widget.inputText is int
          ? NumType.i
          : (widget.inputText is double ? NumType.d : null));

  bool get isInt => _inputNumType == NumType.i;

  bool get isDouble => _inputNumType == NumType.d;

  bool get isString => _inputNumType == null;

  String get inputText {
    if (widget.inputText == null) {
      return "";
    }
    if (isDouble) {
      return _formatDigits("${widget.inputText}");
    }
    return "${widget.inputText}";
  }

  /// 格式化数字字符串
  String _formatDigits(String value) {
    if (isDouble) {
      return value.toDoubleOrNull()?.toDigits(
                digits: widget.inputMaxDigits,
                removeZero: !value.contains("."),
              ) ??
          value;
    }
    return value;
  }

  //--

  @override
  void initState() {
    inputConfig.focusNode = widget.inputFocusNode ?? inputConfig.focusNode;
    inputConfig.text = inputText;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NumberInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inputFocusNode == inputConfig.focusNode) {
      inputConfig.focusNode = widget.inputFocusNode;
    }
    if (oldWidget.inputText != inputText) {
      inputConfig.updateText(inputText, notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //l.d("build->${inputConfig.text}");
    final Widget input = SingleInputWidget(
      config: inputConfig,
      maxLines: 1,
      maxLength: widget.inputMaxLength,
      showInputCounter: false,
      keyboardType: isString ? TextInputType.text : TextInputType.number,
      inputFormatters: widget.inputFormatters ??
          (isDouble
              ? [decimalTextInputFormatter]
              : isInt
                  ? [numberTextInputFormatter]
                  : null),
      textStyle: widget.textStyle,
      textAlign: widget.textAlign,
      inputBorderType: InputBorderType.none,
      inputBuildCounter: null,
      contentPadding: widget.contentPadding,
      autoShowSuffixIcon: false,
      autoSubmitOnUnFocus: widget.autoSubmitOnUnFocus,
      //--
      hintText: widget.hintText,
      onChanged: (value) {
        //debugger();
        /*assert(() {
          l.d("onInputChanged:${inputConfig.text}->$value");
          return true;
        }());*/
        final selection = inputConfig.controller.selection;
        if (isDouble && widget.inputMaxDigits > 0 && selection.isCollapsed) {
          final newValue = _formatDigits(value);
          if (newValue != value &&
              value.decimalDigits > widget.inputMaxDigits) {
            //debugger();
            inputConfig.text = newValue;
          }
        }
        widget.onChanged?.call(_formatResultValue(value));
      },
      onSubmitted: (value) {
        /*assert(() {
          l.d("onSubmitted:${inputConfig.text}->$value");
          return true;
        }());*/
        widget.onSubmitted?.call(_formatResultValue(value));
      },
    );
    return input;
  }

  /// 格式化输出的结果值
  dynamic _formatResultValue(String value) {
    //debugger();
    try {
      if (isString) {
        return value;
      } else if (isDouble) {
        return clamp(
          value.toDouble(),
          widget.inputMinValue,
          widget.inputMaxValue,
        );
      } else if (isInt) {
        return clamp(
          value.toInt(),
          widget.inputMinValue,
          widget.inputMaxValue,
        );
      }
    } catch (e, s) {
      /*assert(() {
        printError(e, s);
        return true;
      }());*/
    }
    return null;
  }
}

/// 数字输入tile
/// 左[label].[输入框tile].[inputHint]
class LabelNumberInputTile extends StatefulWidget with LabelMixin {
  //--label

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

  //--input
  final dynamic number;
  final NumType? numType;
  final num? maxValue;
  final num? minValue;
  final int maxDigits;
  final ValueChanged<dynamic>? onChanged;
  final ValueChanged<dynamic>? onSubmitted;
  final EdgeInsetsGeometry? contentPadding;
  @defInjectMark
  final TextStyle? numberTextStyle;

  //--trailing

  /// 尾部widget
  final Widget? trailingWidget;

  //--tile

  final double? radius;
  final EdgeInsetsGeometry? tilePadding;

  const LabelNumberInputTile({
    super.key,
    //--label
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kNumberLabelPadding,
    this.labelConstraints,
    //--input
    this.number,
    this.maxValue,
    this.minValue,
    this.maxDigits = 2,
    this.onChanged,
    this.onSubmitted,
    this.numType,
    this.contentPadding = kNumberInputPadding,
    this.numberTextStyle,
    //--trailing
    this.trailingWidget,
    //--tile
    this.radius = kDefaultBorderRadiusL,
    this.tilePadding = const EdgeInsets.symmetric(vertical: kM, horizontal: kM),
  });

  @override
  State<LabelNumberInputTile> createState() => _LabelNumberInputTileState();
}

class _LabelNumberInputTileState extends State<LabelNumberInputTile>
    with HoverStateMixin {
  /// 当前输入的值
  dynamic _currentNumber;

  @override
  void initState() {
    _currentNumber = widget.number;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberInputTile oldWidget) {
    _currentNumber = widget.number;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //build label
    Widget? label = widget.buildLabelWidgetMixin(context,
        labelTextStyle: widget.labelTextStyle ?? globalTheme.textDesStyle);
    //build trailing
    Widget? trailingWidget = widget.trailingWidget;

    return buildHoverWidgetMixin(
      context,
      Row(
        children: [
          if (label != null) label,
          NumberInputWidget(
            inputText: _currentNumber,
            contentPadding: widget.contentPadding,
            inputNumType: widget.numType ?? NumType.from(widget.number),
            inputMinValue: widget.minValue,
            inputMaxValue: widget.maxValue,
            inputMaxDigits: widget.maxDigits,
            inputFocusNode: hoverFocusNodeMixin,
            textStyle: widget.numberTextStyle ?? globalTheme.textBodyStyle,
            textAlign: TextAlign.start,
            onChanged: (value) {
              _currentNumber = value;
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
          ).expanded(),
          if (trailingWidget != null) trailingWidget,
        ],
      )
          .paddingInsets(widget.tilePadding)
          .backgroundDecoration(
            buildHoverDecorationMixin(
              context,
              radius: widget.radius,
              normalDecoration: const BoxDecoration(),
            ),
          )
          .constrained(),
    );
  }
}

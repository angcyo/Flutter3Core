part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/18
///
/// ```
/// final value = await showDialogWidget(
///   context,
///   NumberKeyboardDialog(
///     number: number,
///     minValue: minNumber,
///     maxValue: maxNumber,
///     hintText: hintTooltip ?? tooltip,
///   ),
///   type: TranslationType.translation,
///   barrierDismissible: false,
/// );
/// ```
/// 输入回调
typedef NumberInputCallback = void Function(num? value);

/// 按键类型
enum NumberKeyboardType {
  /// 键盘类型: 数字
  number,

  /// 键盘类型: 退格
  backspace,

  /// 键盘类型: 小数点
  decimal,

  /// 键盘类型: 正负
  positiveNegative,
}

/// 数字键盘输入对话框
/// 如果是小数, 返回小数
/// 如果是整数, 返回整数
class NumberKeyboardDialog extends StatefulWidget with DialogMixin {
  //---

  /// 当前的数字, 支持整型/浮点
  final num? number;

  /// 最大值
  final num? maxValue;

  /// 最小值
  final num? minValue;

  /// [number]数字类型
  final NumType? _numType;

  /// 浮点时, 最大的小数位个数
  final int maxDigits;

  /// 允许输入的最大长度, 包含小数点
  final int maxLength;

  /// 提示文本
  final String? hintText;

  /// 是否可以返回
  final bool canPop;

  //---

  /// 是否支持负数, 不指定则通过[minValue]自动判断
  final bool? supportNegative;

  const NumberKeyboardDialog({
    super.key,
    required this.number,
    this.maxValue,
    this.minValue,
    this.maxDigits = 2,
    this.hintText,
    this.maxLength = 9,
    this.canPop = true,
    this.supportNegative,
    NumType? numType,
  }) : _numType = numType ?? (number is int ? NumType.i : NumType.d);

  @override
  State<NumberKeyboardDialog> createState() => _NumberKeyboardDialogState();
}

class _NumberKeyboardDialogState extends State<NumberKeyboardDialog> {
  final gap = 6.0;
  final height = 40.0;
  final borderRadius = 4.0;

  late final BoxDecoration decoration;
  late final pressedDecoration = fillDecoration(
    color: Colors.black12,
    borderRadius: borderRadius,
  );
  late final TextStyle keyboardNumberStyle;
  late final TextStyle numberValueStyle;
  late final numberHintStyle = const TextStyle(
    fontSize: 20,
    color: Colors.grey,
  );
  late final rangeHintStyle = const TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  /// 是否支持小数
  bool get isSupportDecimal => widget._numType == NumType.d;

  /// 是否支持负数
  bool get isSupportNegative =>
      widget.supportNegative ??
      (widget.minValue == null || (widget.minValue ?? 0) < 0);

  /// 是否要显示收起键盘
  bool get isShowPackUp => !isSupportDecimal || !isSupportNegative;

  /// 当前输入的文本
  String _numberText = "";

  /// 是否清空所有
  bool isClearAll = true;

  @override
  void initState() {
    super.initState();
    _numberText = _formatValue(widget.number) ?? "";
    final globalTheme = GlobalTheme.of(context);
    decoration = fillDecoration(
      color: globalTheme.surfaceBgColor,
      borderRadius: borderRadius,
    );

    keyboardNumberStyle = TextStyle(
      fontSize: 16,
      color: context.isThemeDark
          ? globalTheme.textTitleStyle.color
          : globalTheme.textGeneralStyle.color,
      fontWeight: FontWeight.bold,
    );

    numberValueStyle = TextStyle(
      fontSize: 22,
      color: context.isThemeDark
          ? globalTheme.textTitleStyle.color
          : globalTheme.textGeneralStyle.color,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final keyboard = FlowLayout(
      selfConstraints: const LayoutBoxConstraints(
        widthType: ConstraintsType.wrapContent,
        heightType: ConstraintsType.wrapContent,
      ),
      childConstraints: BoxConstraints(minHeight: height),
      childGap: gap,
      equalWidthRange: "",
      lineMaxChildCount: 4,
      padding: EdgeInsets.all(gap),
      children: [
        _createNumberButton("1", NumberKeyboardType.number),
        _createNumberButton("2", NumberKeyboardType.number),
        _createNumberButton("3", NumberKeyboardType.number),
        StateDecorationWidget(
          decoration: decoration,
          pressedDecoration: pressedDecoration,
          child: loadAssetSvgWidget(
            Assets.svg.keyboardBackspace,
            package: 'flutter3_core',
            prefix: kDefAssetsSvgPrefix,
            tintColor: context.isThemeDark ? keyboardNumberStyle.color : null,
          ).align(Alignment.center),
        ).click(() {
          _onSelfInput("", NumberKeyboardType.backspace);
        }),
        _createNumberButton("4", NumberKeyboardType.number),
        _createNumberButton("5", NumberKeyboardType.number),
        _createNumberButton("6", NumberKeyboardType.number),
        StateDecorationWidget(
          decoration: fillDecoration(
            color: globalTheme.accentColor,
            borderRadius: borderRadius,
          ),
          pressedDecoration: pressedDecoration,
          child: LibRes.of(context)
              .libFinish
              .text(style: keyboardNumberStyle)
              .align(Alignment.center),
        ).click(() {
          //debugger();
          if (_checkInputValue(_numberText)) {
            if (isSupportDecimal) {
              context.pop(_numberText.toDoubleOrNull());
            } else {
              context.pop(_numberText.toIntOrNull());
            }
          } else {
            Feedback.forLongPress(context);
            isClearAll = true;
            updateState();
          }
        }).flowLayoutData(
          stack: true,
          weight: 1.0 / 4,
          constraints: BoxConstraints(
            minHeight: height * 3 + gap * 2,
          ),
        ),
        _createEmptyButton(),
        _createNumberButton("7", NumberKeyboardType.number),
        _createNumberButton("8", NumberKeyboardType.number),
        _createNumberButton("9", NumberKeyboardType.number),
        _createEmptyButton(),
        if (isSupportDecimal || isSupportNegative)
          _createNumberButton("0", NumberKeyboardType.number)
        else
          _createNumberButton("0", NumberKeyboardType.number)
              .flowLayoutData(weight: 1.0 / 4 * 2, excludeGapCount: 2),
        if (isSupportDecimal)
          _createNumberButton(".", NumberKeyboardType.decimal),
        if (isSupportNegative)
          _createNumberButton("±", NumberKeyboardType.backspace),
        if (isShowPackUp)
          StateDecorationWidget(
            decoration: decoration,
            pressedDecoration: pressedDecoration,
            child: loadAssetSvgWidget(
              Assets.svg.keyboardPackUp,
              package: 'flutter3_core',
              prefix: kDefAssetsSvgPrefix,
              tintColor: context.isThemeDark ? keyboardNumberStyle.color : null,
            ).align(Alignment.center),
          ).click(() {
            //debugger();
            context.pop();
          }),
      ],
    );

    //前缀
    String? prefixText = '有效范围';
    // 获取范围对应的文本
    String? rangeText;
    if (widget.maxValue != null && widget.minValue != null) {
      rangeText =
          "[${_formatValue(widget.minValue)}~${_formatValue(widget.maxValue)}]";
    } else if (widget.maxValue != null) {
      rangeText = "[~${_formatValue(widget.maxValue)}]";
    } else if (widget.minValue != null) {
      rangeText = "[${_formatValue(widget.minValue)}~]";
    }
    if (rangeText != null) {
      rangeText = "$prefixText$rangeText";
    }

    return [
      //渐变阴影
      linearGradientWidget(
        [Colors.transparent, Colors.black12],
        height: 10,
        gradientDirection: Axis.vertical,
      ),
      [
        [
          if (isNullOrEmpty(_numberText))
            widget.hintText?.text(style: numberHintStyle),
          _numberText
              .text(style: numberValueStyle)
              .container(color: isClearAll ? globalTheme.accentColor : null),
        ].stack()?.expanded(),
        rangeText?.text(style: rangeHintStyle),
      ]
          .row()
          ?.container(
            color: globalTheme.surfaceBgColor,
            padding: const EdgeInsets.symmetric(vertical: kX, horizontal: kX),
          )
          .click(() {
        isClearAll = !isClearAll;
        updateState();
      }),
      keyboard.container(color: globalTheme.whiteSubBgColor),
    ]
        .column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
    )!
        .willPop(() async {
      return widget.canPop;
    });
  }

  String? _formatValue(num? value) {
    if (value == null) {
      return null;
    }
    return formatNumber(
      value,
      numType: widget._numType,
      digits: widget.maxDigits,
    );
  }

  /// 创建占位按钮
  Widget _createEmptyButton() {
    return "".text(style: keyboardNumberStyle).ignorePointer();
  }

  /// 创建数字按钮
  Widget _createNumberButton(String text, NumberKeyboardType type,
      [TextStyle? textStyle]) {
    return StateDecorationWidget(
      decoration: decoration,
      pressedDecoration: pressedDecoration,
      child: text
          .text(style: textStyle ?? keyboardNumberStyle)
          .align(Alignment.center),
    ).click(() {
      _onSelfInput(text, type);
    });
  }

  /// 检查输入的值是否有效
  bool _checkInputValue(String value) {
    if (value.isEmpty) {
      return true;
    }
    var number = num.tryParse(value);
    if (number == null) {
      return false;
    }
    if (widget.maxValue != null && number > widget.maxValue!) {
      return false;
    }
    if (widget.minValue != null && number < widget.minValue!) {
      return false;
    }
    return true;
  }

  /// 键盘输入了一个值
  void _onSelfInput(String value, NumberKeyboardType type) {
    //debugger();
    if (isClearAll || _numberText.toIntOrNull() == 0) {
      if (type == NumberKeyboardType.decimal) {
        _numberText = "0";
      } else {
        _numberText = "";
      }
      isClearAll = false;
    }

    if (type == NumberKeyboardType.backspace) {
      if (_numberText.isNotEmpty) {
        _numberText = _numberText.substring(0, _numberText.length - 1);
      }
    } else if (type == NumberKeyboardType.backspace) {
      if (_numberText.startsWith("-")) {
        _numberText = _numberText.substring(1);
      } else {
        _numberText = "-$_numberText";
      }
    } else if (type == NumberKeyboardType.decimal) {
      if (isSupportDecimal && !_numberText.contains(".")) {
        _numberText += value;
      }
    } else {
      //检查小数点后面的位数是否超过了限制
      if (isSupportDecimal && _numberText.contains(".")) {
        var split = _numberText.split(".");
        if (split.length > 1 && split[1].length >= widget.maxDigits) {
          return;
        }
      }

      if (_numberText.length < widget.maxLength) {
        _numberText += value;
      }
    }
    setState(() {});
  }
}

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

  /// 键盘类型: 完成输入
  finish,
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
  final NumberKeyboardInputController _controller =
      NumberKeyboardInputController();

  final borderRadius = 4.0;

  late final rangeHintStyle = const TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  late final TextStyle numberValueStyle;
  late final numberHintStyle = const TextStyle(
    fontSize: 20,
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

  @override
  void initState() {
    super.initState();
    final globalTheme = GlobalTheme.of(context);
    _controller
      ..isClearAll = true
      ..numType = widget._numType
      ..maxDigits = widget.maxDigits
      ..minValue = widget.minValue
      ..maxValue = widget.maxValue
      ..maxLength = widget.maxLength
      ..initInputValue(widget.number);
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

    final keyboard = NumberKeyboardLayout(
      showDecimal: isSupportDecimal,
      showNegative: isSupportDecimal,
      onKeyboardInput: (keyboard, type) {
        if (type == NumberKeyboardType.finish) {
          _onSelfFinishInput();
        } else {
          _onSelfInput(keyboard, type);
        }
      },
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
          if (isNullOrEmpty(_controller.numberText))
            widget.hintText?.text(style: numberHintStyle),
          _controller.numberText.text(style: numberValueStyle).container(
              color: _controller.isClearAll ? globalTheme.accentColor : null),
        ].stack()?.expanded(),
        rangeText?.text(style: rangeHintStyle),
      ]
          .row()
          ?.container(
            color: globalTheme.surfaceBgColor,
            padding: const EdgeInsets.symmetric(vertical: kX, horizontal: kX),
          )
          .click(() {
        _controller.isClearAll = !_controller.isClearAll;
        updateState();
      }),
      keyboard.backgroundColor(globalTheme.whiteSubBgColor),
    ]
        .column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
        )!
        .adaptiveTablet(context)
        .willPop(() async {
      return widget.canPop;
    }).material();
  }

  String? _formatValue(num? value) {
    return _controller.formatValue(value);
  }

  /// 完成输入时调用
  void _onSelfFinishInput() {
    //debugger();
    _controller.onKeyboardInputFinish(context);
    updateState();
  }

  /// 键盘输入了一个值
  void _onSelfInput(String value, NumberKeyboardType type) {
    _controller.onKeyboardInput(value, type);
    updateState();
  }
}

/// 按键布局
class NumberKeyboardLayout extends StatefulWidget {
  /// 显示小数按键
  final bool showDecimal;

  /// 显示正负按键
  final bool showNegative;

  /// 每个按键的高度
  final double itemHeight;

  /// 每个按键之间的间隙
  final double itemGap;

  /// 每个按键的圆角
  final double itemBorderRadius;

  /// 键盘输入回调
  final void Function(String keyboard, NumberKeyboardType type)?
      onKeyboardInput;

  const NumberKeyboardLayout({
    super.key,
    this.showDecimal = true,
    this.showNegative = true,
    this.itemHeight = 40,
    this.itemGap = 6,
    this.itemBorderRadius = 4,
    this.onKeyboardInput,
  });

  @override
  State<NumberKeyboardLayout> createState() => _NumberKeyboardLayoutState();
}

class _NumberKeyboardLayoutState extends State<NumberKeyboardLayout> {
  late final BoxDecoration decoration;
  late final pressedDecoration = fillDecoration(
    color: Colors.black12,
    borderRadius: widget.itemBorderRadius,
  );

  late final TextStyle keyboardNumberStyle;

  //--

  /// 是否支持小数
  bool get isSupportDecimal => widget.showDecimal;

  /// 是否支持负数
  bool get isSupportNegative => widget.showNegative;

  /// 是否要显示收起键盘
  bool get isShowPackUp => !isSupportDecimal || !isSupportNegative;

  @override
  void initState() {
    super.initState();
    final globalTheme = GlobalTheme.of(context);
    decoration = fillDecoration(
      color: globalTheme.surfaceBgColor,
      borderRadius: widget.itemBorderRadius,
    );

    keyboardNumberStyle = TextStyle(
      fontSize: 16,
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
        widthType: ConstraintsType.matchParent,
        heightType: ConstraintsType.wrapContent,
      ),
      childConstraints: BoxConstraints(minHeight: widget.itemHeight),
      childGap: widget.itemGap,
      equalWidthRange: "",
      lineMaxChildCount: 4,
      padding: EdgeInsets.all(widget.itemGap),
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
            borderRadius: widget.itemBorderRadius,
          ),
          pressedDecoration: pressedDecoration,
          child: LibRes.of(context)
              .libFinish
              .text(style: keyboardNumberStyle)
              .align(Alignment.center),
        ).click(() {
          _onSelfInput("", NumberKeyboardType.finish);
        }).flowLayoutData(
          stack: true,
          weight: 1.0 / 4,
          constraints: BoxConstraints(
            minHeight: widget.itemHeight * 3 + widget.itemGap * 2,
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
          _createNumberButton("±", NumberKeyboardType.positiveNegative),
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
    return keyboard;
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

  /// 创建占位按钮
  Widget _createEmptyButton() {
    return "".text(style: keyboardNumberStyle).ignorePointer();
  }

  /// 键盘输入了一个值
  void _onSelfInput(String value, NumberKeyboardType type) {
    widget.onKeyboardInput?.call(value, type);
  }
}

/// 键盘输入控制器
class NumberKeyboardInputController {
  /// 输入的数字类型
  NumType? numType;

  /// 小数时, 保留后几位
  int maxDigits = 2;

  /// 最大长度
  int maxLength = 9;

  /// 最大值
  num? maxValue;

  /// 最小值
  num? minValue;

  //--

  /// 当前输入的文本
  String numberText = "";

  /// 是否清空所有
  bool isClearAll = false;

  /// 是否支持小数
  bool get isSupportDecimal => numType == NumType.d;

  /// 初始化当前输入的值
  void initInputValue(num? value) {
    numberText = formatValue(value) ?? "";
  }

  //--

  /// 格式化[value]成字符串
  String? formatValue(num? value) {
    if (value == null) {
      return null;
    }
    return formatNumber(
      value,
      numType: numType,
      digits: maxDigits,
    );
  }

  /// 检查输入的值是否有效
  bool checkInputValue(String value) {
    if (value.isEmpty) {
      return true;
    }
    var number = num.tryParse(value);
    if (number == null) {
      return false;
    }
    if (maxValue != null && number > maxValue!) {
      return false;
    }
    if (minValue != null && number < minValue!) {
      return false;
    }
    return true;
  }

  /// 完成输入时调用
  /// @return 验证没问题后, 返回输入的键盘值
  @callPoint
  num? onKeyboardInputFinish(BuildContext? context) {
    //debugger();
    if (checkInputValue(numberText)) {
      if (isSupportDecimal) {
        final result = numberText.toDoubleOrNull();
        context?.pop(result);
        return result;
      } else {
        final result = numberText.toIntOrNull();
        context?.pop(result);
        return result;
      }
    } else {
      if (context != null) {
        Feedback.forLongPress(context);
      }
      isClearAll = true;
    }
    return null;
  }

  /// 键盘输入了一个值
  @callPoint
  void onKeyboardInput(String value, NumberKeyboardType type) {
    //debugger();
    if (isClearAll || numberText.toIntOrNull() == 0) {
      if (type == NumberKeyboardType.decimal) {
        numberText = "0";
      } else {
        numberText = "";
      }
      isClearAll = false;
    }

    if (type == NumberKeyboardType.backspace) {
      if (numberText.isNotEmpty) {
        numberText = numberText.substring(0, numberText.length - 1);
      }
    } else if (type == NumberKeyboardType.positiveNegative) {
      if (numberText.startsWith("-")) {
        numberText = numberText.substring(1);
      } else {
        numberText = "-$numberText";
      }
    } else if (type == NumberKeyboardType.decimal) {
      if (isSupportDecimal && !numberText.contains(".")) {
        numberText += value;
      }
    } else {
      //检查小数点后面的位数是否超过了限制
      if (isSupportDecimal && numberText.contains(".")) {
        var split = numberText.split(".");
        if (split.length > 1 && split[1].length >= maxDigits) {
          return;
        }
      }

      if (numberText.length < maxLength) {
        numberText += value;
      }
    }
  }
}

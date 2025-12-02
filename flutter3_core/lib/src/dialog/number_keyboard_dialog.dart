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

  /// 键盘类型: 清空
  /// All Clear
  clear,

  /// 键盘类型: 小数点
  decimal,

  /// 键盘类型: 正负
  positiveNegative,

  /// 键盘类型: 完成输入
  finish,
}

/// 数字键盘输入对话框
/// - 如果是小数, 返回小数
/// - 如果是整数, 返回整数
///
/// - [NumberKeyboardLayout]
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

  /// 数字文本样式
  @defInjectMark
  final TextStyle? numberStyle;

  //--

  /// 允许输入的最大长度, 包含小数点
  final int maxLength;

  /// 提示文本
  final String? hintText;

  /// 是否可以返回
  final bool canPop;

  //---

  /// 是否支持负数, 不指定则通过[minValue]自动判断
  final bool? supportNegative;

  //--

  /// 拦截输入完成的默认处理
  final ContextNumNullCallback? onNumberInputFinishIntercept;

  /// 输入完成回调
  final NumNullCallback? onNumberResult;

  //--

  /// 输入框的边距
  @defInjectMark
  final EdgeInsetsGeometry? numberPadding;

  /// 是否显示顶部的阴影
  final bool showTopShadow;

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
    this.onNumberInputFinishIntercept,
    this.onNumberResult,
    this.showTopShadow = true,
    this.numberStyle,
    this.numberPadding,
    NumType? numType,
  }) : _numType = numType ?? (number is int ? NumType.i : NumType.d);

  @override
  State<NumberKeyboardDialog> createState() => _NumberKeyboardDialogState();
}

class _NumberKeyboardDialogState extends State<NumberKeyboardDialog> {
  final NumberKeyboardInputController _controller =
      NumberKeyboardInputController();

  final borderRadius = 4.0;

  /// 范围提示文本样式
  late final rangeHintStyle = const TextStyle(fontSize: 14, color: Colors.grey);

  /// 数字文本样式
  late final TextStyle numberValueStyle;

  /// 输入为空时, 提示文本样式
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
      ..isFirstClearAll = true
      ..numType = widget._numType
      ..maxDigits = widget.maxDigits
      ..minValue = widget.minValue
      ..maxValue = widget.maxValue
      ..maxLength = widget.maxLength
      ..onNumberInputFinishIntercept = widget.onNumberInputFinishIntercept
      ..initInputValue(widget.number);
    numberValueStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: context.isThemeDark
          ? globalTheme.textTitleStyle.color
          : globalTheme.textGeneralStyle.color,
    );
  }

  @override
  void didUpdateWidget(covariant NumberKeyboardDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller
      ..numType = widget._numType
      ..maxDigits = widget.maxDigits
      ..minValue = widget.minValue
      ..maxValue = widget.maxValue
      ..maxLength = widget.maxLength
      ..onNumberInputFinishIntercept = widget.onNumberInputFinishIntercept;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final lRes = libRes(context);

    final keyboard = NumberKeyboardLayout(
      showDecimal: isSupportDecimal,
      showNegative: isSupportNegative,
      onKeyboardInput: (keyboard, type) {
        if (type == NumberKeyboardType.finish) {
          _onSelfFinishInput();
        } else {
          _onSelfInput(keyboard, type);
        }
      },
    );

    //前缀
    String? prefixText = lRes?.libValidRangeTip ?? '有效范围';
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
          if (widget.showTopShadow)
            linearGradientWidget(
              [Colors.transparent, Colors.black12],
              height: 10,
              gradientDirection: Axis.vertical,
            ),
          //输入框
          [
                [
                  if (isNullOrEmpty(_controller.numberText))
                    widget.hintText?.text(style: numberHintStyle),
                  _controller.numberText
                      .text(
                        style: (widget.numberStyle ?? numberValueStyle)
                            .copyWith(
                              color: context.isThemeDark
                                  ? globalTheme.textTitleStyle.color
                                  : globalTheme.textGeneralStyle.color,
                            ),
                      )
                      .container(
                        color: _controller.isFirstClearAll
                            ? globalTheme.accentColor
                            : null,
                      ),
                ].stack()?.expanded(),
                rangeText?.text(style: rangeHintStyle),
              ]
              .row()
              ?.container(
                color: globalTheme.surfaceBgColor,
                padding:
                    widget.numberPadding ??
                    const EdgeInsets.symmetric(vertical: kX, horizontal: kX),
              )
              .click(() {
                _controller.isFirstClearAll = !_controller.isFirstClearAll;
                updateState();
              }),
          //键盘布局
          keyboard.safeBottomArea().backgroundColor(
            globalTheme.whiteSubBgColor,
          ),
        ]
        .column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
        )!
        .adaptiveTablet(context)
        .willPop(() async {
          return widget.canPop;
        })
        .material();
  }

  String? _formatValue(num? value) {
    return _controller.formatValue(value);
  }

  /// 完成输入时调用
  void _onSelfFinishInput() {
    //debugger();
    final result = _controller.onKeyboardInputFinish(context);
    widget.onNumberResult?.call(result);
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
    radius: widget.itemBorderRadius,
  );

  /// [NumberKeyboardType.finish] 完成按键的文本样式
  late final TextStyle keyboardFinishStyle;

  /// [NumberKeyboardType.number] 完成按键的文本样式
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
      radius: widget.itemBorderRadius,
    );

    keyboardFinishStyle = TextStyle(
      fontSize: 16,
      color: context.isThemeDark
          ? globalTheme.textTitleStyle.color
          : globalTheme.textGeneralStyle.color,
      fontWeight: FontWeight.bold,
    );
    keyboardNumberStyle = keyboardFinishStyle.copyWith(fontSize: 22);
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
        ).click(
          () {
            _onSelfInput("", NumberKeyboardType.backspace);
          },
          onLongPress: () {
            _onSelfInput("", NumberKeyboardType.clear);
          },
        ),
        //--
        _createNumberButton("4", NumberKeyboardType.number),
        _createNumberButton("5", NumberKeyboardType.number),
        _createNumberButton("6", NumberKeyboardType.number),
        StateDecorationWidget(
              decoration: fillDecoration(
                color: globalTheme.accentColor,
                radius: widget.itemBorderRadius,
              ),
              pressedDecoration: pressedDecoration,
              child: LibRes.of(context).libFinish
                  .text(style: keyboardFinishStyle)
                  .align(Alignment.center),
            )
            .click(() {
              _onSelfInput("", NumberKeyboardType.finish);
            })
            .flowLayoutData(
              stack: true,
              weight: 1.0 / 4,
              constraints: BoxConstraints(
                minHeight: widget.itemHeight * 3 + widget.itemGap * 2,
              ),
            ),
        //--
        _createEmptyButton(),
        _createNumberButton("7", NumberKeyboardType.number),
        _createNumberButton("8", NumberKeyboardType.number),
        _createNumberButton("9", NumberKeyboardType.number),
        _createEmptyButton(),
        if (isSupportDecimal)
          _createNumberButton(".", NumberKeyboardType.decimal),
        if (isSupportDecimal || isSupportNegative)
          _createNumberButton("0", NumberKeyboardType.number)
        else
          _createNumberButton(
            "0",
            NumberKeyboardType.number,
          ).flowLayoutData(weight: 1.0 / 4 * 2, excludeGapCount: 2),
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
  Widget _createNumberButton(
    String text,
    NumberKeyboardType type, [
    TextStyle? textStyle,
  ]) {
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

  /// 初始化的值
  num? initValue;

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
  /// - [numberText]
  /// - [numberValue]
  String numberText = "";

  /// 首次输入, 是否要清空所有.
  bool isFirstClearAll = false;

  /// 是否支持小数
  bool get isSupportDecimal => numType == NumType.d;

  //--

  /// 拦截输入完成事件
  ContextNumNullCallback? onNumberInputFinishIntercept;

  /// 初始化当前输入的值
  void initInputValue(num? value) {
    initValue = value;
    numberText = formatValue(value) ?? "";
  }

  //--

  /// 格式化[value]成字符串
  String? formatValue(num? value) {
    if (value == null) {
      return null;
    }
    return formatNumber(value, numType: numType, digits: maxDigits);
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
    if (number != initValue) {
      if (maxValue != null && number > maxValue!) {
        return false;
      }
      if (minValue != null && number < minValue!) {
        return false;
      }
    }
    return true;
  }

  /// - [numberText]
  /// - [numberValue]
  @api
  num? get numberValue {
    if (checkInputValue(numberText)) {
      if (isSupportDecimal) {
        final result = numberText.toDoubleOrNull();
        return result;
      } else {
        final result = numberText.toIntOrNull();
        return result;
      }
    }
    return null;
  }

  /// 完成输入时调用
  /// @return 验证没问题后, 返回输入的键盘值
  @callPoint
  num? onKeyboardInputFinish(BuildContext? context, {Object? popResult}) {
    //debugger();
    if (checkInputValue(numberText)) {
      if (isSupportDecimal) {
        final result = numberText.toDoubleOrNull();
        if (onNumberInputFinishIntercept == null) {
          context?.pop(result: popResult ?? result);
        } else {
          onNumberInputFinishIntercept?.call(context, result);
        }
        return result;
      } else {
        final result = numberText.toIntOrNull();
        if (onNumberInputFinishIntercept == null) {
          context?.pop(result: popResult ?? result);
        } else {
          onNumberInputFinishIntercept?.call(context, result);
        }
        return result;
      }
    } else {
      if (context != null) {
        Feedback.forLongPress(context);
      }
      isFirstClearAll = true;
    }
    return null;
  }

  /// 键盘输入了一个值
  @callPoint
  void onKeyboardInput(String value, NumberKeyboardType type) {
    //debugger();
    if (type == NumberKeyboardType.finish) {
      return;
    }
    if (isFirstClearAll || numberText.toIntOrNull() == 0) {
      if (type == NumberKeyboardType.decimal) {
        numberText = "0";
      } else {
        numberText = "";
      }
      isFirstClearAll = false;
    }

    if (type == NumberKeyboardType.backspace) {
      if (numberText.isNotEmpty) {
        numberText = numberText.substring(0, numberText.length - 1);
      }
    } else if (type == NumberKeyboardType.clear) {
      numberText = "";
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

  /// 处理桌面端按键事件
  /// - [NumberKeyEventDetectorMixin]
  ///
  /// @return true 表示处理了, 否则返回false
  @callPoint
  @desktopLayout
  bool onKeyEventInput(
    BuildContext? context,
    KeyEvent event, {
    Object? popResult,
  }) {
    assert(() {
      l.d("event[${event.character}]->$event");
      return true;
    }());
    if (event.isKeyDownOrRepeat) {
      final character = event.character;
      if (event.isBackKey) {
        onKeyboardInput("", NumberKeyboardType.backspace);
        return true;
      } else if (event.isEnterKey) {
        //onKeyboardInput("", NumberKeyboardType.finish);
        onKeyboardInputFinish(context, popResult: popResult);
        return true;
      } else if (character != null) {
        //有效输入
        if (character == ".") {
          onKeyboardInput(character, NumberKeyboardType.decimal);
          return true;
        } else if (character == "-" || character == "+") {
          onKeyboardInput(character, NumberKeyboardType.positiveNegative);
          return true;
        } else if (character.isInt) {
          onKeyboardInput(character, NumberKeyboardType.number);
          return true;
        }
      }
    }
    return false;
  }
}

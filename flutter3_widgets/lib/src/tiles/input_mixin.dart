part of '../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
///

enum InputBorderType {
  /// 无
  /// [InputBorder.none]
  none,

  /// [OutlineInputBorder]
  underline,

  /// [UnderlineInputBorder]
  outline,
}

/// 不使用长度显示小部件构建
/// [TextField.buildCounter]
InputCounterWidgetBuilder get noneInputBuildCounter => (context,
        {required currentLength, required maxLength, required isFocused}) {
      return null;
    };

/// 输入混入
/// [InputStateMixin]
/// [kInputPadding]
mixin InputMixin {
  /// 指定输入配置
  TextFieldConfig? get inputFieldConfig => null;

  /// 输入提示
  String? get inputHint => null;

  /// 默认输入的文本
  String? get inputText => null;

  /// 是否自动获取焦点
  bool? get autofocus => false;

  /// [kInputPadding]
  EdgeInsets? get inputPadding => null;

  /// 文本对齐方式
  TextAlign get inputTextAlign => TextAlign.start;

  /// 并不需要在此方法中更新界面
  ValueChanged<String>? get onInputTextChanged => null;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  FutureValueCallback<String>? get onInputTextConfirmChange => null;

  /// 下划线的输入框样式
  InputBorderType get inputBorderType => InputBorderType.underline;

  /// 输入的最大行数
  int? get inputMaxLines => null;

  /// 输入的最大字符长度
  int? get inputMaxLength => null;

  /// 是否显示输入计数器
  bool? get showInputCounter => null;

  /// 输入限制字符
  /// [SingleInputWidget.inputFormatters]
  List<TextInputFormatter>? get inputFormatters => null;

  /// 键盘输入的类型
  /// [SingleInputWidget.keyboardType]
  TextInputType? get inputKeyboardType => null;
}

/// 输入状态的混入
/// [InputMixin]
mixin InputStateMixin<T extends StatefulWidget> on State<T> {
  InputMixin get inputMixin => widget as InputMixin;

  /// 输入框初始化的值
  String? initialInputText;

  /// 输入框当前的值, 如果和[initialInputText]值一致, 则未做修改
  String? currentInputText;

  /// 输入框配置
  late final TextFieldConfig inputMixinConfig = TextFieldConfig(
    text: inputMixin.inputText,
    hintText: inputMixin.inputHint,
    autofocus: inputMixin.autofocus,
    textInputAction: TextInputAction.done,
    onChanged: (value) {
      //FocusScope.of(context).requestFocus(_passwordFocusNode);
      //debugger();
      onSelfInputTextChanged(value);
    },
  );

  /// [TextFieldConfig]
  TextFieldConfig get _inputMixinConfig =>
      inputMixin.inputFieldConfig ?? inputMixinConfig;

  /// 文本是否发生了改变
  bool get isInputChanged => initialInputText != currentInputText;

  /// 文本是否是默认值
  bool get isInputDefault => initialInputText == currentInputText;

  /// 当前的文本是否为空
  bool get isInputEmpty => isNil(currentInputText);

  /// 构建对应的小部件
  @callPoint
  Widget buildInputWidgetMixin(
    BuildContext context, {
    TextAlign? textAlign,
    InputBorder? border,
    InputBorder? focusedBorder,
    InputBorder? disabledBorder,
    InputCounterWidgetBuilder? inputBuildCounter,
    double? prefixIconSize = kSuffixIconSize,
    double? suffixIconSize = kSuffixIconSize,
    EdgeInsetsGeometry? prefixIconPadding,
    EdgeInsetsGeometry? suffixIconPadding,
    BoxConstraints? prefixIconConstraints = kPrefixIconConstraints,
    BoxConstraints? suffixIconConstraints = kSuffixIconConstraints,
  }) {
    final Widget input = SingleInputWidget(
      config: _inputMixinConfig,
      maxLines: inputMixin.inputMaxLines,
      maxLength: inputMixin.inputMaxLength,
      showInputCounter: inputMixin.showInputCounter,
      keyboardType: inputMixin.inputKeyboardType,
      inputFormatters: inputMixin.inputFormatters,
      textAlign: textAlign ?? inputMixin.inputTextAlign,
      border: border,
      focusedBorder: focusedBorder,
      disabledBorder: disabledBorder,
      inputBuildCounter: inputBuildCounter,
      inputBorderType: inputMixin.inputBorderType,
      contentPadding: inputMixin.inputPadding,
      prefixIconSize: prefixIconSize,
      suffixIconSize: suffixIconSize,
      prefixIconPadding: prefixIconPadding,
      suffixIconPadding: suffixIconPadding,
      prefixIconConstraints: prefixIconConstraints,
      suffixIconConstraints: suffixIconConstraints,
      /*autoShowSuffixIcon: false,*/
    );
    return input;
  }

  /// 输入框的值改变回调
  @overridePoint
  void onSelfInputTextChanged(String toValue) async {
    if (inputMixin.onInputTextConfirmChange != null) {
      final result = await inputMixin.onInputTextConfirmChange!(toValue);
      if (result != true) {
        return;
      }
    }
    currentInputText = toValue;
    inputMixin.onInputTextChanged?.call(toValue);
    updateState();
  }

  @override
  void initState() {
    initialInputText = inputMixin.inputText;
    currentInputText = initialInputText;
    _inputMixinConfig.updateText(currentInputText);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    initialInputText = inputMixin.inputText;
    currentInputText = initialInputText;
    _inputMixinConfig.updateText(currentInputText);
    super.didUpdateWidget(oldWidget);
  }
}

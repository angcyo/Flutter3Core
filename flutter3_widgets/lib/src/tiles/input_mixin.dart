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
  TextFieldConfig? get inputFieldConfig;

  /// 输入提示
  String? get inputHint;

  /// 默认输入的文本
  String? get inputText;

  /// [kInputPadding]
  EdgeInsets? get inputPadding;

  /// 并不需要在此方法中更新界面
  ValueChanged<String>? get onInputTextChanged;

  /// 在改变时, 需要进行的确认回调
  /// 返回false, 则不进行改变
  FutureValueCallback<String>? get onInputTextConfirmChange;

  /// 下划线的输入框样式
  InputBorderType get inputBorderType;

  /// 输入的最大行数
  int? get inputMaxLines;

  /// 输入的最大字符长度
  int? get inputMaxLength;

  /// 输入限制字符
  /// [SingleInputWidget.inputFormatters]
  List<TextInputFormatter>? get inputFormatters;

  /// 键盘输入的类型
  /// [SingleInputWidget.keyboardType]
  TextInputType? get inputKeyboardType;
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
    textInputAction: TextInputAction.done,
    onChanged: (value) {
      //FocusScope.of(context).requestFocus(_passwordFocusNode);
      //debugger();
      onInputTextChanged(value);
    },
  );

  /// [TextFieldConfig]
  TextFieldConfig get _inputMixinConfig =>
      inputMixin.inputFieldConfig ?? inputMixinConfig;

  /// 文本是否发生了改变
  bool get isInputChanged => initialInputText != currentInputText;

  /// 当前的文本是否为空
  bool get isInputEmpty => isNil(currentInputText);

  /// 构建对应的小部件
  @callPoint
  Widget buildInputWidgetMixin(
    BuildContext context, {
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
    Widget input = SingleInputWidget(
      config: _inputMixinConfig,
      maxLines: inputMixin.inputMaxLines,
      maxLength: inputMixin.inputMaxLength,
      keyboardType: inputMixin.inputKeyboardType,
      inputFormatters: inputMixin.inputFormatters,
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
  void onInputTextChanged(String toValue) async {
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

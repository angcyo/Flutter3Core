part of '../../../flutter3_widgets.dart';

/// 输入框小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///
/// icons图标, m3图标列表
/// https://fonts.google.com/icons
/// 输入框控制配置
/// - [SingleInputWidget]
/// - [TextField]
class TextFieldConfig {
  /// 输入控制, 用于获取输入内容
  final TextEditingController controller;

  /// 是否自动获取焦点, 具有焦点就会自动显示键盘
  /// [TextField.autofocus]
  final bool? autofocus;

  /// 焦点处理
  /// [EditableTextState.requestKeyboard]
  /// [FocusNode.requestFocus]
  FocusNode? focusNode;

  /// 后缀按钮的焦点控制
  FocusNode? suffixFocusNode;

  /// 前缀按钮的焦点控制
  FocusNode? prefixFocusNode;

  /// 密码输入控制
  final ObscureNode obscureNode;

  /// 是否有焦点
  bool get hasFocus => focusNode?.hasFocus == true;

  /// 是否为空
  bool get isEmpty => text.isEmpty;

  /// 输入的文本
  /// - [value]
  /// - [text]
  String get text => controller.text;

  /// 输入框选中的文本范围
  TextSelection get selection => controller.selection;

  /// 设置选中的文本范围
  set selection(TextSelection value) {
    controller.selection = value;
  }

  /// 选中的文本
  /// - [TextRange.isCollapsed] 未选中文本
  String get selectedText => controller.selection.textInside(text);

  /// [updateText]
  set text(String? text) {
    updateText(text);
  }

  /// 输入的文本
  /// - [value]
  /// - [text]
  TextEditingValue get value => controller.value;

  /// [updateText]
  set value(TextEditingValue value) {
    updateValue(value);
  }

  /// 调用此方法更新输入框的值
  /// 此方法会在自动绑定[_SingleInputWidgetState._updateFieldText]
  /// 此方法会在自动绑定[_SingleInputWidgetState._updateFieldValue]
  @autoInjectMark
  void Function(TextEditingValue value, bool? notify)? updateFieldValueFn;

  /// 是否保持选择范围
  @configProperty
  bool keepSelectionRange = false;

  //region TextField的属性,优先级低

  /// 浮动在输入框上方的提示文字, 单独指定[labelText]也会[hintText]的效果
  /// [SingleInputWidget.labelText]
  String? labelText;

  /// [SingleInputWidget.labelStyle]
  TextStyle? labelTextStyle;

  /// [labelText]的回调版本
  IntlTextBuilder? labelTextBuilder;

  /// 输入框内的提示文字, 占位提示文本
  /// [SingleInputWidget.hintText]
  String? hintText;

  /// [SingleInputWidget.hintStyle]
  TextStyle? hintTextStyle;

  /// [hintText]的回调版本
  IntlTextBuilder? hintTextBuilder;

  /// 前缀图标小部件
  /// [SingleInputWidget.prefixIcon]
  Widget? prefixIcon;

  /// 键盘上的输入类型, 比如完成, 下一步等
  /// - [onSubmitted] 配合此方法, 请求下一个输入框的焦点.
  /// - [SingleInputWidget.textInputAction]
  /// - [TextInputAction.done]
  /// - [TextInputAction.search]
  /// - [TextInputAction.newline] 多行输入
  TextInputAction? textInputAction;

  /// 输入过滤
  /// [SingleInputWidget.inputFormatters]
  List<TextInputFormatter>? inputFormatters;

  /// 用来构建输入长度等信息的回调
  /// [TextField.buildCounter]
  InputCounterWidgetBuilder? inputBuildCounter;

  /// [SingleInputWidget.keyboardType]
  TextInputType? keyboardType;

  //endregion 覆盖TextField的属性,优先级低

  //region 回调方法

  /// 回调

  /// [TextField.onChanged]
  final ValueChanged<String>? onChanged;

  final ContextValueChanged<String>? onContextValueChanged;

  /// [textInputAction]
  /// [TextField.onSubmitted]
  final ValueChanged<String>? onSubmitted;

  /// [TextField.onEditingComplete]
  final VoidCallback? onEditingComplete;

  /// 焦点改变后的回调
  /// [FocusNode]
  /// 由[_SingleInputWidgetState._onFocusChanged]驱动
  final DoubleValueChanged<bool, String>? onFocusAction;

  //endregion 回调方法

  //region 自动完成

  /// 设置此值后, 自动激活自动完成功能
  ///
  /// 在此方法中[buildWrapAutocomplete]使用[Autocomplete]小部件包裹
  ///
  /// @return 返回值即自动完成的提示选项列表
  final FutureOr<Iterable<Object>> Function(
    TextFieldConfig config,
    TextEditingValue textEditingValue,
  )?
  autoOptionsBuilder;

  /// 选项转文本类型
  /// [buildWrapAutocomplete]
  final AutocompleteOptionToString<Object> autoDisplayStringForOption;

  final OptionsViewOpenDirection autoOptionsViewOpenDirection;

  /// 自动选项选中后的回调
  final AutocompleteOnSelected<Object>? onAutoOptionSelected;

  //--

  /// 构建弹出窗口的布局
  /// @return 弹窗显示的界面
  final Widget Function(
    TextFieldConfig config,
    Rect anchorBounds,
    BuildContext context,
    AutocompleteOnSelected<Object> onSelected,
    Iterable<Object> options,
  )?
  autoOptionsViewBuilder;

  /// 构建弹出窗口, 内容包裹小部件
  final WidgetWrapBuilder? autoOverlayBodyWrapBuilder;

  /// 构建弹出窗口, 选项小部件构建
  final AutocompleteOptionItemWidgetBuilder? autoOptionItemBuilder;

  //--

  //样式
  final double autoOverlayElevation;
  final Color? autoOverlayColor;
  final Color? autoOverlayShadowColor;
  final ShapeBorder? autoOverlayShape;
  final BorderRadiusGeometry? autoOverlayBorderRadius;

  /// 弹窗窗口最大高度
  final double autoOptionsMaxHeight;

  /// 自定义的标签数据
  final String? tag;

  TextSelection? _lastSelection;

  //endregion 自动完成

  /// [SingleInputWidget] 的配置信息
  TextFieldConfig({
    String? text /*默认文本*/,
    TextEditingController? controller,
    FocusNode? focusNode /*请求焦点*/,
    bool? obscureText /*是否是密码*/,
    bool notifyDefaultTextChange = false /*是否要触发默认文本改变*/,
    FocusNode? suffixFocusNode,
    FocusNode? prefixFocusNode,
    this.autofocus,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.updateFieldValueFn,
    this.labelText,
    this.labelTextStyle,
    this.labelTextBuilder,
    this.hintText,
    this.hintTextStyle,
    this.hintTextBuilder,
    this.inputBuildCounter,
    this.prefixIcon,
    this.onChanged,
    this.onContextValueChanged,
    this.onEditingComplete,
    this.onFocusAction,
    this.keepSelectionRange = false,
    //--
    this.autoOptionsBuilder,
    this.autoDisplayStringForOption = RawAutocomplete.defaultStringForOption,
    this.autoOptionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.onAutoOptionSelected,
    this.autoOptionsViewBuilder,
    this.autoOverlayBodyWrapBuilder,
    this.autoOptionItemBuilder,
    this.autoOverlayElevation = 4,
    this.autoOverlayColor,
    this.autoOverlayShadowColor,
    this.autoOverlayShape,
    this.autoOverlayBorderRadius,
    this.autoOptionsMaxHeight = 200,
    this.tag,
  }) : controller = controller ?? TextEditingController(text: text),
       focusNode = focusNode ?? FocusNode(),
       suffixFocusNode = suffixFocusNode ?? FocusNode(skipTraversal: true),
       prefixFocusNode = prefixFocusNode ?? FocusNode(skipTraversal: true),
       obscureNode = ObscureNode(obscureText ?? false) {
    if (notifyDefaultTextChange) {
      onChanged?.call(this.controller.value.text);
      //onContextValueChanged?.call(this, this.controller.text);
    }
  }

  //region api

  /// 请求焦点
  @api
  void requestFocus([BuildContext? context]) {
    debugger();
    final node = focusNode;
    if (node == null) {
      return;
    }
    if (context == null) {
      node.requestFocus();
    } else {
      FocusScope.of(context).requestFocus(node);
    }
  }

  /// 移除焦点
  @api
  void removeFocus([BuildContext? context]) {
    debugger();
    final node = focusNode;
    if (node == null) {
      return;
    }
    if (context == null) {
      node.unfocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  ///[updateText]
  ///[updateValue]
  @api
  void updateThis({List<TextInputFormatter>? inputFormatters}) {
    this.inputFormatters = inputFormatters;
    updateValue(value, inputFormatters: inputFormatters);
  }

  /// 更新输入框的文本
  /// [inputFormatters] 限制输入的字符
  /// [restoreSelection] 是否恢复选中位置
  /// [notify] 是否要通知改变, 默认true
  @api
  void updateText(
    String? text, {
    List<TextInputFormatter>? inputFormatters,
    bool? restoreSelection = false,
    bool? notify,
  }) {
    if (this.text == text) {
      //debugger();
      if (notify == true) {
        assert(() {
          l.v('${classHash()} 相同的text[$text], 忽略更新[updateText]');
          return true;
        }());
      }
      return;
    }
    text ??= '';
    final selection = value.selection;
    updateValue(
      //TextEditingValue(text: text),
      value.copyWith(
        text: text,
        selection: restoreSelection == true
            ? selection.copyWith(
                baseOffset: clamp(selection.baseOffset, 0, text.length),
                extentOffset: clamp(selection.extentOffset, 0, text.length),
              )
            : TextSelection.collapsed(offset: text.length),
      ),
      /*TextEditingValue.empty.copyWith(
          text: text ?? '',
          selection: const TextSelection.collapsed(offset: 0)),*/
      inputFormatters: inputFormatters,
      notify: notify,
    );
  }

  /// 更新输入框的值
  /// [inputFormatters] 限制输入的字符
  @api
  void updateValue(
    TextEditingValue value, {
    List<TextInputFormatter>? inputFormatters,
    bool? notify,
  }) {
    //过滤
    TextEditingValue oldValue = TextEditingValue(
      text: "",
      selection: selection,
    );
    /*TextEditingValue value = TextEditingValue(text: text);*/
    value =
        (inputFormatters ?? this.inputFormatters)?.fold<TextEditingValue>(
          value,
          (newValue, formatter) {
            final resultValue = formatter.formatEditUpdate(oldValue, newValue);
            oldValue = newValue;
            return resultValue;
          },
        ) ??
        value;

    if (this.value == value) {
      assert(() {
        l.w('相同的TextEditingValue[$value], 忽略更新');
        return true;
      }());
      return;
    }

    //debugger();
    if (updateFieldValueFn == null) {
      /*assert(() {
        l.w('无法更新TextEditingValue[$text],小部件可能还未[mounted]');
        return true;
      }());*/
      controller.value = value;
    } else {
      //update
      updateFieldValueFn?.call(value, notify);
    }
  }

  /// 当焦点发生改变时触发
  @callPoint
  void onFocusChanged() {
    final hasFocus = this.hasFocus;
    if (hasFocus) {
      //恢复选中范围
      if (keepSelectionRange) {
        final lastSelection = _lastSelection;
        if (lastSelection != null && !lastSelection.isCollapsed) {
          selection = lastSelection;
        }
      }
    } else {
      _lastSelection = selection;
    }
    onFocusAction?.call(hasFocus, text);
  }

  //endregion api

  //region Autocomplete

  /// [TextField.onSubmitted]驱动
  @callPoint
  void onTextFieldSubmitted(String value) {
    onSubmitted?.call(value);
    _autocompleteFieldSubmitted?.call();
  }

  VoidCallback? _autocompleteFieldSubmitted;

  /// 包裹[TextField]的自动完成小部件
  @callPoint
  @overridePoint
  Widget buildWrapAutocomplete(BuildContext context, Widget textField) {
    _autocompleteFieldSubmitted = null;
    if (autoOptionsBuilder == null) {
      return textField;
    }
    return RawAutocomplete<Object>(
      textEditingController: controller,
      focusNode: focusNode,
      fieldViewBuilder /*构建输入框*/ :
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            _autocompleteFieldSubmitted = onFieldSubmitted;
            return textField;
          },
      displayStringForOption: autoDisplayStringForOption,
      /*initialValue: value //不能和[textEditingController]同时指定,*/
      optionsViewOpenDirection /*弹出方向*/ : autoOptionsViewOpenDirection,
      optionsBuilder /*自动提示选项*/ : (TextEditingValue textEditingValue) async {
        return autoOptionsBuilder!(this, textEditingValue);
      },
      optionsViewBuilder /*构建下拉选项内容小部件*/ :
          (
            BuildContext ctx,
            AutocompleteOnSelected<Object> onSelected,
            Iterable<Object> options,
          ) {
            final renderBox = context.findRenderObject();
            final anchorBounds =
                renderBox?.getGlobalBounds(
                  Overlay.maybeOf(
                    context,
                    rootOverlay: true,
                  )?.context.findRenderObject(),
                ) ??
                Rect.zero;

            if (autoOptionsViewBuilder != null) {
              return autoOptionsViewBuilder!(
                this,
                anchorBounds,
                ctx,
                onSelected,
                options,
              );
            }

            return AutocompleteOptionsWidget<Object>(
              displayStringForOption: autoDisplayStringForOption,
              onSelected: onSelected,
              options: options,
              openDirection: autoOptionsViewOpenDirection,
              maxOptionsHeight: autoOptionsMaxHeight,
              bodyWrapBuilder: autoOverlayBodyWrapBuilder,
              optionItemBuilder: autoOptionItemBuilder,
              anchorBounds: anchorBounds,
              elevation: autoOverlayElevation,
              color: autoOverlayColor,
              shadowColor: autoOverlayShadowColor,
              shape: autoOverlayShape,
              borderRadius: autoOverlayBorderRadius,
            );
          },
      onSelected: onAutoOptionSelected,
    );
  }

  //endregion Autocomplete
}

/// 清除图标的大小
const kSuffixIconSize = 18.0;

/// 清除图标的约束
const kSuffixIconConstraintsSize = 36.0;
const kSuffixIconConstraintsMaxSize = 36.0;

/// 后缀图标的约束
const kSuffixIconConstraints = BoxConstraints(
  minWidth: kSuffixIconConstraintsSize,
  minHeight: kSuffixIconConstraintsSize,
  maxWidth: kSuffixIconConstraintsMaxSize,
  maxHeight: kSuffixIconConstraintsMaxSize,
);

/// 前缀图标的约束
const kPrefixIconConstraints = BoxConstraints(
  minWidth: kSuffixIconConstraintsSize,
  minHeight: kSuffixIconConstraintsSize,
  maxWidth: kSuffixIconConstraintsMaxSize,
  maxHeight: kSuffixIconConstraintsMaxSize,
);

/// 数字输入格式化器, 仅支持输入数字
/// [FilteringTextInputFormatter.digitsOnly]
FilteringTextInputFormatter get integerTextInputFormatter =>
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

/// 支持正负整数输入
FilteringTextInputFormatter get numberTextInputFormatter =>
    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'));

/// 仅支持输入正负小数
FilteringTextInputFormatter get decimalTextInputFormatter =>
    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'));

/// 用来控制密码输入控件, 密码的可见性
class ObscureNode with DiagnosticableTreeMixin, ChangeNotifier, NotifierMixin {
  /// 是否是密码输入框
  bool obscureText;

  /// 密码替换字符
  final String obscuringCharacter;

  ObscureNode(this.obscureText, {this.obscuringCharacter = '•'});

  /// 是否要显示密码
  bool _showObscureText = false;

  /// 是否隐藏密码
  bool get showObscureText => _showObscureText;

  /// 显示密码
  set showObscureText(bool value) {
    if (_showObscureText != value) {
      _showObscureText = value;
      notifyListeners();
    }
  }

  /// 切换密码的可见性
  void toggle() {
    showObscureText = !showObscureText;
  }
}

/// https://juejin.cn/post/6910163213778681864
/// https://blog.csdn.net/yuzhiqiang_1993/article/details/88204031
/// 单行/多行输入框
/// [Autocomplete]
///
/// [TextField]->[EditableText]->[_Editable]
///
///
/// - [SingleInputWidget]
/// - [BorderSingleInputWidget]
/// - [AutocompleteOptionsWidget]
class SingleInputWidget extends StatefulWidget {
  /// 是否激活
  final bool enabled;

  /// 是否一直显示后缀图标, 一般是清除按钮和查看密码按钮
  /// - 不指定则在有焦点时自动显示, 否则隐藏
  final bool? alwaysShowSuffixIcon;

  /// 输入控制配置
  final TextFieldConfig config;

  /// 光标的颜色
  final Color? cursorColor;

  /// 背景填充颜色
  /// [decoration]属性
  final Color? fillColor;

  /// 禁用时的填充颜色
  /// [decoration]属性
  final Color? disabledFillColor;

  /// 边框的宽度, 为0取消边框
  final double borderWidth;

  /// 焦点时的边框宽度[borderWidth]
  final double? focusBorderWidth;

  /// 禁用时的边框宽度[borderWidth]
  final double? disableBorderWidth;

  /// 正常情况下的边框颜色
  final Color? borderColor;

  /// 焦点时的边框颜色, 默认是主题色
  final Color? focusBorderColor;

  /// 禁用时的边框颜色
  final Color? disableBorderColor;

  /// 圆角大小
  final double borderRadius;

  /// 下划线装饰边框的圆角大小
  final double underlineBorderRadius;

  final double gapPadding;

  /// [labelText]
  final Widget? label;

  /// 浮动在输入框上方的提示文字
  /// [TextFieldConfig.labelText]
  final String? labelText;

  /// [InputDecoration.labelStyle]
  final TextStyle? labelStyle;

  /// [InputDecoration.floatingLabelStyle]
  final TextStyle? floatingLabelStyle;

  /// [labelText]的回调版本
  /// [TextFieldConfig.labelTextBuilder]
  final IntlTextBuilder? labelTextBuilder;

  /// 输入框内的提示文字, 占位提示文本
  /// [InputDecoration.hintText]
  /// [TextFieldConfig.hintText]
  final String? hintText;

  /// [InputDecoration.hintStyle]
  final TextStyle? hintStyle;

  /// [hintText]的回调版本
  /// [TextFieldConfig.hintTextBuilder]
  final IntlTextBuilder? hintTextBuilder;

  /// 前缀小部件
  final Widget? prefix;

  /// 前缀图标小部件
  final Widget? prefixIcon;

  /// 后缀小部件
  final Widget? suffix;

  /// 后缀/前缀图标的大小
  final double? prefixIconSize;
  final double? suffixIconSize;

  /// 后缀/前缀图标的约束
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;

  /// 后缀/前缀图标的padding
  final EdgeInsetsGeometry? suffixIconPadding;
  final EdgeInsetsGeometry? prefixIconPadding;

  /// 后缀/前缀图标的构建器
  final TransformChildWidgetBuilder? prefixIconBuilder;
  final TransformChildWidgetBuilder? suffixIconBuilder;

  /// 是否折叠显示, true: 则输入框的高度和文本一致
  final bool? isCollapsed;

  /// 是否紧凑/密集显示, true: 则输入框占用更少的空间
  final bool? isDense;

  /// [isDense] [isCollapsed] 也是可以通过[InputDecoration]来控制的
  /// [InputDecoration.contentPadding]
  /// `EdgeInsets. fromLTRB(12, 4, 12, 4`
  /// `EdgeInsets. fromLTRB(12, 8, 12, 8`
  /// `EdgeInsets. fromLTRB(0, 4, 0, 4)`
  /// `EdgeInsets. fromLTRB(0, 8, 0, 8)`
  /// `EdgeInsets.fromLTRB(12, 24, 12, 16)`
  ///
  /// `EdgeInsets.fromLTRB(12, 12, 12, 12)` 默认
  ///
  final EdgeInsetsGeometry? contentPadding;

  /// 键盘输入类型
  /// keyboardType = keyboardType ?? (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
  ///
  /// [TextField.keyboardType]
  ///
  final TextInputType? keyboardType;

  /// 输入的文本格式化, 限制输入的字符
  /// ```
  /// FilteringTextInputFormatter.deny('\n'); // 禁止输入换行符, 也就是单行输入
  /// FilteringTextInputFormatter.allow(RegExp(r'[0-9]')); // 仅支持数字输入
  /// ```
  /// 限制仅支持小数输入
  /// ```
  /// FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
  /// ```
  ///
  /// [FilteringTextInputFormatter.singleLineFormatter] 单行输入
  /// [FilteringTextInputFormatter.digitsOnly] 仅支持数字输入, 不支持负数
  /// [FilteringTextInputFormatter.allow]
  /// [FilteringTextInputFormatter]
  /// [LengthLimitingTextInputFormatter]
  ///
  /// [integerTextInputFormatter]
  /// [numberTextInputFormatter]
  /// [decimalTextInputFormatter]
  ///
  /// https://pub.dev/packages/mask_text_input_formatter
  ///
  final List<TextInputFormatter>? inputFormatters;

  /// 输入的文本样式
  final TextStyle? textStyle;
  final TextAlign textAlign;

  /// 限制输入的最大长度
  /// 等于[TextField.noMaxLength]时, 会显示字符计数器
  /// [_TextFieldState.needsCounter] 显示计数器的条件判断
  /// 文本样式[InputDecorationTheme].[ThemeData.inputDecorationTheme]
  /// [_m3CounterErrorStyle]
  /// [_m2CounterErrorStyle]
  /// 直接使用[inputBuildCounter]覆盖系统的方法也可以自定义
  final int? maxLength;

  /// 用来构建输入长度等信息的回调
  /// [TextField.buildCounter]
  /// [noneInputBuildCounter]
  final InputCounterWidgetBuilder? inputBuildCounter;

  /// 是否显示[maxLength].[inputBuildCounter]
  final bool? showInputCounter;

  /// 最大行数
  final int? maxLines;
  final int? minLines;

  /// 计数器的文本, 为""时, 会不显示计数器, 但是又可以限制输入的最大长度
  final String? counterText;

  /// 输入框的装饰样式, 设置之后, 下面的所有装饰相关的属性都无效
  /// [InputDecoration]
  final InputDecoration? decoration;

  /// 是否使用下划线[InputBorder]
  final InputBorderType inputBorderType;

  /// 不指定根据[inputBorderType]自动设置
  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  @defInjectMark
  final InputBorder? border;

  /// 不指定根据[inputBorderType]自动设置
  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  @defInjectMark
  final InputBorder? focusedBorder;

  /// 不指定根据[inputBorderType]自动设置
  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  @defInjectMark
  final InputBorder? disabledBorder;

  /// 键盘上的输入类型, 比如完成, 下一步等
  /// [onSubmitted] 配合此方法, 请求下一个输入框的焦点.
  final TextInputAction? textInputAction;

  /// 回调
  /// https://blog.csdn.net/yuzhiqiang_1993/article/details/88204031
  final ValueChanged<String>? onChanged;
  final ContextValueChanged<String>? onContextValueChanged;

  ///点击键盘的动作按钮时的回调, 通常是按回车之后回调
  final VoidCallback? onEditingComplete
  /*无参数的回调*/;

  /// [onEditingComplete]回调之后会马上触发[onSubmitted]回调
  /// 按回车键之后会触发此回调
  final ValueChanged<String>? onSubmitted
  /*有参数的回调*/;

  /// 焦点改变后的回调
  /// [FocusNode]
  final ValueChanged<bool>? onFocusAction;

  /// [TextField.canRequestFocus]
  final bool canRequestFocus;

  /// 丢失焦点后, 是否自动触发提交
  final bool autoSubmitOnUnFocus;

  /// 调试标签
  final String? debugLabel;

  /// [TextField] 内部实现
  /// [TextFieldConfig] 核心配置
  const SingleInputWidget({
    super.key,
    required this.config,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.disableBorderColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.underlineBorderRadius = 0,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.focusBorderWidth,
    this.disableBorderWidth,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputBuildCounter,
    this.showInputCounter,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.alwaysShowSuffixIcon,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.label,
    this.labelText,
    this.labelStyle,
    this.floatingLabelStyle,
    this.labelTextBuilder,
    this.hintText,
    this.hintStyle,
    this.hintTextBuilder,
    this.suffix,
    this.prefix,
    this.prefixIcon,
    this.prefixIconSize = kSuffixIconSize,
    this.suffixIconSize = kSuffixIconSize,
    this.suffixIconConstraints = kSuffixIconConstraints,
    this.prefixIconConstraints = kPrefixIconConstraints,
    this.suffixIconPadding,
    this.prefixIconPadding,
    this.counterText,
    this.isCollapsed,
    this.isDense = true,
    this.contentPadding = kInputPadding,
    this.decoration,
    this.inputBorderType = InputBorderType.outline,
    this.border,
    this.focusedBorder,
    this.disabledBorder,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.onContextValueChanged,
    this.onEditingComplete,
    this.onFocusAction,
    this.prefixIconBuilder,
    this.suffixIconBuilder,
    this.canRequestFocus = true,
    this.autoSubmitOnUnFocus = false,
    this.debugLabel,
  });

  /// 不带输入框的样式
  const SingleInputWidget.decoration({
    super.key,
    required this.config,
    this.fillColor /*整体填充颜色*/,
    this.borderColor = Colors.transparent /*去掉正常边框的颜色*/,
    this.focusBorderColor /*焦点时的边框颜色*/,
    this.disableBorderColor,
    this.borderRadius = kDefaultBorderRadiusX /*圆角*/,
    this.underlineBorderRadius = 0,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.focusBorderWidth,
    this.disableBorderWidth,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputBuildCounter,
    this.showInputCounter,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.alwaysShowSuffixIcon,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.label,
    this.labelText,
    this.labelStyle,
    this.floatingLabelStyle,
    this.labelTextBuilder,
    this.hintText,
    this.hintStyle,
    this.hintTextBuilder,
    this.suffix,
    this.prefix,
    this.prefixIcon,
    this.prefixIconSize = kSuffixIconSize,
    this.suffixIconSize = kSuffixIconSize,
    this.suffixIconConstraints = kSuffixIconConstraints,
    this.prefixIconConstraints = kPrefixIconConstraints,
    this.suffixIconPadding,
    this.prefixIconPadding,
    this.counterText,
    this.isCollapsed,
    this.isDense = true,
    this.contentPadding = kInputPadding,
    this.decoration,
    this.inputBorderType = InputBorderType.fillOutline,
    this.border,
    this.focusedBorder,
    this.disabledBorder,
    this.textInputAction,
    this.onChanged,
    this.onContextValueChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onFocusAction,
    this.prefixIconBuilder,
    this.suffixIconBuilder,
    this.canRequestFocus = true,
    this.autoSubmitOnUnFocus = false,
    this.debugLabel,
  });

  /// 去掉了所有默认装饰的样式
  /// 此时可以使用外部的[Widget]进行背景装饰
  /// - [StateDecorationWidgetEx.backgroundDecoration]
  const SingleInputWidget.none({
    super.key,
    required this.config,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.disableBorderColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.underlineBorderRadius = 0,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.focusBorderWidth,
    this.disableBorderWidth,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputBuildCounter,
    this.showInputCounter = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.alwaysShowSuffixIcon,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.label,
    this.labelText,
    this.labelStyle,
    this.floatingLabelStyle,
    this.labelTextBuilder,
    this.hintText,
    this.hintStyle,
    this.hintTextBuilder,
    this.suffix,
    this.prefix,
    this.prefixIcon,
    this.prefixIconSize = kSuffixIconSize,
    this.suffixIconSize = kSuffixIconSize,
    this.suffixIconConstraints = kSuffixIconConstraints,
    this.prefixIconConstraints = kPrefixIconConstraints,
    this.suffixIconPadding,
    this.prefixIconPadding,
    this.counterText,
    this.isCollapsed,
    this.isDense = true,
    this.contentPadding = kInputSubPadding,
    this.decoration,
    this.inputBorderType = InputBorderType.outline,
    this.border = InputBorder.none,
    this.focusedBorder = InputBorder.none,
    this.disabledBorder,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.onContextValueChanged,
    this.onEditingComplete,
    this.onFocusAction,
    this.prefixIconBuilder,
    this.suffixIconBuilder,
    this.canRequestFocus = true,
    this.autoSubmitOnUnFocus = false,
    this.debugLabel,
  });

  @override
  State<SingleInputWidget> createState() => _SingleInputWidgetState();
}

class _SingleInputWidgetState extends State<SingleInputWidget> {
  /// 是否显示后缀图标, 一般是清除按钮和查看密码按钮
  bool get _showSuffixIcon =>
      widget.alwaysShowSuffixIcon != false &&
      widget.enabled &&
      widget.config.hasFocus &&
      widget.config.controller.text.isNotEmpty;

  /// 前缀图标
  Widget? _buildPrefixIcon(BuildContext context) {
    Widget? result = widget.prefixIcon ?? widget.config.prefixIcon;
    if (widget.prefixIconBuilder != null) {
      result = widget.prefixIconBuilder?.call(context, result);
    }
    return result;
  }

  /// 后缀图标
  Widget? _buildSuffixIcon(BuildContext context) {
    Widget? result;
    if (_showSuffixIcon) {
      final globalTheme = GlobalTheme.of(context);
      if (widget.config.obscureNode.obscureText) {
        //密码输入框
        result = IconButton(
          color: globalTheme.icoNormalColor,
          padding: widget.suffixIconPadding,
          constraints: widget.suffixIconConstraints,
          focusNode: widget.config.suffixFocusNode,
          //tapTargetSize: MaterialTapTargetSize.shrinkWrap, //收紧大小
          //最小视觉密度
          //visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          /*style: ButtonStyle(
              //minimumSize: MaterialStateProperty.all(Size.zero),
              //padding: MaterialStateProperty.all(EdgeInsets.zero),
              //tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              ),*/
          onPressed: () {
            widget.config.obscureNode.toggle();
            setState(() {});
          },
          icon: Icon(
            size: widget.suffixIconSize,
            widget.config.obscureNode.showObscureText
                ? Icons.visibility
                : Icons.visibility_off,
          ),
        );
      } else {
        //普通文本输入框
        result = IconButton(
          /*飞溅的颜色*/
          color: globalTheme.icoNormalColor,
          padding: widget.suffixIconPadding,
          constraints: widget.suffixIconConstraints,
          focusNode: widget.config.suffixFocusNode,
          onPressed: () {
            _updateFieldText("");
          },
          icon: Icon(
            size: widget.suffixIconSize,
            Icons.cancel_rounded,
            /*图标的颜色*/
            color: globalTheme.icoNormalColor,
          ),
        );
      }
    }
    if (widget.suffixIconBuilder != null) {
      result = widget.suffixIconBuilder?.call(context, result);
    }
    return result;
  }

  /// 更新输入框的值
  @Deprecated("请使用[_updateFieldValue]")
  void _updateFieldText(String text) {
    //debugger();
    //clear 不会触发onChanged回调
    //widget.config.controller.clear();
    //setText 也不会触发onChanged回调
    widget.config.controller.text = text;
    _onSelfTextChanged(text);
    //setState(() {});
  }

  /// 更新输入框的值
  void _updateFieldValue(TextEditingValue value, bool? notify) {
    //debugger();
    //clear 不会触发onChanged回调
    //widget.config.controller.clear();
    //setText 也不会触发onChanged回调
    widget.config.controller.value = value;
    _onSelfValueChanged(value, notify: notify);
    //setState(() {});
  }

  /// 输入框的值改变
  void _onSelfTextChanged(String text) {
    _onSelfValueChanged(TextEditingValue(text: text));
  }

  /// 输入框的值提交时触发
  /// 比如: 按下回车/焦点丢失
  void _onSelfTextSubmitted(String text) {
    widget.onSubmitted?.call(text);
    widget.config.onTextFieldSubmitted(text);
  }

  /// 输入框编辑完成, 完成后就会触发[_onSelfTextSubmitted]
  void _onSelfEditingComplete() {
    widget.onEditingComplete?.call();
    widget.config.onEditingComplete?.call();
  }

  /// 输入框的值改变
  void _onSelfValueChanged(TextEditingValue value, {bool? notify}) {
    if (notify != false) {
      widget.onChanged?.call(value.text);
      widget.config.onChanged?.call(value.text);
      widget.onContextValueChanged?.call(context, value.text);
      widget.config.onContextValueChanged?.call(context, value.text);
    }
    _checkSuffixIcon();

    // 通知输入框的值改变了
    value.text.notifyInputValueChanged();
  }

  /// 焦点改变后的回调
  void _onFocusChanged() {
    _checkSuffixIcon();
    final hasFocus = widget.config.hasFocus;
    assert(() {
      l.d("[${classHash()}] 焦点变化：$hasFocus :${widget.config.selection}");
      return true;
    }());
    final text = widget.config.value.text;
    widget.onFocusAction?.call(hasFocus);
    widget.config.onFocusChanged();
    if (!hasFocus) {
      //丢失焦点
      if (widget.autoSubmitOnUnFocus) {
        _onSelfEditingComplete();
        _onSelfTextSubmitted(text);
      }
    }
  }

  /// 检查是否需要显示后缀图标
  void _checkSuffixIcon() {
    if (widget.alwaysShowSuffixIcon == true ||
        (widget.alwaysShowSuffixIcon == null && widget.config.hasFocus)) {
      setState(() {});
    }
  }

  @override
  void initState() {
    widget.config.focusNode?.addListener(_onFocusChanged);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.addListener(_checkSuffixIcon);
    }
    //debugger();
    widget.config.updateFieldValueFn = _updateFieldValue;
    super.initState();
  }

  @override
  void dispose() {
    widget.config.updateFieldValueFn = null;
    widget.config.focusNode?.removeListener(_onFocusChanged);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.removeListener(_checkSuffixIcon);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SingleInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.config.updateFieldValueFn = null;
    widget.config.updateFieldValueFn = _updateFieldValue;

    oldWidget.config.focusNode?.removeListener(_onFocusChanged);
    widget.config.focusNode?.addListener(_onFocusChanged);

    oldWidget.config.obscureNode.removeListener(_checkSuffixIcon);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.addListener(_checkSuffixIcon);
    }
  }

  /// [MaterialTextSelectionControls.buildHandle]选中后的控制按钮构建
  @override
  Widget build(BuildContext context) {
    //debugger();
    //圆角填充的输入装饰样式
    final globalTheme = GlobalTheme.of(context);
    //normal正常状态
    final normalBorderSide =
        widget.borderColor == Colors.transparent || widget.borderWidth <= 0
        ? BorderSide.none
        : BorderSide(
            color: widget.borderColor ?? globalTheme.borderColor,
            width: widget.borderWidth,
          );
    final normalBorder =
        widget.border ??
        switch (widget.inputBorderType) {
          InputBorderType.outline ||
          InputBorderType.fillOutline => OutlineInputBorder(
            gapPadding: widget.gapPadding,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: normalBorderSide,
          ),
          InputBorderType.underline => UnderlineInputBorder(
            borderSide: normalBorderSide,
            borderRadius: BorderRadius.circular(widget.underlineBorderRadius),
          ),
          _ => InputBorder.none,
        };

    //focused聚焦状态
    final focusedBorderSide =
        widget.focusBorderColor == Colors.transparent ||
            (widget.focusBorderWidth ?? widget.borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: widget.focusBorderColor ?? globalTheme.accentColor,
            width: (widget.focusBorderWidth ?? widget.borderWidth),
          );
    final focusedBorder =
        widget.focusedBorder ??
        switch (widget.inputBorderType) {
          InputBorderType.outline ||
          InputBorderType.fillOutline => OutlineInputBorder(
            gapPadding: widget.gapPadding,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: focusedBorderSide,
          ),
          InputBorderType.underline => UnderlineInputBorder(
            borderSide: focusedBorderSide,
            borderRadius: BorderRadius.circular(widget.underlineBorderRadius),
          ),
          _ => InputBorder.none,
        };

    //disabled禁用状态
    final disableBorderSide =
        widget.disableBorderColor == Colors.transparent ||
            (widget.disableBorderWidth ?? widget.borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: widget.disableBorderColor ?? globalTheme.disableColor,
            width: (widget.disableBorderWidth ?? widget.borderWidth),
          );
    final disabledBorder =
        widget.disabledBorder ??
        switch (widget.inputBorderType) {
          InputBorderType.outline ||
          InputBorderType.fillOutline => OutlineInputBorder(
            gapPadding: widget.gapPadding,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: disableBorderSide,
          ),
          InputBorderType.underline => UnderlineInputBorder(
            borderSide: disableBorderSide,
            borderRadius: BorderRadius.circular(widget.underlineBorderRadius),
          ),
          _ => InputBorder.none,
        };

    // InputBorderType.fillOutline
    final fillColor =
        widget.fillColor ??
        (widget.inputBorderType == InputBorderType.fillOutline
            ? globalTheme.itemWhiteSubBgColor
            : null);
    final decoration =
        widget.decoration ??
        InputDecoration(
          filled:
              fillColor != null ||
              (!widget.enabled && widget.disabledFillColor != null),
          fillColor: widget.enabled
              ? fillColor
              : widget.disabledFillColor ?? fillColor?.disabledColor,
          isDense: widget.isDense,
          isCollapsed: widget.isCollapsed,
          counterText: widget.counterText,
          contentPadding:
              widget.contentPadding ??
              switch (widget.inputBorderType) {
                InputBorderType.outline || InputBorderType.fillOutline => null,
                InputBorderType.underline => const EdgeInsets.all(12),
                _ => const EdgeInsets.all(4),
              },
          //contentPadding: const EdgeInsets.only(top: 60),
          //contentPadding: const EdgeInsets.all(0),
          //contentPadding: EdgeInsets.symmetric(horizontal: globalTheme.xh),
          border: normalBorder,
          //2025-07-02
          enabledBorder: normalBorder,
          focusedBorder: focusedBorder,
          disabledBorder: disabledBorder,
          enabled: widget.enabled,
          label: widget.label,
          labelText:
              widget.labelText ??
              widget.labelTextBuilder?.call(context) ??
              widget.config.labelText ??
              widget.config.labelTextBuilder?.call(context),
          labelStyle:
              widget.labelStyle ??
              widget.config.labelTextStyle ??
              globalTheme.textLabelStyle,
          hintText:
              widget.hintText ??
              widget.hintTextBuilder?.call(context) ??
              widget.config.hintText ??
              widget.config.hintTextBuilder?.call(context),
          hintStyle:
              widget.hintStyle ??
              widget.config.hintTextStyle ??
              globalTheme.textPlaceStyle,
          //floatingLabel
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelStyle:
              widget.floatingLabelStyle ??
              widget.labelStyle ??
              TextStyle(
                color: widget.focusBorderColor ?? globalTheme.accentColor,
              ),
          //控制label的行为
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffix: widget.suffix,
          suffixIcon: _buildSuffixIcon(context),
          suffixIconConstraints: widget.suffixIconConstraints,
          prefix: widget.prefix,
          prefixIcon: _buildPrefixIcon(context),
          prefixIconConstraints: widget.prefixIconConstraints,
        );

    final cursorColor = widget.cursorColor ?? globalTheme.accentColor;
    final textSelectionThemeData = TextSelectionThemeData(
      cursorColor: cursorColor,
      selectionColor: cursorColor,
      selectionHandleColor: cursorColor,
    );
    final child = TextSelectionTheme(
      data: textSelectionThemeData,
      child: DefaultSelectionStyle(
        cursorColor: cursorColor,
        //光标的颜色
        selectionColor: cursorColor,
        //选中文本的颜色
        //mouseCursor: SystemMouseCursors.text,//鼠标的样式
        child: TextField(
          /*groupId: EditableText,*/
          autofocus: widget.config.autofocus ?? widget.config.hasFocus,
          focusNode: widget.config.focusNode,
          canRequestFocus: widget.canRequestFocus,
          decoration: decoration,
          controller: widget.config.controller,
          enabled: widget.enabled,
          textInputAction:
              widget.textInputAction ?? widget.config.textInputAction,
          onChanged: (value) {
            _onSelfTextChanged(value);
          },
          onSubmitted: (value) {
            //编辑完成后的提交
            //l.w("onSubmitted");
            _onSelfTextSubmitted(value);
          },
          onEditingComplete: () {
            //编辑完成
            //l.w("onEditingComplete");
            _onSelfEditingComplete();
          },
          style: widget.textStyle,
          textAlign: widget.textAlign,
          expands: false,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          /*maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,*/
          buildCounter: widget.showInputCounter == false
              ? noneInputBuildCounter
              : widget.inputBuildCounter ?? widget.config.inputBuildCounter,
          //scrollPadding: EdgeInsets.zero,
          obscureText:
              widget.config.obscureNode.obscureText &&
              !widget.config.obscureNode._showObscureText,
          obscuringCharacter: widget.config.obscureNode.obscuringCharacter,
          keyboardType: widget.config.keyboardType ?? widget.keyboardType,
          inputFormatters:
              widget.inputFormatters ?? widget.config.inputFormatters,
          cursorColor: cursorColor,
          //selectionControls: ,
          //selectionHeightStyle: ,
          //selectionWidthStyle: ,
        ),
      ),
    );
    return widget.config.buildWrapAutocomplete(context, child);
  }
}

/// 选项item小部件构建
typedef AutocompleteOptionItemWidgetBuilder =
    Widget Function(BuildContext context, bool isHighlighted, Object option);

// The default Material-style Autocomplete options.
@FromFramework("_AutocompleteOptions")
class AutocompleteOptionsWidget<T extends Object> extends StatelessWidget {
  const AutocompleteOptionsWidget({
    super.key,
    required this.options,
    required this.onSelected,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.openDirection = OptionsViewOpenDirection.down,
    this.maxOptionsHeight = 200.0,
    //--
    this.elevation = 4.0,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.shape,
    this.borderRadius,
    this.constraints,
    //--
    this.bodyWrapBuilder,
    this.optionItemBuilder,
    this.anchorBounds,
  });

  /// 构建body的包装小部件
  final WidgetWrapBuilder? bodyWrapBuilder;

  /// 选项小部件构建
  final AutocompleteOptionItemWidgetBuilder? optionItemBuilder;

  //--

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;
  final OptionsViewOpenDirection openDirection;

  final Iterable<T> options;
  final double maxOptionsHeight;

  //--

  final Rect? anchorBounds;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final TextStyle? textStyle;
  final ShapeBorder? shape;
  final BorderRadiusGeometry? borderRadius;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional optionsAlignment = switch (openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    };

    Widget body = ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final T option = options.elementAt(index);
        return InkWell(
          onTap: () {
            onSelected(option);
          },
          child: Builder(
            builder: (BuildContext context) {
              final bool highlight =
                  AutocompleteHighlightedOption.of(context) == index;
              if (highlight) {
                SchedulerBinding.instance.addPostFrameCallback((
                  Duration timeStamp,
                ) {
                  Scrollable.ensureVisible(context, alignment: 0.5);
                }, debugLabel: 'AutocompleteOptions.ensureVisible');
              }
              return optionItemBuilder?.call(context, highlight, option) ??
                  Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: displayStringForOption(option).text(),
                  );
            },
          ),
        );
      },
    );

    body =
        bodyWrapBuilder?.call(context, body) ??
        Material(
          elevation: elevation,
          color: color,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          shape: shape,
          borderRadius: borderRadius,
          textStyle: textStyle,
          child: ConstrainedBox(
            constraints:
                constraints ??
                BoxConstraints(
                  maxHeight: maxOptionsHeight,
                  minWidth: anchorBounds?.width ?? 0,
                  maxWidth: anchorBounds?.width ?? double.infinity,
                ),
            child: body,
          ),
        );

    return Align(alignment: optionsAlignment, child: body);
  }
}

//--

/// 单行/多行文本输入
/// 样式: 边框线
///
/// - [SingleInputWidget]
/// - [BorderSingleInputWidget]
/// - [AutocompleteOptionsWidget]
class BorderSingleInputWidget extends StatefulWidget {
  /// 默认的文本
  final String? text;

  /// 提示文本
  final String? hintText;

  /// [TextField.autofocus]
  final bool? autofocus;

  /// [SingleInputWidget.inputFormatters]
  final List<TextInputFormatter>? inputFormatters;

  /// [SingleInputWidget.keyboardType]
  final TextInputType? keyboardType;

  /// 最大行数
  final int maxLines;

  /// 最大长度
  final int? maxLength;

  /// 显示输入计数
  final bool? showInputCounter;

  /// 输入值改变
  final ValueChanged<String>? onChanged;

  //--

  final double? borderRadius;

  /// 边距
  final EdgeInsetsGeometry? tileInsets;

  const BorderSingleInputWidget({
    super.key,
    this.text,
    this.hintText,
    this.autofocus,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength = kDefaultInputLength,
    this.showInputCounter = false,
    this.onChanged,
    //--
    this.borderRadius = kDefaultBorderRadiusX,
    this.tileInsets,
  });

  @override
  State<BorderSingleInputWidget> createState() =>
      _BorderSingleInputWidgetState();
}

class _BorderSingleInputWidgetState extends State<BorderSingleInputWidget> {
  /// 输入框配置
  late TextFieldConfig _inputConfig;

  @override
  void initState() {
    _inputConfig = TextFieldConfig(
      text: widget.text,
      hintText: widget.hintText,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return SingleInputWidget(
      config: _inputConfig,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      showInputCounter: widget.showInputCounter,
      border: outlineInputBorder(
        color: globalTheme.borderColor,
        borderRadius: widget.borderRadius,
      ),
      focusedBorder: outlineInputBorder(
        color: globalTheme.accentColor,
        borderRadius: widget.borderRadius,
      ),
      onChanged: widget.onChanged,
    ).paddingOnly(horizontal: kX, vertical: kL, insets: widget.tileInsets);
  }
}

//--

extension TextFieldConfigEx on TextFieldConfig {
  /// [TextFieldConfig] 输入框的一些核心配置
  /// [SingleInputWidget] 输入框的小部件
  Widget toTextField({
    int? maxLength,
    int? maxLines = 1,
    int? minLines,
    String? hintText,
  }) {
    return SingleInputWidget(
      config: this,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      hintText: hintText,
    );
  }
}

part of '../../../flutter3_widgets.dart';

/// 输入框小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///
/// icons图标, m3图标列表
/// https://fonts.google.com/icons
/// 输入框控制配置
/// [SingleInputWidget]
class TextFieldConfig {
  /// 输入控制, 用于获取输入内容
  TextEditingController controller;

  /// 是否自动获取焦点, 具有焦点就会自动显示键盘
  /// [TextField.autofocus]
  bool? autofocus;

  /// 焦点模式
  /// [EditableTextState.requestKeyboard]
  /// [FocusNode.requestFocus]
  FocusNode focusNode;

  /// 密码输入控制
  ObscureNode obscureNode;

  /// 输入的文本
  String get text => controller.text;

  /// [updateText]
  set text(String? text) {
    updateText(text);
  }

  /// 调用此方法更新输入框的值
  /// 此方法会在自动绑定[_SingleInputWidgetState._updateFieldValue]
  @autoInjectMark
  void Function(String value)? updateFieldValueFn;

  //region 覆盖TextField的属性, 优先级低

  /// 浮动在输入框上方的提示文字
  String? labelText;

  /// [labelText]的回调版本
  IntlTextBuilder? labelTextBuilder;

  /// 输入框内的提示文字, 占位提示文本
  /// [SingleInputWidget.hintText]
  String? hintText;

  /// [hintText]的回调版本
  IntlTextBuilder? hintTextBuilder;

  /// 前缀图标小部件
  /// [SingleInputWidget.prefixIcon]
  Widget? prefixIcon;

  /// 键盘上的输入类型, 比如完成, 下一步等
  /// [SingleInputWidget.textInputAction]
  /// [TextInputAction.done]
  /// [TextInputAction.search]
  TextInputAction? textInputAction;

  /// 输入过滤
  /// [SingleInputWidget.inputFormatters]
  List<TextInputFormatter>? inputFormatters;

  /// 用来构建输入长度等信息的回调
  /// [TextField.buildCounter]
  InputCounterWidgetBuilder? inputBuildCounter;

  /// [SingleInputWidget.keyboardType]
  TextInputType? keyboardType;

  //endregion 覆盖TextField的属性, 优先级低

  /// 回调

  /// [TextField.onChanged]
  ValueChanged<String>? onChanged;

  /// [TextField.onSubmitted]
  ValueChanged<String>? onSubmitted;

  /// [TextField.onEditingComplete]
  VoidCallback? onEditingComplete;

  /// 焦点改变后的回调
  /// [FocusNode]
  /// 由[_SingleInputWidgetState._onFocusChanged]驱动
  DoubleValueChanged<bool, String>? onFocusAction;

  TextFieldConfig({
    String? text /*默认文本*/,
    TextEditingController? controller,
    FocusNode? focusNode /*请求焦点*/,
    bool? obscureText /*是否是密码*/,
    bool notifyDefaultTextChange = false /*是否要触发默认文本改变*/,
    this.autofocus,
    this.textInputAction,
    this.inputFormatters,
    this.keyboardType,
    this.updateFieldValueFn,
    this.labelText,
    this.labelTextBuilder,
    this.hintText,
    this.hintTextBuilder,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onFocusAction,
  })  : controller = controller ?? TextEditingController(text: text),
        focusNode = focusNode ?? FocusNode(),
        obscureNode = ObscureNode(obscureText ?? false) {
    if (notifyDefaultTextChange) {
      onChanged?.call(this.controller.text);
    }
  }

  ///[updateText]
  @api
  void updateThis({List<TextInputFormatter>? inputFormatters}) {
    this.inputFormatters = inputFormatters;
    updateText(text, inputFormatters: inputFormatters);
  }

  /// 更新输入框的文本
  /// [inputFormatters] 限制输入的字符
  @api
  void updateText(String? text, {List<TextInputFormatter>? inputFormatters}) {
    //debugger();
    if (updateFieldValueFn == null) {
      assert(() {
        l.w('无效更新TextEditingValue[$text],小部件可能还未[mounted]');
        return true;
      }());
    }
    text ??= "";

    //过滤
    TextEditingValue oldValue = const TextEditingValue(text: "");
    TextEditingValue value = TextEditingValue(text: text);
    value = (inputFormatters ?? this.inputFormatters)?.fold<TextEditingValue>(
          value,
          (newValue, formatter) {
            final resultValue = formatter.formatEditUpdate(oldValue, newValue);
            oldValue = newValue;
            return resultValue;
          },
        ) ??
        value;

    //update
    updateFieldValueFn?.call(value.text);
  }
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

/// 用来控制密码输入控件, 密码的可见性
class ObscureNode with DiagnosticableTreeMixin, ChangeNotifier, NotifierMixin {
  /// 是否是密码输入框
  bool obscureText;

  /// 密码替换字符
  final String obscuringCharacter;

  ObscureNode(
    this.obscureText, {
    this.obscuringCharacter = '•',
  });

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
class SingleInputWidget extends StatefulWidget {
  /// 是否激活
  final bool enabled;

  /// 是否自动显示后缀图标, 一般是清除按钮和查看密码按钮
  final bool autoShowSuffixIcon;

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

  /// [labelText]的回调版本
  /// [TextFieldConfig.labelTextBuilder]
  final IntlTextBuilder? labelTextBuilder;

  /// 输入框内的提示文字, 占位提示文本
  /// [InputDecoration.hintText]
  /// [TextFieldConfig.hintText]
  final String? hintText;

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
  final TextInputType? keyboardType;

  /// 输入的文本格式化, 限制输入的字符
  /// ```
  /// FilteringTextInputFormatter.deny('\n');
  /// FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  /// ```
  /// 限制仅支持小数输入
  /// ```
  /// FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))
  /// ```
  ///
  /// [FilteringTextInputFormatter.singleLineFormatter]
  /// [FilteringTextInputFormatter.digitsOnly]
  /// [FilteringTextInputFormatter.allow]
  /// [FilteringTextInputFormatter]
  /// [LengthLimitingTextInputFormatter]
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

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  final InputBorder? border;

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  final InputBorder? focusedBorder;

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  /// [InputBorder.none]
  final InputBorder? disabledBorder;

  /// 键盘上的输入类型, 比如完成, 下一步等
  final TextInputAction? textInputAction;

  /// 回调
  /// https://blog.csdn.net/yuzhiqiang_1993/article/details/88204031
  final ValueChanged<String>? onChanged;

  ///点击键盘的动作按钮时的回调, 通常是按回车之后回调
  final VoidCallback? onEditingComplete /*无参数的回调*/;

  /// [onEditingComplete]回调之后会马上触发[onSubmitted]回调
  final ValueChanged<String>? onSubmitted /*有参数的回调*/;

  /// 焦点改变后的回调
  /// [FocusNode]
  final ValueChanged<bool>? onFocusAction;

  /// [TextField]
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
    this.autoShowSuffixIcon = true,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.label,
    this.labelText,
    this.labelTextBuilder,
    this.hintText,
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
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onFocusAction,
    this.prefixIconBuilder,
    this.suffixIconBuilder,
  });

  /// 不带输入框的样式
  const SingleInputWidget.decoration({
    super.key,
    required this.config,
    this.fillColor = const Color(0xfff9f9f9) /*整体填充颜色*/,
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
    this.autoShowSuffixIcon = true,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.label,
    this.labelText,
    this.labelTextBuilder,
    this.hintText,
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
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onFocusAction,
    this.prefixIconBuilder,
    this.suffixIconBuilder,
  });

  @override
  State<SingleInputWidget> createState() => _SingleInputWidgetState();
}

class _SingleInputWidgetState extends State<SingleInputWidget> {
  /// 是否显示后缀图标, 一般是清除按钮和查看密码按钮
  bool get _showSuffixIcon =>
      widget.autoShowSuffixIcon &&
      widget.enabled &&
      widget.config.focusNode.hasFocus == true &&
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
          onPressed: () {
            _updateFieldValue("");
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
  void _updateFieldValue(String value) {
    //debugger();
    //clear 不会触发onChanged回调
    //widget.config.controller.clear();
    //setText 也不会触发onChanged回调
    widget.config.controller.text = value;
    _onSelfValueChanged(value);
    //setState(() {});
  }

  /// 输入框的值改变
  void _onSelfValueChanged(String value) {
    widget.onChanged?.call(value);
    widget.config.onChanged?.call(value);
    _checkSuffixIcon();

    // 通知输入框的值改变了
    value.notifyInputValueChanged();
  }

  /// 焦点改变后的回调
  void _onFocusChanged() {
    _checkSuffixIcon();
    final hasFocus = widget.config.focusNode.hasFocus;
    widget.onFocusAction?.call(hasFocus);
    widget.config.onFocusAction?.call(hasFocus, widget.config.text);
  }

  /// 检查是否需要显示后缀图标
  void _checkSuffixIcon() {
    if (widget.autoShowSuffixIcon) {
      setState(() {});
    }
  }

  @override
  void initState() {
    widget.config.focusNode.addListener(_onFocusChanged);
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
    widget.config.focusNode.removeListener(_onFocusChanged);
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

    oldWidget.config.focusNode.removeListener(_onFocusChanged);
    widget.config.focusNode.addListener(_onFocusChanged);

    oldWidget.config.obscureNode.removeListener(_checkSuffixIcon);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.addListener(_checkSuffixIcon);
    }
  }

  /// [MaterialTextSelectionControls.buildHandle]选中后的控制按钮构建
  @override
  Widget build(BuildContext context) {
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
    final normalBorder = widget.border ??
        switch (widget.inputBorderType) {
          InputBorderType.outline => OutlineInputBorder(
              gapPadding: widget.gapPadding,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: normalBorderSide),
          InputBorderType.underline => UnderlineInputBorder(
              borderSide: normalBorderSide,
              borderRadius:
                  BorderRadius.circular(widget.underlineBorderRadius)),
          _ => InputBorder.none,
        };

    //focused聚焦状态
    final focusedBorderSide = widget.focusBorderColor == Colors.transparent ||
            (widget.focusBorderWidth ?? widget.borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: widget.focusBorderColor ?? globalTheme.accentColor,
            width: (widget.focusBorderWidth ?? widget.borderWidth),
          );
    final focusedBorder = widget.focusedBorder ??
        switch (widget.inputBorderType) {
          InputBorderType.outline => OutlineInputBorder(
              gapPadding: widget.gapPadding,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: focusedBorderSide),
          InputBorderType.underline => UnderlineInputBorder(
              borderSide: focusedBorderSide,
              borderRadius:
                  BorderRadius.circular(widget.underlineBorderRadius)),
          _ => InputBorder.none,
        };

    //disabled禁用状态
    final disableBorderSide = widget.disableBorderColor == Colors.transparent ||
            (widget.disableBorderWidth ?? widget.borderWidth) <= 0
        ? BorderSide.none
        : BorderSide(
            color: widget.disableBorderColor ?? globalTheme.disableColor,
            width: (widget.disableBorderWidth ?? widget.borderWidth),
          );
    final disabledBorder = widget.disabledBorder ??
        switch (widget.inputBorderType) {
          InputBorderType.outline => OutlineInputBorder(
              gapPadding: widget.gapPadding,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: disableBorderSide),
          InputBorderType.underline => UnderlineInputBorder(
              borderSide: disableBorderSide,
              borderRadius:
                  BorderRadius.circular(widget.underlineBorderRadius)),
          _ => InputBorder.none,
        };

    final decoration = widget.decoration ??
        InputDecoration(
          filled: widget.fillColor != null ||
              (!widget.enabled && widget.disabledFillColor != null),
          fillColor: widget.enabled
              ? widget.fillColor
              : widget.disabledFillColor ?? widget.fillColor?.disabledColor,
          isDense: widget.isDense,
          isCollapsed: widget.isCollapsed,
          counterText: widget.counterText,
          contentPadding: widget.contentPadding ??
              switch (widget.inputBorderType) {
                InputBorderType.outline => null,
                InputBorderType.underline => const EdgeInsets.all(12),
                _ => const EdgeInsets.all(4),
              },
          //contentPadding: const EdgeInsets.only(top: 60),
          //contentPadding: const EdgeInsets.all(0),
          //contentPadding: EdgeInsets.symmetric(horizontal: globalTheme.xh),
          border: normalBorder,
          focusedBorder: focusedBorder,
          disabledBorder: disabledBorder,
          label: widget.label,
          labelText: widget.labelText ??
              widget.labelTextBuilder?.call(context) ??
              widget.config.labelText ??
              widget.config.labelTextBuilder?.call(context),
          hintText: widget.hintText ??
              widget.hintTextBuilder?.call(context) ??
              widget.config.hintText ??
              widget.config.hintTextBuilder?.call(context),
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelStyle: TextStyle(
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
    return TextSelectionTheme(
      data: textSelectionThemeData,
      child: DefaultSelectionStyle(
        cursorColor: cursorColor,
        //光标的颜色
        selectionColor: cursorColor,
        //选中文本的颜色
        //mouseCursor: SystemMouseCursors.text,//鼠标的样式
        child: TextField(
          autofocus:
              widget.config.autofocus ?? widget.config.focusNode.hasFocus,
          focusNode: widget.config.focusNode,
          decoration: decoration,
          controller: widget.config.controller,
          enabled: widget.enabled,
          textInputAction:
              widget.textInputAction ?? widget.config.textInputAction,
          onChanged: (value) {
            _onSelfValueChanged(value);
          },
          onSubmitted: (value) {
            widget.onSubmitted?.call(value);
            widget.config.onSubmitted?.call(value);
          },
          onEditingComplete: () {
            widget.onEditingComplete?.call();
            widget.config.onEditingComplete?.call();
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
          obscureText: widget.config.obscureNode.obscureText &&
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
  }
}

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

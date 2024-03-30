part of flutter3_widgets;

/// 输入框小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///
/// icons图标, m3图标列表
/// https://fonts.google.com/icons
/// 输入框控制配置
class TextFieldConfig {
  /// 输入控制, 用于获取输入内容
  final TextEditingController controller;

  /// 焦点模式
  /// [EditableTextState.requestKeyboard]
  final FocusNode focusNode;

  /// 密码输入控制
  final ObscureNode obscureNode;

  /// 输入的文本
  String get text => controller.text;

  //region 可以覆盖TextField的属性, 优先级低

  /// 输入框内的提示文字, 占位提示文本
  /// [SingleInputWidget.hintText]
  final String? hintText;

  /// 前缀图标小部件
  /// [SingleInputWidget.prefixIcon]
  final Widget? prefixIcon;

  /// 键盘上的输入类型, 比如完成, 下一步等
  /// [SingleInputWidget.textInputAction]
  final TextInputAction? textInputAction;

  //endregion 可以覆盖TextField的属性, 优先级低

  /// 回调
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  TextFieldConfig({
    String? text,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool? obscureText,
    this.textInputAction,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
  })  : controller = controller ?? TextEditingController(text: text),
        focusNode = focusNode ?? FocusNode(),
        obscureNode = ObscureNode(obscureText ?? false);
}

/// 清除图标的大小
const kSuffixIconSize = 18.0;

/// 清除图标的约束
const kSuffixIconConstraintsSize = 36.0;

/// 用来控制密码输入控件, 密码的可见性
class ObscureNode with DiagnosticableTreeMixin, ChangeNotifier {
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
  final Color? fillColor;

  /// 禁用时的填充颜色
  final Color? disabledFillColor;

  /// 边框的宽度, 为0取消边框
  final double borderWidth;

  /// 正常情况下的边框颜色
  final Color? borderColor;

  /// 焦点时的边框颜色, 默认是主题色
  final Color? focusBorderColor;

  /// 圆角大小
  final double borderRadius;

  final double gapPadding;

  /// 浮动在输入框上方的提示文字
  final String? labelText;

  /// 输入框内的提示文字, 占位提示文本
  final String? hintText;

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

  /// 是否折叠显示, true: 则输入框的高度和文本一致
  final bool? isCollapsed;

  /// 是否紧凑/密集显示, true: 则输入框占用更少的空间
  final bool? isDense;

  /// [isDense] [isCollapsed] 也是可以通过[InputDecoration]来控制的
  /// [InputDecoration.contentPadding]
  final EdgeInsetsGeometry? contentPadding;

  /// 键盘输入类型
  /// keyboardType = keyboardType ?? (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
  final TextInputType? keyboardType;

  /// 输入的文本格式化
  /// [FilteringTextInputFormatter.singleLineFormatter]
  /// [FilteringTextInputFormatter.digitsOnly]
  /// [FilteringTextInputFormatter]
  /// [LengthLimitingTextInputFormatter]
  final List<TextInputFormatter>? inputFormatters;

  /// 输入的文本样式
  final TextStyle? textStyle;
  final TextAlign textAlign;

  /// 限制输入的最大长度
  /// 等于[TextField.noMaxLength]时, 会显示字符计数器
  /// [_TextFieldState.needsCounter] 显示计数器的条件判断
  final int? maxLength;

  /// 最大行数
  final int? maxLines;
  final int? minLines;

  /// 计数器的文本, 为""时, 会不显示计数器, 但是又可以限制输入的最大长度
  final String? counterText;

  /// 输入框的装饰样式
  /// [InputDecoration]
  final InputDecoration? decoration;

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  final InputBorder? border;

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  final InputBorder? focusedBorder;

  /// [outlineInputBorder]
  /// [underlineInputBorder]
  final InputBorder? disabledBorder;

  /// 键盘上的输入类型, 比如完成, 下一步等
  final TextInputAction? textInputAction;

  /// 回调
  /// https://blog.csdn.net/yuzhiqiang_1993/article/details/88204031
  final ValueChanged<String>? onChanged;

  ///点击键盘的动作按钮时的回调
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  const SingleInputWidget({
    super.key,
    required this.config,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autoShowSuffixIcon = true,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.disabledFillColor,
    this.cursorColor,
    this.labelText,
    this.hintText,
    this.suffix,
    this.prefix,
    this.prefixIcon,
    this.prefixIconSize = kSuffixIconSize,
    this.suffixIconSize = kSuffixIconSize,
    this.suffixIconConstraints = const BoxConstraints(
      maxWidth: kSuffixIconConstraintsSize,
      maxHeight: kSuffixIconConstraintsSize,
      minHeight: kSuffixIconConstraintsSize,
      minWidth: kSuffixIconConstraintsSize,
    ),
    this.prefixIconConstraints = const BoxConstraints(
      maxWidth: kSuffixIconConstraintsSize,
      maxHeight: kSuffixIconConstraintsSize,
      minHeight: kSuffixIconConstraintsSize,
      minWidth: kSuffixIconConstraintsSize,
    ),
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.counterText,
    this.isCollapsed,
    this.isDense = true,
    this.contentPadding,
    this.decoration,
    this.border,
    this.focusedBorder,
    this.disabledBorder,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
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

  /// 后缀图标
  Widget? _buildSuffixIcon() {
    if (_showSuffixIcon) {
      final globalTheme = GlobalTheme.of(context);
      if (widget.config.obscureNode.obscureText) {
        //密码输入框
        return IconButton(
          color: globalTheme.icoGrayColor,
          iconSize: widget.suffixIconSize,
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
            widget.config.obscureNode.showObscureText
                ? Icons.visibility
                : Icons.visibility_off,
          ),
        );
      } else {
        //普通文本输入框
        return IconButton(
          /*飞溅的颜色*/
          color: globalTheme.icoNormalColor,
          iconSize: widget.suffixIconSize,
          constraints: widget.suffixIconConstraints,
          onPressed: () {
            widget.config.controller.clear();
            setState(() {});
          },
          icon: Icon(
            Icons.cancel_rounded,
            /*图标的颜色*/
            color: globalTheme.icoNormalColor,
          ),
        );
      }
    }
    return null;
  }

  /// 检查是否需要显示后缀图标
  void _checkSuffixIcon() {
    if (widget.autoShowSuffixIcon) {
      setState(() {});
    }
  }

  @override
  void initState() {
    widget.config.focusNode.addListener(_checkSuffixIcon);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.addListener(_checkSuffixIcon);
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.config.focusNode.removeListener(_checkSuffixIcon);
    if (widget.config.obscureNode.obscureText) {
      widget.config.obscureNode.removeListener(_checkSuffixIcon);
    }
    super.dispose();
  }

  /// [MaterialTextSelectionControls.buildHandle]选中后的控制按钮构建
  @override
  Widget build(BuildContext context) {
    //圆角填充的输入装饰样式
    var globalTheme = GlobalTheme.of(context);
    var normalBorder = widget.border ??
        OutlineInputBorder(
          gapPadding: widget.gapPadding,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: widget.borderColor == Colors.transparent ||
                  widget.borderWidth <= 0
              ? BorderSide.none
              : BorderSide(
                  color: widget.borderColor ?? globalTheme.borderColor,
                  width: widget.borderWidth,
                ),
        );

    var focusedBorder = widget.focusedBorder ??
        OutlineInputBorder(
          gapPadding: widget.gapPadding,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: widget.focusBorderColor == Colors.transparent ||
                  widget.borderWidth <= 0
              ? BorderSide.none
              : BorderSide(
                  color: widget.focusBorderColor ?? globalTheme.accentColor,
                  width: widget.borderWidth,
                ),
        );

    var disabledBorder = widget.disabledBorder ?? normalBorder;

    var decoration = widget.decoration ??
        InputDecoration(
          filled: widget.fillColor != null ||
              (!widget.enabled && widget.disabledFillColor != null),
          fillColor: widget.enabled
              ? widget.fillColor
              : widget.disabledFillColor ?? widget.fillColor?.disabledColor,
          isDense: widget.isDense,
          isCollapsed: widget.isCollapsed,
          counterText: widget.counterText,
          contentPadding: widget.contentPadding,
          //contentPadding: const EdgeInsets.only(top: 60),
          //contentPadding: const EdgeInsets.all(0),
          //contentPadding: EdgeInsets.symmetric(horizontal: globalTheme.xh),
          border: normalBorder,
          focusedBorder: focusedBorder,
          disabledBorder: disabledBorder,
          label: null,
          labelText: widget.labelText,
          hintText: widget.hintText ?? widget.config.hintText,
          //floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelStyle: TextStyle(
            color: widget.focusBorderColor ?? globalTheme.accentColor,
          ),
          //控制label的行为
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffix: widget.suffix,
          suffixIcon: _buildSuffixIcon(),
          suffixIconConstraints: widget.suffixIconConstraints,
          prefix: widget.prefix,
          prefixIcon: widget.prefixIcon ?? widget.config.prefixIcon,
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
          focusNode: widget.config.focusNode,
          decoration: decoration,
          controller: widget.config.controller,
          enabled: widget.enabled,
          textInputAction:
              widget.textInputAction ?? widget.config.textInputAction,
          onChanged: (value) {
            widget.onChanged?.call(value);
            widget.config.onChanged?.call(value);
            _checkSuffixIcon();
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
          //scrollPadding: EdgeInsets.zero,
          obscureText: widget.config.obscureNode.obscureText &&
              !widget.config.obscureNode._showObscureText,
          obscuringCharacter: widget.config.obscureNode.obscuringCharacter,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          cursorColor: cursorColor,
          //selectionControls: ,
          //selectionHeightStyle: ,
          //selectionWidthStyle: ,
        ),
      ),
    );
  }
}

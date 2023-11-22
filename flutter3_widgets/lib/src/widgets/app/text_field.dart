part of flutter3_widgets;

/// 输入框小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///

/// https://juejin.cn/post/6910163213778681864

/// 单行输入框
class SingleInputWidget extends StatefulWidget {
  /// 是否激活
  final bool enabled;

  /// 是否隐藏输入内容, 也就是密码输入框
  final bool obscureText;

  /// 光标的颜色
  final Color? cursorColor;

  /// 是否显示清楚按钮
  final bool showClearSuffix;

  /// 背景填充颜色
  final Color fillColor;

  /// 边框的宽度, 为0取消边框
  final double borderWidth;

  /// 正常情况下的边框颜色
  final Color? borderColor;

  /// 焦点时的边框颜色, 默认是主题色
  final Color? focusBorderColor;

  /// 圆角大小
  final double borderRadius;

  /// 输入控制, 用于获取输入内容
  final TextEditingController controller;
  final double gapPadding;

  /// 浮动在输入框上方的提示文字
  final String? labelText;

  /// 输入框内的提示文字, 占位提示文本
  final String? hintText;

  /// 前缀小部件
  final Widget? prefix;

  /// 后缀小部件
  final Widget? suffix;

  /// 是否折叠显示, true: 则输入框的高度和文本一致
  final bool? isCollapsed;

  /// 是否紧凑/密集显示, true: 则输入框占用更少的空间
  final bool? isDense;

  /// [isDense] [isCollapsed] 也是可以通过[InputDecoration]来控制的
  final EdgeInsetsGeometry? contentPadding;

  /// 键盘输入类型
  /// keyboardType = keyboardType ?? (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
  final TextInputType? keyboardType;

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

  const SingleInputWidget({
    super.key,
    required this.controller,
    this.fillColor = Colors.white,
    this.obscureText = false,
    this.borderColor,
    this.focusBorderColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.showClearSuffix = true,
    this.textAlign = TextAlign.start,
    this.cursorColor,
    this.labelText,
    this.hintText,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.maxLength,
    this.counterText,
    this.isCollapsed,
    this.isDense = true,
    this.contentPadding,
  });

  @override
  State<SingleInputWidget> createState() => _SingleInputWidgetState();
}

class _SingleInputWidgetState extends State<SingleInputWidget> {
  @override
  Widget build(BuildContext context) {
    //圆角填充的输入装饰样式
    var globalTheme = GlobalTheme.of(context);
    var normalBorder = OutlineInputBorder(
      gapPadding: widget.gapPadding,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: widget.borderColor == null || widget.borderWidth <= 0
          ? BorderSide.none
          : BorderSide(
              color: widget.borderColor!,
              width: widget.borderWidth,
            ),
    );

    var focusedBorder = OutlineInputBorder(
      gapPadding: widget.gapPadding,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: widget.borderWidth <= 0
          ? BorderSide.none
          : BorderSide(
              color: widget.focusBorderColor ?? globalTheme.accentColor,
              width: widget.borderWidth,
            ),
    );

    var decoration = InputDecoration(
      fillColor: widget.fillColor,
      filled: true,
      isDense: widget.isDense,
      isCollapsed: widget.isCollapsed,
      counterText: widget.counterText,
      contentPadding: widget.contentPadding,
      //contentPadding: const EdgeInsets.only(top: 60),
      //contentPadding: const EdgeInsets.all(0),
      //contentPadding: EdgeInsets.symmetric(horizontal: globalTheme.xh),
      border: normalBorder,
      focusedBorder: focusedBorder,
      labelText: widget.labelText ?? widget.hintText,
      hintText: widget.hintText,
      //floatingLabelAlignment: FloatingLabelAlignment.center,
      floatingLabelStyle: TextStyle(
        color: widget.focusBorderColor ?? globalTheme.accentColor,
      ),
      //控制label的行为
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      suffix: widget.suffix,
      /*suffixIcon: const Icon(Icons.clear).click(() {
        widget.controller.clear();
      }),*/
      suffixIcon: (widget.showClearSuffix && widget.controller.text.isNotEmpty)
          ? IconButton(
              onPressed: () {
                widget.controller.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear),
            )
          : null,
      prefix: widget.prefix,
    );

    return TextField(
      decoration: decoration,
      controller: widget.controller,
      enabled: widget.enabled,
      onChanged: (value) {
        if (widget.showClearSuffix) {
          setState(() {});
        }
      },
      //expands: true,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      //scrollPadding: EdgeInsets.zero,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      cursorColor: widget.cursorColor,
    );
  }
}

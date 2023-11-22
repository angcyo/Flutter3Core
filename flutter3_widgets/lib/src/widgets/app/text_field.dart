part of flutter3_widgets;

/// 输入框小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/22
///

/// 单行输入框
class SingleInputWidget extends StatefulWidget {
  /// 是否激活
  final bool enabled;

  /// 光标的颜色
  final Color? cursorColor;

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

  const SingleInputWidget({
    super.key,
    required this.controller,
    this.fillColor = Colors.white,
    this.borderColor,
    this.focusBorderColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.gapPadding = 0,
    this.borderWidth = 1,
    this.enabled = true,
    this.cursorColor,
    this.labelText,
    this.hintText,
    this.suffix,
    this.prefix,
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
      //contentPadding: EdgeInsets.all(0),
      border: normalBorder,
      focusedBorder: focusedBorder,
      labelText: widget.labelText ?? widget.hintText,
      hintText: widget.hintText,
      floatingLabelStyle: TextStyle(
        color: widget.focusBorderColor ?? globalTheme.accentColor,
      ),
      //控制label的行为
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      suffix: widget.suffix,
      /*suffixIcon: const Icon(Icons.clear).click(() {
        widget.controller.clear();
      }),*/
      suffixIcon: IconButton(
        onPressed: widget.controller.clear,
        icon: const Icon(Icons.clear),
      ),
      prefix: widget.prefix,
    );

    return TextField(
      decoration: decoration,
      controller: widget.controller,
      enabled: widget.enabled,
      cursorColor: widget.cursorColor,
    );
  }
}

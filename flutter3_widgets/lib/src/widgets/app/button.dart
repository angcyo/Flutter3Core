part of flutter3_widgets;

/// 按钮小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/23
///

class FillButton extends StatelessWidget {
  /// 按钮文本, 设置之后, [child]无效
  final String? text;

  /// [child]
  final Widget? child;

  /// 按钮是否可用
  final bool enabled;

  /// 圆角大小
  final double radius;

  /// 圆角, 覆盖[radius]属性
  final BorderRadius? borderRadius;

  /// 按钮的宽度, 会影响[minWidth].[maxWidth]
  final double? width;

  /// 按钮的高度
  final double? height;

  /// 按钮的最小宽度
  final double minWidth;

  /// 按钮的最小高度
  final double minHeight;

  /// 按钮的最大宽度
  final double maxWidth;

  /// 按钮的最大高度
  final double maxHeight;

  /// 渐变颜色默认是
  /// [theme.primaryColor, theme.primaryColorDark]
  final List<Color>? gradientColors;

  /// 填充颜色, 指定之后, 渐变颜色无效
  final Color? fillColor;

  /// 禁用时的填充颜色
  final Color? disabledFillColor;

  /// 强制指定文本颜色, 否则会自动根据[fillColor]匹配颜色
  final Color? textColor;

  /// 禁用时的文本颜色, 不指定同样会自动匹配
  final Color? disabledTextColor;

  const FillButton({
    super.key,
    this.text,
    this.child,
    this.enabled = true,
    this.radius = kDefaultBorderRadiusX,
    this.gradientColors,
    this.fillColor,
    this.disabledFillColor,
    this.minWidth = 88,
    this.minHeight = kInteractiveHeight,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.width,
    this.height,
    this.borderRadius,
    this.textColor,
    this.disabledTextColor,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    var fillRefColor = fillColor ?? gradientColors?.firstOrNull;
    var isLightFill = fillRefColor?.isLight == true;
    var textColor = this.textColor ??
        (isLightFill
            ? globalTheme.textPrimaryStyle.color
            : globalTheme.themeWhiteColor);
    var disabledTextColor =
        this.disabledTextColor ?? (textColor ?? Colors.black38).disabledColor;
    return GradientButton(
      onPressed: enabled ? () {} : null,
      color: fillColor,
      colors: fillColor == null ? gradientColors : [],
      disabledColor: disabledFillColor ?? fillRefColor?.disabledColor,
      textColor: textColor,
      disabledTextColor: disabledTextColor,
      borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(radius)),
      minWidth: width != null ? width! : minWidth,
      maxWidth: width != null ? width! : maxWidth,
      minHeight: height != null ? height! : minHeight,
      maxHeight: height != null ? height! : maxHeight,
      child: text?.text() ?? child ?? const Empty(),
    );
  }
}

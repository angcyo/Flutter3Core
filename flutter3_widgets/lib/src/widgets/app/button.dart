part of flutter3_widgets;

/// 按钮小部件
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/23
///

/// 色块填充样式的按钮
class FillButton extends StatelessWidget {
  /// 按钮文本, 设置之后, [child]无效
  final String? text;

  /// [child]
  final Widget? child;

  /// 按钮是否可用
  final bool enabled;

  /// 手势事件
  final GestureTapCallback? onTap;

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
    this.onTap,
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
      onPressed: enabled
          ? onTap ??
              () {
                assert(() {
                  debugPrint("FillButton.onTap is null");
                  return true;
                }());
              }
          : null,
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

/// 勾选框, 带文本
class CheckButton extends StatelessWidget {
  /// 是否选中
  final bool isChecked;

  /// 是否是圆形
  final bool? isCircle;

  /// 框框的形状, 优先[isCircle]
  final OutlinedBorder? shape;

  /// 状态改变回调
  final ValueChanged<bool?>? onChanged;

  /// 未选中时框框的颜色
  final Color? borderColor;

  /// 未选中时框框的宽度
  final double borderWidth;

  /// 选中后, 填充的颜色
  final Color? fillColor;

  /// 选中后中间勾勾的颜色
  final Color? checkColor;

  /// 显示在框框右边的文本
  final String? text;

  /// 显示在框框右边的小部件, 会优先[text]
  final Widget? child;

  /// 按钮的密度, 用来决定box的大小, 最小时按钮32dp, 最大时按钮64dp, 正常48dp
  /// 32dp 48dp 64dp (±16dp)
  /// 最大 ±4
  /// [VisualDensity.minimumDensity]
  /// [VisualDensity.maximumDensity]
  final VisualDensity? visualDensity;

  const CheckButton({
    super.key,
    this.isChecked = false,
    this.onChanged,
    this.text,
    this.child,
    this.isCircle,
    this.shape,
    this.visualDensity,
    this.borderWidth = 2,
    this.borderColor,
    this.checkColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    var globalTheme = GlobalTheme.of(context);
    var borderColor = this.borderColor ??
        globalTheme.textPlaceStyle.color ??
        globalTheme.icoNormalColor;
    return Checkbox(
      value: isChecked,
      onChanged: onChanged,
      activeColor: fillColor,
      checkColor: checkColor,
      side: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
      shape: shape ?? (isCircle == true ? const CircleBorder() : null),
      //visualDensity: VisualDensity.compact,
      visualDensity: visualDensity ?? VisualDensity.compact,
    ).rowOf(
      (child ??
              text?.text(
                style: globalTheme.textPrimaryStyle,
              ))
          ?.click(
        () {
          onChanged?.call(!isChecked);
        },
      ).expanded(),
      mainAxisAlignment: MainAxisAlignment.start, //全部靠左布局
      crossAxisAlignment: CrossAxisAlignment.start, //全部顶部对齐
    );
  }
}
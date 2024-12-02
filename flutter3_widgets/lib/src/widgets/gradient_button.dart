part of '../../flutter3_widgets.dart';

/// https://github.com/flutterchina/flukit
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/09
///

/// 渐变按钮
class GradientButton extends StatelessWidget {
  /// 主题渐变样式
  const GradientButton({
    super.key,
    this.color /*指定单一颜色, 无渐变*/,
    this.colors /*指定渐变颜色*/,
    this.onTap,
    required this.child,
    this.onContextTap,
    this.enable,
    this.padding,
    this.textStyle,
    this.radius = kDefaultBorderRadiusL,
    this.decoration,
    this.borderRadius,
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 88,
    this.maxWidth = double.infinity,
    this.minHeight = kButtonHeight,
    this.maxHeight = double.infinity,
  });

  /// 最小样式
  const GradientButton.min({
    super.key,
    this.color,
    this.colors,
    this.onTap,
    this.onContextTap,
    required this.child,
    this.enable,
    this.padding = const EdgeInsets.symmetric(vertical: kS, horizontal: kM),
    this.textStyle,
    this.radius = kDefaultBorderRadiusL,
    this.decoration,
    this.borderRadius,
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.minHeight = 0,
    this.maxHeight = double.infinity,
  });

  const GradientButton.normal(
    this.onTap, {
    super.key,
    this.color,
    this.colors,
    required this.child,
    this.onContextTap,
    this.enable,
    this.padding = const EdgeInsets.symmetric(vertical: kM, horizontal: kL),
    this.textStyle,
    this.decoration,
    this.radius = kDefaultBorderRadiusL,
    this.borderRadius,
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.minHeight = kMinHeight,
    this.maxHeight = double.infinity,
  });

  /// 黑色填充按钮样式
  const GradientButton.black(
    this.onTap, {
    super.key,
    this.color = const Color(0xff333333),
    this.colors,
    this.splashColor = const Color(0x20ffffff),
    required this.child,
    this.onContextTap,
    this.enable,
    this.padding = const EdgeInsets.symmetric(vertical: kM, horizontal: kL),
    this.textStyle,
    this.decoration,
    this.radius = kDefaultBorderRadiusX,
    this.borderRadius,
    this.textColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.minHeight = kButtonHeight,
    this.maxHeight = double.infinity,
  });

  /// 白色填充按钮样式
  const GradientButton.white(
    this.onTap, {
    super.key,
    required this.child,
    this.color = const Color(0xffffffff),
    this.colors,
    this.splashColor = const Color(0x20000000),
    this.textColor = const Color(0xff000000),
    this.onContextTap,
    this.enable,
    this.padding = const EdgeInsets.symmetric(vertical: kM, horizontal: kL),
    this.textStyle,
    this.decoration,
    this.radius = kDefaultBorderRadiusX,
    this.borderRadius,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.minHeight = kButtonHeight,
    this.maxHeight = double.infinity,
  });

  /// 描边按钮样式
  GradientButton.stroke({
    super.key,
    //--
    Color? strokeColor,
    double strokeWidth = 1.0,
    this.radius = kDefaultBorderRadiusH,
    this.borderRadius,
    //--
    this.color,
    this.colors,
    this.onTap,
    this.onContextTap,
    required this.child,
    this.enable,
    this.padding = const EdgeInsets.symmetric(vertical: kM, horizontal: kL),
    this.textStyle,
    this.textColor = const Color(0xff333333),
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.minHeight = kButtonHeight,
    this.maxHeight = double.infinity,
  }) : decoration = BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: strokeColor ?? Colors.grey, width: strokeWidth),
          ),
          borderRadius:
              borderRadius ?? BorderRadius.all(Radius.circular(radius ?? 0)),
        );

  /// 是否启用
  /// 为`null`时, 自动根据[onTap]判断
  final bool? enable;

  /// 渐变色数组装饰
  final List<Color>? colors;

  /// 单一装饰颜色
  final Color? color;
  final Color? textColor;
  final Color? splashColor;

  /// 禁用时的文本颜色
  final Color? disabledTextColor;

  /// 禁用时的颜色
  final Color? disabledColor;

  /// Defaults to 24.0 on the left and right if [textTheme] is [ButtonTextTheme.primary],
  /// otherwise defaults to 16.0.
  /// [EdgeInsets]
  /// [ButtonThemeData.padding]
  final EdgeInsetsGeometry? padding;

  final Widget child;

  /// 文本默认样式
  final TextStyle? textStyle;
  final double? radius;
  final BorderRadius? borderRadius;

  final GestureTapCallback? onTap;

  /// 带[BuildContext]参数的点击事件
  final GestureContextTapCallback? onContextTap;
  final ValueChanged<bool>? onHighlightChanged;

  /// [BoxConstraints.minWidth]
  final double minWidth;

  /// [BoxConstraints.maxWidth]
  final double maxWidth;

  /// [BoxConstraints.minHeight]
  final double minHeight;

  /// [BoxConstraints.maxHeight]
  final double maxHeight;

  /// 强制指定装饰
  /// [BoxDecoration]
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //确保colors数组不空
    final tempSplashColor = splashColor ??
        this.colors?.lastOrNull ??
        /*color?.withOpacity(0.3) ??*/
        Colors.black12;
    List<Color> colors = this.colors ??
        (color == null
            ? [globalTheme.primaryColor, globalTheme.primaryColorDark]
            : [color!, color!]);
    final radius = borderRadius ??
        (this.radius == null ? null : BorderRadius.circular(this.radius!));
    bool disabled =
        enable == null ? (onTap == null && onContextTap == null) : !enable!;
    return DecoratedBox(
      decoration: decoration ??
          BoxDecoration(
            gradient: disabled || colors.isEmpty
                ? null
                : LinearGradient(colors: colors),
            color:
                disabled ? disabledColor ?? globalTheme.disableBgColor : color,
            borderRadius: radius,
          ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: InkWell(
            splashColor: tempSplashColor,
            highlightColor: Colors.transparent,
            onHighlightChanged: onHighlightChanged,
            onTap: disabled
                ? null
                : () {
                    onTap?.call();
                    onContextTap?.call(context);
                  },
            child: Padding(
              padding: padding ?? globalTheme.buttonPadding,
              child: DefaultTextStyle(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle(
                    style: (textStyle ?? globalTheme.textBodyStyle).copyWith(
                      color: disabled
                          ? disabledTextColor ?? Colors.black38
                          : textStyle == null
                              ? (textColor ?? Colors.white)
                              : null,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 阴影变化渐变按钮
class ElevatedGradientButton extends StatefulWidget {
  const ElevatedGradientButton({
    super.key,
    this.colors,
    this.onPressed,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.shadowColor,
    required this.child,
    this.minWidth = 88,
    this.maxWidth = double.infinity,
    this.minHeight = 36,
    this.maxHeight = double.infinity,
  });

  // 渐变色数组
  final List<Color>? colors;
  final Color? textColor;
  final Color? splashColor;
  final Color? disabledTextColor;
  final Color? disabledColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? padding;

  final Widget child;
  final BorderRadius? borderRadius;

  final GestureTapCallback? onPressed;
  final ValueChanged<bool>? onHighlightChanged;

  /// [BoxConstraints.minWidth]
  final double minWidth;

  /// [BoxConstraints.maxWidth]
  final double maxWidth;

  /// [BoxConstraints.minHeight]
  final double minHeight;

  /// [BoxConstraints.maxHeight]
  final double maxHeight;

  @override
  _ElevatedGradientButtonState createState() => _ElevatedGradientButtonState();
}

class _ElevatedGradientButtonState extends State<ElevatedGradientButton> {
  bool _tapDown = false;

  @override
  Widget build(BuildContext context) {
    bool disabled = widget.onPressed == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: disabled
            ? null
            : [
                _tapDown
                    ? BoxShadow(
                        offset: const Offset(2, 6),
                        spreadRadius: -2,
                        blurRadius: 9,
                        color: widget.shadowColor ?? Colors.black54,
                      )
                    : BoxShadow(
                        offset: const Offset(0, 2),
                        spreadRadius: -2,
                        blurRadius: 3,
                        color: widget.shadowColor ?? Colors.black87,
                      )
              ],
      ),
      child: GradientButton(
        colors: widget.colors,
        onTap: widget.onPressed,
        padding: widget.padding,
        borderRadius: widget.borderRadius,
        textColor: widget.textColor,
        splashColor: widget.splashColor,
        disabledColor: widget.disabledColor,
        disabledTextColor: widget.disabledTextColor,
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
        minHeight: widget.minHeight,
        maxHeight: widget.maxHeight,
        onHighlightChanged: (v) {
          setState(() {
            _tapDown = v;
          });
          if (widget.onHighlightChanged != null) {
            widget.onHighlightChanged!(v);
          }
        },
        child: widget.child,
      ),
    );
  }
}

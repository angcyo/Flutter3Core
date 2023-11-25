part of flutter3_widgets;

/// https://github.com/flutterchina/flukit
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/09
///

class GradientButton extends StatelessWidget {
  const GradientButton({
    Key? key,
    this.color,
    this.colors,
    required this.onPressed,
    required this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.textColor,
    this.splashColor,
    this.disabledColor,
    this.disabledTextColor,
    this.onHighlightChanged,
    this.minWidth = 88,
    this.maxWidth = double.infinity,
    this.minHeight = kInteractiveHeight,
    this.maxHeight = double.infinity,
  }) : super(key: key);

  // 渐变色数组
  final List<Color>? colors;
  final Color? color;
  final Color? textColor;
  final Color? splashColor;
  final Color? disabledTextColor;
  final Color? disabledColor;
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
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    //确保colors数组不空
    List<Color> colors =
        this.colors ?? [theme.primaryColor, theme.primaryColorDark];
    final radius = borderRadius;
    bool disabled = onPressed == null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient:
            disabled || colors.isEmpty ? null : LinearGradient(colors: colors),
        color: disabled ? disabledColor ?? theme.disabledColor : color,
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
              maxHeight: maxHeight),
          child: InkWell(
            splashColor: splashColor ?? colors.lastOrNull ?? color,
            highlightColor: Colors.transparent,
            onHighlightChanged: onHighlightChanged,
            onTap: onPressed,
            child: Padding(
              padding: padding ?? theme.buttonTheme.padding,
              child: DefaultTextStyle(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle(
                    style: theme.textTheme.button!.copyWith(
                      color: disabled
                          ? disabledTextColor ?? Colors.black38
                          : textColor ?? Colors.white,
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

class ElevatedGradientButton extends StatefulWidget {
  const ElevatedGradientButton({
    Key? key,
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
  }) : super(key: key);

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
        onPressed: widget.onPressed,
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

part of '../../flutter3_widgets.dart';

/// https://github.com/flutterchina/flukit
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/09
///
/// 渐变按钮, 内部使用[Material]+[InkWell]实现
///
class GradientButton extends StatefulWidget {
  /// 主题渐变样式
  const GradientButton({
    super.key,
    this.color /*指定单一颜色, 无渐变*/,
    this.colors /*指定渐变颜色*/,
    this.onLongPress,
    this.onTap,
    required this.child,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
  });

  /// 最小样式
  const GradientButton.min({
    super.key,
    this.color,
    this.colors,
    this.onLongPress,
    this.onTap,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
  });

  const GradientButton.normal(
    this.onTap, {
    super.key,
    this.color,
    this.colors,
    required this.child,
    this.onLongPress,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
  });

  /// 黑色填充按钮样式
  const GradientButton.black(
    this.onTap, {
    super.key,
    this.color = const Color(0xff333333),
    this.colors,
    this.splashColor = const Color(0x20ffffff),
    required this.child,
    this.onLongPress,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
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
    this.onLongPress,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
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
    this.onLongPress,
    this.onContextTap,
    this.onAsyncContextTap,
    this.loadingWidget,
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
    this.progress,
    this.debugLabel,
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
  /// [GlobalTheme.disableBgColor]
  @defInjectMark
  final Color? disabledColor;

  /// Defaults to 24.0 on the left and right if [textTheme] is [ButtonTextTheme.primary],
  /// otherwise defaults to 16.0.
  /// [EdgeInsets]
  /// [ButtonThemeData.padding]
  final EdgeInsetsGeometry? padding;

  final Widget? child;

  /// 文本默认样式
  final TextStyle? textStyle;
  final double? radius;
  final BorderRadius? borderRadius;

  /// 点击事件
  /// - [onTap]
  /// - [onContextTap]
  /// - [onAsyncContextTap]
  final GestureTapCallback? onTap;

  /// 长按事件
  final GestureLongPressCallback? onLongPress;

  /// 带[BuildContext]参数的点击事件
  final GestureContextTapCallback? onContextTap;

  /// 异步的点击事件, 同时开启loading状态显示
  /// - [onTap]
  /// - [onContextTap]
  /// - [onAsyncContextTap]
  /// - [loadingWidget]
  final AsyncGestureContextTapCallback? onAsyncContextTap;

  /// [onAsyncContextTap]加载中显示的小部件, 不指定用默认
  @defInjectMark
  final Widget? loadingWidget;

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

  //--

  /// 按钮的背景进度提示[0~1]
  /// - [ProgressStateInfo]
  /// - [ProgressStateInfo.noProgress]
  /// - [ProgressStateInfo.infinityProgress]
  final double? progress;

  /// 调试标签
  final String? debugLabel;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  /// 没有设置手势事件
  bool get noSetGestureTap =>
      widget.onTap == null &&
      widget.onContextTap == null &&
      widget.onAsyncContextTap == null;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //确保colors数组不空
    final tempSplashColor =
        widget.splashColor ??
        widget.colors?.lastOrNull ??
        /*color?.withOpacity(0.3) ??*/
        Colors.black12;
    List<Color> colors =
        widget.colors ??
        (widget.color == null
            ? [globalTheme.primaryColor, globalTheme.primaryColorDark]
            : [widget.color!, widget.color!]);
    final radius =
        widget.borderRadius ??
        (widget.radius == null ? null : BorderRadius.circular(widget.radius!));
    bool disabled = widget.enable == null ? noSetGestureTap : !widget.enable!;
    debugger(when: widget.debugLabel != null);
    return DecoratedBox(
      decoration:
          widget.decoration ??
          ProgressBoxDecoration(
            gradient: disabled || colors.isEmpty
                ? null
                : LinearGradient(colors: colors),
            color: disabled
                ? widget.disabledColor ?? globalTheme.disableBgColor
                : widget.color,
            borderRadius: radius,
            debugLabel: widget.debugLabel,
            progress: widget.progress,
          ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        clipBehavior: Clip.hardEdge,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            minHeight: widget.minHeight,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          ),
          child: InkWell(
            splashColor: tempSplashColor,
            highlightColor: Colors.transparent,
            onHighlightChanged: widget.onHighlightChanged,
            onLongPress: widget.onLongPress,
            onTap: disabled
                ? null
                : () async {
                    if (_isLoading == true) {
                      return;
                    }
                    widget.onTap?.call();
                    widget.onContextTap?.call(context);
                    if (widget.onAsyncContextTap != null) {
                      _isLoading = true;
                      updateState();
                      try {
                        await widget.onAsyncContextTap!(context);
                        _isLoading = false;
                        updateState();
                      } catch (e) {
                        assert(() {
                          print(e);
                          return true;
                        }());
                        _isLoading = false;
                        updateState();
                      }
                    }
                  },
            child: Padding(
              padding: widget.padding ?? globalTheme.buttonPadding,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontWeight: FontWeight.bold),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: DefaultTextStyle.merge(
                    style: (widget.textStyle ?? globalTheme.textBodyStyle)
                        .copyWith(
                          color: disabled
                              ? widget.disabledTextColor ?? Colors.black38
                              : widget.textStyle == null
                              ? (widget.textColor ?? Colors.white)
                              : null,
                        ),
                    child: wrapLoadingIfNeed(
                      context,
                      globalTheme,
                      widget.child,
                      colors,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 是否处于加载中...
  /// - [onAsyncContextTap] 配置此成员后自动激活
  bool? _isLoading;

  /// - [colors] 按钮当前的颜色, 用来决定loading的颜色
  Widget wrapLoadingIfNeed(
    BuildContext context,
    GlobalTheme globalTheme,
    Widget? child,
    List<Color> colors,
  ) {
    return _isLoading == true
        ? widget.loadingWidget ??
              CircularProgressIndicator(
                value: null,
                color: colors.firstOrNull?.isLight == true
                    ? globalTheme.accentColor
                    : globalTheme.themeWhiteColor,
                constraints: BoxConstraints.tightFor(width: 20, height: 20),
                strokeWidth: 2,
              )
        /*.center()*/
        : (child ?? empty);
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
                      ),
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

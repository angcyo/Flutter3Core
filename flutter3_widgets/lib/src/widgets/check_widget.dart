part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/12
///
/// 正常状态下, 显示标准样式
/// checked状态下, 显示背景+阴影高亮选中样式
/// 选中状态样式小部件
/// [HighlightCheckWidget]
/// [StrokeFillCheckWidget]
class HighlightCheckWidget extends StatefulWidget {
  /// 是否选中
  final bool checked;
  final Widget child;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? margin;

  /// [GlobalTheme.accentColor]
  @defInjectMark
  final Color? checkedColor;

  final double? checkedBorderRadius;

  //--
  final Color? shadowColor;

  //--

  /// 点击事件, 设置之后[onValueChanged]不会被默认回调
  final GestureTapCallback? onTap;

  /// 不指定[onTap]时, 自动触发的值改变回调
  final ValueChanged<bool>? onValueChanged;

  /// 是否激活点击
  final bool enableTap;

  const HighlightCheckWidget({
    super.key,
    required this.child,
    this.checked = false,
    this.minWidth = 40,
    this.minHeight = kMinInteractiveHeight,
    this.margin = const EdgeInsets.symmetric(vertical: kM, horizontal: kL),
    this.checkedColor,
    this.checkedBorderRadius = kDefaultBorderRadiusXX,
    this.shadowColor = kShadowColor,
    this.enableTap = true,
    this.onTap,
    this.onValueChanged,
  });

  @override
  State<HighlightCheckWidget> createState() => _HighlightCheckWidgetState();
}

class _HighlightCheckWidgetState extends State<HighlightCheckWidget> {
  bool _initialValue = false;
  bool _currentValue = false;

  @override
  void initState() {
    super.initState();
    _updateValue();
  }

  @override
  void didUpdateWidget(covariant HighlightCheckWidget oldWidget) {
    _updateValue();
    super.didUpdateWidget(oldWidget);
  }

  void _updateValue() {
    _initialValue = widget.checked;
    _currentValue = _initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return [
      if (_currentValue)
        DecoratedBox(
          decoration: fillDecoration(
            color: widget.checkedColor ?? globalTheme.accentColor,
            shadowColor: widget.shadowColor,
            radius: widget.checkedBorderRadius,
          ),
        ).matchParent(debugLabel: widget.runtimeType.toString()),
      widget.child,
    ]
        .stack(alignment: Alignment.center)!
        .constrainedMin(minWidth: widget.minWidth, minHeight: widget.minHeight)
        .paddingInsets(widget.margin)
        .click(
            widget.onTap ??
                () {
                  setState(() {
                    _currentValue = !_currentValue;
                    widget.onValueChanged?.call(_currentValue);
                  });
                },
            enable: widget.enableTap);
  }
}

/// 正常状态下, fill背景样式
/// checked状态下, stroke+fill背景样式
/// 选中状态样式小部件
/// [HighlightCheckWidget]
/// [StrokeFillCheckWidget]
class StrokeFillCheckWidget extends StatefulWidget {
  final Widget child;
  final bool checked;

  /// [GlobalTheme.accentColor]
  @defInjectMark
  final Color? checkedColor;

  final double strokeWidth;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  //--

  /// 点击事件, 设置之后[onValueChanged]不会被默认回调
  final GestureTapCallback? onTap;

  /// 长按事件
  final GestureLongPressCallback? onLongPress;

  /// 不指定[onTap]时, 自动触发的值改变回调
  final ValueChanged<bool>? onValueChanged;

  /// 是否激活点击
  final bool enableTap;

  /// 是否使用波纹点击样式
  final bool useInkWell;

  const StrokeFillCheckWidget({
    super.key,
    required this.child,
    this.checked = false,
    this.padding = kHSymInsets,
    this.margin = kMInsets,
    this.checkedColor,
    this.borderRadius = kDefaultBorderRadiusX,
    this.strokeWidth = 1,
    //--
    this.useInkWell = false,
    this.enableTap = true,
    this.onTap,
    this.onLongPress,
    this.onValueChanged,
  });

  @override
  State<StrokeFillCheckWidget> createState() => _StrokeFillCheckWidgetState();
}

class _StrokeFillCheckWidgetState extends State<StrokeFillCheckWidget> {
  bool _initialValue = false;
  bool _currentValue = false;

  @override
  void initState() {
    super.initState();
    _updateValue();
  }

  @override
  void didUpdateWidget(covariant StrokeFillCheckWidget oldWidget) {
    _updateValue();
    super.didUpdateWidget(oldWidget);
  }

  void _updateValue() {
    _initialValue = widget.checked;
    _currentValue = _initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final borderRadius = widget.borderRadius;
    final checkedColor = widget.checkedColor ?? globalTheme.accentColor;
    //装饰
    final decoration = _currentValue
        ? fillDecoration(
            color: checkedColor.withOpacity(0.3),
            radius: borderRadius,
            border: strokeBorder(
              color: checkedColor,
              borderRadius: borderRadius,
              strokeWidth: widget.strokeWidth,
            ),
          )
        : fillDecoration(
            color: globalTheme.itemWhiteBgColor,
            radius: borderRadius,
            border: strokeBorder(
              color: globalTheme.itemWhiteBgColor,
              borderRadius: borderRadius,
              strokeWidth: widget.strokeWidth,
            ),
          );

    if (widget.useInkWell) {
      //波纹点击效果
      return widget.child
          .container(padding: widget.padding, alignment: Alignment.center)
          .ink(
            widget.onTap ??
                () {
                  setState(() {
                    _currentValue = !_currentValue;
                    widget.onValueChanged?.call(_currentValue);
                  });
                },
            radius: borderRadius,
            decoration: decoration,
            enable: widget.enableTap,
            onLongPress: widget.onLongPress,
          )
          .paddingInsets(widget.margin);
    }

    return widget.child
        .container(
          padding: widget.padding,
          margin: widget.margin,
          decoration: decoration,
          alignment: Alignment.center,
        )
        .click(
          widget.onTap ??
              () {
                setState(() {
                  _currentValue = !_currentValue;
                  widget.onValueChanged?.call(_currentValue);
                });
              },
          enable: widget.enableTap,
          onLongPress: widget.onLongPress,
        );
  }
}

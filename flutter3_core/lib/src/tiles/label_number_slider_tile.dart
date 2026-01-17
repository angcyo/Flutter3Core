part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024-5-25
///
/// 上[label]     右[value].[number](支持键盘输入)
/// 下[Slider]
///
/// [SliderTile]
/// [LabelNumberTile]
/// [LabelNumberSliderTile]
/// [LabelRangeNumberSliderTile]
class LabelNumberSliderTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// value
  /// 不指定[value]时, 则使用[valueText]显示
  final num? value;
  final num? minValue;
  final num? maxValue;
  final int maxDigits;
  final String? valueText;

  /// 分段数, 必须>0, 表示把滑块分成多少段.
  /// null: 表示连续的, 不分段
  final int? divisions;
  final NumType? _numType;

  /// 是否显示数字
  final bool showNumber;

  /// 是否显示滑块
  final bool showSlider;

  /// 回调, 改变后的回调. 拖动过程中不回调
  final NumCallback? onValueChanged;

  /// 回调, 值更新就触发的回调. (拖动过程中也触发)
  final NumCallback? onValueUpdated;

  //MARK: -

  /// 活跃/不活跃的轨道渐变颜色
  final List<Color>? activeTrackGradientColors;
  final List<Color>? inactiveTrackGradientColors;

  /// 轨道高度
  final double? trackHeight;

  /// 轨道激活状态下的额外高度
  final double? additionalActiveTrackHeight;

  /// 轨道颜色
  @defInjectMark
  final Color? activeTrackColor;

  /// 不活跃滚动颜色
  final Color? inactiveTrackColor;

  /// 是否使用双边的轨道
  final bool? useCenteredTrackShape;

  /// 指示器的背景颜色
  final Color? valueIndicatorColor;

  /// 浮子文本样式
  final TextStyle? valueIndicatorTextStyle;

  /// 浮子的颜色
  @defInjectMark
  final Color? thumbColor;

  /// 自定义的浮子
  final SliderComponentShape? thumbShape;

  /// 浮子的半径, 默认10
  final double? thumbRadius;

  /// 光晕的半径,默认24
  final double? overlayRadius;

  /// 首次是否要通知
  final bool? firstNotify;

  const LabelNumberSliderTile({
    super.key,
    //--
    this.label,
    this.labelWidget,
    //--
    this.value = 0.0,
    this.valueText,
    this.minValue,
    this.maxValue,
    this.maxDigits = 2,
    this.divisions,
    this.onValueUpdated,
    this.onValueChanged,
    this.showNumber = true,
    this.showSlider = true,
    NumType? numType,
    //--
    this.trackHeight,
    this.additionalActiveTrackHeight,
    this.useCenteredTrackShape,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeTrackGradientColors,
    this.inactiveTrackGradientColors,
    this.valueIndicatorColor,
    this.valueIndicatorTextStyle,
    this.thumbColor,
    this.thumbShape,
    this.thumbRadius,
    this.overlayRadius,
    //--
    this.firstNotify,
  }) : _numType =
           numType ??
           (value != null
               ? (value is int ? NumType.i : NumType.d)
               : (minValue != null
                     ? (minValue is int ? NumType.i : NumType.d)
                     : (maxValue is int ? NumType.i : NumType.d)));

  @override
  State<LabelNumberSliderTile> createState() => _LabelNumberSliderTileState();
}

class _LabelNumberSliderTileState extends State<LabelNumberSliderTile>
    with TileMixin {
  num? _initialValue = 0;
  num? _currentValue = 0;

  @override
  void initState() {
    _updateValue(initial: true);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberSliderTile oldWidget) {
    _updateValue();
    super.didUpdateWidget(oldWidget);
  }

  void _updateValue({bool initial = false}) {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    if (initial && widget.firstNotify == true && _currentValue != null) {
      //debugger();
      notifyValueUpdated(_currentValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    //MARK: - label
    final labelWidget = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );

    //MARK: - number
    final numberStr = _currentValue == null
        ? widget.valueText
        : formatNumber(_currentValue!, numType: widget._numType);
    final numberWidget = widget.showNumber
        ? isDesktopOrWeb
              ? buildNumberInputWidget(
                  context,
                  numberStr,
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                  maxDigits: widget.maxDigits,
                  numType: widget._numType,
                  onChanged: (value) {
                    if (value is num) {
                      _currentValue = value;
                      notifyValueUpdated(value);
                      updateState();
                    }
                  },
                )
              : buildNumberWidget(
                  context,
                  numberStr,
                  onTap: () async {
                    final value = await context.showWidgetDialog(
                      NumberKeyboardDialog(
                        number: _currentValue ?? widget.minValue,
                        minValue: widget.minValue,
                        maxValue: widget.maxValue,
                        maxDigits: widget.maxDigits,
                        numType: widget._numType,
                      ),
                    );
                    if (value != null) {
                      _currentValue = value;
                      notifyValueUpdated(value);
                      updateState();
                    }
                  },
                )
        : null;

    //MARK: - top
    final top = [
      labelWidget?.expanded(),
      numberWidget?.paddingOnly(right: kX),
    ].row();
    final minValue = widget.minValue?.toDouble() ?? 0.0;
    final maxValue = widget.maxValue?.toDouble() ?? 1.0;
    double value = _currentValue?.toDouble() ?? minValue;
    if (value >= minValue && value <= maxValue) {
    } else {
      assert(() {
        debugger();
        return true;
      }());
      value = value.clamp(minValue, maxValue);
    }

    //MARK: - slider
    final bottom = buildSliderWidget(
      context,
      value,
      label: numberStr,
      divisions: widget.divisions,
      minValue: minValue,
      maxValue: maxValue,
      activeTrackGradientColors: widget.activeTrackGradientColors,
      activeTrackColor:
          widget.activeTrackColor ??
          (widget.inactiveTrackGradientColors == null
              ? globalTheme.primaryColor
              : Colors.transparent),
      inactiveTrackColor: widget.inactiveTrackColor,
      inactiveTrackGradientColors: widget.inactiveTrackGradientColors,
      trackHeight: widget.trackHeight,
      additionalActiveTrackHeight: widget.additionalActiveTrackHeight,
      useCenteredTrackShape: widget.useCenteredTrackShape,
      thumbColor: widget.thumbColor ?? globalTheme.accentColor,
      valueIndicatorColor: widget.valueIndicatorColor,
      valueIndicatorTextStyle: widget.valueIndicatorTextStyle,
      thumbShape: widget.thumbShape,
      overlayRadius: widget.overlayRadius,
      thumbRadius: widget.thumbRadius,
      onChanged: (value) {
        _currentValue = value;
        widget.onValueUpdated?.call(value);
        updateState();
      },
      onChangeEnd: (value) {
        num result = _currentValue ?? value;
        if (widget._numType == NumType.i) {
          result = (_currentValue ?? value).round();
        }
        widget.onValueChanged?.call(result);
      },
    );

    return [top, if (widget.showSlider) bottom].column()!.material();
  }

  /// 通知
  void notifyValueUpdated(num value) {
    widget.onValueUpdated?.call(value);
    widget.onValueChanged?.call(value);
  }
}

/// 范围滑块. 带范围值的滑块, 2个值.
/// 上[label]     右[startValue].[number](支持键盘输入) [endValue].[number](支持键盘输入)
/// 下[Slider]
/// [SliderTile]
/// [LabelNumberTile]
/// [LabelNumberSliderTile]
/// [LabelRangeNumberSliderTile]
class LabelRangeNumberSliderTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// value
  final num startValue;
  final num endValue;
  final num? minValue;
  final num? maxValue;
  final int maxDigits;
  final int? divisions;
  final NumType? _numType;

  /// 是否显示数字
  final bool showNumber;

  ///
  final RangeNumCallback? onValueChanged;
  final ValueChanged<RangeValues>? onRangeValueChanged;

  /// 活跃/不活跃的轨道颜色
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  /// 轨道高度
  final double? trackHeight;

  /// 指示器的背景颜色
  final Color? valueIndicatorColor;

  /// 浮子的颜色
  final Color? thumbColor;

  /// 自定义的浮子
  final RangeSliderThumbShape? thumbShape;

  /// 浮子文本样式
  final TextStyle? valueIndicatorTextStyle;

  const LabelRangeNumberSliderTile({
    super.key, //--
    this.label,
    this.labelWidget,
    //--
    this.startValue = 0,
    this.endValue = 100,
    this.minValue = 0,
    this.maxValue = 100,
    this.maxDigits = 2,
    this.onValueChanged,
    this.onRangeValueChanged,
    this.showNumber = true,
    //--
    this.divisions,
    NumType? numType,
    //--
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackHeight,
    this.thumbShape,
    this.thumbColor,
    this.valueIndicatorColor,
    this.valueIndicatorTextStyle,
  }) : _numType = numType ?? (startValue is int ? NumType.i : NumType.d);

  @override
  State<LabelRangeNumberSliderTile> createState() =>
      _LabelRangeNumberSliderTileState();
}

class _LabelRangeNumberSliderTileState extends State<LabelRangeNumberSliderTile>
    with TileMixin {
  num _initialStartValue = 0;
  num _currentStartValue = 0;

  num _initialEndValue = 100;
  num _currentEndValue = 100;

  @override
  void initState() {
    _updateValue();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelRangeNumberSliderTile oldWidget) {
    _updateValue();
    super.didUpdateWidget(oldWidget);
  }

  void _updateValue() {
    _initialStartValue = widget.startValue;
    _initialEndValue = widget.endValue;
    _currentStartValue = _initialStartValue;
    _currentEndValue = _initialEndValue;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );
    //number
    final startNumberStr = formatNumber(
      _currentStartValue,
      numType: widget._numType,
    );
    final startNumber = widget.showNumber
        ? buildNumberWidget(
            context,
            startNumberStr,
            onTap: () async {
              final value = await context.showWidgetDialog(
                NumberKeyboardDialog(
                  number: _currentStartValue,
                  minValue: widget.minValue,
                  maxValue: _currentEndValue,
                  maxDigits: widget.maxDigits,
                  numType: widget._numType,
                ),
              );
              if (value != null) {
                _currentStartValue = value;
                widget.onValueChanged?.call(
                  _currentStartValue,
                  _currentEndValue,
                );
                widget.onRangeValueChanged?.call(
                  RangeValues(
                    _currentStartValue.toNumDouble(),
                    _currentEndValue.toNumDouble(),
                  ),
                );
                updateState();
              }
            },
          )
        : null;

    final endNumberStr = formatNumber(
      _currentEndValue,
      numType: widget._numType,
    );
    final endNumber = widget.showNumber
        ? buildNumberWidget(
            context,
            endNumberStr,
            onTap: () async {
              final value = await context.showWidgetDialog(
                NumberKeyboardDialog(
                  number: _currentEndValue,
                  minValue: _currentStartValue,
                  maxValue: widget.maxValue,
                  maxDigits: widget.maxDigits,
                  numType: widget._numType,
                ),
              );
              if (value != null) {
                _currentEndValue = value;
                widget.onValueChanged?.call(
                  _currentStartValue,
                  _currentEndValue,
                );
                widget.onRangeValueChanged?.call(
                  RangeValues(
                    _currentStartValue.toNumDouble(),
                    _currentEndValue.toNumDouble(),
                  ),
                );
                updateState();
              }
            },
          )
        : null;

    //
    final top = [
      label?.expanded(),
      [
        startNumber,
        "-".text().paddingSymmetric(horizontal: kL),
        endNumber,
      ].row()?.paddingOnly(right: kX),
    ].row();
    final bottom = buildRangeSliderWidget(
      context,
      _currentStartValue.toNumDouble(),
      _currentEndValue.toNumDouble(),
      startLabel: startNumberStr,
      endLabel: endNumberStr,
      divisions: widget.divisions,
      minValue: widget.minValue?.toNumDouble() ?? 0.0,
      maxValue: widget.maxValue?.toNumDouble() ?? 100.0,
      /*activeTrackGradientColors: widget.activeTrackGradientColors,*/
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      /*inactiveTrackGradientColors: widget.inactiveTrackGradientColors,*/
      trackHeight: widget.trackHeight,
      /*useCenteredTrackShape: widget.useCenteredTrackShape,*/
      thumbColor: widget.thumbColor,
      valueIndicatorColor: widget.valueIndicatorColor,
      valueIndicatorTextStyle: widget.valueIndicatorTextStyle,
      thumbShape: widget.thumbShape,
      onChanged: (value) {
        _currentStartValue = formatDoubleNumber(value.start, widget._numType);
        _currentEndValue = formatDoubleNumber(value.end, widget._numType);
        updateState();
      },
      onChangeEnd: (value) {
        widget.onValueChanged?.call(_currentStartValue, _currentEndValue);
        widget.onRangeValueChanged?.call(
          RangeValues(
            _currentStartValue.toNumDouble(),
            _currentEndValue.toNumDouble(),
          ),
        );
      },
    );

    return [top, bottom].column()!.material();
  }
}

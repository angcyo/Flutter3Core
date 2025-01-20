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
  final num value;
  final num? minValue;
  final num? maxValue;
  final int maxDigits;
  final int? divisions;
  final NumType? _numType;

  /// 是否显示数字
  final bool showNumber;

  /// 活跃/不活跃的轨道渐变颜色
  final List<Color>? activeTrackGradientColors;
  final List<Color>? inactiveTrackGradientColors;

  /// 轨道高度
  final double? trackHeight;

  /// 轨道颜色
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;

  /// 是否使用双边的轨道
  final bool? useCenteredTrackShape;

  /// 指示器的背景颜色
  final Color? valueIndicatorColor;

  /// 浮子文本样式
  final TextStyle? valueIndicatorTextStyle;

  /// 浮子的颜色
  final Color? thumbColor;

  /// 自定义的浮子
  final SliderComponentShape? thumbShape;

  /// 回调, 改变后的回调. 拖动过程中不回调
  final NumCallback? onValueChanged;

  const LabelNumberSliderTile({
    super.key,
    //--
    this.label,
    this.labelWidget,
    //--
    this.value = 0.0,
    this.minValue,
    this.maxValue,
    this.maxDigits = 2,
    this.onValueChanged,
    this.showNumber = true,
    NumType? numType,
    //--
    this.divisions,
    this.trackHeight,
    this.useCenteredTrackShape,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.activeTrackGradientColors,
    this.inactiveTrackGradientColors,
    this.valueIndicatorColor,
    this.valueIndicatorTextStyle,
    this.thumbColor,
    this.thumbShape,
  }) : _numType = numType ?? (value is int ? NumType.i : NumType.d);

  @override
  State<LabelNumberSliderTile> createState() => _LabelNumberSliderTileState();
}

class _LabelNumberSliderTileState extends State<LabelNumberSliderTile>
    with TileMixin {
  num _initialValue = 0;
  num _currentValue = 0;

  @override
  void initState() {
    _updateValue();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberSliderTile oldWidget) {
    _updateValue();
    super.didUpdateWidget(oldWidget);
  }

  void _updateValue() {
    _initialValue = widget.value;
    _currentValue = _initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );
    final numberStr = formatNumber(_currentValue, numType: widget._numType);
    final number = widget.showNumber
        ? buildNumberWidget(context, numberStr, onTap: () async {
            final value = await context.showWidgetDialog(NumberKeyboardDialog(
              number: _currentValue,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
              maxDigits: widget.maxDigits,
              numType: widget._numType,
            ));
            if (value != null) {
              _currentValue = value;
              widget.onValueChanged?.call(_currentValue);
              updateState();
            }
          })
        : null;

    //
    final top = [
      label?.expanded(),
      number?.paddingOnly(right: kX),
    ].row();
    final value = _currentValue.toDouble();
    final minValue = widget.minValue?.toDouble() ?? 0.0;
    final maxValue = widget.maxValue?.toDouble() ?? 1.0;
    if (value >= minValue && value <= maxValue) {
    } else {
      assert(() {
        debugger();
        return true;
      }());
    }
    final bottom = buildSliderWidget(
      context,
      value,
      label: numberStr,
      divisions: widget.divisions,
      minValue: minValue,
      maxValue: maxValue,
      activeTrackGradientColors: widget.activeTrackGradientColors,
      activeTrackColor: widget.activeTrackColor ??
          (widget.inactiveTrackGradientColors == null
              ? null
              : Colors.transparent),
      inactiveTrackColor: widget.inactiveTrackColor,
      inactiveTrackGradientColors: widget.inactiveTrackGradientColors,
      trackHeight: widget.trackHeight,
      useCenteredTrackShape: widget.useCenteredTrackShape,
      thumbColor: widget.thumbColor,
      valueIndicatorColor: widget.valueIndicatorColor,
      valueIndicatorTextStyle: widget.valueIndicatorTextStyle,
      thumbShape: widget.thumbShape,
      onChanged: (value) {
        _currentValue = value;
        updateState();
      },
      onChangeEnd: (value) {
        num result = _currentValue;
        if (widget._numType == NumType.i) {
          result = _currentValue.round();
        }
        widget.onValueChanged?.call(result);
      },
    );

    return [top, bottom].column()!.material();
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
    final startNumberStr =
        formatNumber(_currentStartValue, numType: widget._numType);
    final startNumber = widget.showNumber
        ? buildNumberWidget(context, startNumberStr, onTap: () async {
            final value = await context.showWidgetDialog(NumberKeyboardDialog(
              number: _currentStartValue,
              minValue: widget.minValue,
              maxValue: _currentEndValue,
              maxDigits: widget.maxDigits,
              numType: widget._numType,
            ));
            if (value != null) {
              _currentStartValue = value;
              widget.onValueChanged?.call(_currentStartValue, _currentEndValue);
              widget.onRangeValueChanged?.call(RangeValues(
                  _currentStartValue.toNumDouble(),
                  _currentEndValue.toNumDouble()));
              updateState();
            }
          })
        : null;

    final endNumberStr =
        formatNumber(_currentEndValue, numType: widget._numType);
    final endNumber = widget.showNumber
        ? buildNumberWidget(context, endNumberStr, onTap: () async {
            final value = await context.showWidgetDialog(NumberKeyboardDialog(
              number: _currentEndValue,
              minValue: _currentStartValue,
              maxValue: widget.maxValue,
              maxDigits: widget.maxDigits,
              numType: widget._numType,
            ));
            if (value != null) {
              _currentEndValue = value;
              widget.onValueChanged?.call(_currentStartValue, _currentEndValue);
              widget.onRangeValueChanged?.call(RangeValues(
                  _currentStartValue.toNumDouble(),
                  _currentEndValue.toNumDouble()));
              updateState();
            }
          })
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
        widget.onRangeValueChanged?.call(RangeValues(
            _currentStartValue.toNumDouble(), _currentEndValue.toNumDouble()));
      },
    );

    return [top, bottom].column()!.material();
  }
}

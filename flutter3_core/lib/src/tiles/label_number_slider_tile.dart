part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024-5-25
///
/// 上label     number(支持键盘输入)
/// 下slider
/// [SliderTile]
/// [LabelNumberTile]
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

  /// 活跃/不活跃的轨道渐变颜色
  final List<Color>? activeTrackGradientColors;
  final List<Color>? inactiveTrackGradientColors;

  /// 回调
  final NumCallback? onNumberChange;

  const LabelNumberSliderTile({
    super.key,
    this.label,
    this.labelWidget,
    this.value = 0.0,
    this.minValue,
    this.maxValue,
    this.maxDigits = 2,
    this.divisions,
    this.activeTrackGradientColors,
    this.inactiveTrackGradientColors,
    this.onNumberChange,
    NumType? numType,
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
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberSliderTile oldWidget) {
    _initialValue = widget.value;
    _currentValue = _initialValue;
    super.didUpdateWidget(oldWidget);
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
    final number = buildNumberWidget(context, numberStr, onTap: () async {
      final value = await context.showWidgetDialog(NumberKeyboardDialog(
        number: _currentValue,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        maxDigits: widget.maxDigits,
        numType: widget._numType,
      ));
      if (value != null) {
        _currentValue = value;
        widget.onNumberChange?.call(_currentValue);
        updateState();
      }
    });

    //
    final top = [
      label?.expanded(),
      number?.paddingOnly(right: kX),
    ].row()!;
    final bottom = buildSliderWidget(
      context,
      _currentValue.toDouble(),
      label: numberStr,
      divisions: widget.divisions,
      minValue: widget.minValue?.toDouble() ?? 0.0,
      maxValue: widget.maxValue?.toDouble() ?? 1.0,
      activeTrackGradientColors: widget.activeTrackGradientColors,
      activeTrackColor: widget.inactiveTrackGradientColors == null
          ? null
          : Colors.transparent,
      inactiveTrackGradientColors: widget.inactiveTrackGradientColors,
      onChanged: (value) {
        _currentValue = value;
        updateState();
      },
      onChangeEnd: (value) {
        widget.onNumberChange?.call(_currentValue);
      },
    );

    return [top, bottom].column()!.material();
  }
}

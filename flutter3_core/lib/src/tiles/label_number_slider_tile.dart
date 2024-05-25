part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024-5-25
///
/// 上label     number(支持键盘输入)
/// 下slider
/// [SliderTile]
class LabelNumberSliderTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// value
  final num value;
  final num minValue;
  final num maxValue;
  final int? divisions;
  final NumType? _numType;

  ///
  final List<Color>? activeTrackGradientColors;

  /// 回调
  final NumCallback? onNumberChange;

  const LabelNumberSliderTile({
    super.key,
    this.label,
    this.labelWidget,
    this.value = 0.0,
    this.minValue = 0.0,
    this.maxValue = 1.0,
    this.divisions,
    this.activeTrackGradientColors,
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
      minValue: widget.minValue.toDouble(),
      maxValue: widget.maxValue.toDouble(),
      activeTrackGradientColors: widget.activeTrackGradientColors,
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

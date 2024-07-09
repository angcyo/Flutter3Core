part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/13
///
/// 滑块tile
/// [leading]...[slider]...[trailing]
/// [LabelNumberSliderTile]
class SliderTile extends StatefulWidget {
  /// 左边/头部的小部件
  /// [leading]  头部
  /// [trailing] 尾部
  final Widget? leadingWidget;

  /// 右边/尾部的小部件
  /// [leading]  头部
  /// [trailing] 尾部
  final Widget? trailingWidget;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 间隔
  final double gap;

  /// 是否显示尾部的数值显示
  final bool showValue;

  /// 数值显示的最小宽度
  final double showValueMinWidth;

  /// 小数位数
  final int showValueDigits;

  //---slider---

  /// 是否显示值指示器
  final ShowValueIndicator showValueIndicator;

  /// 滑块的当前的值
  final double value;

  /// 滑块的最小值
  final double minValue;

  /// 滑块的最大值
  final double maxValue;

  /// 滑块的分割线
  final int? divisions;

  /// 滑块值改变回调
  final ValueChanged<double>? onChanged;

  /// 滑块值改变开始回调
  final ValueChanged<double>? onChangeStart;

  /// 滑块值改变结束回调
  final ValueChanged<double>? onChangeEnd;

  const SliderTile({
    super.key,
    this.leadingWidget,
    this.trailingWidget,
    this.divisions,
    this.showValue = true,
    this.showValueMinWidth = 40,
    this.showValueDigits = kDefaultDigits,
    this.padding = const EdgeInsets.symmetric(vertical: kL, horizontal: kX),
    this.value = 0,
    this.minValue = 0,
    this.maxValue = 1,
    this.gap = kH,
    this.showValueIndicator = ShowValueIndicator.always,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  State<SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> with TileMixin {
  double _value = 0;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final valueStr = _value.toDigits(digits: widget.showValueDigits);
    return [
      widget.leadingWidget,
      SliderTheme(
        data: SliderThemeData(
          showValueIndicator: widget.showValueIndicator,
        ),
        child: Slider(
          value: _value,
          min: widget.minValue,
          max: widget.maxValue,
          divisions: widget.divisions,
          label: valueStr,
          onChanged: (value) {
            _value = value;
            widget.onChanged?.call(value);
            updateState();
          },
          onChangeStart: widget.onChangeStart,
          onChangeEnd: widget.onChangeEnd,
        ),
      ).expanded(),
      if (widget.showValue)
        valueStr
            .text(textAlign: TextAlign.center)
            .constrainedMin(minWidth: widget.showValueMinWidth),
      widget.trailingWidget,
    ].row(gap: widget.gap)!.paddingInsets(widget.padding).material();
  }
}

/// 双向滑块tile
/// [start]...[end]
/// [RangeSlider]
///
class RangeSliderTile extends StatefulWidget {
  /// 开始值的提示小部件
  final Widget? startWidget;
  final EdgeInsetsGeometry? startPadding;

  /// 结束值的提示小部件
  final Widget? endWidget;
  final EdgeInsetsGeometry? endPadding;

  /// 小数位数
  final int showValueDigits;

  //---RangeSlider---

  /// 是否显示值指示器
  final ShowValueIndicator showValueIndicator;

  /// 滑块的当前的值
  final double startValue;
  final double endValue;

  /// 滑块的最小值
  final double minValue;

  /// 滑块的最大值
  final double maxValue;

  /// 滑块的分割线
  final int? divisions;

  /// 滑块值改变回调
  final ValueChanged<RangeValues>? onChanged;

  /// 滑块值改变开始回调
  final ValueChanged<RangeValues>? onChangeStart;

  /// 滑块值改变结束回调
  final ValueChanged<RangeValues>? onChangeEnd;

  const RangeSliderTile({
    super.key,
    this.startWidget,
    this.endWidget,
    this.showValueDigits = kDefaultDigits,
    this.startPadding = kLabelPaddingInline,
    this.endPadding = kLabelPaddingInline,
    //--
    this.divisions,
    this.showValueIndicator = ShowValueIndicator.always,
    this.startValue = 0,
    this.endValue = 1,
    this.minValue = 0,
    this.maxValue = 1,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  State<RangeSliderTile> createState() => _RangeSliderTileState();
}

class _RangeSliderTileState extends State<RangeSliderTile> with TileMixin {
  double _startValue = 0;
  double _endValue = 0;

  @override
  void initState() {
    _startValue = widget.startValue;
    _endValue = widget.endValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RangeSliderTile oldWidget) {
    _startValue = widget.startValue;
    _endValue = widget.endValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    //
    final top = LeftCenterRightLayout(
      left: widget.startWidget?.paddingInsets(widget.startPadding),
      right: widget.endWidget?.paddingInsets(widget.endPadding),
    );
    //
    final startValueStr = _startValue.toDigits(digits: widget.showValueDigits);
    final endValueStr = _endValue.toDigits(digits: widget.showValueDigits);
    //debugger();
    final bottom = buildRangeSliderWidget(
      context,
      _startValue,
      _endValue,
      minValue: widget.minValue,
      maxValue: widget.maxValue,
      divisions: widget.divisions,
      startLabel: startValueStr,
      endLabel: endValueStr,
      showValueIndicator: widget.showValueIndicator,
      onChanged: (value) {
        _startValue = value.start;
        _endValue = value.end;
        widget.onChanged?.call(value);
        updateState();
      },
      onChangeStart: widget.onChangeStart,
      onChangeEnd: widget.onChangeEnd,
    );
    return [
      top,
      bottom,
    ].column()!;
  }
}

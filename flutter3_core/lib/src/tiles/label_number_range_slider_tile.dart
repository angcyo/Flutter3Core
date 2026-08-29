part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/29
///
/// 范围数字滑动条
/// - [RangeSliderTile]
///
/// - [LabelNumberSliderTile] 单数字滑块
/// - [LabelNumberRangeSliderTile] 范围数字滑块
class LabelNumberRangeSliderTile extends StatefulWidget with LabelMixin {
  /// 是否显示数字输入
  final bool showNumber;

  /// 是否显示滑块
  final bool showSlider;

  //MARK: LabelMixin

  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final Widget? labelTrailingWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  //MARK: RangeSliderTile

  /// 需要显示的小数位数
  final int showValueDigits;

  /// 滑块的当前的值
  final double startValue;
  final double endValue;

  /// 滑块的最小值/最大值
  final double? minValue;
  final double? maxValue;

  /// 滑块值改变回调
  final ValueChanged<RangeValues>? onChanged;

  /// 滑块值改变开始回调
  final ValueChanged<RangeValues>? onChangeStart;

  /// 滑块值改变结束回调
  final ValueChanged<RangeValues>? onChangeEnd;

  /// 限制2个拇指之间的最小距离像素
  final double? minThumbSeparation;

  /// 滑块轨道的高度
  final double? trackHeight;

  /// 激活时滑块的额外补偿高度
  final double? additionalActiveTrackHeight;

  final double? overlayRadius;
  final double? thumbRadius;

  //--
  const LabelNumberRangeSliderTile({
    super.key,
    this.showNumber = true,
    this.showSlider = true,
    //MARK: LabelMixin
    this.label,
    this.labelWidget,
    this.labelTrailingWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints = kLabelConstraints,
    //MARK: RangeSliderTile
    this.showValueDigits = kDefaultDigits,
    this.startValue = 0,
    this.endValue = 1,
    this.minValue,
    this.maxValue,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.minThumbSeparation,
    this.trackHeight,
    this.additionalActiveTrackHeight,
    this.overlayRadius,
    this.thumbRadius,
  });

  @override
  State<LabelNumberRangeSliderTile> createState() =>
      _LabelNumberRangeSliderTileState();
}

class _LabelNumberRangeSliderTileState extends State<LabelNumberRangeSliderTile>
    with TileMixin {
  double _startValue = 0;
  double _endValue = 0;

  @override
  void initState() {
    _startValue = widget.startValue;
    _endValue = widget.endValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelNumberRangeSliderTile oldWidget) {
    _startValue = widget.startValue;
    _endValue = widget.endValue;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final digits = widget.showValueDigits;
    final startValueLabel = _startValue.toDigits(digits: digits);
    final endValueLabel = _endValue.toDigits(digits: digits);
    final minValue = widget.minValue ?? widget.startValue;
    final maxValue = widget.maxValue ?? widget.endValue;
    //
    final labelWidget = widget.buildLabelWidgetMixin(context);
    final WidgetList numberWidgetList;
    if (widget.showNumber) {
      numberWidgetList = [
        //start value
        _buildNumberWidget(
          context,
          startValueLabel,
          minValue: minValue,
          maxValue: _endValue,
          maxDigits: digits,
          onChanged: (value) {
            _startValue = value;
            widget.onChanged?.call(RangeValues(_startValue, _endValue));
            updateState();
          },
          onSubmitted: (value) {
            widget.onChangeEnd?.call(RangeValues(_startValue, _endValue));
          },
        ),
        " $kNRS ".text(),
        //end value
        _buildNumberWidget(
          context,
          endValueLabel,
          minValue: _startValue,
          maxValue: maxValue,
          maxDigits: digits,
          onChanged: (value) {
            _endValue = value;
            widget.onChanged?.call(RangeValues(_startValue, _endValue));
            updateState();
          },
          onSubmitted: (value) {
            widget.onChangeEnd?.call(RangeValues(_startValue, _endValue));
          },
        ),
      ];
    } else {
      numberWidgetList = [];
    }
    return [
      [
        labelWidget,
        numberWidgetList.row(mainAxisAlignment: .end)?.expanded(),
      ].row()?.insets(right: kX),
      if (widget.showSlider)
        RangeSliderTile(
          startValue: _startValue,
          endValue: _endValue,
          minValue: minValue,
          maxValue: maxValue,
          showValueDigits: digits,
          onChanged: (values) {
            _startValue = values.start;
            _endValue = values.end;
            widget.onChanged?.call(values);
            updateState();
          },
          onChangeStart: widget.onChangeStart,
          onChangeEnd: widget.onChangeEnd,
          minThumbSeparation: widget.minThumbSeparation,
          trackHeight: widget.trackHeight,
          additionalActiveTrackHeight: widget.additionalActiveTrackHeight,
          overlayRadius: widget.overlayRadius,
          thumbRadius: widget.thumbRadius,
        ),
    ].column()!;
  }

  /// 构建数字小部件
  Widget _buildNumberWidget(
    BuildContext context,
    String numberStr, {
    double? minValue,
    double? maxValue,
    int? maxDigits,
    double? radius = kDefaultBorderRadiusL,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onSubmitted,
  }) {
    return isDesktopOrWeb
        ? buildNumberInputWidget(
            context,
            numberStr,
            minValue: minValue,
            maxValue: maxValue,
            maxDigits: maxDigits ?? 2,
            numType: .d,
            radius: radius,
            ignoreInputOverflow: true,
            /*debugLabel: "buildNumberWidget",*/
            onChanged: (value) {
              if (value is double) {
                onChanged?.call(value);
              }
            },
            onSubmitted: (value) {
              if (value is double) {
                onSubmitted?.call(value);
              }
            },
          )
        : buildNumberWidget(
            context,
            numberStr,
            radius: radius,
            onTap: () async {
              final value = await context.showWidgetDialog(
                NumberKeyboardDialog(
                  number: numberStr.toDouble(),
                  minValue: minValue,
                  maxValue: maxValue,
                  maxDigits: maxDigits ?? 2,
                  numType: .d,
                ),
              );
              if (value is double) {
                onChanged?.call(value);
                onSubmitted?.call(value);
              }
            },
          );
  }
}

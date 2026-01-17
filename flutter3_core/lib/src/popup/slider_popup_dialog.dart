part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/17
///
/// 滑块popup弹窗
class SliderPopupDialog extends StatefulWidget with TranslationTypeMixin {
  @defInjectMark
  final Widget? body;

  //MARK: -

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

  /// 是否显示数字
  final bool showNumber;

  /// 是否显示滑块
  final bool showSlider;

  /// 回调, 改变后的回调. 拖动过程中不回调
  final NumCallback? onValueChanged;

  /// 回调, 值更新就触发的回调. (拖动过程中也触发)
  final NumCallback? onValueUpdated;

  /// 首次是否要通知
  final bool? firstNotify;

  const SliderPopupDialog({
    super.key,
    this.body,
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
    //--
    this.firstNotify,
  });

  @override
  State<SliderPopupDialog> createState() => _SliderPopupDialogState();
}

class _SliderPopupDialogState extends State<SliderPopupDialog> {
  @override
  Widget build(BuildContext context) {
    return widget.body ??
        LabelNumberSliderTile(
          label: widget.label,
          value: widget.value,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          maxDigits: widget.maxDigits,
          divisions: widget.divisions,
          onValueChanged: widget.onValueChanged,
          onValueUpdated: widget.onValueUpdated,
          showNumber: widget.showNumber,
          showSlider: widget.showSlider,
          firstNotify: widget.firstNotify,
        ).constrainedMax(maxWidth: kDesktopPopupWidth);
  }
}

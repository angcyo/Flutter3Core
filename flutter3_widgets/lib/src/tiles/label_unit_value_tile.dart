part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/02
///
/// [label]..[value]..[unit]
class LabelUnitValueTile extends StatelessWidget with LabelMixin, TileMixin {
  /// 标签/LabelMixin
  @override
  final String? label;
  @override
  final Widget? labelWidget;
  @override
  final TextStyle? labelTextStyle;
  @override
  final EdgeInsets? labelPadding;
  @override
  final BoxConstraints? labelConstraints;

  //--unit
  @dp
  final double? value;
  final IUnit? unit;

  //--

  final double gap;

  const LabelUnitValueTile({
    super.key,
    //LabelMixin
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPaddingMin,
    this.labelConstraints,
    //--
    this.value,
    this.unit,
    //--
    this.gap = 2,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final labelStyle = labelTextStyle ?? globalTheme.textDesStyle;
    //label
    Widget? label = buildLabelWidgetMixin(
      context,
      labelTextStyle: labelStyle,
    );
    //value
    Widget? value = buildTextWidget(
      context,
      text: this.value == null
          ? null
          : unit?.formatFromDp(this.value ?? 0, showSuffix: false),
    );
    //unit
    Widget? suffix = buildLabelWidget(
      context,
      label: unit?.suffix,
      labelStyle: labelStyle,
      labelPadding: labelPadding,
      constraints: null,
    );
    return [
      label,
      value?.expanded(),
      suffix,
    ].row(gap: gap)!;
  }
}

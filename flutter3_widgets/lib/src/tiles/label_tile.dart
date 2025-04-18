part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
///

/// 左[label] 右[layout] tile
class LabelLayoutTile extends StatelessWidget with LabelMixin {
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

  //--

  /// layout
  final WidgetNullList? children;

  /// 间隙
  final double? childGap;

  const LabelLayoutTile({
    super.key,
    //LabelMixin
    this.label,
    this.labelWidget,
    this.labelTextStyle,
    this.labelPadding = kLabelPadding,
    this.labelConstraints = kLabelConstraints,
    //
    this.children,
    this.childGap = kH,
  });

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //label
    Widget? label = buildLabelWidgetMixin(context);
    return [
      label,
      ...?children,
    ].row(gap: childGap)!;
  }
}

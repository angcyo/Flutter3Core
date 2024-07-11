part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
/// 标签混入
/// [kLabelPadding]
mixin LabelMixin {
  /// 标签
  String? get label => null;

  Widget? get labelWidget => null;

  TextStyle? get labelTextStyle => null;

  EdgeInsets? get labelPadding => null;

  BoxConstraints? get labelConstraints => null;

  /// 构建对应的小部件
  /// [buildLabelWidget]
  @callPoint
  Widget? buildLabelWidgetMixin(
    BuildContext context, {
    bool themeStyle = true,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = labelWidget ??
        (label
            ?.text(
              style: labelTextStyle ??
                  (themeStyle ? globalTheme.textLabelStyle : null),
            )
            .constrainedBox(labelConstraints)
            .paddingInsets(labelPadding));
    return widget?.paddingInsets(padding);
  }
}

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

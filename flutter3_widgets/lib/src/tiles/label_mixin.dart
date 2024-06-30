part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/06/29
/// 标签混入
/// [kLabelPadding]
mixin LabelMixin {
  /// 标签
  String? get label;

  Widget? get labelWidget;

  TextStyle? get labelTextStyle;

  EdgeInsets? get labelPadding;

  BoxConstraints? get labelConstraints;

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

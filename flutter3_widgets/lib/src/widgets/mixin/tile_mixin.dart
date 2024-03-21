part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/21
///

mixin TileMixin {
  /// 构建图标小部件
  Widget? buildIconWidget(
    BuildContext context,
    Widget? iconWidget, {
    IconData? icon,
    double? iconSize,
    Color? iconColor,
    bool themeStyle = true,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = iconWidget ??
        (icon == null
            ? null
            : Icon(
                icon,
                size: iconSize,
                color:
                    iconColor ?? (themeStyle ? globalTheme.accentColor : null),
              ));
    return widget?.paddingInsets(padding);
  }

  /// 构建文本小部件
  Widget? buildTextWidget(
    BuildContext context,
    Widget? textWidget, {
    String? text,
    TextStyle? textStyle,
    bool themeStyle = true,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = textWidget ??
        (text?.text(
          style: textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null),
        ));
    return widget?.paddingInsets(padding);
  }
}

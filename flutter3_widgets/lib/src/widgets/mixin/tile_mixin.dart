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

  /// 构建一个[Switch]开关小部件
  /// [activeColor] 激活时圈圈的颜色
  /// [activeTrackColor] 激活时轨道的颜色
  Widget buildSwitchWidget(
    BuildContext context,
    bool value, {
    ValueChanged<bool>? onChanged,
    double? height = 30.0,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    Color? focusColor,
    Color? hoverColor,
    Color? splashColor,
    Color? disabledColor,
    MouseCursor? mouseCursor,
    MaterialTapTargetSize? materialTapTargetSize =
        MaterialTapTargetSize.shrinkWrap,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    double? iconSize,
    Widget? icon,
    Widget? activeIcon,
    Color? tintColor,
    Color? disableTintColor,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    Widget widget = Switch(
      value: value,
      onChanged: onChanged ??
          (value) {
            l.d('开关->$value');
          },
      activeColor: activeColor,
      activeTrackColor: activeTrackColor ?? globalTheme.accentColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      mouseCursor: mouseCursor,
      materialTapTargetSize: materialTapTargetSize,
      dragStartBehavior: dragStartBehavior,
    );

    //使用[FittedBox]控制大小
    if (height != null) {
      widget = widget.fittedBox().wh(60 / 40 * height, height);
    }

    return widget.paddingInsets(padding);
  }
}

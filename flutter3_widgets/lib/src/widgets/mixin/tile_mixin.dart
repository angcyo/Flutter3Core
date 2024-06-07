part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/21
///

/// 提供一个文本字符串
mixin ITextProvider {
  String? get provideText;
}

/// 提供一个Widget
mixin IWidgetProvider {
  WidgetBuilder? get provideWidget;
}

/// 在一个数据中, 提取文本
String? textOf(dynamic data) {
  if (data == null) {
    return null;
  }
  if (data is String) {
    return data;
  }
  if (data is ITextProvider) {
    return data.provideText;
  }
  if (data != null) {
    try {
      return data.text;
    } catch (e) {
      assert(() {
        l.w('当前类型[${data.runtimeType}],不支持[.text]/[ITextProvider]操作.');
        return true;
      }());
      return "$data";
    }
  }
  return null;
}

/// 在一个数据中, 提取Widget
/// [tryTextWidget] 是否尝试使用[Text]小部件
Widget? widgetOf(
  BuildContext context,
  dynamic data, {
  bool tryTextWidget = false,
  TextStyle? textStyle,
  TextAlign? textAlign,
}) {
  if (data == null) {
    return null;
  }
  if (data is Widget) {
    return data;
  }
  if (data is IWidgetProvider && data.provideWidget != null) {
    return data.provideWidget?.call(context);
  }
  if (tryTextWidget) {
    final text = textOf(data);
    if (text != null) {
      final globalTheme = GlobalTheme.of(context);
      return text.text(
        style: textStyle ?? globalTheme.textGeneralStyle,
        textAlign: textAlign,
      );
    }
  }
  assert(() {
    l.w('当前类型[${data.runtimeType}]不支持[IWidgetProvider]操作.');
    return true;
  }());
  return null;
}

//---

/// label默认的填充
/// 左边显示的文本
const kLabelPadding = EdgeInsets.only(
  left: kX,
  right: kX,
  top: kH,
  bottom: kH,
);

/// content默认的填充
/// [kLabelPadding] 右边的内容
const kContentPadding = EdgeInsets.only(
  left: 0,
  top: kM,
  bottom: kM,
  right: kX,
);

const kLabelMinWidth = 80.0;
const kNumberMinWidth = 50.0;

/// label默认的约束
const kLabelConstraints = BoxConstraints(
  minWidth: kLabelMinWidth,
  maxWidth: kLabelMinWidth,
);

/// number默认的约束
const kNumberConstraints = BoxConstraints(
  minWidth: kNumberMinWidth,
);

//---

mixin TileMixin {
  //region ---构建小部件---

  /// 构建图标小部件
  Widget? buildIconWidget(
    BuildContext context, {
    Widget? iconWidget,
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
  /// [GlobalTheme.textDesStyle]
  /// [GlobalTheme.textBodyStyle]
  /// [GlobalTheme.textLabelStyle]
  Widget? buildTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    TextAlign? textAlign,
    TextStyle? textStyle,
    bool themeStyle = true,
    EdgeInsets? textPadding,
    EdgeInsets? padding,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = textWidget ??
        (text
            ?.text(
              textAlign: textAlign,
              style:
                  textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null),
            )
            .paddingInsets(textPadding));
    return widget?.paddingInsets(padding);
  }

  /// [buildTextWidget]
  Widget? buildLabelWidget(
    BuildContext context, {
    Widget? labelWidget,
    String? label,
    TextStyle? labelStyle,
    bool themeStyle = true,
    EdgeInsets? labelPadding = kLabelPadding,
    EdgeInsets? padding,
    BoxConstraints? constraints = kLabelConstraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = labelWidget ??
        (label
            ?.text(
              style: labelStyle ??
                  (themeStyle ? globalTheme.textLabelStyle : null),
            )
            .constrainedBox(constraints)
            .paddingInsets(labelPadding));
    return widget?.paddingInsets(padding);
  }

  /// 构建判断文本小部件, 支持选中状态提示
  /// [enable] 是否启用
  /// [isSelected] 是否选中
  Widget? buildSegmentTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    bool enable = true,
    bool isSelected = false,
    bool themeStyle = true,
    EdgeInsets? padding = const EdgeInsets.all(kL),
  }) {
    final globalTheme = GlobalTheme.of(context);
    final normalTextStyle =
        textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null);
    final selectTextStyle = selectedTextStyle ??
        textStyle?.copyWith(fontWeight: ui.FontWeight.bold) ??
        (themeStyle
            ? globalTheme.textBodyStyle.copyWith(
                fontWeight: ui.FontWeight.bold,
                color: context.isThemeDark ? globalTheme.blackColor : null)
            : null);

    final widget = textWidget ??
        (text?.text(
          textAlign: ui.TextAlign.center,
          style: isSelected ? selectTextStyle : normalTextStyle,
        ));
    return widget?.paddingInsets(padding).backgroundDecoration(!enable
        ? fillDecoration(
            color: globalTheme.disableColor,
            borderRadius: kDefaultBorderRadiusX,
          )
        : isSelected
            ? fillDecoration(
                color: globalTheme.accentColor,
                borderRadius: kDefaultBorderRadiusX,
              )
            : null);
  }

  //endregion ---构建小部件---

  //region ---常用小部件---

  /*Widget buildCheckBoxWidget(BuildContext context,){
    final globalTheme = GlobalTheme.of(context);

    return Checkbox();
  }*/

  /// 构建一个[Switch]开关小部件
  /// [activeColor] 激活时圈圈的颜色
  /// [activeTrackColor] 激活时轨道的颜色
  /// [Switch]小部件需要[Material]支持.
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
            assert(() {
              l.d('开关切换->$value');
              return true;
            }());
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

  /// 构建一个[Slider]滑块小部件
  /// [value] 当前值[minValue~maxValue]
  /// [minValue]
  /// [maxValue]
  /// [divisions] 滑块要分几段, 1段2个点(首尾)
  /// [showValueIndicator] 在滑块上显示值的时机
  ///
  /// [trackHeight] 轨道的高度
  /// [thumbColor] 浮子的颜色
  /// [overlayColor] 触摸时浮子光晕的颜色
  /// [activeTrackColor] 有值轨道的颜色
  /// [activeTrackGradientColors] 有值轨道的渐变颜色
  /// [inactiveTrackColor] 无值轨道的颜色(背景颜色)
  /// [valueIndicatorColor] 气泡的颜色
  ///
  /// [Slider]小部件需要[Material]支持.
  Widget buildSliderWidget(
    BuildContext context,
    double value, {
    String? label,
    double minValue = 0,
    double maxValue = 1,
    int digits = kDefaultDigits,
    int? divisions,
    ShowValueIndicator? showValueIndicator = ShowValueIndicator.always,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    Color? thumbColor,
    Color? overlayColor,
    Color? activeTrackColor,
    List<Color>? activeTrackGradientColors,
    Color? inactiveTrackColor,
    Color? valueIndicatorColor,
    double? trackHeight,
    SliderTrackShape? trackShape,
  }) {
    if (trackShape == null) {
      if (!isNil(activeTrackGradientColors)) {
        trackShape = GradientSliderTrackShape(activeTrackGradientColors!);
        final last = activeTrackGradientColors.last;
        thumbColor ??= last;
        valueIndicatorColor = thumbColor;
        overlayColor ??= last.withOpacity(0.1);
      }
    }
    final globalTheme = GlobalTheme.of(context);
    final darkAccentColor =
        context.isThemeDark ? globalTheme.accentColor : null;
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: showValueIndicator,
        thumbColor: thumbColor ?? darkAccentColor,
        activeTrackColor: activeTrackColor ?? darkAccentColor,
        overlayColor: overlayColor ?? darkAccentColor?.withOpacity(0.1),
        valueIndicatorColor: valueIndicatorColor ?? darkAccentColor,
        inactiveTrackColor: inactiveTrackColor,
        //thumbShape: ,
        trackShape: trackShape,
        /*inactiveTrackColor: Colors.redAccent,*/
        trackHeight: trackHeight,
        /*valueIndicatorTextStyle: globalTheme.textBodyStyle,*/
      ),
      child: Slider(
        value: value,
        min: minValue,
        max: maxValue,
        divisions: divisions,
        label: label ?? value.toDigits(digits: digits),
        onChanged: onChanged ??
            (value) {
              assert(() {
                l.d('滑块[$minValue~$maxValue]:$value');
                return true;
              }());
            },
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  //endregion ---常用小部件---

  //region ---辅助小部件---

  /// 根据[values].[children]创建[WidgetList]
  /// [selectedIndex] 选中的索引, 选中的颜色会不一样
  WidgetList? buildChildrenFromValues(
    BuildContext context, {
    List? values,
    List<Widget>? valuesWidget,
    TransformDataWidgetBuilder? transformValueWidget,
    int? selectedIndex,
  }) {
    WidgetList? result;
    if (valuesWidget == null) {
      final globalTheme = GlobalTheme.of(context);
      result = values?.mapIndex((data, index) {
        final widget = widgetOf(context, data, tryTextWidget: false);
        if (widget != null) {
          return transformValueWidget?.call(context, widget, data) ?? widget;
        }
        final textWidget = textOf(data)!.text(
          style: globalTheme.textGeneralStyle.copyWith(
            color: index == selectedIndex ? globalTheme.blackColor : null,
          ),
        );
        return transformValueWidget?.call(context, textWidget, data) ??
            textWidget.min();
      }).toList();
    } else {
      result = valuesWidget;
    }
    return result;
  }

  ///
  Widget? buildNumberWidget(
    BuildContext context,
    String number, {
    Widget? numberWidget,
    GestureTapCallback? onTap,
    EdgeInsetsGeometry? padding =
        const EdgeInsets.symmetric(horizontal: kH, vertical: kM),
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints = kNumberConstraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    return Container(
      /*decoration: fillDecoration(
        color: globalTheme.itemWhiteBgColor,
        borderRadius: kDefaultBorderRadiusL,
      ),*/
      constraints: constraints,
      padding: padding,
      child: (numberWidget ?? number.text()).center(),
    ).ink(
      () {
        onTap?.call();
      },
      backgroundColor: globalTheme.itemWhiteBgColor,
      radius: kDefaultBorderRadiusL,
    ).paddingInsets(margin);
  }

//endregion ---辅助小部件---
}

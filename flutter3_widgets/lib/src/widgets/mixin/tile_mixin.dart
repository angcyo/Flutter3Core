part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/21
///
/// 单item默认的填充
const kItemPadding = EdgeInsets.only(
  left: kX,
  right: kX,
  top: kH,
  bottom: kH,
);

/// input输入框默认的填充
const kInputPadding = EdgeInsets.only(
  left: kH,
  right: kH,
  top: kX,
  bottom: kX,
);

/// number input输入框默认的填充
const kNumberInputPadding = EdgeInsets.only(
  left: kM,
  right: kM,
  top: 0,
  bottom: 0,
);

/// number input输入框label的填充
const kNumberLabelPadding = EdgeInsets.only(
  left: 0,
  right: kM,
  top: 0,
  bottom: 0,
);

/// label默认的填充
/// 左边显示的文本
const kLabelPadding = EdgeInsets.only(
  left: kX,
  right: kX,
  top: kH,
  bottom: kH,
);

const kSubLabelPadding = EdgeInsets.only(
  left: kXx,
  right: kX,
  top: kH,
  bottom: kH,
);

/// [kLabelPadding]的小号
const kLabelPaddingMin = EdgeInsets.only(
  left: kH,
  right: kH,
  top: kH,
  bottom: kH,
);

const kLabelPaddingInline = EdgeInsets.only(
  left: kX,
  right: kX,
  top: kH,
  bottom: 0,
);

/// des默认的填充
/// [label]下面显示的文本
const kDesPadding = EdgeInsets.only(
  left: kX,
  right: kX,
  top: 0,
  bottom: 0,
);

/// tile默认的填充
/// item整体
const kTilePadding = EdgeInsets.only(
  left: 0,
  right: kX,
  top: kL,
  bottom: kL,
);

const kSubTilePadding = EdgeInsets.only(
  left: kX,
  right: kXx,
  top: kL,
  bottom: kL,
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
const kNumberMinHeight = 26.0;
const kMenuMinWidth = 160.0;

/// label默认的约束
const kLabelConstraints = BoxConstraints(
  minWidth: kLabelMinWidth,
  maxWidth: kLabelMinWidth,
);

/// number数字输入默认的约束
const kNumberConstraints = BoxConstraints(
  minWidth: kNumberMinWidth,
  minHeight: kNumberMinHeight,
);

/// input number数字输入默认的约束
const kNumberInputConstraints = BoxConstraints(
  minWidth: kNumberMinWidth,
  minHeight: kNumberMinHeight,
  maxWidth: kNumberMinWidth,
  /*maxHeight: kNumberMinHeight,*/
);

/*
class TestSliderComponentShape extends RoundSliderThumbShape {
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    //debugger();
  }
}
*/

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
  ///
  /// [buildTextWidget]
  /// [buildLabelWidget]
  /// [buildDesWidget]
  Widget? buildTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    TextSpan? textSpan,
    TextAlign? textAlign,
    TextStyle? textStyle,
    bool themeStyle = true,
    EdgeInsets? textPadding,
    EdgeInsets? padding,
    BoxConstraints? constraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = textWidget ??
        ((textSpan != null ? "" : text)
            ?.text(
              textSpan: textSpan,
              //--
              textAlign: textAlign,
              style:
                  textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null),
            )
            .constrainedBox(constraints)
            .paddingInsets(textPadding));
    return widget?.paddingInsets(padding);
  }

  /// [buildTextWidget]
  /// [buildDesWidget]
  /// [buildLabelWidget]
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

  /// [buildTextWidget]
  /// [buildDesWidget]
  /// [buildLabelWidget]
  Widget? buildDesWidget(
    BuildContext context, {
    Widget? desWidget,
    String? des,
    TextStyle? desStyle,
    bool themeStyle = true,
    EdgeInsets? desPadding = kDesPadding,
    EdgeInsets? padding,
    BoxConstraints? constraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final widget = desWidget ??
        (des
            ?.text(
              style: desStyle ?? (themeStyle ? globalTheme.textDesStyle : null),
            )
            .constrainedBox(constraints)
            .paddingInsets(desPadding));
    return widget?.paddingInsets(padding);
  }

  /// 构建判断文本小部件, 支持选中状态提示
  /// [enable] 是否启用
  /// [isSelected] 是否选中
  /// [selectedTextStyle] 选中时的文本样式
  /// [selectedTextColor] 选中时的文本颜色, 不指定[selectedTextStyle]时生效
  /// [selectedTextBold] 选中时的文本是否加粗
  /// [selectedBgColor] 选中时的背景颜色
  /// [selectedBorderRadius] 选中时的背景圆角大小
  /// [textSelectedLeading] 选中时的前导小部件
  /// [textSelectedTrailing] 选中时的后导小部件
  Widget? buildSegmentTextWidget(
    BuildContext context, {
    Widget? textWidget,
    String? text,
    Widget? textSelectedLeading,
    Widget? textSelectedTrailing,
    double? textSelectedGap = kM,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    Color? selectedTextColor,
    bool selectedTextBold = true,
    Color? selectedBgColor,
    double? selectedBorderRadius = kDefaultBorderRadiusXX,
    bool enable = true,
    bool isSelected = false,
    bool themeStyle = true,
    EdgeInsets? padding = const EdgeInsets.all(kL),
    bool disableTap = false,
    bool selectedDisableTap = true /*选中后是否禁止点击*/,
    GestureTapCallback? onTap,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final normalTextStyle =
        textStyle ?? (themeStyle ? globalTheme.textBodyStyle : null);
    final selectTextStyle = selectedTextStyle ??
        textStyle?.copyWith(
            fontWeight: selectedTextBold ? ui.FontWeight.bold : null,
            color: selectedTextColor) ??
        (themeStyle
            ? globalTheme.textBodyStyle.copyWith(
                fontWeight: selectedTextBold ? ui.FontWeight.bold : null,
                color: context.isThemeDark
                    ? globalTheme.blackColor
                    : selectedTextColor)
            : null);

    Widget? widget = textWidget ??
        (text?.text(
          textAlign: ui.TextAlign.center,
          style: isSelected ? selectTextStyle : normalTextStyle,
        ));
    if (widget != null && isSelected) {
      //选中了
      if (textSelectedLeading != null || textSelectedTrailing != null) {
        widget = [textSelectedLeading, widget, textSelectedTrailing]
                .row(mainAxisSize: MainAxisSize.min, gap: textSelectedGap) ??
            widget;
      }
    }
    return widget
        ?.paddingInsets(padding)
        .backgroundDecoration(!enable
            ? fillDecoration(
                color: globalTheme.disableColor,
                radius: kDefaultBorderRadiusX,
              )
            : isSelected
                ? fillDecoration(
                    color: selectedBgColor ?? globalTheme.accentColor,
                    radius: selectedBorderRadius,
                  )
                : null)
        .click(onTap,
            enable && !disableTap && (selectedDisableTap ? !isSelected : true));
  }

  //endregion ---构建小部件---

  //region ---常用小部件---

  /*Widget buildCheckBoxWidget(BuildContext context,){
    final globalTheme = GlobalTheme.of(context);

    return Checkbox();
  }*/

  /// 构建一个[Switch]开关小部件
  /// [activeColor] 激活时圈圈的颜色
  /// [inactiveThumbColor] 未激活时圈圈的颜色
  /// [activeTrackColor] 激活时轨道的颜色
  ///
  /// [trackOutlineColor] 轨道外轮廓颜色
  /// [WidgetStatePropertyColorMap]
  /// [WidgetStatePropertyAll]
  ///
  /// [Switch]小部件需要[Material]支持.
  ///
  /// [SwitchTheme]
  /// [SwitchThemeData]
  ///
  Widget buildSwitchWidget(
    BuildContext context,
    bool value, {
    ValueChanged<bool>? onChanged,
    double? height = 30.0,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    WidgetStateProperty<Color?>? trackOutlineColor,
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
      trackOutlineColor: trackOutlineColor,
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
  /// [thumbRadius] 浮子的半径, 默认是10.0, 使用[RoundSliderThumbShape]
  /// [overlayColor] 触摸时浮子光晕的颜色
  /// [activeTrackColor] 有值轨道的颜色
  /// [activeTrackGradientColors] 有值轨道的渐变颜色
  /// [activeTrackGradientColorStops] 有值轨道的渐变颜色的位置
  /// [syncGradientColor] 浮子是否同步渐变颜色
  /// [inactiveTrackColor] 无值轨道的颜色(背景颜色)
  /// [valueIndicatorColor] 气泡的颜色
  ///
  /// [useCenteredTrackShape] 是否使用中心轨道形状 [CenteredRectangularSliderTrackShape]
  ///
  /// [trackShape]轨道的shape, 默认[RoundedRectSliderTrackShape]
  /// [thumbShape]浮子的shape, 默认[RoundSliderThumbShape], 浮子不负责光晕的绘制
  /// [overlayShape]光晕的shape, 默认[RoundSliderOverlayShape]
  ///
  /// [SliderTheme]->[SliderThemeData]
  ///
  /// [Slider]小部件需要[Material]支持.
  /// [RangeSlider]双向滑块
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
    double? thumbRadius /*浮子的半径, 默认10*/,
    Color? overlayColor,
    double? overlayRadius /*光晕的半径,默认24*/,
    Color? activeTrackColor,
    List<Color>? inactiveTrackGradientColors,
    List<double>? inactiveTrackGradientColorStops,
    List<Color>? activeTrackGradientColors,
    List<double>? activeTrackGradientColorStops,
    bool syncGradientColor = true,
    Color? inactiveTrackColor,
    Color? valueIndicatorColor,
    double? trackHeight,
    bool? useCenteredTrackShape,
    SliderTrackShape? trackShape /*轨道的shape*/,
    SliderComponentShape? thumbShape /*浮子的shape*/,
    SliderComponentShape? overlayShape /*光晕的shape*/,
    TextStyle? valueIndicatorTextStyle /*指示器中的文本样式*/,
  }) {
    if (trackShape == null) {
      //渐变进度在渐变颜色中的颜色值
      Color? gradientColor;
      if (syncGradientColor &&
          (!isNil(activeTrackGradientColors) ||
              !isNil(inactiveTrackGradientColors))) {
        final progress = (value - minValue) / (maxValue - minValue);
        gradientColor = getGradientColor(
            progress, activeTrackGradientColors ?? inactiveTrackGradientColors!,
            colorStops: activeTrackGradientColorStops ??
                inactiveTrackGradientColorStops);
      }

      //居中双边shape
      if (useCenteredTrackShape == true) {
        trackShape = CenteredRectangularSliderTrackShape(
          activeColors: activeTrackGradientColors,
          activeColorStops: activeTrackGradientColorStops,
          inactiveColors: inactiveTrackGradientColors,
          inactiveColorStops: inactiveTrackGradientColorStops,
        );
        //--
        final color = gradientColor ?? activeTrackGradientColors?.last;
        thumbColor ??= color;
        valueIndicatorColor ??= thumbColor;
        overlayColor ??= color?.withOpacity(0.1);
      } else {
        if (!isNil(activeTrackGradientColors) ||
            !isNil(inactiveTrackGradientColors)) {
          trackShape = GradientSliderTrackShape(
            activeColors: activeTrackGradientColors,
            activeColorStops: activeTrackGradientColorStops,
            inactiveColors: inactiveTrackGradientColors,
            inactiveColorStops: inactiveTrackGradientColorStops,
          );
          //--
          final color = gradientColor ?? activeTrackGradientColors?.last;
          thumbColor ??= color;
          valueIndicatorColor ??= thumbColor;
          overlayColor ??= color?.withOpacity(0.1);
        }
      }
    }
    final globalTheme = GlobalTheme.of(context);
    final darkAccentColor =
        context.isThemeDark ? globalTheme.accentColor : globalTheme.accentColor;
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: showValueIndicator,
        thumbColor: thumbColor ?? darkAccentColor,
        activeTrackColor: activeTrackColor ?? darkAccentColor,
        overlayColor: overlayColor ?? darkAccentColor.withOpacity(0.1),
        valueIndicatorColor: valueIndicatorColor ?? darkAccentColor,
        inactiveTrackColor: inactiveTrackColor,
        thumbShape: thumbShape ??
            (thumbRadius == null
                ? null
                : RoundSliderThumbShape(enabledThumbRadius: thumbRadius)),
        trackShape: trackShape,
        overlayShape: overlayShape ??
            (overlayRadius == null
                ? null
                : RoundSliderOverlayShape(overlayRadius: overlayRadius)),
        /*inactiveTrackColor: Colors.redAccent,*/
        trackHeight: trackHeight,
        valueIndicatorTextStyle: valueIndicatorTextStyle,
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

  /// [RangeSlider]双向滑块, 双向范围滑块
  Widget buildRangeSliderWidget(
    BuildContext context,
    double startValue,
    double endValue, {
    String? startLabel,
    String? endLabel,
    double minValue = 0,
    double maxValue = 1,
    int digits = kDefaultDigits,
    int? divisions,
    ShowValueIndicator? showValueIndicator = ShowValueIndicator.always,
    ValueChanged<RangeValues>? onChanged,
    ValueChanged<RangeValues>? onChangeStart,
    ValueChanged<RangeValues>? onChangeEnd,
    Color? thumbColor,
    Color? overlayColor,
    Color? activeTrackColor,
    List<Color>? inactiveTrackGradientColors,
    List<double>? inactiveTrackGradientColorStops,
    List<Color>? activeTrackGradientColors,
    List<double>? activeTrackGradientColorStops,
    bool syncGradientColor = true,
    Color? inactiveTrackColor,
    Color? valueIndicatorColor,
    double? trackHeight,
    bool? useCenteredTrackShape,
    RangeSliderTrackShape? trackShape /*轨道shape*/,
    RangeSliderThumbShape? thumbShape /*浮子shape*/,
    TextStyle? valueIndicatorTextStyle /*指示器中的文本样式*/,
  }) {
    /*if (rangeTrackShape == null) {
      //渐变进度在渐变颜色中的颜色值
      Color? gradientColor;
      if (syncGradientColor &&
          (!isNil(activeTrackGradientColors) ||
              !isNil(inactiveTrackGradientColors))) {
        final progress = 0.5 */ /*(value - minValue) / (maxValue - minValue)*/ /*;
        gradientColor = getGradientColor(
            progress, activeTrackGradientColors ?? inactiveTrackGradientColors!,
            colorStops: activeTrackGradientColorStops ??
                inactiveTrackGradientColorStops);
      }

      //居中双边shape
      if (useCenteredTrackShape == true) {
        rangeTrackShape = CenteredRectangularSliderTrackShape(
          activeColors: activeTrackGradientColors,
          activeColorStops: activeTrackGradientColorStops,
          inactiveColors: inactiveTrackGradientColors,
          inactiveColorStops: inactiveTrackGradientColorStops,
        );
        final color = gradientColor ?? activeTrackGradientColors?.last;
        thumbColor ??= color;
        valueIndicatorColor = thumbColor;
        overlayColor ??= color?.withOpacity(0.1);
      } else {
        if (!isNil(activeTrackGradientColors) ||
            !isNil(inactiveTrackGradientColors)) {
          rangeTrackShape = GradientSliderTrackShape(
            activeColors: activeTrackGradientColors,
            activeColorStops: activeTrackGradientColorStops,
            inactiveColors: inactiveTrackGradientColors,
            inactiveColorStops: inactiveTrackGradientColorStops,
          );
          final color = gradientColor ?? activeTrackGradientColors?.last;
          thumbColor ??= color;
          valueIndicatorColor = thumbColor;
          overlayColor ??= color?.withOpacity(0.1);
        }
      }
    }*/
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
        rangeTrackShape: trackShape,
        rangeThumbShape: thumbShape,
        /*rangeValueIndicatorShape: rangeValueIndicatorShape,*/
        /*inactiveTrackColor: Colors.redAccent,*/
        trackHeight: trackHeight,
        valueIndicatorTextStyle: valueIndicatorTextStyle,
      ),
      child: RangeSlider(
        values: RangeValues(startValue, endValue),
        min: minValue,
        max: maxValue,
        divisions: divisions,
        labels: RangeLabels(startLabel ?? startValue.toDigits(digits: digits),
            endLabel ?? endValue.toDigits(digits: digits)),
        onChanged: onChanged ??
            (values) {
              assert(() {
                l.d('滑块[$minValue~$maxValue]:(${values.start}, ${values.end})');
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
            color: index == selectedIndex ? globalTheme.themeBlackColor : null,
            fontWeight: index == selectedIndex ? ui.FontWeight.bold : null,
            /*fontSize: 14,*/
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

  /// 数字显示, 并输入的小部件
  /// [NumberKeyboardDialog]
  Widget buildNumberWidget(
    BuildContext context,
    dynamic number, {
    Widget? numberWidget,
    GestureTapCallback? onTap,
    EdgeInsetsGeometry? padding =
        const EdgeInsets.symmetric(horizontal: kH, vertical: kM),
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Color? backgroundColor,
    BoxConstraints? constraints = kNumberConstraints,
  }) {
    final globalTheme = GlobalTheme.of(context);
    if (onTap == null) {
      //默认的点击事件
    }
    return Container(
      /*fillDecoration(
        color: globalTheme.whiteSubBgColor,
        borderRadius: kDefaultBorderRadiusL,
      )*/
      decoration: decoration,
      constraints: constraints,
      padding: padding,
      child: (numberWidget ?? "$number".text()).center(),
    ).ink(
      () {
        onTap?.call();
      },
      backgroundColor: backgroundColor ?? globalTheme.whiteSubBgColor,
      radius: kDefaultBorderRadiusL,
    ).paddingInsets(margin);
  }

  /// 数字输入的小部件
  /// [NumberInputWidget]
  Widget buildNumberInputWidget(
    BuildContext context,
    dynamic number, {
    NumType? numType,
    GestureTapCallback? onTap,
    EdgeInsetsGeometry? padding = const EdgeInsets.symmetric(vertical: kS),
    EdgeInsetsGeometry? contentPadding = kNumberInputPadding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Color? backgroundColor,
    BoxConstraints? constraints = kNumberInputConstraints,
    //--
    num? maxValue,
    num? minValue,
    int maxDigits = 2,
    ValueChanged<dynamic>? onChanged,
    ValueChanged<dynamic>? onSubmitted,
  }) {
    final globalTheme = GlobalTheme.of(context);
    if (onTap == null) {
      //默认的点击事件
    }
    return Container(
      /*fillDecoration(
        color: globalTheme.whiteSubBgColor,
        borderRadius: kDefaultBorderRadiusL,
      )*/
      decoration: decoration,
      constraints: constraints,
      padding: padding,
      child: NumberInputWidget(
        inputText: number,
        contentPadding: contentPadding,
        inputNumType: numType ?? NumType.from(number),
        inputMinValue: minValue,
        inputMaxValue: maxValue,
        inputMaxDigits: maxDigits,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      /*child: TextField(
        */ /*contentPadding: padding,*/ /*
        textAlign: TextAlign.center,
        expands: false,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: padding */ /*EdgeInsets.zero*/ /*,
          border: InputBorder.none,
        ),
      ),*/
    ).ink(
      () {
        onTap?.call();
      },
      backgroundColor: backgroundColor ?? globalTheme.whiteSubBgColor,
      radius: kDefaultBorderRadiusL,
    ).paddingInsets(margin);
  }

  /// 构建一个用于点击操作的容器, 带圆角背景
  Widget buildClickContainerWidget(
    BuildContext context,
    Widget? child, {
    GestureTapCallback? onTap,
    EdgeInsetsGeometry? contentMargin = kContentPadding,
    EdgeInsetsGeometry? contentPadding =
        const EdgeInsets.symmetric(horizontal: kH, vertical: kX),
    AlignmentGeometry? contentAlignment = Alignment.centerLeft,
    BoxConstraints? contentConstraints = const BoxConstraints(
      minHeight: kMinInteractiveHeight,
    ),
    double radius = kDefaultBorderRadiusXX,
  }) {
    final globalTheme = GlobalTheme.of(context);
    final result = Container(
      padding: contentPadding,
      alignment: contentAlignment,
      constraints: contentConstraints,
      child: child,
    )
        .ink(
          onTap,
          backgroundColor: globalTheme.itemWhiteBgColor,
          radius: radius,
        )
        .paddingInsets(contentMargin);
    return result;
  }

//endregion ---辅助小部件---
}

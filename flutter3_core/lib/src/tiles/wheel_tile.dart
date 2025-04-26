part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 滚动输入小部件, 没有其它装饰
/// [leftWidget]..[value]..[rightWidget]
///
/// [WheelDialog]
/// [LabelWheelTile]
/// [LabelWheelDateTimeTile]
class WheelTile extends StatefulWidget {
  /// 是否激活
  final bool enable;

  /// 默认显示的数据
  final dynamic value;

  /// 将[value]转成对应的小部件, 不指定会使用文本小部件进行显示
  @defInjectMark
  final WidgetNullBuilder? onValueBuilder;

  //--

  /// [value]小部件的对齐方式
  final AlignmentGeometry valueAlignment;

  /// 在[value]最左边的小部件
  final Widget? leftWidget;

  /// 在[value]最右边的小部件
  /// 如果[wheelValues]有值时, 会自动设置一个默认的图标提示小部件
  @defInjectMark
  final Widget? rightWidget;

  //--

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  //--

  /// [WheelDialog]的标题
  final String? wheelTitle;

  /// 滚轮选择的数据
  final List? wheelValues;

  /// 数值索引回调
  /// 并不需要在此方法中更新界面
  final IndexCallback? onWheelIndexInput;

  //--

  /// 装饰的圆角大小
  final double decorationRadius;

  /// 按下时的颜色
  final Color? pressedColor;

  const WheelTile({
    super.key,
    this.enable = true,
    this.value,
    this.valueAlignment = Alignment.center,
    this.leftWidget,
    this.rightWidget,
    this.onValueBuilder,
    this.wheelTitle,
    this.wheelValues,
    this.onWheelIndexInput,
    this.padding = const EdgeInsets.symmetric(vertical: kL, horizontal: kH),
    this.margin,
    this.decorationRadius = kH,
    this.pressedColor = Colors.black12,
  });

  @override
  State<WheelTile> createState() => _WheelTileState();
}

class _WheelTileState extends State<WheelTile> {
  dynamic _initValue;

  @override
  void initState() {
    super.initState();
    _initValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant WheelTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    final radius = widget.decorationRadius;

    final valueWidget = (widget.onValueBuilder?.call(_initValue) ??
            widgetOf(context, _initValue) ??
            _initValue?.toString().text())
        ?.align(widget.valueAlignment);

    final rightWidget = widget.rightWidget ??
        (!isNil(widget.wheelValues)
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: widget.enable
                    ? globalTheme.icoNormalColor
                    : globalTheme.icoDisableColor,
              ) /*.rotate(90.hd)*/ .paddingAll(4)
            : null);

    return StateDecorationWidget(
      decoration: fillDecoration(
        color: widget.enable
            ? globalTheme.whiteSubBgColor
            : globalTheme.disableBgColor,
        radius: radius,
      ),
      pressedDecoration: fillDecoration(
        color: widget.pressedColor,
        radius: radius,
      ),
      enablePressedDecoration: widget.enable && _initValue != null,
      child: [
        widget.leftWidget,
        valueWidget?.expanded(),
        rightWidget,
      ].row()?.paddingInsets(widget.padding),
    ).click(() async {
      if (!isNil(widget.wheelValues)) {
        final index = await context.showWidgetDialog(
          WheelDialog(
            title: widget.wheelTitle ?? "请选择",
            initValue: _initValue,
            values: widget.wheelValues,
          ),
        );
        _initValue = widget.wheelValues?[index];
        updateState();
        widget.onWheelIndexInput?.call(index);
      }
    }, widget.enable && !isNil(widget.wheelValues)).paddingInsets(
        widget.margin);
  }
}

/// 左[label]      右[initValue].[wheel]
/// [WheelDialog]
class LabelWheelTile extends StatefulWidget {
  /// label
  final String? label;
  final TextStyle? labelTextStyle;
  final Widget? labelWidget;

  /// content
  final dynamic initValue;

  /// 不指定[values], 则不显示[rightWidget];
  /// 指定一个空[rightWidget], 则禁用[rightWidget];
  final List? values;
  final List<Widget>? valuesWidget;
  final TransformDataWidgetBuilder? transformValueWidget;

  /// 显示[initValue]小部件的宽度
  final double? valueWidth;

  /// [values]改变回调, 如果有
  final ValueCallback? onValueChanged;

  /// 索引改变回调
  final IndexCallback? onValueIndexChanged;

  /// wheel
  final bool enableWheelSelectedIndexColor;

  /// wheel 选中项的颜色
  final Color? wheelSelectedIndexColor;

  /// 拦截默认的点击事件
  final GestureTapCallback? onContainerTap;

  /// [WheelDialog.title]对话框的标题, 默认[label]
  final String? wheelTitle;

  //--

  /// 在[initValue]最左边的小部件
  final Widget? leftWidget;

  /// 在[initValue]最右边的小部件
  /// 如果[wheelValues]有值时, 会自动设置一个默认的图标提示小部件
  @defInjectMark
  final Widget? rightWidget;

  const LabelWheelTile({
    super.key,
    this.label,
    this.labelTextStyle,
    this.labelWidget,
    this.leftWidget,
    this.rightWidget,
    this.initValue,
    this.values,
    this.valueWidth,
    this.valuesWidget,
    this.transformValueWidget,
    this.onValueChanged,
    this.onValueIndexChanged,
    this.enableWheelSelectedIndexColor = true,
    this.wheelSelectedIndexColor,
    this.onContainerTap,
    this.wheelTitle,
  });

  @override
  State<LabelWheelTile> createState() => _LabelWheelTileState();
}

class _LabelWheelTileState extends State<LabelWheelTile>
    with TileMixin, ValueChangeMixin<LabelWheelTile, dynamic> {
  @override
  getInitialValueMixin() => widget.initValue;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelStyle: widget.labelTextStyle,
      labelWidget: widget.labelWidget,
    );

    final rightWidget = widget.rightWidget ??
        (widget.values != null
            ? loadCoreAssetSvgPicture(Assets.svg.coreNext,
                tintColor: widget.values?.isEmpty == true
                    ? globalTheme.icoDisableColor
                    : globalTheme.icoNormalColor)
            : null);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: kH, vertical: kX),
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints(
        minWidth: widget.valueWidth ?? 0,
        maxWidth: widget.valueWidth ?? double.infinity,
        minHeight: kMinInteractiveHeight,
      ),
      child: [
        widget.leftWidget,
        (widgetOf(context, currentValueMixin, tryTextWidget: true) ?? empty)
            .expanded(),
        rightWidget,
      ].row()!,
    )
        .ink(
          widget.onContainerTap ??
              () async {
                if (isNil(widget.values) && isNil(widget.valuesWidget)) {
                  return;
                }
                final resultIndex = await context.showWidgetDialog(
                  WheelDialog(
                    title: widget.wheelTitle ?? widget.label,
                    initValue: currentValueMixin,
                    values: widget.values,
                    valuesWidget: widget.valuesWidget,
                    transformValueWidget: widget.transformValueWidget,
                    wheelSelectedIndexColor: widget.wheelSelectedIndexColor,
                    enableWheelSelectedIndexColor:
                        widget.enableWheelSelectedIndexColor,
                  ),
                );
                if (resultIndex is int) {
                  currentValueMixin = widget.values?.getOrNull(resultIndex) ??
                      currentValueMixin;
                  widget.onValueIndexChanged?.call(resultIndex);
                  widget.onValueChanged?.call(
                      widget.values?.getOrNull(resultIndex) ??
                          widget.valuesWidget?.getOrNull(resultIndex));
                  updateState();
                } else {
                  assert(() {
                    l.w('无效的wheel返回值类型[$resultIndex]');
                    return true;
                  }());
                }
              },
          backgroundColor: globalTheme.itemWhiteBgColor,
          radius: kDefaultBorderRadiusXX,
        )
        .paddingInsets(kContentPadding)
        .ignorePointer(
          isNil(widget.values),
        );

    return [label, content.align(Alignment.centerRight).expanded()]
        .row()!
        .material();
  }
}

/// 左[label]      右[dateTime].[wheel]
/// [WheelDateTimeDialog]
class LabelWheelDateTimeTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// dateTime
  final DateTime initDateTime;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;

  /// 日期格式, 默认 yyyy-MM-dd HH:mm:ss
  final String? dateTimePattern;

  /// 日期/时间的类型
  final List wheelDateTimeType;

  /// [values]改变回调, 如果有
  final ValueCallback<DateTime>? onDateTimeValueChanged;

  ///wheel

  /// 拦截点击事件
  final GestureTapCallback? onContainerTap;

  /// [WheelDateTimeDialog.title]对话框的标题, 默认[label]
  final String? wheelTitle;

  const LabelWheelDateTimeTile({
    super.key,
    //title
    this.label,
    this.labelWidget,
    //dateTime
    required this.initDateTime,
    this.minDateTime,
    this.maxDateTime,
    this.onDateTimeValueChanged,
    this.dateTimePattern = "yyyy-MM-dd",
    this.wheelDateTimeType = sDateWheelType,
    //wheel
    this.onContainerTap,
    this.wheelTitle,
  });

  @override
  State<LabelWheelDateTimeTile> createState() => _LabelWheelDateTimeTileState();
}

class _LabelWheelDateTimeTileState extends State<LabelWheelDateTimeTile>
    with TileMixin, ValueChangeMixin<LabelWheelDateTimeTile, DateTime> {
  @override
  DateTime getInitialValueMixin() => widget.initDateTime;

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );

    final content = buildClickContainerWidget(
        context,
        [
          (widgetOf(context, currentValueMixin.format(widget.dateTimePattern),
                      tryTextWidget: true) ??
                  empty)
              .expanded(),
          loadCoreAssetSvgPicture(Assets.svg.coreNext)
        ].row()!,
        onTap: widget.onContainerTap ??
            () async {
              final resultDateTime =
                  await context.showWidgetDialog(WheelDateTimeDialog(
                title: widget.wheelTitle ?? widget.label,
                initDateTime: currentValueMixin,
                minDateTime: widget.minDateTime,
                maxDateTime: widget.maxDateTime,
                dateTimeType: widget.wheelDateTimeType,
              ));
              if (resultDateTime is DateTime) {
                currentValueMixin = resultDateTime;
                widget.onDateTimeValueChanged?.call(resultDateTime);
                updateState();
              } else {
                assert(() {
                  l.w('无效的wheel返回值类型[$resultDateTime]');
                  return true;
                }());
              }
            });

    return [label, content.align(Alignment.centerRight).expanded()]
        .row()!
        .material();
  }
}

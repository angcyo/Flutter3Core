part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/24
///
/// 左[label]      右[initValue].[wheel]
/// [WheelDialog]
class LabelWheelTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// content
  final dynamic initValue;
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

  /// [WheelDialog.title]对话框的标题, 默认[label]
  final String? wheelTitle;

  const LabelWheelTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.valueWidth,
    this.valuesWidget,
    this.transformValueWidget,
    this.onValueChanged,
    this.onValueIndexChanged,
    this.enableWheelSelectedIndexColor = true,
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
      labelWidget: widget.labelWidget,
    );

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: kH, vertical: kX),
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints(
        minWidth: widget.valueWidth ?? 0,
        maxWidth: widget.valueWidth ?? double.infinity,
        minHeight: kMinInteractiveHeight,
      ),
      child: [
        (widgetOf(context, currentValueMixin, tryTextWidget: true) ?? empty)
            .expanded(),
        loadCoreAssetSvgPicture(Assets.svg.coreNext)
      ].row()!,
    ).ink(
      () async {
        final resultIndex = await context.showWidgetDialog(WheelDialog(
          title: widget.wheelTitle ?? widget.label,
          initValue: currentValueMixin,
          values: widget.values,
          valuesWidget: widget.valuesWidget,
          transformValueWidget: widget.transformValueWidget,
          enableWheelSelectedIndexColor: widget.enableWheelSelectedIndexColor,
        ));
        if (resultIndex is int) {
          currentValueMixin =
              widget.values?.getOrNull(resultIndex) ?? currentValueMixin;
          widget.onValueIndexChanged?.call(resultIndex);
          widget.onValueChanged?.call(widget.values?.getOrNull(resultIndex) ??
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
    ).paddingInsets(kContentPadding);

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
  /// 日期格式, 默认"yyyy-MM-dd"
  final String? dateTimePattern;
  final DateTime initDateTime;
  final DateTime? minDateTime;
  final DateTime? maxDateTime;

  /// [values]改变回调, 如果有
  final ValueCallback<DateTime>? onDateTimeValueChanged;

  ///wheel

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
    this.dateTimePattern = "yyyy-MM-dd",
    this.onDateTimeValueChanged,
    //wheel
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
        ].row()!, onTap: () async {
      final resultDateTime = await context.showWidgetDialog(WheelDateTimeDialog(
        title: widget.wheelTitle ?? widget.label,
        initDateTime: currentValueMixin,
        minDateTime: widget.minDateTime,
        maxDateTime: widget.maxDateTime,
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

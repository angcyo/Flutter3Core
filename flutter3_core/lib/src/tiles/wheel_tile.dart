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

  /// 宽度
  final double? valueWidth;

  /// [values]改变回调, 如果有
  final ValueCallback? onValueChanged;

  /// 索引改变回调
  final IndexCallback? onValueIndexChanged;

  /// wheel
  final bool enableWheelSelectedIndexColor;

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
  });

  @override
  State<LabelWheelTile> createState() => _LabelWheelTileState();
}

class _LabelWheelTileState extends State<LabelWheelTile> with TileMixin {
  dynamic _initialValue;

  dynamic _currentValue;

  @override
  void initState() {
    _initialValue = widget.initValue;
    _currentValue = _initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LabelWheelTile oldWidget) {
    _initialValue = widget.initValue;
    _currentValue = _initialValue;
    super.didUpdateWidget(oldWidget);
  }

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
        (widgetOf(context, _currentValue, tryTextWidget: true) ?? empty)
            .expanded(),
        loadCoreAssetSvgPicture(Assets.svg.coreNext)
      ].row()!,
    ).ink(
      () async {
        final resultIndex = await context.showWidgetDialog(WheelDialog(
          title: widget.label,
          initValue: _currentValue,
          values: widget.values,
          valuesWidget: widget.valuesWidget,
          transformValueWidget: widget.transformValueWidget,
          enableWheelSelectedIndexColor: widget.enableWheelSelectedIndexColor,
        ));
        if (resultIndex != null) {
          if (resultIndex is int) {
            _currentValue =
                widget.values?.getOrNull(resultIndex) ?? _currentValue;
            widget.onValueIndexChanged?.call(resultIndex);
            widget.onValueChanged?.call(widget.values?.getOrNull(resultIndex) ??
                widget.valuesWidget?.getOrNull(resultIndex));
            updateState();
          } else {
            assert(() {
              l.w('无效的wheel返回值类型');
              return true;
            }());
          }
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

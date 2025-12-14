part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/14
///
/// 一组可切换的[RadioButton]
class RadioGroupTile extends StatefulWidget {
  /// 轴向
  final Axis axis;

  //MARK: - content
  /// content
  final dynamic initValue;
  final List? values;
  final List<Widget>? valuesWidget;
  final ValueChanged? onValueChanged;

  /// item 间距
  final EdgeInsetsGeometry? itemPadding;

  const RadioGroupTile({
    super.key,
    this.axis = Axis.horizontal,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.onValueChanged,
    this.itemPadding,
  });

  @override
  State<RadioGroupTile> createState() => _RadioGroupTileState();
}

class _RadioGroupTileState extends State<RadioGroupTile>
    with TileMixin, ValueChangeMixin {
  @override
  getInitialValueMixin() => widget.initValue;

  @override
  Widget build(BuildContext context) {
    WidgetList? children = buildChildrenFromValues(
      context,
      values: widget.values,
      valuesWidget: widget.valuesWidget,
      /*selectedIndex: widget.initValue,*/
      transformValueWidget: (ctx, child, index, data) {
        return RadioButton(
          isChecked: data == currentValueMixin,
          padding: widget.itemPadding,
          onChanged: (checked) {
            if (checked == true) {
              updateValueMixin(data);
              widget.onValueChanged?.call(data);
            }
          },
          child: child.insets(right: kH),
        );
      },
    );
    if (widget.axis == Axis.vertical) {
      return children?.column() ?? empty;
    }
    return children?.wrap() ?? empty;
  }
}

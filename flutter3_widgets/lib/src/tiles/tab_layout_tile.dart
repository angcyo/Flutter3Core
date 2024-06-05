part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/23
///
/// 可以滑动切换多个值的tile
class LabelTabLayoutTile extends StatefulWidget {
  /// label
  final String? label;
  final Widget? labelWidget;

  /// content
  final dynamic initValue;
  final List? values;
  final List<Widget>? valuesWidget;

  /// 索引改变回调
  final IndexCallback? onTabIndexChanged;

  const LabelTabLayoutTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.onTabIndexChanged,
  });

  @override
  State<LabelTabLayoutTile> createState() => _LabelTabLayoutTileState();
}

class _LabelTabLayoutTileState extends State<LabelTabLayoutTile>
    with SingleTickerProviderStateMixin, TileMixin {
  late TabLayoutController tabLayoutController = TabLayoutController(
    vsync: this,
    initialIndex: widget.values?.indexOf(widget.initValue) ?? 0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    tabLayoutController.dispose();
  }

  @override
  void didUpdateWidget(covariant LabelTabLayoutTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    //debugger();
    tabLayoutController.index = widget.values?.indexOf(widget.initValue) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );

    //--
    WidgetList? children = buildChildrenFromValues(
      context,
      values: widget.values,
      valuesWidget: widget.valuesWidget,
      selectedIndex: tabLayoutController.index,
    )
        ?.mapIndex((child, index) => child.click(() {
              tabLayoutController.selectedItem(index);
              widget.onTabIndexChanged?.call(index);
            }))
        .toList();
    final content = TabLayout(
      tabLayoutController: tabLayoutController,
      padding: const EdgeInsets.symmetric(horizontal: kM, vertical: kM),
      bgDecoration: fillDecoration(color: globalTheme.itemWhiteBgColor),
      children: [
        ...?children,
        DecoratedBox(decoration: fillDecoration(color: globalTheme.accentColor))
            .tabItemData(
          itemType: TabItemType.indicator,
          itemPaintType: TabItemPaintType.background,
        )
      ],
    ).paddingInsets(kContentPadding);
    return [label, content.expanded()].row()!;
  }
}

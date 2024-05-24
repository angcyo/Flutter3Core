part of '../../../flutter3_widgets.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/23
///
/// 可以滑动切换多个值的tile
class TabLayoutTile extends StatefulWidget {
  final String? label;
  final Widget? labelWidget;

  final dynamic initValue;
  final List? values;
  final List<Widget>? children;

  /// 索引改变回调
  final IndexAction? onTabIndexChanged;

  const TabLayoutTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.children,
    this.onTabIndexChanged,
  });

  @override
  State<TabLayoutTile> createState() => _TabLayoutTileState();
}

class _TabLayoutTileState extends State<TabLayoutTile>
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
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);

    final label = buildLabelWidget(
      context,
      label: widget.label,
      labelWidget: widget.labelWidget,
    );

    //--
    WidgetList children;
    if (widget.children == null) {
      children = widget.values!.map((data) {
        final widget = widgetOf(context, data, tryTextWidget: false);
        return widget ?? textOf(data)!.text().min();
      }).toList();
    } else {
      children = widget.children!;
    }
    children = children
        .mapIndex((child, index) => child.click(() {
              tabLayoutController.selectedItem(index);
              widget.onTabIndexChanged?.call(index);
            }))
        .toList();
    final content = TabLayout(
      tabLayoutController: tabLayoutController,
      padding: const EdgeInsets.symmetric(horizontal: kM, vertical: kM),
      bgDecoration: fillDecoration(color: globalTheme.itemWhiteBgColor),
      children: [
        ...children,
        DecoratedBox(decoration: fillDecoration(color: globalTheme.accentColor))
            .tabItemData(
          itemType: TabItemType.indicator,
          itemPaintType: TabItemPaintType.background,
        )
      ],
    ).paddingOnly(top: kM, bottom: kM, right: kX);
    return [label, content.expanded()].row()!;
  }
}

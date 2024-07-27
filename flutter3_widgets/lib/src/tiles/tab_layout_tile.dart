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

  /// [label].[values]布局方向
  final Axis axis;

  const LabelTabLayoutTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.onTabIndexChanged,
    this.axis = Axis.horizontal,
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
    final index = widget.values?.indexOf(widget.initValue) ?? -1;
    if (index == -1) {
      assert(() {
        l.w('不在列表内的元素[${widget.initValue}]');
        return true;
      }());
    }
    tabLayoutController.index = index.clamp(0, widget.values?.lastIndex ?? 0);
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
        ?.mapIndex(
          (child, index) => child.click(() {
            tabLayoutController.selectedItem(index);
            widget.onTabIndexChanged?.call(index);
          }),
        )
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
    ).paddingInsets(
      widget.axis == Axis.vertical
          ? kContentPadding.copyWith(left: kX)
          : kContentPadding,
    );
    return widget.axis == Axis.vertical
        ? [label?.align(Alignment.centerLeft), content].column()!
        : [label, content.expanded()].row()!;
  }
}

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

  //--

  /// [TabLayout] 是否完全展开
  final bool isExpanded;

  /// 指示器的颜色, 默认时主题[GlobalTheme.accentColor]
  final Color? indicatorColor;

  /// 背景的颜色, 默认时主题[GlobalTheme.itemWhiteBgColor]
  final Color? backgroundColor;

  /// 圆角大小
  final double? borderRadius;

  const LabelTabLayoutTile({
    super.key,
    this.label,
    this.labelWidget,
    this.initValue,
    this.values,
    this.valuesWidget,
    this.onTabIndexChanged,
    this.axis = Axis.horizontal,
    this.isExpanded = true,
    this.backgroundColor,
    this.indicatorColor,
    this.borderRadius = kDefaultBorderRadiusXX,
  });

  @override
  State<LabelTabLayoutTile> createState() => _LabelTabLayoutTileState();
}

class _LabelTabLayoutTileState extends State<LabelTabLayoutTile>
    with SingleTickerProviderStateMixin, TileMixin {
  late TabLayoutController tabLayoutController = TabLayoutController(
    vsync: this,
    initialIndex: (widget.values?.indexOf(widget.initValue) ?? 0).maxOf(0),
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
    final content = isNil(children)
        ? empty
        : TabLayout(
            tabLayoutController: tabLayoutController,
            padding: const EdgeInsets.symmetric(horizontal: kM, vertical: kM),
            bgDecoration: fillDecoration(
              color: widget.backgroundColor ?? globalTheme.itemWhiteBgColor,
              radius: widget.borderRadius,
            ),
            /*selfConstraints:
          LayoutBoxConstraints(widthType: ConstraintsType.wrapContent),*/
            children: [
              ...?children,
              DecoratedBox(
                      decoration: fillDecoration(
                color: widget.indicatorColor ?? globalTheme.accentColor,
                radius: widget.borderRadius,
              ))
                  .shadowDecorated(
                    radius: widget.borderRadius,
                    shadowBlurRadius: 6,
                    shadowSpreadRadius: 1,
                  )
                  .tabItemData(
                    itemType: TabItemType.indicator /*指示器*/,
                    itemPaintType: TabItemPaintType.background,
                  )
            ],
          ).paddingInsets(
            widget.axis == Axis.vertical
                ? kContentPadding.copyWith(left: kX)
                : kContentPadding,
          );
    return widget.axis == Axis.vertical
        ? [
            label?.align(Alignment.centerLeft),
            content.matchParentWidth(),
          ].column()!
        : [
            label,
            widget.isExpanded
                ? content.expanded()
                : content.align(Alignment.centerRight).expanded(),
          ].row()!;
  }
}

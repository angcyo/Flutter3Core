part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/03
///

/// [RScrollView] 的子项
class RItemTile extends StatefulWidget {
  const RItemTile({
    super.key,
    this.child,
    this.childBuilder,
    this.isSliverItem = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.crossAxisCount = 0,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1.0,
  });

  //region 基础

  /// 强制指定子部件
  final Widget? child;

  /// 用来构建子部件的构建器
  final WidgetBuilder? childBuilder;

  //endregion 基础

  //region 普通布局

  /// 决定是否直接塞到[CustomScrollView.slivers]中

  /// 是否是[Sliver]布局
  /// 需要使用[SliverToBoxAdapter]包裹
  final bool isSliverItem;

  //endregion 普通布局

  //region SliverList

  /// 决定是否使用[SliverList]组合[RItemTile]
  /// [SliverList.list]

  /// [SliverChildListDelegate.addAutomaticKeepAlives]
  final bool addAutomaticKeepAlives;

  /// [SliverChildListDelegate.addRepaintBoundaries]
  final bool addRepaintBoundaries;

  /// [SliverChildListDelegate.addSemanticIndexes]
  final bool addSemanticIndexes;

  //endregion SliverList

  //region SliverGrid

  /// 决定是否使用[SliverGrid]组合[RItemTile]
  /// [SliverGrid.count]

  /// 交叉轴的数量, 比如网格的列数. 不为0时开启功能.
  /// 列数相同的[RItemTile]会被合并到同一个[SliverGrid]中,
  /// 并且默认使用第一个[RItemTile]的属性配置[SliverGrid].
  /// [SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount]
  final int crossAxisCount;

  /// [SliverGridDelegateWithFixedCrossAxisCount.mainAxisSpacing]
  final double mainAxisSpacing;

  /// [SliverGridDelegateWithFixedCrossAxisCount.crossAxisSpacing]
  final double crossAxisSpacing;

  /// [SliverGridDelegateWithFixedCrossAxisCount.childAspectRatio]
  final double childAspectRatio;

  //endregion SliverGrid

  Widget buildChild(BuildContext context) {
    return child ??
        childBuilder?.call(context) ??
        (isSliverItem
            ? const SliverToBoxAdapter(child: Placeholder())
            : const Placeholder());
  }

  @override
  State<RItemTile> createState() => _RItemTileState();
}

class _RItemTileState extends State<RItemTile> {
  @override
  Widget build(BuildContext context) {
    return widget.buildChild(context);
  }
}

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
    this.headerChildBuilder,
    this.headerFixedHeight = kMinInteractiveDimension,
    this.headerMaxHeight = kMinInteractiveDimension,
    this.headerMinHeight = kMinInteractiveDimension,
    this.headerDelegate,
    this.pinned = false,
    this.floating = false,
    this.fillRemaining = false,
    this.fillHasScrollBody = false,
    this.fillOverscroll = false,
    this.fillExpand = false,
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

  //region SliverPersistentHeader

  /// 决定是否使用[SliverPersistentHeader]包裹[RItemTile]

  /// 当不指定[headerDelegate]时, 则使用默认的[SingleSliverPersistentHeaderDelegate]构建
  final SliverPersistentHeaderWidgetBuilder? headerChildBuilder;

  /// 是否使用固定的高度
  /// [SingleSliverPersistentHeaderDelegate.headerFixedHeight]
  final double? headerFixedHeight;

  /// 最大高度
  /// [SingleSliverPersistentHeaderDelegate.headerMaxHeight]
  final double headerMaxHeight;

  /// 最小高度
  /// [SingleSliverPersistentHeaderDelegate.headerMinHeight]
  final double headerMinHeight;

  //---

  /// [SliverPersistentHeader.delegate]
  final SliverPersistentHeaderDelegate? headerDelegate;

  /// 是否固定在顶部, 支持多个
  /// 开启后, 当滚动到元素时, 会固定在顶部.
  /// [SliverPersistentHeader.pinned]
  final bool pinned;

  /// 是否浮动在顶部, 支持多个
  /// 开启后, 元素不可见时, 向下滚动, 会先将元素滚动出来显示
  /// [SliverPersistentHeader.floating]
  final bool floating;

  //endregion SliverPersistentHeader

  // region SliverFillRemaining

  /// 决定是否使用[SliverFillRemaining]包裹[RItemTile]

  /// 是否要填充剩余空间
  final bool fillRemaining;

  /// 是否有滚动体, 用来决定最大的高度
  /// [SliverFillRemaining.hasScrollBody]
  final bool fillHasScrollBody;

  /// Overscroll 时是否填充超出的空间
  /// 一定要有 Overscroll 才有效果, 列表中要有 [SliverList] 或者 [SliverGrid]
  /// 如果child使用[Container]并且设置了背景颜色, 那么此效果无效.
  /// 此时可以使用[SizedBox.expand]来包裹[Container]
  /// [SliverFillRemaining.fillOverscroll]
  final bool fillOverscroll;

  /// 是否要使用[SizedBox.expand]包裹[SliverFillRemaining]的child
  /// 解决[fillOverscroll]的问题
  final bool fillExpand;

  //endregion SliverFillRemaining

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

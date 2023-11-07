part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/02
///

typedef RItemTileBuilder = void Function(RItemTileListBuilder builder);

/// 使用[CustomScrollView]快速组合界面
/// [SliverPersistentHeader] 可以在顶部固定,可以实现悬浮效果 [SliverFillRemaining] 可以填充剩余空间
/// [SliverList] - [SliverGrid]
/// [RItemTile] 的容器
class RScrollView extends StatefulWidget {
  const RScrollView(
    this.children, {
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.scrollBehavior = const MaterialScrollBehavior(),
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    this.enableFrameLoad = false,
    this.frameSplitCount = 1,
    this.frameSplitDuration = const Duration(milliseconds: 16),
  });

  /// 使用[RItemTile]的构建器
  RScrollView.builder(
    RItemTileBuilder builder, {
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.scrollBehavior = const MaterialScrollBehavior(),
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.physics = const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    this.enableFrameLoad = false,
    this.frameSplitCount = 1,
    this.frameSplitDuration = const Duration(milliseconds: 16),
  }) : children = RItemTileListBuilder().apply(builder);

  /// [RItemTile] 的列表核心的数据集合
  final List<Widget> children;

  //region ScrollView属性
  /// [ScrollView]

  /// [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// [ScrollView.reverse]
  final bool reverse;

  /// [ScrollView.controller]
  final ScrollController? controller;

  /// [ScrollView.primary]
  final bool? primary;

  /// [ScrollView.physics]
  final ScrollPhysics? physics;

  /// [ScrollView.scrollBehavior]
  final ScrollBehavior? scrollBehavior;

  /// [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  /// [ScrollView.center]
  final Key? center;

  /// [ScrollView.anchor]
  final double anchor;

  /// [ScrollView.cacheExtent]
  final double? cacheExtent;

  /// [ScrollView.semanticChildCount]
  final int? semanticChildCount;

  /// [ScrollView.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// [ScrollView.keyboardDismissBehavior]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// [ScrollView.restorationId]
  final String? restorationId;

  ///[ScrollView.clipBehavior]
  final Clip clipBehavior;

  //endregion ScrollView属性

  //region 分帧加载属性

  /// [FrameSplitLoad.enableFrameLoad]
  final bool enableFrameLoad;

  /// [FrameSplitLoad.frameSplitCount]
  final int frameSplitCount;

  /// [FrameSplitLoad.frameSplitDuration]
  final Duration frameSplitDuration;

  //endregion 分帧加载属性

  @override
  State<RScrollView> createState() => _RScrollViewState();
}

class _RScrollViewState extends State<RScrollView> with FrameSplitLoad {
  /// 构建[RItemTile]的列表
  List<Widget> _buildItemTileList(BuildContext context) {
    final result = <Widget>[];

    // 收集到的list tile, 使用[SliverList]包裹
    final listWrap = <Widget>[];

    // 收集到的grid tile, 使用[SliverGrid]包裹
    final gridWrap = <Widget>[];

    // 清除收集到的list tile, 并添加到result中
    clearAndAppendList() {
      final widget = _buildSliverList(context, listWrap);
      if (widget != null) {
        result.add(widget);
      }
      listWrap.clear();
    }

    // 清除收集到的grid tile, 并添加到result中
    clearAndAppendGrid() {
      final widget = _buildSliverGrid(context, gridWrap);
      if (widget != null) {
        result.add(widget);
      }
      gridWrap.clear();
    }

    // 检查是否要合并网格tile
    checkAndAppendGrid(RItemTile element) {
      if (gridWrap.isEmpty) {
        //网格的第一个
        gridWrap.add(element);
      } else {
        final first = gridWrap.first as RItemTile;
        if (first.crossAxisCount == element.crossAxisCount) {
          //合并
          gridWrap.add(element);
        } else {
          //不合并, 新的网格
          clearAndAppendGrid();
          gridWrap.add(element);
        }
      }
    }

    // 开始遍历, 组装
    for (var tile in widget.children) {
      if (tile is RItemTile) {
        //RItemTile
        if (tile.isSliverItem ||
            tile.pinned ||
            tile.floating ||
            tile.fillRemaining) {
          //简单的
          clearAndAppendList();
          clearAndAppendGrid();
          if (tile.fillRemaining) {
            // SliverFillRemaining wrap
            final Widget child;
            if (tile.fillExpand) {
              child = SizedBox.expand(child: tile);
            } else {
              child = tile;
            }
            result.add(SliverFillRemaining(
              hasScrollBody: tile.fillHasScrollBody,
              fillOverscroll: tile.fillOverscroll,
              child: child,
            ));
          } else if (tile.pinned || tile.floating) {
            // SliverPersistentHeader wrap
            if (tile.headerDelegate == null) {
              result.add(SliverPersistentHeader(
                delegate: SingleSliverPersistentHeaderDelegate(
                  child: tile,
                  childBuilder: tile.headerChildBuilder,
                  headerFixedHeight: tile.headerFixedHeight,
                  headerMaxHeight: tile.headerMaxHeight,
                  headerMinHeight: tile.headerMinHeight,
                ),
                pinned: tile.pinned,
                floating: tile.floating,
              ));
            } else {
              result.add(SliverPersistentHeader(
                delegate: tile.headerDelegate!,
                pinned: tile.pinned,
                floating: tile.floating,
              ));
            }
          } else {
            result.add(tile);
          }
        } else {
          //复合的
          if (tile.crossAxisCount > 0) {
            clearAndAppendList();
            checkAndAppendGrid(tile);
          } else {
            clearAndAppendGrid();
            listWrap.add(tile);
          }
        }
      } else {
        //普通的Widget
        if ("$tile".toLowerCase().startsWith("sliver")) {
          clearAndAppendList();
          clearAndAppendGrid();
          result.add(tile);
        } else {
          listWrap.add(tile);
        }
      }
    }
    clearAndAppendList();
    clearAndAppendGrid();

    return frameLoad(result);
  }

  /// 构建成[SliverList]
  SliverList? _buildSliverList(BuildContext context, List<Widget> list) {
    if (list.isEmpty) {
      return null;
    }
    RItemTile first = list.firstWhere((element) => element is RItemTile,
        orElse: () => const RItemTile()) as RItemTile;
    return SliverList.list(
      addAutomaticKeepAlives: first.addAutomaticKeepAlives,
      addRepaintBoundaries: first.addRepaintBoundaries,
      addSemanticIndexes: first.addSemanticIndexes,
      children: list.toList(growable: false), //复制一份
    );
  }

  /// 构建成[SliverGrid]
  SliverGrid? _buildSliverGrid(BuildContext context, List<Widget> list) {
    if (list.isEmpty) {
      return null;
    }
    RItemTile first = list.firstWhere((element) => element is RItemTile,
        orElse: () => const RItemTile()) as RItemTile;
    return SliverGrid.count(
      crossAxisCount: first.crossAxisCount,
      mainAxisSpacing: first.mainAxisSpacing,
      crossAxisSpacing: first.crossAxisSpacing,
      childAspectRatio: first.childAspectRatio,
      children: list.toList(growable: false), //复制一份
    );
  }

  @override
  void initState() {
    enableFrameLoad = widget.enableFrameLoad;
    frameSplitCount = widget.frameSplitCount;
    frameSplitDuration = widget.frameSplitDuration;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //SliverGrid.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder);
    //SliverList.builder(itemBuilder: itemBuilder);
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      scrollBehavior: widget.scrollBehavior,
      shrinkWrap: widget.shrinkWrap,
      center: widget.center,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: _buildItemTileList(context),
    );
  }
}

/// [RScrollView] 的子项 [RItemTile] 构建
class RItemTileListBuilder {
  final List<Widget> _itemTileList = [];

  RItemTileListBuilder add(Widget itemTile) {
    _itemTileList.add(itemTile);
    return this;
  }

  RItemTileListBuilder operator +(Widget itemTile) {
    _itemTileList.add(itemTile);
    return this;
  }

  apply(RItemTileBuilder action) {
    action(this);
    return _itemTileList;
  }
}

/// [RItemTileListBuilder]
@dsl
List<Widget> itemTileListBuilder(RItemTileBuilder builder) {
  return RItemTileListBuilder().apply(builder);
}

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
  }) : children = RItemTileListBuilder().apply(builder);

  /// [RItemTile] 的列表核心的数据集合
  final List<Widget> children;

  //region ScrollView属性
  /// [ScrollView]

  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final bool shrinkWrap;
  final Key? center;
  final double anchor;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  //endregion ScrollView属性

  @override
  State<RScrollView> createState() => _RScrollViewState();
}

class _RScrollViewState extends State<RScrollView> {
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
        if (tile.isSliverItem) {
          //简单的
          clearAndAppendList();
          clearAndAppendGrid();
          result.add(tile);
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
    return result;
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

@dsl
List<Widget> itemTileBuilder(RItemTileBuilder builder) {
  return RItemTileListBuilder().apply(builder);
}

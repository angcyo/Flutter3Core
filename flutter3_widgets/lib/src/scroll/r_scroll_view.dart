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
  const RScrollView({
    required this.children,
    super.key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.showScrollbar = false,
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
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.showScrollbar = false,
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

  /// 是否要显示滚动条
  /// [ScrollbarTheme]
  /// [ScrollbarThemeData]
  final bool showScrollbar;

  /// 滚动控制, 状态切换控制, 刷新/加载更多控制
  /// [ScrollController]
  /// [ScrollView.controller]
  final RScrollController? controller;

  //region ScrollView属性
  /// [ScrollView]

  /// [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// [ScrollView.reverse]
  final bool reverse;

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
  /// [children] 入参
  /// [useFrameLoad]是否需要使用分帧加载
  List<Widget> _buildItemTileList(
    BuildContext context, {
    List<Widget>? children,
    bool? useFrameLoad,
  }) {
    children ??= widget.children;

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
    for (var tile in children) {
      if (tile is RItemTile) {
        if (tile.hide) {
          continue;
        }
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
            result.add(tile.buildWrapChild(
                context,
                result,
                _wrapSliverPadding(
                  tile.sliverPadding,
                  SliverFillRemaining(
                    hasScrollBody: tile.fillHasScrollBody,
                    fillOverscroll: tile.fillOverscroll,
                    child: child,
                  ),
                )));
          } else if (tile.pinned || tile.floating) {
            // SliverPersistentHeader wrap
            if (tile.headerDelegate == null) {
              result.add(tile.buildWrapChild(
                  context,
                  result,
                  _wrapSliverPadding(
                    tile.sliverPadding,
                    SliverPersistentHeader(
                      delegate: SingleSliverPersistentHeaderDelegate(
                        child: tile,
                        childBuilder: tile.headerChildBuilder,
                        headerFixedHeight: tile.headerFixedHeight,
                        headerMaxHeight: tile.headerMaxHeight,
                        headerMinHeight: tile.headerMinHeight,
                      ),
                      pinned: tile.pinned,
                      floating: tile.floating,
                    ),
                  )));
            } else {
              result.add(tile.buildWrapChild(
                  context,
                  result,
                  _wrapSliverPadding(
                    tile.sliverPadding,
                    SliverPersistentHeader(
                      delegate: tile.headerDelegate!,
                      pinned: tile.pinned,
                      floating: tile.floating,
                    ),
                  )));
            }
          } else {
            result.add(tile.buildWrapChild(
                context,
                result,
                _wrapSliverPadding(
                  tile.sliverPadding,
                  tile,
                )));
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
        clearAndAppendList();
        clearAndAppendGrid();
        if ("$tile".toLowerCase().startsWith("sliver")) {
          result.add(tile);
        } else {
          result.add(SliverToBoxAdapter(
            child: tile,
          ));
          //listWrap.add(tile);
        }
      }
    }
    clearAndAppendList();
    clearAndAppendGrid();

    //result
    if (useFrameLoad == true) {
      return frameLoad(result);
    } else {
      return result;
    }
  }

  /// 构建成[SliverList]
  Widget? _buildSliverList(BuildContext context, List<Widget> list) {
    if (list.isEmpty) {
      return null;
    }
    RItemTile first = list.firstWhere(
      (element) => element is RItemTile,
      orElse: () => const RItemTile(),
    ) as RItemTile;

    List<Widget> newList = [];
    list.forEachIndexed((index, element) {
      if (element is RItemTile) {
        newList.add(element.buildListWrapChild(context, list, element, index));
      } else {
        newList.add(element);
      }
    });
    return _wrapSliverPadding(
      first.sliverPadding,
      SliverList.list(
        addAutomaticKeepAlives: first.addAutomaticKeepAlives,
        addRepaintBoundaries: first.addRepaintBoundaries,
        addSemanticIndexes: first.addSemanticIndexes,
        children: newList,
      ),
    );
  }

  /// 构建成[SliverGrid]
  Widget? _buildSliverGrid(BuildContext context, List<Widget> list) {
    if (list.isEmpty) {
      return null;
    }
    RItemTile first = list.firstWhere(
      (element) => element is RItemTile,
      orElse: () => const RItemTile(),
    ) as RItemTile;

    List<Widget> newList = [];
    list.forEachIndexed((index, element) {
      if (element is RItemTile) {
        newList.add(element.buildGridWrapChild(context, list, element, index));
      } else {
        newList.add(element);
      }
    });
    return _wrapSliverPadding(
      first.sliverPadding,
      SliverGrid.count(
        crossAxisCount: first.crossAxisCount,
        mainAxisSpacing: first.mainAxisSpacing,
        crossAxisSpacing: first.crossAxisSpacing,
        childAspectRatio: first.childAspectRatio,
        children: newList,
      ),
    );
  }

  Widget _wrapSliverPadding(
    EdgeInsetsGeometry? sliverPadding,
    Widget sliverChild,
  ) {
    if (sliverPadding == null) {
      return sliverChild;
    }
    return SliverPadding(
      padding: sliverPadding,
      sliver: sliverChild,
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
  void didUpdateWidget(covariant RScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    //SliverGrid.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder);
    //SliverList.builder(itemBuilder: itemBuilder);
    WidgetList slivers;
    var controller = widget.controller;
    if (controller == null ||
        controller.widgetStateValue.value == WidgetState.none) {
      //需要显示内容
      slivers = _buildItemTileList(context);
    } else {
      slivers = _buildItemTileList(
        context,
        children: [controller.buildWidgetStateWidget(this.context).rFill()],
        useFrameLoad: false,
      );
    }
    Widget result = CustomScrollView(
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
      slivers: slivers,
    );
    if (widget.showScrollbar) {
      result = Scrollbar(
        controller: widget.controller,
        child: result,
      );
    }
    return result;
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

extension RScrollViewEx on WidgetList {
  /// [RScrollView]
  Widget rScroll({
    RScrollController? controller,
  }) {
    return RScrollView(
      controller: controller,
      children: this,
    );
  }
}

part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/02
///

/// 是否要显示底部的加载更多
typedef ShowLoadMoreCallback = bool Function();

/// 使用[CustomScrollView]快速组合界面
/// [SliverPersistentHeader] 可以在顶部固定,可以实现悬浮效果. [SliverFillRemaining]可以填充剩余空间
/// [SliverList] - [SliverGrid]
/// [RItemTile] 的容器
class RScrollView extends StatefulWidget {
  const RScrollView({
    super.key,
    required this.children,
    this.filterChain = _defaultFilterChain,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.showScrollbar = false,
    this.enableRefresh = false,
    this.enableLoadMore = false,
    this.showLoadMoreCallback,
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

  /// [RItemTile] 的列表核心的数据集合
  final List<Widget> children;

  /// [RItemTile] 的列表过滤器
  final RFilterChain? filterChain;

  /// 是否要显示滚动条
  /// [ScrollbarTheme]
  /// [ScrollbarThemeData]
  final bool showScrollbar;

  /// 滚动控制, 状态切换控制, 刷新/加载更多控制
  /// [ScrollController]
  /// [ScrollView.controller]
  final RScrollController? controller;

  /// 是否启用下拉刷新
  /// [RScrollController.wrapRefreshWidget]
  final bool enableRefresh;

  /// 是否启用上拉加载更多
  final bool enableLoadMore;

  /// 是否要显示底部的加载更多
  final ShowLoadMoreCallback? showLoadMoreCallback;

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

    final result = _resolveItemTileList(context, children);

    //加载更多显示处理
    if (widget.enableLoadMore) {
      //debugger();
      Widget? loadMoreWidget;
      var controller = widget.controller;
      if (controller != null) {
        var callback = widget.showLoadMoreCallback;
        if ((callback == null &&
                children.length >= controller.requestPage.requestPageSize) ||
            (callback != null && callback())) {
          //show load more
          loadMoreWidget = controller.buildLoadMoreStateWidget.call(context,
              controller.loadMoreStateValue.value, controller._widgetStateData);
        }
      }
      if (loadMoreWidget != null) {
        result.addAll(_resolveItemTileList(context, [loadMoreWidget]));
      }
    }

    //result
    if (useFrameLoad == true) {
      return frameLoad(result);
    } else {
      return result;
    }
  }

  /// 将普通的[Widget]解析成[SliverWidget]
  List<Widget> _resolveItemTileList(
      BuildContext context, List<Widget> children) {
    //过滤
    children = widget.filterChain?.doFilter(children) ?? children;

    final result = <Widget>[];

    // 收集到的list tile, 使用[SliverList]包裹
    final listWrap = <Widget>[];

    // 收集到的grid tile, 使用[SliverGrid]包裹
    final gridWrap = <Widget>[];

    // 普通的sliver tile, 用来放到sliver group
    final normalGroupWrap = <Widget>[];

    //分组的头, 如果有
    _GroupHeaderInfo? groupHeaderInfo;

    // 清除收集到的list tile, 并添加到result中
    clearAndAppendList() {
      if (listWrap.isNotEmpty) {
        final widget = _buildSliverList(context, groupHeaderInfo, listWrap);
        if (widget != null) {
          result.add(widget);
          groupHeaderInfo = null;
        }
        listWrap.clear();
      }
    }

    // 清除收集到的grid tile, 并添加到result中
    clearAndAppendGrid() {
      if (gridWrap.isNotEmpty) {
        final widget = _buildSliverGrid(context, groupHeaderInfo, gridWrap);
        if (widget != null) {
          result.add(widget);
          groupHeaderInfo = null;
        }
        gridWrap.clear();
      }
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

    // 不在list/grid中的sliver group中的item
    clearNormalSliverGroupList() {
      if (groupHeaderInfo != null) {
        var sliverGroup = _wrapSliverGroup(groupHeaderInfo!, normalGroupWrap);
        result.removeWhere((e) => normalGroupWrap.contains(e));
        result.add(sliverGroup);
      }
      groupHeaderInfo = null;
      normalGroupWrap.clear();
    }

    // 开始遍历, 组装
    for (var tile in children) {
      //debugger();
      if (tile is RItemTile) {
        if (tile.part) {
          clearAndAppendList();
          clearAndAppendGrid();
          clearNormalSliverGroupList();
        }
        Widget sliverTile = tile;
        //RItemTile
        if (tile.isSliverItem ||
            tile.isHeader ||
            tile.fillRemaining ||
            tile.isGroup) {
          //简单的
          if (groupHeaderInfo == null) {
            clearAndAppendList();
            clearAndAppendGrid();
          }
          if (tile.fillRemaining) {
            // SliverFillRemaining wrap
            final Widget child;
            if (tile.fillExpand) {
              child = SizedBox.expand(child: tile);
            } else {
              child = tile;
            }
            sliverTile = tile.buildWrapChild(
                context,
                result,
                _wrapSliverTile(
                  tile,
                  SliverFillRemaining(
                    hasScrollBody: tile.fillHasScrollBody,
                    fillOverscroll: tile.fillOverscroll,
                    child: child,
                  ),
                ));
          } else if (tile.isHeader) {
            // SliverPersistentHeader wrap
            if (tile.isGroup) {
              sliverTile = _wrapHeader(tile);
            } else {
              sliverTile = tile.buildWrapChild(
                  context,
                  result,
                  _wrapSliverTile(
                    tile,
                    _wrapHeader(tile),
                  ));
            }
          } else {
            sliverTile = tile.buildWrapChild(
                context,
                result,
                _wrapSliverTile(
                  tile,
                  tile,
                ));
          }

          if (tile.isGroup) {
            clearNormalSliverGroupList();
            groupHeaderInfo = _GroupHeaderInfo(sliverTile, tile);
          } else {
            if (groupHeaderInfo == null) {
              result.add(sliverTile);
            } else {
              normalGroupWrap.add(sliverTile);
            }
          }
        } else {
          //复合的, 需要丢到List或Grid中
          if (tile.crossAxisCount > 0) {
            //网格tile
            clearAndAppendList();
            checkAndAppendGrid(tile);
          } else {
            //列表tile
            clearAndAppendGrid();
            listWrap.add(tile);
          }
        }
      } else {
        //普通的Widget
        clearAndAppendList();
        clearAndAppendGrid();
        clearNormalSliverGroupList();
        result.add(ensureSliver(tile));
      }
    }
    clearAndAppendList();
    clearAndAppendGrid();
    clearNormalSliverGroupList();

    //result
    return result;
  }

  /// 确保是[Sliver]小部件
  Widget ensureSliver(Widget tile) {
    if ("$tile".toLowerCase().startsWith("sliver")) {
      return tile;
    } else {
      return SliverToBoxAdapter(
        child: tile,
      );
    }
  }

  /// 悬浮头包裹
  Widget _wrapHeader(RItemTile tile) {
    if (tile.useSliverAppBar) {
      var height = tile.headerFixedHeight ?? tile.headerMinHeight;
      return SliverAppBar(
        title: tile,
        floating: tile.floating,
        pinned: tile.pinned,
        titleSpacing: 0,
        toolbarHeight: height,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: tile.headerBackgroundColor,
        foregroundColor: tile.headerForegroundColor,
        expandedHeight: null,
        collapsedHeight: null,
        titleTextStyle: tile.headerTitleTextStyle,
        primary: false,
        snap: false,
      );
    }
    if (tile.headerDelegate == null) {
      return SliverPersistentHeader(
        delegate: SingleSliverPersistentHeaderDelegate(
          child: tile,
          childBuilder: tile.headerChildBuilder,
          headerFixedHeight: tile.headerFixedHeight,
          headerMaxHeight: tile.headerMaxHeight,
          headerMinHeight: tile.headerMinHeight,
        ),
        pinned: tile.pinned,
        floating: tile.floating,
      );
    }
    return SliverPersistentHeader(
      delegate: tile.headerDelegate!,
      pinned: tile.pinned,
      floating: tile.floating,
    );
  }

  //region 组装成list grid

  /// 构建成[SliverList]
  /// [SliverAnimatedList]
  Widget? _buildSliverList(
    BuildContext context,
    _GroupHeaderInfo? groupHeaderInfo,
    List<Widget> list,
  ) {
    if (list.isEmpty) {
      return groupHeaderInfo == null
          ? null
          : _wrapSliverGroup(groupHeaderInfo, list);
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
    var sliverList = SliverList.list(
      addAutomaticKeepAlives: first.addAutomaticKeepAlives,
      addRepaintBoundaries: first.addRepaintBoundaries,
      addSemanticIndexes: first.addSemanticIndexes,
      children: newList,
    );
    return _wrapSliverTile(
      first,
      groupHeaderInfo == null
          ? sliverList
          : _wrapSliverGroup(groupHeaderInfo, [sliverList]),
    );
  }

  /// 构建成[SliverGrid]
  /// [SliverAnimatedGrid]
  Widget? _buildSliverGrid(
    BuildContext context,
    _GroupHeaderInfo? groupHeaderInfo,
    List<Widget> list,
  ) {
    if (list.isEmpty) {
      return groupHeaderInfo == null
          ? null
          : _wrapSliverGroup(groupHeaderInfo, list);
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
    var sliverGrid = SliverGrid.count(
      crossAxisCount: first.crossAxisCount,
      mainAxisSpacing: first.mainAxisSpacing,
      crossAxisSpacing: first.crossAxisSpacing,
      childAspectRatio: first.childAspectRatio,
      children: newList,
    );
    return _wrapSliverTile(
      first,
      groupHeaderInfo == null
          ? sliverGrid
          : _wrapSliverGroup(groupHeaderInfo, [sliverGrid]),
    );
  }

  //endregion 组装成list grid

  //region 装饰tile

  /// 判断tile是否需要padding和装饰
  /// [sliverChild] 需要包装的child
  /// [SliverPadding]
  /// [DecoratedSliver]
  /// [_wrapSliverPadding]
  /// [_wrapSliverDecoration]
  Widget _wrapSliverTile(
    RItemTile tile,
    Widget sliverChild,
  ) =>
      _wrapSliverPadding(
          tile.sliverPadding,
          _wrapSliverDecoration(
            tile.sliverDecoration,
            tile.sliverDecorationPosition,
            sliverChild,
          ));

  /// 一组[sliverChild]
  /// [SliverMainAxisGroup]
  Widget _wrapSliverGroup(
    _GroupHeaderInfo groupHeaderInfo,
    WidgetList sliverChild,
  ) {
    //debugger();
    return _wrapSliverTile(
      groupHeaderInfo.headerTile,
      SliverMainAxisGroup(slivers: [
        groupHeaderInfo.headerWidget,
        ...sliverChild,
      ]),
    );
  }

  /// 间隙填充当前的[sliverChild]
  /// [SliverPadding]
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

  /// 装饰当前的[sliverChild]
  /// [DecoratedSliver]
  Widget _wrapSliverDecoration(
    Decoration? sliverDecoration,
    DecorationPosition sliverDecorationPosition,
    Widget sliverChild,
  ) {
    //debugger();
    if (sliverDecoration == null) {
      return sliverChild;
    }

    return DecoratedSliver(
      decoration: sliverDecoration,
      position: sliverDecorationPosition,
      sliver: sliverChild,
    );
  }

  //endregion 装饰tile

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
        controller.adapterStateValue.value == WidgetState.none) {
      //需要显示内容
      slivers = _buildItemTileList(context);
    } else {
      //debugger();
      slivers = _resolveItemTileList(context, [
        controller
            .buildAdapterStateWidget(
              context,
              controller.adapterStateValue.value,
              controller._widgetStateData,
            )
            .rFill()
      ]);
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
    if (widget.enableRefresh) {
      result = widget.controller?.wrapRefreshWidget(context, result) ?? result;
    }
    if (widget.showScrollbar) {
      result = Scrollbar(
        controller: widget.controller,
        child: result,
      );
    }
    return result;
  }
}

/// 分组头的信息
class _GroupHeaderInfo {
  Widget headerWidget;
  RItemTile headerTile;

  _GroupHeaderInfo(
    this.headerWidget,
    this.headerTile,
  );
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

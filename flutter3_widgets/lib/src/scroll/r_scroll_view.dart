part of '../../flutter3_widgets.dart';

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
/// [RScrollController] 滚动控制
/// [RScrollConfig] 滚动配置, 默认是[defaultScrollConfig]
/// [RScrollView._transformTileList] 处理[RItemTile]
class RScrollView extends StatefulWidget {
  const RScrollView({
    super.key,
    this.scrollType = .customScrollView,
    this.children,
    this.childrenBuilder,
    this.updateSignal,
    this.scrollConfig,
    this.itemTileWrapBuilder,
    this.controller,
    this.scrollDirection = .vertical,
    this.reverse = false,
    this.showScrollbar = false,
    this.enableRefresh = false,
    this.enableLoadMore = false,
    this.showLoadMoreCallback,
    this.primary,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    @Deprecated('Use scrollCacheExtent instead.') this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = .start,
    this.keyboardDismissBehavior = .manual,
    this.restorationId,
    this.clipBehavior = .hardEdge,
    this.scrollBehavior = const MaterialScrollBehavior(),
    this.physics = kScrollPhysics,
    //--
    this.enableFrameLoad = false,
    this.frameSplitCount = 1,
    this.frameSplitDuration = const Duration(milliseconds: 16),
    //--
    this.tag,
    this.debugLabel,
    //--
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  //--

  /// 列表类型
  final RScrollType? scrollType;

  /// 监听此值的变化, 用来重建[children]
  final Listenable? updateSignal;

  /// [RItemTile] 的列表核心的数据集合
  final List<Widget>? children;

  /// 用来构建[children], 优先于[children]
  final ChildrenBuilder? childrenBuilder;

  //--

  /// 是否要显示滚动条
  /// [ScrollbarTheme]
  /// [ScrollbarThemeData]
  final bool showScrollbar;

  /// 控件配置, 过滤器和转换链
  final RScrollConfig? scrollConfig;

  /// 用来实现[RItemTile]包裹, 比如添加边距/添加分割线等
  final RItemTileWrapBuilder? itemTileWrapBuilder;

  /// 滚动控制, 状态切换控制, 刷新/加载更多控制
  /// [ScrollController]
  /// [ScrollView.controller]
  final RScrollController? controller;

  /// 是否启用下拉刷新小部件
  /// [RScrollController.wrapRefreshWidget]
  final bool enableRefresh;

  /// 是否启用上拉加载更多小部件
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
  @Deprecated('Use scrollCacheExtent instead.')
  final double? cacheExtent;

  /// [ScrollView.scrollCacheExtent]
  final ScrollCacheExtent? scrollCacheExtent;

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

  //MARK: - WaterfallFlow

  /// [waterfall.SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount]
  final int? crossAxisCount;

  /// [waterfall.SliverGridDelegateWithFixedCrossAxisCount.mainAxisSpacing]
  final double? mainAxisSpacing;

  /// [waterfall.SliverGridDelegateWithFixedCrossAxisCount.crossAxisSpacing]
  final double? crossAxisSpacing;

  //MARK: - tag

  final String? tag;
  final String? debugLabel;

  @override
  State<RScrollView> createState() => _RScrollViewState();
}

class _RScrollViewState extends State<RScrollView>
    with WidgetsBindingObserver, MediaQueryDataChangeMixin, FrameSplitLoad {
  @override
  bool get updateByAny => false;

  /// 在桌面端, 动态修改了尺寸
  @override
  bool get updateBySize => true;

  /// [widget.tag]
  @override
  void onSelfPlatformSizeChanged(ui.Size? from, ui.Size to) {
    //debugger();
    if (from != null) {
      postFrameCallback((_) {
        widget.controller?.checkScrollPosition();
      });
    }
  }

  //--

  /// 列表过滤转换入口点
  /// 构建[RItemTile]的列表
  /// [children] 入参
  /// [useFrameLoad]是否需要使用分帧加载
  /// [build]->[_buildTileList]->[_transformTileList]
  @entryPoint
  WidgetList _buildTileList(
    BuildContext context, {
    WidgetList? children,
    bool? useFrameLoad,
    bool ensureSliverItem = true,
  }) {
    //debugger();
    children ??= widget.childrenBuilder?.call(context) ?? widget.children ?? [];

    //debugger();
    final result = _transformTileList(
      context,
      children,
      ensureSliverItem: ensureSliverItem,
    );

    //加载更多显示处理
    if (widget.enableLoadMore) {
      //debugger();
      Widget? loadMoreWidget;
      final controller = widget.controller;
      if (controller != null) {
        final callback = widget.showLoadMoreCallback;
        if ((callback == null &&
                children.length >= controller.requestPage.requestPageSize) ||
            (callback != null && callback())) {
          final loadMoreStateValue = controller.loadMoreStateValue.value;
          //show load more
          loadMoreWidget = controller.buildLoadMoreStateWidget.call(
            context,
            loadMoreStateValue,
            controller._widgetStateData,
          )
          /*.bounds()*/;
          if (loadMoreStateValue.isNoneState || loadMoreStateValue.isLoading) {
            //如果是第一页, 并且列表数据不足一页, 则检查滚动位置, 触发加载更多
            //2026-10-8 网格布局有可能好几页了, 页面还是没有撑满布局
            postDelayCallback(() {
              controller.checkScrollPosition();
            }, const Duration(milliseconds: 160));
          }
        }
      }
      if (loadMoreWidget != null) {
        result.addAll(
          _transformTileList(context, [
            loadMoreWidget,
          ], ensureSliverItem: ensureSliverItem),
        );
      }
    }

    assert(() {
      if (widget.debugLabel != null) {
        l.d(
          "${(widget.tag ?? widget.debugLabel)?.wsb ?? ""}"
          "[${classHash()}]tile转换[${children?.length}]->[${result.length}]↓"
          "\n-> ${children?.map2ListIndex((e, index) => "[$index]${e.runtimeType}".connect(e is RItemTile ? e.shortLog.wph : null)).join(" ")}"
          "\n-> ${result.map2ListIndex((e, index) => "[$index]${e.runtimeType}".connect(e is RItemTile ? e.shortLog.wph : null)).join(" ")}",
        );
      }
      return true;
    }());

    //result
    if (useFrameLoad == true) {
      return frameLoad(result);
    } else {
      return result;
    }
  }

  /// 将普通的[Widget]解析/变换成[SliverWidget]
  /// [RTileTransformChain]
  /// [BaseTileTransform]
  ///
  /// [RScrollConfig]
  ///
  /// [build]->[_buildTileList]->[_transformTileList]->[RScrollConfig.filterAndTransformTileList]
  WidgetList _transformTileList(
    BuildContext context,
    WidgetList children, {
    bool ensureSliverItem = true,
  }) {
    final scrollConfig = widget.scrollConfig ?? defaultScrollConfig;
    return scrollConfig.filterAndTransformTileList(
      context,
      children,
      itemTileWrapBuilder: widget.itemTileWrapBuilder,
      ensureSliverItem: ensureSliverItem,
    );
  }

  void _rebuild() {
    //debugger();
    updateState();
  }

  @override
  void initState() {
    widget.updateSignal?.addListener(_rebuild);
    enableFrameLoad = widget.enableFrameLoad;
    frameSplitCount = widget.frameSplitCount;
    frameSplitDuration = widget.frameSplitDuration;
    super.initState();
  }

  @override
  void dispose() {
    widget.updateSignal?.removeListener(_rebuild);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.updateSignal?.removeListener(_rebuild);
    widget.updateSignal?.removeListener(_rebuild);
    widget.updateSignal?.addListener(_rebuild);
  }

  @override
  Widget build(BuildContext context) {
    //debugger();
    //SliverGrid.builder(gridDelegate: gridDelegate, itemBuilder: itemBuilder);
    //SliverList.builder(itemBuilder: itemBuilder);
    WidgetList? children;
    WidgetList slivers;
    final controller = widget.controller;
    final scrollType = controller?.scrollType ?? widget.scrollType;
    final ensureSliverItem = scrollType == .customScrollView;
    if (controller == null || controller.adapterStateValue.value == .none) {
      //需要显示内容
      children = widget.childrenBuilder?.call(context) ?? widget.children;
      slivers = _buildTileList(
        context,
        children: children,
        /*useFrameLoad: widget.enableFrameLoad,*/
        ensureSliverItem: ensureSliverItem,
      );
    } else {
      //需要显示情感图状态
      //debugger();
      final adapterStateWidget = controller.buildAdapterStateWidget(
        context,
        controller.adapterStateValue.value,
        controller._widgetStateData,
      );
      slivers = _transformTileList(context, [
        ensureSliverItem
            ? adapterStateWidget.rFill()
            : adapterStateWidget.matchParentHeight(
                isInSliver: true,
                /*debugLabel: "RScrollView",*/
              ),
        /*.bounds()*/
      ], ensureSliverItem: ensureSliverItem);
    }

    Widget result;
    if (scrollType == .waterfallFlow) {
      RItemTile? first;
      if (children?.firstOrNull is RItemTile) {
        first = children?.firstOrNull as RItemTile;
      }
      result = waterfall.WaterfallFlow.builder(
        scrollDirection:
            first?.tileWrapScrollDirection ?? widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: first?.tileWrapPhysics ?? widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: first?.tileWrapPadding,
        gridDelegate:
            waterfall.SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: (first?.crossAxisCount ?? 0) > 0
                  ? first!.crossAxisCount
                  : widget.crossAxisCount ?? 1,
              mainAxisSpacing:
                  first?.mainAxisSpacing ?? widget.mainAxisSpacing ?? 0,
              crossAxisSpacing:
                  first?.crossAxisSpacing ?? widget.crossAxisSpacing ?? 0,
              lastChildLayoutTypeBuilder: (index) =>
                  (widget.enableLoadMore && children?.getOrNull(index) == null)
                  ? .fullCrossAxisExtent /*紧跟主轴空间*/ //.foot /*一直在底部*/
                  : .none,
              /* collectGarbage: collectGarbage,
            viewportBuilder: viewportBuilder,
            closeToTrailing: closeToTrailing,*/
            ),
        itemBuilder: (context, index) {
          return slivers.getOrNull(index) ?? empty;
        },
        itemCount: slivers.length,
        cacheExtent: widget.scrollCacheExtent?.value ?? widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    } else {
      result = CustomScrollView(
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics: widget.physics,
        scrollBehavior: widget.scrollBehavior,
        shrinkWrap: widget.shrinkWrap,
        center: widget.center,
        anchor: widget.anchor,
        /*cacheExtent: widget.cacheExtent,*/
        scrollCacheExtent:
            widget.scrollCacheExtent ??
            (widget.cacheExtent != null
                ? ScrollCacheExtent.pixels(widget.cacheExtent!)
                : null),
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        slivers: slivers,
      );
    }

    if (widget.enableRefresh) {
      result = widget.controller?.wrapRefreshWidget(context, result) ?? result;
    }
    if (widget.showScrollbar) {
      result = Scrollbar(controller: widget.controller, child: result);
    }
    return result;
  }
}

extension RScrollViewEx on WidgetNullList {
  /// - [updateSignal] 刷新信号
  /// [RScrollView]
  Widget rScroll({
    RScrollController? controller,
    Axis axis = .vertical,
    ScrollBehavior? scrollBehavior,
    ScrollPhysics? physics = kScrollPhysics,
    ChildrenBuilder? childrenBuilder,
    Listenable? updateSignal,
    bool shrinkWrap = false,
    //--
    String? tag,
    String? debugLabel,
  }) {
    return RScrollView(
      tag: tag,
      debugLabel: debugLabel,
      controller: controller,
      scrollDirection: axis,
      scrollBehavior:
          scrollBehavior ??
          (physics == null ? null : const MaterialScrollBehavior()),
      physics: physics,
      childrenBuilder: childrenBuilder,
      updateSignal: updateSignal,
      shrinkWrap: shrinkWrap,
      children: filterNull(),
    );
  }
}

/// 列表类型
enum RScrollType {
  /// 使用[CustomScrollView]
  customScrollView,

  /// 使用[waterfall.WaterfallFlow]
  waterfallFlow,
}

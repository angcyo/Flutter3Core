part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/02
///

/// 是否要显示底部的加载更多
typedef ShowLoadMoreCallback = bool Function();

/// 默认的滚动物理特性
const kDefaultScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

/// 使用[CustomScrollView]快速组合界面
/// [SliverPersistentHeader] 可以在顶部固定,可以实现悬浮效果. [SliverFillRemaining]可以填充剩余空间
/// [SliverList] - [SliverGrid]
/// [RItemTile] 的容器
/// [RScrollController]
class RScrollView extends StatefulWidget {
  const RScrollView({
    super.key,
    required this.children,
    this.scrollConfig,
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
    this.physics = kDefaultScrollPhysics,
    this.enableFrameLoad = false,
    this.frameSplitCount = 1,
    this.frameSplitDuration = const Duration(milliseconds: 16),
  });

  /// [RItemTile] 的列表核心的数据集合
  final List<Widget> children;

  /// 是否要显示滚动条
  /// [ScrollbarTheme]
  /// [ScrollbarThemeData]
  final bool showScrollbar;

  /// 控件配置
  final RScrollConfig? scrollConfig;

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
  /// [build]
  WidgetList _buildTileList(
    BuildContext context, {
    WidgetList? children,
    bool? useFrameLoad,
  }) {
    children ??= widget.children;

    final result = _transformTileList(context, children);

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
        result.addAll(_transformTileList(context, [loadMoreWidget]));
      }
    }

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
  /// [_buildTileList]
  /// [build]
  WidgetList _transformTileList(BuildContext context, WidgetList children) {
    //过滤
    final scrollConfig = widget.scrollConfig ?? defaultScrollConfig;
    children = scrollConfig.filterChain?.doFilter(children) ?? children;
    final transformChain = scrollConfig.transformChain;
    final WidgetList result;
    if (transformChain != null) {
      transformChain.reset();
      result = transformChain.doTransform(context, children);
    } else {
      result = children;
    }
    return result;
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
    final controller = widget.controller;
    if (controller == null ||
        controller.adapterStateValue.value == WidgetBuildState.none) {
      //需要显示内容
      slivers = _buildTileList(context);
    } else {
      //debugger();
      slivers = _transformTileList(context, [
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

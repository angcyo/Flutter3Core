part of flutter3_widgets;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/30
///
/// 混入一个[RScrollView]的页面, 支持刷新/加载更多等基础功能的页面
/// [RScrollView]
mixin RScrollPage<T extends StatefulWidget> on State<T> {
  /// 刷新/加载更多/滚动控制
  /// [RequestPage]
  late final RScrollController scrollController = RScrollController()
    ..onLoadDataCallback = onLoadData;

  /// 默认的情感图状态, 同时也会触发对应的事件
  /// [initState]
  WidgetState defWidgetState = WidgetState.loading;

  /// 当前界面的数据
  WidgetList pageDataList = [];

  //region 生命周期

  @override
  void initState() {
    if (defWidgetState == WidgetState.loading) {
      firstLoad();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this is AbsScrollPage) {
      return (this as AbsScrollPage).buildScaffold(context);
    }
    return pageRScrollView();
  }

  //endregion 生命周期

  //region 数据加载

  /// 重写此方法, 加载数据
  /// 通过[RequestPage]实现页面分页
  @protected
  void onLoadData();

  /// 调用此方法, 加载数据完成, 并自动处理情感图/加载更多状态控制
  /// [loadData] 当前加载到的数据, 非所有数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  /// [handleData] 是否自动处理数据到[pageDataList]
  @callPoint
  void loadDataEnd(
    List? loadData, [
    dynamic stateData,
    bool handleData = true,
  ]) {
    if (handleData) {
      if (loadData is WidgetList) {
        if (scrollController.requestPage.isFirstPage) {
          pageDataList.clear();
        }
        pageDataList.addAll(loadData);
      }
    }
    scrollController.finishRefresh(this, loadData, stateData);
  }

  /// 首次加载, 如果需要请主动调用, 触发
  @callPoint
  void firstLoad() {
    scrollController.updateAdapterState(this, defWidgetState);
  }

  /// 分页请求参数
  Map<String, dynamic> pageRequestData() =>
      scrollController.requestPage.toMap();

  //endregion 数据加载

  //region 页面控制

  /// 是否启用下拉刷新
  bool get enableRefresh => true;

  /// 是否启用加载更多
  bool get enableLoadMore => true;

  /// 简单页面请求, 只有一页数据
  @api
  void singlePage() {
    scrollController.requestPage.singlePage();
  }

  /// 显示下拉刷新
  @api
  void startRefresh() {
    scrollController.startRefresh();
  }

  /// 显示状态刷新
  @api
  void startRefreshState() {
    scrollController.startRefresh(state: this, useWidgetState: true);
  }

  /// 包裹内容
  /// [RScrollView]
  @callPoint
  RScrollView pageRScrollView({
    WidgetList? children,
    bool? enableRefresh,
    bool? enableLoadMore,
  }) {
    return RScrollView(
      controller: scrollController,
      enableRefresh: enableRefresh ?? this.enableRefresh,
      enableLoadMore: enableLoadMore ?? this.enableLoadMore,
      children: children ?? pageDataList,
    );
  }

//endregion 页面控制
}

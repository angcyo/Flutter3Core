part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/30
///
/// 混入一个[RScrollView]的页面, 支持`刷新/加载更多`等基础功能的页面
///
/// 重写[onLoadData]方法, 加载数据之后调用[loadDataEnd]
/// ```
/// @override
/// FutureOr onLoadData() {
///   loadDataEnd([], e);
/// }
/// ```
///
/// [RScrollView]
/// [AbsScrollPage]
/// [RScrollPage]
/// [RStatusScrollPage]
mixin RScrollPage<T extends StatefulWidget> on State<T> {
  /// 刷新/加载更多/滚动控制
  /// [RScrollController.widgetStateIntercept]情感图状态切换拦截
  /// [RScrollController.buildAdapterStateWidget] 自定义情感图状态
  /// [RScrollController.buildLoadMoreStateWidget] 自定义加载更多状态
  /// [RequestPage]
  late final RScrollController scrollController = RScrollController()
    ..onLoadDataCallback = onSelfLoadDataWrap;

  /// 默认的情感图状态, 同时也会触发对应的事件
  /// [initState]
  WidgetBuildState defWidgetState = WidgetBuildState.loading;

  /// 当前界面的数据, 用来放到滚动体里面
  /// [pageRScrollView]
  WidgetList pageWidgetList = [];

  /// 界面是否[build]了, 决定更新状态时是否要延迟
  /// [updateAdapterState]
  bool _isPageBuild = false;

  /// 当页面需要更新新, 使用哪个[State]对象
  @configProperty
  State? pageUpdateState;

  /// 当前的[State]对象
  State get _updateState => pageUpdateState ?? this;

  //region 生命周期

  @override
  void initState() {
    //延迟一帧, 等待[WidgetStateScope]初始化
    postFrameCallback((timeStamp) {
      //debugger();
      if (mounted) {
        defWidgetState = WidgetStateScope.of(context) ?? defWidgetState;
      }
      if (defWidgetState.isLoading) {
        firstLoad();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    cancelAllFuture();
    super.dispose();
  }

  /// 重新构建
  @override
  void reassemble() {
    onSelfLoadDataWrap();
    super.reassemble();
  }

  /// [AbsScrollPage.buildBody]会调用[pageRScrollView]
  @override
  Widget build(BuildContext context) {
    _isPageBuild = true;
    if (this is AbsScrollPage) {
      //交给[AbsScrollPage]处理
      return (this as AbsScrollPage).buildScaffold(context);
    }
    return pageRScrollView();
  }

  //endregion 生命周期

  //region Future

  /// 用来取消[Future]
  late final Map futureCancelMap = {};

  @callPoint
  Future<T> hookFuture(Future<T> future, [String? tag]) {
    tag ??= future.hash();
    //取消旧的
    cancelFuture(tag);
    //新的
    FutureCancelToken cancelToken = FutureCancelToken();
    futureCancelMap[tag] = cancelToken;
    return future.listenCancel(cancelToken);
  }

  /// 取消指定的[Future]
  @api
  void cancelFuture(String tag) {
    FutureCancelToken? cancelToken = futureCancelMap[tag];
    if (cancelToken != null) {
      cancelToken.cancel();
      futureCancelMap.remove(tag);
    }
  }

  /// 取消所有的[Future]
  @api
  void cancelAllFuture() {
    for (var element in futureCancelMap.values) {
      element.cancel();
    }
    futureCancelMap.clear();
  }

  //endregion Future

  //region 数据加载

  /// 加载数据入口
  /// [RScrollController.onLoadDataCallback]
  Future onSelfLoadDataWrap() async {
    try {
      await onLoadData();
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
      loadDataEnd(null, e);
    }
  }

  /// 重写此方法, 加载数据
  /// 通过[RequestPage]实现页面分页
  ///
  /// [onSelfLoadDataWrap]
  @overridePoint
  FutureOr onLoadData();

  /// 调用此方法, 加载数据完成, 并自动处理情感图/加载更多状态控制
  /// [loadData] 当前加载到的数据, 非所有数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  /// [handleData] 是否自动处理数据到[pageWidgetList]
  ///
  /// 重写[wrapScrollChildren]方法,实现额外的布局
  ///
  /// [updateLoadDataWidget] 简单刷新整体界面
  @callPoint
  @updateMark
  void loadDataEnd(
    List? loadData, [
    dynamic stateData,
    bool handleData = true,
  ]) {
    if (handleData && loadData != null) {
      if (loadData is WidgetList) {
        if (scrollController.requestPage.isFirstPage) {
          pageWidgetList.clear();
        }
        pageWidgetList.addAll(loadData);
      } else {
        assert(() {
          l.w('无法处理的数据类型:${loadData.runtimeType}');
          return true;
        }());
      }
    }
    scrollController.finishRefresh(_updateState, loadData, stateData);
  }

  /// 首次加载, 如果需要请主动调用, 触发
  @callPoint
  void firstLoad([WidgetBuildState? state]) {
    state ??= defWidgetState;
    //debugger();
    //当前的状态
    var currentState = scrollController.adapterStateValue.value;
    if (currentState.isNoneState) {
      //已经显示了内容
    } else if (currentState == WidgetBuildState.preLoading ||
        currentState != state) {
      scrollController.updateAdapterState(_updateState, state);
    }
  }

  /// 在已经[loadDataEnd]过后, 此时需要刷新简单的静态界面时调用此方法
  /// 调用此方法不会触发[onLoadData]回调
  /// 不调用此方法, 直接调用[State.setState]无法更新在[onLoadData]回调中创建的小部件
  ///
  /// [loadDataEnd]
  @callPoint
  void updateLoadDataWidget(WidgetList widgetList) {
    if (scrollController.requestPage.isFirstPage) {
      pageWidgetList.clear();
    }
    pageWidgetList.addAll(widgetList);
    _updateState.updateState();
  }

  /// 分页请求参数
  Map<String, dynamic> pageRequestData() =>
      scrollController.requestPage.toMap();

  //endregion 数据加载

  //region 页面控制

  /// 是否启用下拉刷新
  @configProperty
  bool get enableRefresh => true;

  /// 是否启用加载更多
  @configProperty
  bool get enableLoadMore => true;

  /// 重置分页请求信息
  @api
  void resetPage([RequestPage? page]) {
    if (page == null) {
      scrollController.requestPage.reset();
    } else {
      scrollController.requestPage = page;
    }
  }

  /// 简单页面请求, 只有一页数据
  @api
  void singlePage() {
    scrollController.requestPage.singlePage();
  }

  /// 显示下拉刷新
  /// [loadDataEnd]
  @api
  @updateMark
  void startRefresh() {
    scrollController.startRefresh();
  }

  /// 结束下拉刷新, 更多时候应该调用[loadDataEnd]
  @api
  @updateMark
  void finishRefresh() {
    scrollController.finishRefresh(null);
  }

  /// 显示情感图状态刷新
  @api
  @updateMark
  void startRefreshState() {
    scrollController.startRefresh(state: this, useWidgetState: true);
  }

  /// 更新情感图状态
  @api
  @updateMark
  bool updateAdapterState(WidgetBuildState widgetState, [dynamic stateData]) {
    if (_isPageBuild) {
      return scrollController.updateAdapterState(
          _updateState, widgetState, stateData);
    } else {
      postFrameCallback((timeStamp) {
        if (isMounted) {
          scrollController.updateAdapterState(
              _updateState, widgetState, stateData);
        }
      });
      return false;
    }
  }

  /// 重写此方法, 实现收尾插入自定义的小部件
  @overridePoint
  WidgetList wrapScrollChildren(WidgetList children) => children;

  /// 包裹内容
  /// [RScrollView]
  /// [build]
  /// [RScrollPage.build]->[RScrollPage.pageRScrollView]
  /// [AbsScrollPage.buildBody]
  @callPoint
  RScrollView pageRScrollView({
    WidgetList? children,
    bool? enableRefresh,
    bool? enableLoadMore,
  }) {
    _isPageBuild = true;
    return RScrollView(
      controller: scrollController,
      enableRefresh: enableRefresh ?? this.enableRefresh,
      enableLoadMore: enableLoadMore ?? this.enableLoadMore,
      children: wrapScrollChildren(children ?? pageWidgetList),
    );
  }

  //endregion 页面控制

  //region 页面更新

  /// 更新指定[value]对应的tile
  /// [value] 可以是单个值, 也可以是多个值(列表)
  @api
  void updateTile(dynamic value) {
    rebuildTile((tile, signal) {
      return signal.value == value ||
          (value is Iterable && value.contains(signal.value));
    });
  }

  /// 更新指定的tile
  /// [test] 测试是否需要更新, 返回true, 表示需要rebuild
  @api
  void rebuildTile(
      bool Function(RItemTile tile, UpdateValueNotifier signal) test) {
    for (final element in pageWidgetList) {
      //debugger();
      if (element is RItemTile) {
        //element.updateTile();
        final updateSignal = element.updateSignal;
        if (updateSignal != null) {
          try {
            if (test(element, updateSignal)) {
              //debugger();
              updateSignal.updateValue();
            }
          } catch (e) {
            //中断循环
            assert(() {
              printError(e);
              return true;
            }());
            break;
          }
        }
      }
    }
  }

//endregion 页面更新
}

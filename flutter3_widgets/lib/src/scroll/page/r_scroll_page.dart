part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/30
///
/// 混入一个[RScrollView]的页面, 支持`刷新/加载更多`等基础功能的页面
///
/// [build]->[buildScrollPage]->[pageRScrollView]
///
/// 重写[onLoadData]方法, 加载数据之后调用[loadDataEnd]加载界面和数据
/// ```
/// @override
/// FutureOr onLoadData() {
///   loadDataEnd([], e);
/// }
/// ```
///
/// [RScrollView]
/// [AbsScrollPage] 基础[RScrollView]页面
/// [RScrollPage]   全功能[RScrollView]页面
/// [RStatusScrollPage]
///
/// ## 分页信息
///
/// - [RScrollController.requestPage]
/// - [resetPage]
/// - [singlePage]
///
mixin RScrollPage<T extends StatefulWidget> on State<T> {
  /// 保存最后一次[rebuildByBean]方法创建的更新信号,
  /// 然后在[RItemTileExtension]中消耗此对象
  static WeakReference<UpdateValueNotifier>? _lastRebuildBeanSignal;

  /// - 使用 [rebuildByBean] 创建一个更新信号
  /// - 使用 [RItemTileExtension] 扩展消耗更新信号
  static UpdateValueNotifier? consumeRebuildBeanSignal() {
    if (_lastRebuildBeanSignal?.target != null) {
      final signal = _lastRebuildBeanSignal?.target;
      _lastRebuildBeanSignal = null;
      return signal;
    }
    return null;
  }

  /// 刷新/加载更多/滚动控制
  /// [RScrollController.widgetStateIntercept]情感图状态切换拦截
  /// [RScrollController.buildAdapterStateWidget] 自定义情感图状态
  /// [RScrollController.buildLoadMoreStateWidget] 自定义加载更多状态
  /// [RequestPage]
  late final RScrollController scrollController =
      RScrollController(tag: classHash(), debugLabel: null)
        ..isSupportScrollLoadDataCallback = isSelfSupportScrollLoadData
        ..onLoadDataCallback = onSelfLoadDataWrap;

  /// 首次加载[initState]时, 需要触发的情感图状态
  /// 默认的情感图状态, 同时也会触发对应的事件
  /// [initState]
  /// 也可以使用[WidgetStateScope]指定情感图状态
  WidgetBuildState? defWidgetState;

  /// 首次加载[initState]时, 需要触发的情感图状态
  /// 当未指定[defWidgetState]时, 自动根据页面类型识别
  WidgetBuildState get firstWidgetState {
    if (defWidgetState != null) {
      return defWidgetState!;
    }
    if (this is BasePageChildLifecycleState) {
      //如果是在[PageView]里面, 则使用预加载
      return WidgetBuildState.preLoading;
    }
    return WidgetBuildState.loading;
  }

  /// 当前界面的数据, 用来放到滚动体里面
  /// [pageRScrollView]
  WidgetList pageWidgetList = [];

  /// 获取所有[pageWidgetList].[RItemTile.UpdateValueNotifier]
  List<Bean> getWidgetDataList<Bean>() {
    final List<Bean> result = [];
    pageWidgetList.map((e) {
      if (e is RItemTile) {
        final value = e.updateSignal?.value;
        if (value != null) {
          result.add(value);
        }
      }
    });
    return result;
  }

  /// 界面是否[build]了, 决定更新状态时是否要延迟
  /// [updateAdapterState]
  bool _isPageBuild = false;

  /// 在[pageRScrollView]中使用->[RScrollView]小部件的更新信号
  /// - [updateLoadDataWidget] 刷新界面
  final UpdateValueNotifier _scrollViewUpdateSignal = createUpdateSignal();

  //region 生命周期

  @override
  void initState() {
    if (defWidgetState != null) {
      //默认状态
      scrollController.adapterStateValue.value = defWidgetState!;
    }
    //延迟一帧, 等待[WidgetStateScope]初始化
    postFrameCallback((timeStamp) {
      //debugger();
      if (mounted) {
        defWidgetState = WidgetStateScope.of(context) ?? defWidgetState;
      }
      if (firstWidgetState.isLoading) {
        firstState();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    cancelAllFuture();
    super.dispose();
  }

  /// 重新构建, 热更新触发
  @override
  void reassemble() {
    //debugger();
    onSelfLoadDataWrap();
    super.reassemble();
  }

  /// [AbsScrollPage.buildBody]会调用[pageRScrollView]
  @override
  Widget build(BuildContext context) => buildScrollPage(context);

  /// [build]->[buildScrollPage]->[pageRScrollView]->[RScrollView]
  @callPoint
  Widget buildScrollPage(BuildContext context) {
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

  /// 是否支持滚动到底加载更多
  /// [RScrollController.isSupportScrollLoadData]
  bool isSelfSupportScrollLoadData() => true;

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

  /// 重写此方法, 加载数据, 自动处理异常状态
  /// 通过[RequestPage]实现页面分页
  /// 加载数据完成后, 调用[loadDataEnd]刷新界面
  ///
  /// - [onSelfLoadDataWrap]
  /// - [RScrollController.requestPage]
  @overridePoint
  FutureOr onLoadData();

  /// 调用此方法, 加载数据完成, 并自动处理情感图/加载更多状态控制
  /// [loadData] 当前加载到的数据, 非所有数据. 当前只支持[WidgetList]类型
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误[Exception]
  /// [handleData] 是否自动处理数据到[pageWidgetList]
  ///
  /// 重写[wrapScrollChildren]方法,实现额外的布局
  ///
  /// [updateLoadDataWidget] 简单刷新整体界面
  ///
  /// ```
  /// loadDataEnd(values?.mapToList<Widget>((e)=>Widget());, error);
  /// ```
  ///
  /// ## 如果需要动态更新Tile
  ///
  /// 先使用[rebuildByBean]包裹[Widget]
  /// 然后就可以使用[rebuildTile]更新对应的[Widget]
  ///
  /// - [rebuildByBean]
  /// - [deleteTile]
  /// - [rebuildTile]
  /// - [updateTile]
  ///
  /// ```
  /// rebuildByBean(bean, (ctx, bean) => widget).rTile;
  /// ```
  ///
  /// - [RScrollPage._lastRebuildBeanSignal] 创建更新信号
  /// - [RScrollPage.consumeRebuildBeanSignal] 消耗更新信号
  /// - [RItemTile.updateSignal] 存储对应的信号
  ///
  @callPoint
  @updateMark
  @api
  void loadDataEnd(
    Iterable? loadData /*支持[WidgetList]*/, [
    dynamic stateData /*不同的状态, 附加的任意数据*/,
    bool handleData = true /*是否处理数据*/,
  ]) {
    if (handleData && loadData != null) {
      if (loadData is Iterable<Widget>) {
        if (requestPage.isFirstPage) {
          pageWidgetList.clear();
        }
        pageWidgetList.addAll(loadData);
      } else if (loadData.firstOrNull is Widget) {
        if (requestPage.isFirstPage) {
          pageWidgetList.clear();
        }
        pageWidgetList.addAll(loadData.cast<Widget>());
      } else if (loadData.isNotEmpty) {
        assert(() {
          l.w('无法处理的数据类型:${loadData.runtimeType}');
          debugger();
          return true;
        }());
      }
    }
    scrollController.finishRefresh(loadData, stateData);
  }

  /// 处理[onLoadData]加载了的数据
  /// - [loadDataEnd]
  /// - [enableRebuild] 是否支持通过[beanList]中的数据动态更新[Widget]
  ///   - [deleteTile]
  ///   - [removeTile]
  ///   - [updateTile]
  ///   - [updateTileList]
  ///   - [updateAllTile]
  @api
  void loadBeanEnd(
    Iterable? beanList, [
    dynamic stateData /*不同的状态, 附加的任意数据*/,
    WidgetValueIndexBuilder? builder,
    bool enableRebuild = false,
  ]) {
    final widgetList = beanList?.mapIndex((bean, index) {
      final widget = builder?.call(context, bean, index, null);
      if (widget != null && enableRebuild) {
        return rebuildByBean(bean, (ctx, data) => widget);
      } else {
        return widget;
      }
    }).filterNull();
    loadDataEnd(widgetList, stateData, true);
  }

  /// 设置首次的加载状态
  /// [initState]
  @callPoint
  void firstState([WidgetBuildState? state]) {
    state ??= firstWidgetState;
    //debugger();
    //当前的状态
    final currentState = scrollController.adapterStateValue.value;
    if (currentState != state) {
      scrollController.updateAdapterState(state);
    }
  }

  /// 首次触发[WidgetBuildState.loading]加载状态, 如果需要请主动调用触发事件
  @callPoint
  void firstLoad([WidgetBuildState? state]) {
    state ??= WidgetBuildState.loading;
    //debugger();
    //当前的状态
    final currentState = scrollController.adapterStateValue.value;
    if (currentState.isNoneState) {
      //已经显示了内容
    } else if (currentState == WidgetBuildState.preLoading ||
        currentState != state) {
      scrollController.updateAdapterState(state);
    }
  }

  /// 在已经[loadDataEnd]过后, 此时需要刷新简单的静态界面时调用此方法
  /// 调用此方法不会触发[onLoadData]回调
  /// 不调用此方法, 直接调用[State.setState]无法更新在[onLoadData]回调中创建的小部件
  ///
  /// [loadDataEnd]
  @callPoint
  void updateLoadDataWidget([WidgetList? widgetList]) {
    widgetList ??= pageWidgetList;
    if (pageWidgetList != widgetList) {
      if (requestPage.isFirstPage) {
        pageWidgetList.clear();
      }
      pageWidgetList.addAll(widgetList);
    }
    _scrollViewUpdateSignal.update();
  }

  //endregion 数据加载

  //region 页面控制

  /// 是否启用下拉刷新
  @configProperty
  bool get enablePageRefresh => true;

  /// 是否启用加载更多
  @configProperty
  bool get enablePageLoadMore => true;

  @output
  RequestPage get requestPage => scrollController.requestPage;

  /// 分页请求参数
  @output
  Map<String, dynamic> pageRequestData() => requestPage.toMap();

  /// 重置分页请求信息
  @api
  void resetPage([RequestPage? page]) {
    if (page == null) {
      requestPage.reset();
    } else {
      scrollController.requestPage = page;
    }
  }

  /// 简单页面请求, 只有一页数据
  @api
  void singlePage() {
    requestPage.singlePage();
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
    scrollController.startRefresh(useWidgetState: true);
  }

  /// 更新情感图状态
  @api
  @updateMark
  bool updateAdapterState(WidgetBuildState widgetState, [dynamic stateData]) {
    if (_isPageBuild) {
      return scrollController.updateAdapterState(widgetState, stateData);
    } else {
      postFrameCallback((timeStamp) {
        if (isMounted) {
          scrollController.updateAdapterState(widgetState, stateData);
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
  /// [build]->[buildScrollPage]->[pageRScrollView]->[RScrollView]
  /// [AbsScrollPage.buildBody]
  @callPoint
  Widget pageRScrollView({
    WidgetList? children,
    bool? enableRefresh,
    bool? enableLoadMore,
  }) {
    //debugger();
    _isPageBuild = true;
    return rebuild(_scrollViewUpdateSignal, (context, value) {
      scrollController.scrollViewUpdateSignal = _scrollViewUpdateSignal;
      //debugger();
      return RScrollView(
        controller: scrollController,
        tag: classHash(),
        enableRefresh: enableRefresh ?? enablePageRefresh,
        enableLoadMore: enableLoadMore ?? enablePageLoadMore,
        children: wrapScrollChildren(children ?? pageWidgetList),
      );
    });
  }

  //--

  /// 注册一个情感图状态小部件
  /// [AdapterStateWidget]
  @api
  void registerAdapterState(
    WidgetBuildState widgetState,
    WidgetStateBuilder builder,
  ) {
    scrollController.widgetStateBuilderMap[widgetState] = builder;
  }

  /// 注册一个加载更多状态小部件
  /// [LoadMoreStateWidget]
  @api
  void registerLoadMoreState(
    WidgetBuildState widgetState,
    WidgetStateBuilder builder,
  ) {
    scrollController.loadMoreStateBuilderMap[widgetState] = builder;
  }

  //endregion 页面控制

  //region 页面更新

  /// 使用[bean]自动创建一个带[RItemTile.updateSignal]更新信号的[Widget]
  /// 将生成的信号存储在[RScrollPage._lastRebuildBeanSignal]中,
  /// 然后在[RItemTileExtension]中消耗此信号对象
  /// 之后可以通过[updateTile]更新指定的小部件
  @api
  Widget rebuildByBean<Bean>(Bean bean, DataWidgetBuilder<Bean> builder) {
    final updateSignal = UpdateSignalNotifier(bean);
    RScrollPage._lastRebuildBeanSignal = WeakReference(updateSignal);
    return rebuild(updateSignal, (context, value) {
      //debugger();
      return builder(context, value);
    });
  }

  /// 更新指定[value]对应的tile
  /// [value] 可以是单个值, 也可以是多个值(列表)
  /// 如果是多个值, 则所有命中[RItemTile.updateSignal]值的tile, 都将收到更新信号通知
  /// - [rebuildTile]
  /// - [updateTile]
  /// - [updateTileList]
  @api
  void updateTile(dynamic value) {
    rebuildTile((tile, signal) {
      //debugger();
      final update =
          signal.value == value ||
          (value is Iterable && value.contains(signal.value));
      assert(() {
        if (update) {
          l.d("更新[${tile.classHash()}]->$value");
        }
        return true;
      }());
      return update;
    });
  }

  /// 更新一组 tile
  /// - [rebuildTile]
  /// - [updateTile]
  /// - [updateTileList]
  @api
  void updateTileList(List<dynamic> values) {
    for (final value in values) {
      updateTile(value);
    }
  }

  /// 更新所有tile
  /// - [updateTile]
  /// - [rebuildTile]
  @api
  void updateAllTile() {
    rebuildTile((tile, signal) {
      return true;
    });
  }

  /// 更新满足条件的tile, 前提是需要配置[RItemTile.updateSignal]更新信号
  /// [test] 测试是否需要更新, 返回true, 表示需要rebuild
  @api
  void rebuildTile(
    bool Function(RItemTile tile, UpdateValueNotifier signal) test,
  ) {
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

  /// - [deleteTile]
  /// - [removeTile]
  @api
  void removeTile(dynamic value) {
    deleteTile((tile, signal) {
      return signal.value == value ||
          (value is Iterable && value.contains(signal.value));
    });
  }

  /// 在[pageWidgetList]中移除所有[RItemTile.updateSignal]满足条件的value
  /// - [updateTile]
  /// - [deleteTile]
  /// - [removeTile]
  ///
  /// [pageWidgetList]
  @api
  void deleteTile(
    bool Function(RItemTile tile, UpdateValueNotifier signal) test,
  ) {
    final WidgetList removeList = [];
    for (final element in pageWidgetList) {
      //debugger();
      if (element is RItemTile) {
        //element.updateTile();
        final updateSignal = element.updateSignal;
        if (updateSignal != null) {
          try {
            if (test(element, updateSignal)) {
              //debugger();
              removeList.add(element);
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
    if (removeList.isNotEmpty) {
      pageWidgetList.removeAll(removeList);
      _scrollViewUpdateSignal.update();

      if (pageWidgetList.isEmpty) {
        //显示空页面
        updateAdapterState(WidgetBuildState.empty);
      }
    }
  }

  //endregion 页面更新
}

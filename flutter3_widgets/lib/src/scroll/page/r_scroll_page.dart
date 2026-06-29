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
/// [RStatusScrollPage] 支持切换不同状态的页面
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
  /// - [pageRScrollView]
  ///
  /// - [pageWidgetList]
  /// - [pageBeanList]
  WidgetList pageWidgetList = [];

  /// 获取[pageWidgetList]对应的数据结构列表
  /// [getWidgetDataList]
  ///
  /// - [pageWidgetList]
  /// - [pageBeanList]
  List? get pageBeanList => getWidgetDataList();

  /// 滚动内容数量监听
  @streamMark
  final pageWidgetCountLive = $live<int>(0);

  /// 获取所有[pageWidgetList].[RItemTile.UpdateValueNotifier]
  List<Bean> getWidgetDataList<Bean>() {
    final List<Bean> result = [];
    for (final widget in pageWidgetList) {
      dynamic value = widget.tileValue;
      //--
      if (value != null) {
        result.add(value);
      }
    }
    return result;
  }

  /// 界面是否[build]了, 决定更新状态时是否要延迟
  /// [updateAdapterState]
  @tempFlag
  bool _isPageBuild = false;

  /// 在[pageRScrollView]中使用->[RScrollView]小部件的更新信号
  /// - [updateLoadDataWidget] 刷新界面
  @tempFlag
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
    //onSelfLoadDataWrap();
    startRefresh();
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
    } catch (e, s) {
      l.e(e);
      assert(() {
        printError(e, s);
        //debugger();
        return true;
      }());
      loadDataEnd(null, e);
    }
  }

  /// 重写此方法, 加载数据, 自动处理异常状态
  /// 通过[RequestPage]实现页面分页
  /// 加载数据完成后, 调用[loadDataEnd]刷新界面
  ///
  /// ```
  /// final beanList = await $activityApi.fetchPromotionList(
  ///   type: null,
  ///   status: null,
  ///   current: requestPage.requestPageIndex,
  ///   size: requestPage.requestPageSize,
  /// );
  /// loadBeanEnd(
  ///   beanList,
  ///   null,
  ///   (ctx, bean, index, isSelected) => YDTableRowTile());
  /// ```
  ///
  /// - [loadBeanEnd] -> [loadDataEnd]
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
        pageWidgetCountLive <= pageWidgetList.size();
      } else if (loadData.firstOrNull is Widget) {
        if (requestPage.isFirstPage) {
          pageWidgetList.clear();
        }
        pageWidgetList.addAll(loadData.cast<Widget>());
        pageWidgetCountLive <= pageWidgetList.size();
      } else if (loadData.isNotEmpty) {
        assert(() {
          l.w('无法处理的数据类型:${loadData.runtimeType}');
          debugger();
          return true;
        }());
      }
    } else if (stateData is Exception) {
      //error
      pageWidgetCountLive <= 0;
    }
    scrollController.finishRefresh(loadData, stateData);
  }

  /// 插入数据
  ///  - [index] 插入数据的索引, 支持负数(倒序索引)
  @api
  void insertData(Iterable? loadData, int index) {
    if (loadData == null || loadData.isEmpty) {
      return;
    }
    if (pageWidgetList.isEmpty) {
      loadDataEnd(loadData, null, true);
      return;
    }
    final insertIndex = index < 0 ? pageWidgetList.length + index : index;
    if (loadData is Iterable<Widget>) {
      pageWidgetList.insertAll(insertIndex, loadData);
      pageWidgetCountLive <= pageWidgetList.size();
    } else if (loadData.firstOrNull is Widget) {
      pageWidgetList.insertAll(insertIndex, loadData.cast<Widget>());
      pageWidgetCountLive <= pageWidgetList.size();
    } else if (loadData.isNotEmpty) {
      assert(() {
        l.w('无法处理的数据类型:${loadData.runtimeType}');
        debugger();
        return true;
      }());
    }
    //重建界面
    rebuildScrollView();
  }

  /// 处理[onLoadData]加载了的数据
  /// - [loadDataEnd]
  /// - [enableRebuild] 是否支持通过[beanList]中的数据动态更新[Widget]
  ///   - [deleteTile] 删除满足条件的[RItemTile]
  ///   - [removeTile] 通过数据删除[RItemTile]
  ///   - [updateTile] 通过数据更新[RItemTile]
  ///   - [updateTileList]
  ///   - [updateAllTile]
  /// - [enableRebuild] 是否支持动态更新数据
  /// - [insetIndex] 是否是插入数据
  @api
  void loadBeanEnd<T>(
    Iterable<T>? beanList, [
    dynamic stateData /*不同的状态, 附加的任意数据*/,
    WidgetValueIndexBuilder<T>? builder,
    bool enableRebuild = false,
    int? insetIndex,
  ]) {
    final widgetList = beanList?.mapIndex((bean, index) {
      if (enableRebuild) {
        return rebuildByBean(
          bean,
          (ctx, data) =>
              builder?.call(context, data ?? bean, index, null) ?? empty,
        );
      } else {
        return builder?.call(context, bean, index, null);
      }
    }).filterNull();
    if (insetIndex == null) {
      loadDataEnd(widgetList, stateData, true);
    } else {
      insertData(widgetList, insetIndex);
    }
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
      pageWidgetCountLive <= pageWidgetList.size();
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
  /// - 触发刷新加载数据
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

  /// 仅重建界面
  @api
  @updateMark
  void rebuildScrollView() {
    scrollController.notifyRebuildScrollViewWidget();
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
  /// - 也可以在此方法内进行排序
  ///
  /// # 自动排序交互
  /// ```
  ///  requestPage.buildSortWidget(
  ///    context,
  ///    "状态",
  ///    "status",
  ///    ascIcon: loadRootSvgWidget(Assets.svg.sortAsc, size: 16),
  ///    descIcon: loadRootSvgWidget(Assets.svg.sortDesc, size: 16),
  ///    onSortAction: scrollController.notifyRebuildScrollViewWidget,
  ///  ),
  /// ```
  ///  # 排序
  /// ```
  /// if (requestPage.hasSort) {
  ///   return [...children]..sort((a, b) {
  ///     final ab = a.tileValue;
  ///     final bb = b.tileValue;
  ///     if (ab is ActivityBean && bb is ActivityBean) {
  ///       if (requestPage.reversed == true) {
  ///         //倒序
  ///         if (requestPage.sortField == "status") {
  ///           return bb.status?.compareTo(ab.status ?? "") ?? 0;
  ///         }
  ///         if (requestPage.sortField == "updateTime") {
  ///           return bb.updateTime?.compareTo(ab.updateTime ?? "") ?? 0;
  ///         }
  ///         return bb.createTime?.compareTo(ab.createTime ?? "") ?? 0;
  ///       } else {
  ///         //升序
  ///         if (requestPage.sortField == "status") {
  ///           return ab.status?.compareTo(bb.status ?? "") ?? 0;
  ///         }
  ///         if (requestPage.sortField == "updateTime") {
  ///           return ab.updateTime?.compareTo(bb.updateTime ?? "") ?? 0;
  ///         }
  ///         return ab.createTime?.compareTo(bb.createTime ?? "") ?? 0;
  ///       }
  ///     }
  ///     //debugger();
  ///     return 0;
  ///   });
  /// } else {
  ///   return super.wrapScrollChildren(children);
  /// }
  /// ```
  ///
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
    return rebuild(updateSignal, (context, value) => builder(context, value));
  }

  /// 更新指定[value]对应的tile
  /// [value] 可以是单个值, 也可以是多个值(列表)
  /// 如果是多个值, 则所有命中[RItemTile.updateSignal]值的tile, 都将收到更新信号通知
  ///
  /// - [onUpdateValueAction]
  ///   - 请在此方法中执行旧(界面)数据字段的更新,
  ///   - 防止id相同时, 其它字段不同, 界面读取不到新数据
  ///
  /// - [rebuildTile]
  /// - [updateTile]
  /// - [updateTileList]
  @api
  void updateTile<T>(
    T value, {
    void Function(T oldValue)? onUpdateValueAction,
  }) {
    rebuildTile((tile, signal) {
      //debugger();
      final update =
          signal.value == value ||
          (value is Iterable && value.contains(signal.value));
      if (update) {
        /*debugger();
        if (signal is ValueNotifier) {
          //先清空, 后赋值. 否则id相同时, 其它字段不同, 不会更新
          signal.value = null;//不支持
          signal.value = value;
        }*/
        onUpdateValueAction?.call(signal.value);
        assert(() {
          if (update) {
            l.d("找到需要更新[${tile.classHash()}]->$value");
          }
          return true;
        }());
      }
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
    rebuildTile((tile, signal) => true);
  }

  /// 更新满足条件的tile, 前提是需要配置[RItemTile.updateSignal]更新信号
  /// [test] 测试是否需要更新, 返回true, 表示需要rebuild
  @api
  void rebuildTile(bool Function(Widget tile, Listenable signal) test) {
    for (final element in pageWidgetList) {
      //debugger();
      Listenable? updateSignal = element.tileUpdateSignal;
      if (updateSignal != null) {
        try {
          if (test(element, updateSignal)) {
            //debugger();
            if (updateSignal is UpdateSignalNotifier) {
              updateSignal.updateValue();
            } else if (updateSignal is ChangeNotifier) {
              updateSignal.notifyListeners();
            } else {
              debugger();
            }
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

  /// 支持使用数据结构[value]删除对应的tile
  /// - [deleteTile]
  /// - [removeTile]
  @api
  WidgetList removeTile(dynamic value, {@defInjectMark bool? checkScroll}) {
    return deleteTile((tile, signal) {
      return signal.value == value ||
          (value is Iterable && value.contains(signal.value));
    }, checkScroll: checkScroll);
  }

  /// 在[pageWidgetList]中移除所有[RItemTile.updateSignal]满足条件的value
  ///
  /// - [checkScroll] 是否检查滚动位置, 触发加载更多
  ///
  /// - [updateTile]
  /// - [deleteTile]
  /// - [removeTile]
  ///
  /// [pageWidgetList]
  /// @return 被删除的小部件列表
  @api
  WidgetList deleteTile(
    bool Function(Widget tile, Listenable signal) test, {
    @defInjectMark bool? checkScroll,
  }) {
    final WidgetList removeList = [];
    for (final element in pageWidgetList) {
      //debugger();
      Listenable? updateSignal = element.tileUpdateSignal;
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
    if (removeList.isNotEmpty) {
      pageWidgetList.removeAll(removeList);
      pageWidgetCountLive <= pageWidgetList.size();
      _scrollViewUpdateSignal.update();

      if (pageWidgetList.isEmpty) {
        //显示空页面
        updateAdapterState(WidgetBuildState.empty);
      } else if (checkScroll ?? false /*scrollController._isEnableLoadMore*/ ) {
        scrollController.checkScrollPosition();
      }
    } else {
      assert(() {
        l.w("没有找到需要删除的的tile");
        return true;
      }());
    }
    return removeList;
  }

  //endregion 页面更新
}

/// 按键刷新界面 / 快捷键刷新界面
/// - 支持搜索布局
///
/// # Windows
///   F5: 刷新界面
///   Ctrl + F: 显示搜索界面
/// # macOS
///   ⌘ R: 刷新界面
///   ⌘ F: 显示搜索界面
/// # 按键描述符
/// _LocalizedShortcutLabeler.instance.getShortcutLabel( shortcut!, MaterialLocalizations.of(context),);
///
mixin RScrollPageRefreshMixin<T extends StatefulWidget> on RScrollPage<T> {
  /// [build]->[buildScrollPage]->[pageRScrollView]->[RScrollView]
  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  void dispose() {
    if (enableFilterMixin) {
      OverlayEntryControlState.hideOverlayByTag(kSearchOverlayTag);
    }
    super.dispose();
  }

  @override
  Widget pageRScrollView({
    WidgetList? children,
    bool? enableRefresh,
    bool? enableLoadMore,
  }) {
    return super
        .pageRScrollView(
          children: children,
          enableRefresh: enableRefresh,
          enableLoadMore: enableLoadMore,
        )
        .keyEvent(
          isMacOS
              ? [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR]
              : [LogicalKeyboardKey.f5],
          (event) {
            startRefresh();
            return .handled;
          },
          keyEventRegisterList: [
            if (enableFilterMixin)
              KeyEventRegister(
                [
                  isMacOS
                      ? [LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF]
                      : [LogicalKeyboardKey.control, LogicalKeyboardKey.keyF],
                ],
                onKeyEventAction: (event) {
                  showFilterInputOverlay();
                  return .handled;
                },
              ),
          ],
        );
  }

  //MARK: - 过滤功能

  final kSearchOverlayTag = "RScrollPageRefreshMixinSearch";

  /// 是否激活过滤功能
  @configProperty
  bool enableFilterMixin = false;

  /// 需要过滤的内容文本
  @output
  String? filterTextMixin;

  /// 显示过滤输入框
  @api
  @overridePoint
  void showFilterInputOverlay({
    BuildContext? context,
    //--
    Alignment? targetAnchor,
    Alignment? followerAnchor,
    Offset? alignmentOffset,
  }) {
    context ??= buildContext;
    final globalTheme = GlobalTheme.of(context);
    context?.showOverlay(
      (ctx, entry) {
        return SingleInputWidget(
              config: TextFieldConfig(
                hintText: "搜索内容",
                text: filterTextMixin,
                onChanged: (value) {
                  filterTextMixin = value;
                  debounce(() {
                    rebuildScrollView();
                  });
                },
                onKeyEvent: (node, event) {
                  if (event.isEscKey) {
                    OverlayEntryControlState.hideOverlayByTag(
                      kSearchOverlayTag,
                    );
                  }
                  return .ignored;
                },
              ),
            )
            .insets(all: kH)
            .decoration(fillDecoration(color: globalTheme.dialogSurfaceBgColor))
            .size(width: 260)
            .elevation(kDefaultElevation)
            .overlayDragTrigger();
      },
      tag: kSearchOverlayTag,
      targetAnchor: targetAnchor ?? .topRight,
      followerAnchor: followerAnchor ?? .topRight,
      alignmentOffset: alignmentOffset ?? Offset(-30, 40),
      closeBefore: true,
      onHide: () {
        filterTextMixin = null;
        rebuildScrollView();
      },
    );
  }
}

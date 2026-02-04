part of '../../flutter3_widgets.dart';

/// 滚动控制, 刷新/加载更多控制, 情感图状态切换控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [Completer]
///
/// - [wrapRefreshWidget]        :实现自定义的刷新小部件
/// - [buildAdapterStateWidget]  :实现自定义的情感图
/// - [buildLoadMoreStateWidget] :实现自定义的加载更多
///
class RScrollController extends ScrollController {
  /// 用来控制刷新的key
  /// [RefreshIndicatorState]
  final GlobalKey<RefreshIndicatorState> scrollRefreshKey = GlobalKey();

  /// 用来控制加载更多的key
  final GlobalKey<WidgetStateBuildWidgetState> loadMoreKey = GlobalKey();

  /// 滚动视图更新信号, 调用更新信号, 更新滚动小部件重构更新
  /// - 触发更新整体的界面
  /// - 一般是重建[RScrollView]
  /// - 在[RScrollPage.pageRScrollView]中赋值
  @configProperty
  UpdateValueNotifier? scrollViewUpdateSignal;

  /// 用来控制刷新完成
  /// [_onRefresh]
  /// [finishRefresh]
  Completer<void> _refreshCompleter = Completer();

  /// 当前的刷新状态, 可以监听这个值的变化触发刷新
  /// [WidgetBuildState]
  final ValueNotifier<WidgetBuildState> refreshStateValue = ValueNotifier(
    .none,
  );

  /// 情感图的状态
  /// [WidgetBuildState]
  ///
  /// [buildAdapterStateWidget]
  final ValueNotifier<WidgetBuildState> adapterStateValue = ValueNotifier(
    .preLoading,
  );

  /// 加载更多的状态
  /// [WidgetBuildState]
  ///
  /// [buildLoadMoreStateWidget]
  final ValueNotifier<WidgetBuildState> loadMoreStateValue = ValueNotifier(
    .none,
  );

  /// 请求的分页信息
  RequestPage requestPage = RequestPage();

  /// 情感图状态切换拦截
  WidgetBuildStateIntercept widgetStateIntercept = WidgetBuildStateIntercept();

  /// 状态对应的任意数据
  dynamic _widgetStateData;

  /// 是否启用加载更多, 自动在
  /// [buildLoadMoreStateWidget]中激活
  var _isEnableLoadMore = false;

  //---

  /// 也可以设置[onRefreshCallback]来监听刷新
  /// 刷新回调
  VoidCallback? onRefreshCallback;

  /// 加载更多回调
  VoidCallback? onLoadMoreCallback;

  /// 加载数据的回调[onRefreshCallback].[onLoadMoreCallback]的结合体
  /// 通过[requestPage]判断是否是刷新
  /// [_onRefreshStart]
  /// [_onLoadMoreStart]
  VoidCallback? onLoadDataCallback;

  /// 是否支持加载更多的触发
  /// [checkScrollPosition]->[isSupportScrollLoadData]
  bool Function()? isSupportScrollLoadDataCallback;

  //MARK: - tag
  String? tag;

  /// 满状态控制器
  RScrollController({this.tag, super.debugLabel});

  /// 简单状态控制器
  RScrollController.single() {
    adapterStateValue.value = .none;
  }

  /// 检查滚动位置
  /// 监听滚动到底部,驱动触发加载更多
  @api
  void checkScrollPosition() {
    //debugger();
    if (!position.isScrollingNotifier.value /*没有在滚动*/ &&
        position.hasContentDimensions /*具有内容的尺寸信息*/ &&
        position.pixels >= position.maxScrollExtent /*到底了*/ ) {
      //滚动到底部了
      if (adapterStateValue.value != .none) {
        //debugger();
        assert(() {
          l.d("[${tag ?? debugLabel}]情感图状态不是[none], 忽略滚动状态监听.");
          return true;
        }());
      } else if (_isEnableLoadMore) {
        //debugger();
        if (refreshStateValue.value == .loading) {
          assert(() {
            l.d("[${tag ?? debugLabel}]正在刷新中,忽略加载更多处理!");
            return true;
          }());
        } else if (loadMoreStateValue.value == .loading) {
          //正在加载中...
          //l.d("正在加载中...忽略加载更多处理.");
        } else if (loadMoreStateValue.value == .empty) {
          //没有更多数据了
          assert(() {
            l.d("[${tag ?? debugLabel}]没有更多数据了,忽略加载更多处理!");
            return true;
          }());
        } else if (isSupportScrollLoadData()) {
          assert(() {
            l.d(
              "[${tag ?? debugLabel}][${loadMoreStateValue.value}]滚动到底啦,触发加载更多...",
            );
            return true;
          }());
          updateLoadMoreState(.loading);
        } else {
          assert(() {
            l.d(
              "[${tag ?? debugLabel}][${loadMoreStateValue.value}]忽略滚动到底加载更多!",
            );
            return true;
          }());
        }
      }
    }
  }

  @override
  void attach(ScrollPosition position) {
    //debugger();
    addListener(checkScrollPosition);
    position.isScrollingNotifier.addListener(checkScrollPosition);
    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    //debugger();
    removeListener(checkScrollPosition);
    position.isScrollingNotifier.removeListener(checkScrollPosition);
    super.detach(position);
  }

  /// 释放资源
  @override
  void dispose() {
    super.dispose();
  }

  /// 是否支持加载更多
  @overridePoint
  bool isSupportScrollLoadData() {
    try {
      return isSupportScrollLoadDataCallback?.call() ?? true;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    return true;
  }

  //---

  /// 开始触发刷新, 并显示刷新头
  /// [useWidgetState] 是否使用[widgetStateValue]来触发刷新, 否则使用刷新头
  /// [state] 用来触发界面刷新
  @callPoint
  @updateMark
  void startRefresh({bool useWidgetState = false, bool atTop = true}) {
    if (useWidgetState) {
      updateAdapterState(.loading, null);
    } else {
      scrollRefreshKey.currentState?.show(atTop: atTop);
    }
  }

  /// 结束刷新, 在不指定[widgetState]状态的情况下.并自动根据[loadData].[stateData]切换至对应的状态
  /// [updateState] 用来触发界面刷新
  /// [allData] 当前所有的数据, 用来识别是否为空数据
  /// [loadData] 当前加载的数据, 用来识别是否无更多数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  /// [Exception]
  @callPoint
  @updateMark
  void finishRefresh([
    Iterable? loadData,
    dynamic stateData,
    WidgetBuildState? widgetState,
  ]) {
    //debugger();
    //stopScroll();
    WidgetBuildState toState =
        widgetState ??
        widgetStateIntercept.interceptorWidgetBuildState(
          requestPage,
          loadData,
          stateData,
        );

    if (refreshStateValue.value == .loading) {
      refreshStateValue.value = toState;
      _refreshCompleter.complete();
      _refreshCompleter = Completer();
    }
    if (requestPage.isFirstPage) {
      //jumpTo(0); //回到顶部
      updateAdapterState(toState, stateData);
    } else {
      updateLoadMoreState(toState, stateData);
    }
  }

  /// 更新情感图状态
  /// [buildAdapterStateWidget]
  /// @return true 表示状态更新成功
  @updateMark
  bool updateAdapterState(WidgetBuildState widgetState, [stateData]) {
    //debugger();
    if (adapterStateValue.value != widgetState) {
      _widgetStateData = stateData;
      adapterStateValue.value = widgetState;
      // 提前调用, 防止[_onRefreshStart]内有异步方法阻塞导致没有更新界面
      notifyRebuildScrollViewWidget();
      if (widgetState == .loading) {
        _onRefreshStart();
      }
      return true;
    } else {
      notifyRebuildScrollViewWidget();
      return false;
    }
  }

  /// 更新加载更多状态
  /// [buildLoadMoreStateWidget]
  @updateMark
  bool updateLoadMoreState(WidgetBuildState widgetState, [stateData]) {
    //debugger();
    //debugger(when: widgetState == .empty);
    final oldLoadMoreState = loadMoreStateValue.value;
    if (oldLoadMoreState != widgetState) {
      _widgetStateData = stateData;
      loadMoreStateValue.value = widgetState;
      //scrollViewUpdateSignal?.update();
      notifyRebuildLoadMoreWidget();
      if (widgetState == .loading) {
        _onLoadMoreStart();
      } else if (widgetState == .none) {
        requestPage.pageLoadEnd();
        notifyRebuildScrollViewWidget();
      } else if (widgetState == .empty) {
        //无加载更多了
        //debugger();
        requestPage.pageLoadEnd();
        if (oldLoadMoreState.isLoading) {
          notifyRebuildScrollViewWidget();
        }
      } else {
        assert(() {
          l.d("[${tag ?? debugLabel}]未处理的状态[$widgetState]");
          return true;
        }());
        debugger(when: widgetState != .error);
      }
      return true;
    } else {
      assert(() {
        l.d("[${tag ?? debugLabel}][$oldLoadMoreState]已是目标状态[$widgetState]!");
        return true;
      }());
    }
    return false;
  }

  /// 通知滚动布局重新构建
  /// - [notifyRebuildScrollViewWidget]
  /// - [notifyRebuildLoadMoreWidget]
  @api
  void notifyRebuildScrollViewWidget() {
    final signal = scrollViewUpdateSignal;
    if (signal == null) {
      assert(() {
        l.d("[${classHash()}]无法重建布局!");
        debugger();
        return true;
      }());
    } else {
      signal.update();
    }
  }

  /// 通知加载更多布局重新构建
  /// - [notifyRebuildScrollViewWidget]
  /// - [notifyRebuildLoadMoreWidget]
  @api
  void notifyRebuildLoadMoreWidget() {
    final WidgetStateBuildWidgetState? state = loadMoreKey.currentState;
    if (state == null) {
      assert(() {
        l.d("[${classHash()}]无法重建布局!");
        debugger();
        return true;
      }());
    } else {
      state.updateWidgetState(loadMoreStateValue.value, _widgetStateData);
      //state.updateState();
    }
  }

  /// 使用刷新布局包裹[child]
  /// [RefreshIndicator]
  /// [RScrollView.build]驱动
  @configProperty
  late WidgetWrapBuilder wrapRefreshWidget = (context, child) {
    //debugger();
    if (adapterStateValue.value.isLoading) {
      //如果情感图状态是加载中, 则不需要下拉刷新
      return child;
    }
    return RefreshIndicator(
      key: scrollRefreshKey,
      color: GlobalTheme.of(context).accentColor,
      onRefresh: _onRefresh,
      child: child,
    );
  };

  /// 为指定的[WidgetBuildState]状态, 注册指定的[Widget]
  /// [buildAdapterStateWidget]驱动
  final Map<WidgetBuildState, WidgetStateBuilder?> widgetStateBuilderMap = {};

  /// 情感图[Widget], 可以自定义
  /// 根据不同的状态, 构建不同的Widget
  /// [RScrollView.build]驱动
  @configProperty
  late WidgetStateBuilder buildAdapterStateWidget =
      (context, widgetState, stateData) {
        return widgetStateBuilderMap[widgetState]?.call(
              context,
              widgetState,
              stateData,
            ) ??
            AdapterStateWidget(
              widgetState: widgetState,
              stateData: stateData,
              requestChangeStateFn: (_, oldWidgetState, newWidgetState) {
                adapterStateValue.value = newWidgetState;
                if (newWidgetState == .loading) {
                  _onRefreshStart();
                }
                return false;
              },
            );
      };

  /// 为加载更多指定的[WidgetBuildState]状态, 注册指定的[Widget]
  /// [buildLoadMoreStateWidget]驱动
  final Map<WidgetBuildState, WidgetStateBuilder?> loadMoreStateBuilderMap = {};

  /// 加载更多[Widget], 可以自定义
  /// 根据不同的状态, 构建不同的Widget
  /// [_RScrollViewState._buildTileList]驱动
  @configProperty
  late WidgetStateBuilder buildLoadMoreStateWidget =
      (context, widgetState, stateData) {
        _isEnableLoadMore = true;
        return loadMoreStateBuilderMap[widgetState]?.call(
              context,
              widgetState,
              stateData,
            ) ??
            LoadMoreStateWidget(
              key: loadMoreKey,
              widgetState: widgetState,
              stateData: stateData,
              requestChangeStateFn: (context, oldWidgetState, newWidgetState) {
                loadMoreStateValue.value = newWidgetState;
                if (newWidgetState == .loading) {
                  _onLoadMoreStart();
                }
                return false;
              },
              onClick: () {
                if (loadMoreStateValue.value == .empty) {
                  //点击滚动到顶部
                  scrollToTop(anim: false);
                }
              },
            );
      };

  /// [RefreshIndicator]的刷新回调
  @property
  Future<void> _onRefresh() async {
    //debugger();
    if (refreshStateValue.value != .loading) {
      refreshStateValue.value = .loading;
      //这里要异步调用, 否则可能状态会被同步更改,
      //而导致没有等到await, 就结束了.
      delayCallback(() {
        _onRefreshStart();
      });
      await _refreshCompleter.future;
    }
  }

  /// 内部刷新处理开始处理
  /// 如果[_onRefreshStart]内部有异步方法
  /// [updateAdapterState]
  /// [buildAdapterStateWidget]
  /// [_onRefresh]
  @property
  void _onRefreshStart() {
    //debugger();
    loadMoreStateValue.value = .none;
    requestPage.pageRefresh();
    onRefreshCallback?.call();
    onLoadDataCallback?.call();
  }

  /// 内部刷新处理开始处理
  /// [updateLoadMoreState]
  @property
  void _onLoadMoreStart() {
    requestPage.pageLoadMore();
    onLoadMoreCallback?.call();
    onLoadDataCallback?.call();
  }
}

/// 情感图状态切换拦截
/// 可以继承[extends]也可以[implements]
class WidgetBuildStateIntercept {
  /// 获取可能的[WidgetBuildState]
  /// [requestPage] 请求的分页信息
  /// [loadData] 当前页加载到的数据, 非所有数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  WidgetBuildState interceptorWidgetBuildState(
    RequestPage requestPage,
    Iterable? loadData,
    dynamic stateData,
  ) {
    WidgetBuildState toState = .none;
    if (stateData is Exception) {
      toState = .error;
    } else {
      if (isNullOrEmpty(loadData)) {
        toState = .empty;
      } else if (loadData!.length < requestPage.requestPageSize) {
        if (requestPage.isFirstPage) {
          toState = .none;
        } else {
          toState = .empty;
        }
      } else {
        toState = .none;
      }
    }
    return toState;
  }
}

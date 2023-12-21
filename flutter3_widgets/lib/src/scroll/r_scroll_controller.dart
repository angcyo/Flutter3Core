part of flutter3_widgets;

/// 滚动控制, 刷新/加载更多控制, 情感图状态切换控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [Completer]
class RScrollController extends ScrollController {
  /// 请求的分页信息
  RequestPage requestPage = RequestPage();

  /// 用来控制刷新的key
  /// [RefreshIndicatorState]
  final GlobalKey<RefreshIndicatorState> scrollRefreshKey = GlobalKey();

  /// 用来控制加载更多的key
  final GlobalKey<WidgetStateWidgetState> loadMoreKey = GlobalKey();

  /// 用来控制刷新完成
  Completer<void> _refreshCompleter = Completer();

  /// 当前的刷新状态, 可以监听这个值的变化触发刷新
  /// [WidgetState]
  final ValueNotifier<WidgetState> refreshStateValue =
      ValueNotifier(WidgetState.none);

  /// 情感图的状态
  /// [WidgetState]
  final ValueNotifier<WidgetState> adapterStateValue =
      ValueNotifier(WidgetState.none);

  /// 加载更多的状态
  /// [WidgetState]
  final ValueNotifier<WidgetState> loadMoreStateValue =
      ValueNotifier(WidgetState.none);

  /// 状态对应的数据
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
  VoidCallback? onLoadDataCallback;

  RScrollController() {
    addListener(_listenerScrollPosition);
  }

  /// 监听滚动到底部,驱动触发加载更多
  void _listenerScrollPosition() {
    if (position.pixels >= position.maxScrollExtent) {
      //滚动到底部了
      if (_isEnableLoadMore) {
        if (loadMoreStateValue.value == WidgetState.loading) {
          //正在加载中...
        } else if (loadMoreStateValue.value == WidgetState.empty) {
          //没有更多数据了
        } else {
          loadMoreKey.currentState?.updateWidgetState(WidgetState.loading);
          updateLoadMoreState(loadMoreKey.currentState, WidgetState.loading);
        }
      }
    }
  }

  /// 释放资源
  @override
  void dispose() {
    super.dispose();
  }

  /// 滚动到顶部
  void scrollToTop({bool anim = true}) {
    if (anim) {
      animateTo(
        0,
        duration: kDefaultAnimationDuration,
        curve: Curves.easeOut,
      );
    } else {
      jumpTo(0);
    }
  }

  /// 滚动到底部
  void scrollToBottom({bool anim = true}) {
    if (anim) {
      animateTo(
        position.maxScrollExtent,
        duration: kDefaultAnimationDuration,
        curve: Curves.easeOut,
      );
    } else {
      jumpTo(position.maxScrollExtent);
    }
  }

  //---

  /// 开始触发刷新, 并显示刷新头
  /// [useWidgetState] 是否使用[widgetStateValue]来触发刷新, 否则使用刷新头
  /// [state] 用来触发界面刷新
  @callPoint
  void startRefresh({
    State? state,
    bool useWidgetState = false,
    bool atTop = true,
  }) {
    if (useWidgetState) {
      updateAdapterState(state, WidgetState.loading, null);
    } else {
      scrollRefreshKey.currentState?.show(atTop: atTop);
    }
  }

  /// 结束刷新, 在不指定[widgetState]状态的情况下.并自动根据[loadData].[stateData]切换至对应的状态
  /// [state] 用来触发界面刷新
  /// [allData] 当前所有的数据, 用来识别是否为空数据
  /// [loadData] 当前加载的数据, 用来识别是否无更多数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  /// [Exception]
  @callPoint
  void finishRefresh(
    State? state, [
    List? loadData,
    dynamic stateData,
    WidgetState? widgetState,
  ]) {
    //debugger();
    WidgetState toState = WidgetState.none;
    if (widgetState == null) {
      if (stateData is Exception) {
        toState = WidgetState.error;
      } else {
        if (loadData == null || loadData.isEmpty) {
          toState = WidgetState.empty;
        } else if (loadData.length < requestPage.requestPageSize) {
          if (requestPage.isFirstPage) {
            toState = WidgetState.none;
          } else {
            toState = WidgetState.empty;
          }
        } else {
          toState = WidgetState.none;
        }
      }
    } else {
      toState = widgetState;
    }

    if (refreshStateValue.value == WidgetState.loading) {
      refreshStateValue.value = toState;
      _refreshCompleter.complete();
      _refreshCompleter = Completer();
    }
    if (requestPage.isFirstPage) {
      //jumpTo(0); //回到顶部
      updateAdapterState(state, toState, stateData);
    } else {
      updateLoadMoreState(state, toState, stateData);
    }
  }

  /// 更新情感图状态
  /// [buildAdapterStateWidget]
  void updateAdapterState(State? state, WidgetState widgetState, [stateData]) {
    //debugger();
    if (adapterStateValue.value != widgetState) {
      _widgetStateData = stateData;
      adapterStateValue.value = widgetState;
      // 提前调用, 防止[_onRefreshStart]内有异步方法阻塞导致没有更新界面
      state?.updateState();
      if (widgetState == WidgetState.loading) {
        _onRefreshStart();
      }
    } else {
      state?.updateState();
    }
  }

  /// 更新加载更多状态
  /// [buildLoadMoreStateWidget]
  void updateLoadMoreState(State? state, WidgetState widgetState, [stateData]) {
    //debugger();
    if (loadMoreStateValue.value != widgetState) {
      _widgetStateData = stateData;
      loadMoreStateValue.value = widgetState;
      state?.updateState();
      if (widgetState == WidgetState.loading) {
        _onLoadMoreStart();
      } else if (widgetState == WidgetState.none) {
        requestPage.pageLoadEnd();
      }
    }
  }

  /// 使用刷新布局包裹[child]
  late WidgetWrapBuilder wrapRefreshWidget = (context, child) {
    //debugger();
    if (adapterStateValue.value == WidgetState.loading) {
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

  /// 情感图[Widget]
  /// 根据不同的状态, 构建不同的Widget
  late WidgetStateBuilder buildAdapterStateWidget =
      (context, widgetState, stateData) {
    return AdapterStateWidget(
      widgetState: widgetState,
      stateData: stateData,
      requestChangeStateFn: (_, oldWidgetState, newWidgetState) {
        adapterStateValue.value = newWidgetState;
        if (newWidgetState == WidgetState.loading) {
          _onRefreshStart();
        }
        return false;
      },
    );
  };

  /// 加载更多[Widget]
  /// 根据不同的状态, 构建不同的Widget
  late WidgetStateBuilder buildLoadMoreStateWidget =
      (context, widgetState, stateData) {
    _isEnableLoadMore = true;
    return LoadMoreStateWidget(
      key: loadMoreKey,
      widgetState: widgetState,
      stateData: stateData,
      requestChangeStateFn: (context, oldWidgetState, newWidgetState) {
        loadMoreStateValue.value = newWidgetState;
        if (newWidgetState == WidgetState.loading) {
          _onLoadMoreStart();
        }
        return false;
      },
    );
  };

  /// [RefreshIndicator]的刷新回调
  Future<void> _onRefresh() async {
    if (refreshStateValue.value != WidgetState.loading) {
      _onRefreshStart();
      refreshStateValue.value = WidgetState.loading;
      await _refreshCompleter.future;
    }
  }

  /// 内部刷新处理开始处理
  /// 如果[_onRefreshStart]内部有异步方法
  void _onRefreshStart() {
    loadMoreStateValue.value = WidgetState.none;
    requestPage.pageRefresh();
    onRefreshCallback?.call();
    onLoadDataCallback?.call();
  }

  /// 内部刷新处理开始处理
  void _onLoadMoreStart() {
    requestPage.pageLoadMore();
    onLoadMoreCallback?.call();
    onLoadDataCallback?.call();
  }
}
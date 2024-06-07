part of '../../flutter3_widgets.dart';

/// 滚动控制, 刷新/加载更多控制, 情感图状态切换控制
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/08
///

/// [Completer]
class RScrollController extends ScrollController {
  /// 用来控制刷新的key
  /// [RefreshIndicatorState]
  final GlobalKey<RefreshIndicatorState> scrollRefreshKey = GlobalKey();

  /// 用来控制加载更多的key
  final GlobalKey<WidgetStateWidgetState> loadMoreKey = GlobalKey();

  /// 用来控制刷新完成
  /// [_onRefresh]
  /// [finishRefresh]
  Completer<void> _refreshCompleter = Completer();

  /// 当前的刷新状态, 可以监听这个值的变化触发刷新
  /// [WidgetBuildState]
  final ValueNotifier<WidgetBuildState> refreshStateValue =
      ValueNotifier(WidgetBuildState.none);

  /// 情感图的状态
  /// [WidgetBuildState]
  final ValueNotifier<WidgetBuildState> adapterStateValue =
      ValueNotifier(WidgetBuildState.preLoading);

  /// 加载更多的状态
  /// [WidgetBuildState]
  final ValueNotifier<WidgetBuildState> loadMoreStateValue =
      ValueNotifier(WidgetBuildState.none);

  /// 请求的分页信息
  RequestPage requestPage = RequestPage();

  /// 情感图状态拦截
  WidgetStateIntercept widgetStateIntercept = WidgetStateIntercept();

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
  /// [_onRefreshStart]
  /// [_onLoadMoreStart]
  VoidCallback? onLoadDataCallback;

  RScrollController();

  /// 检查滚动位置
  /// 监听滚动到底部,驱动触发加载更多
  void _checkScrollPosition() {
    //debugger();
    if (!position.isScrollingNotifier.value /*没有在滚动*/ &&
        position.hasContentDimensions /*具有内容的尺寸信息*/ &&
        position.pixels >= position.maxScrollExtent /*到底了*/) {
      //滚动到底部了
      if (adapterStateValue.value != WidgetBuildState.none) {
        //debugger();
        assert(() {
          l.d("情感图状态不是[none], 忽略滚动监听.");
          return true;
        }());
      } else if (_isEnableLoadMore) {
        //debugger();
        if (refreshStateValue.value == WidgetBuildState.loading) {
          assert(() {
            l.d("正在刷新中...忽略加载更多处理.");
            return true;
          }());
        } else if (loadMoreStateValue.value == WidgetBuildState.loading) {
          //正在加载中...
          //l.d("正在加载中...忽略加载更多处理.");
        } else if (loadMoreStateValue.value == WidgetBuildState.empty) {
          //没有更多数据了
          assert(() {
            l.d("没有更多数据了...忽略加载更多处理.");
            return true;
          }());
        } else {
          loadMoreKey.currentState?.updateWidgetState(WidgetBuildState.loading);
          updateLoadMoreState(
              loadMoreKey.currentState, WidgetBuildState.loading);
        }
      }
    }
  }

  @override
  void attach(ScrollPosition position) {
    //debugger();
    addListener(_checkScrollPosition);
    position.isScrollingNotifier.addListener(_checkScrollPosition);
    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    //debugger();
    removeListener(_checkScrollPosition);
    position.isScrollingNotifier.removeListener(_checkScrollPosition);
    super.detach(position);
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

  /// 停止滚动
  void stopScroll() {
    position.didEndScroll();
  }

  //---

  /// 开始触发刷新, 并显示刷新头
  /// [useWidgetState] 是否使用[widgetStateValue]来触发刷新, 否则使用刷新头
  /// [state] 用来触发界面刷新
  @callPoint
  @updateMark
  void startRefresh({
    State? state,
    bool useWidgetState = false,
    bool atTop = true,
  }) {
    if (useWidgetState) {
      updateAdapterState(state, WidgetBuildState.loading, null);
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
  void finishRefresh(
    State? updateState, [
    List? loadData,
    dynamic stateData,
    WidgetBuildState? widgetState,
  ]) {
    //debugger();
    //stopScroll();
    WidgetBuildState toState = widgetState ??
        widgetStateIntercept.interceptor(
          requestPage,
          loadData,
          stateData,
        );

    if (refreshStateValue.value == WidgetBuildState.loading) {
      refreshStateValue.value = toState;
      _refreshCompleter.complete();
      _refreshCompleter = Completer();
    }
    if (requestPage.isFirstPage) {
      //jumpTo(0); //回到顶部
      updateAdapterState(updateState, toState, stateData);
    } else {
      updateLoadMoreState(updateState, toState, stateData);
    }
  }

  /// 更新情感图状态
  /// [buildAdapterStateWidget]
  /// @return true 表示状态更新成功
  @updateMark
  bool updateAdapterState(State? state, WidgetBuildState widgetState,
      [stateData]) {
    //debugger();
    if (adapterStateValue.value != widgetState) {
      _widgetStateData = stateData;
      adapterStateValue.value = widgetState;
      // 提前调用, 防止[_onRefreshStart]内有异步方法阻塞导致没有更新界面
      state?.updateState();
      if (widgetState == WidgetBuildState.loading) {
        _onRefreshStart();
      }
      return true;
    } else {
      state?.updateState();
      return false;
    }
  }

  /// 更新加载更多状态
  /// [buildLoadMoreStateWidget]
  @updateMark
  bool updateLoadMoreState(State? state, WidgetBuildState widgetState,
      [stateData]) {
    //debugger();
    if (loadMoreStateValue.value != widgetState) {
      _widgetStateData = stateData;
      loadMoreStateValue.value = widgetState;
      state?.updateState();
      if (widgetState == WidgetBuildState.loading) {
        _onLoadMoreStart();
      } else if (widgetState == WidgetBuildState.none) {
        requestPage.pageLoadEnd();
      }
      return true;
    }
    return false;
  }

  /// 使用刷新布局包裹[child]
  /// [RefreshIndicator]
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

  /// 情感图[Widget]
  /// 根据不同的状态, 构建不同的Widget
  @configProperty
  late WidgetStateBuilder buildAdapterStateWidget =
      (context, widgetState, stateData) {
    return AdapterStateWidget(
      widgetState: widgetState,
      stateData: stateData,
      requestChangeStateFn: (_, oldWidgetState, newWidgetState) {
        adapterStateValue.value = newWidgetState;
        if (newWidgetState == WidgetBuildState.loading) {
          _onRefreshStart();
        }
        return false;
      },
    );
  };

  /// 加载更多[Widget]
  /// 根据不同的状态, 构建不同的Widget
  @configProperty
  late WidgetStateBuilder buildLoadMoreStateWidget =
      (context, widgetState, stateData) {
    _isEnableLoadMore = true;
    return LoadMoreStateWidget(
      key: loadMoreKey,
      widgetState: widgetState,
      stateData: stateData,
      requestChangeStateFn: (context, oldWidgetState, newWidgetState) {
        loadMoreStateValue.value = newWidgetState;
        if (newWidgetState == WidgetBuildState.loading) {
          _onLoadMoreStart();
        }
        return false;
      },
    );
  };

  /// [RefreshIndicator]的刷新回调
  @property
  Future<void> _onRefresh() async {
    //debugger();
    if (refreshStateValue.value != WidgetBuildState.loading) {
      refreshStateValue.value = WidgetBuildState.loading;
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
    loadMoreStateValue.value = WidgetBuildState.none;
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

/// 情感图状态拦截
class WidgetStateIntercept {
  /// 获取可能的[WidgetBuildState]
  /// [requestPage] 请求的分页信息
  /// [loadData] 当前页加载到的数据, 非所有数据
  /// [stateData] 当前状态的附加信息, 用来识别是否有错误
  WidgetBuildState interceptor(
    RequestPage requestPage,
    List? loadData,
    dynamic stateData,
  ) {
    WidgetBuildState toState = WidgetBuildState.none;
    if (stateData is Exception) {
      toState = WidgetBuildState.error;
    } else {
      if (isNullOrEmpty(loadData)) {
        toState = WidgetBuildState.empty;
      } else if (loadData!.length < requestPage.requestPageSize) {
        if (requestPage.isFirstPage) {
          toState = WidgetBuildState.none;
        } else {
          toState = WidgetBuildState.empty;
        }
      } else {
        toState = WidgetBuildState.none;
      }
    }
    return toState;
  }
}

extension ScrollControllerEx on ScrollController {
  /// 滚动到底部
  void scrollToBottom({bool anim = true}) {
    if (!hasClients) {
      return;
    }
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

  /// 停止滚动
  void stopScroll() {
    position.didEndScroll();
  }
}

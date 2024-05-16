part of '../../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/30
///
/// 混入一个带有状态切换的滚动页面, 比如不同的分类列表页面
/// [RScrollView]
/// [AbsScrollPage]
/// [RScrollPage]
/// [RStatusScrollPage]
mixin RStatusScrollPage<T extends StatefulWidget> on RScrollPage<T> {
  /// 所有状态集合
  List<StatusInfo> statusInfoList = [];

  /// 当前的状态
  StatusInfo? currentStatusInfo;

  /// 获取所有状态的数据
  List<T> getStatusDataList<T>() =>
      statusInfoList.map((e) => e.status as T?).filterNull();

  /// 判断[status]是否是当前选中的状态
  bool isCurrentStatus(dynamic status) => currentStatusInfo?.status == status;

  /// 动态数据[status]转换成[StatusInfo]数据
  StatusInfo? getStatusInfo(dynamic status) => status is StatusInfo
      ? status
      : statusInfoList.firstWhereOrNull((element) => element.status == status);

  @override
  void onLoadData() {
    if (isNullOrEmpty(statusInfoList)) {
      onLoadStatusList();
    } else {
      startLoadStatusData(currentStatusInfo);
    }
  }

  @private
  @override
  void loadDataEnd(List? loadData, [stateData, bool handleData = true]) {
    super.loadDataEnd(loadData, stateData, handleData);
  }

  //region 状态控制

  /// 加载状态列表
  @overridePoint
  void onLoadStatusList();

  /// 加载状态对应的数据
  /// 加载结束之后, 请调用[loadStatusDataEnd]方法
  @overridePoint
  void onLoadStatusData(dynamic status);

  @api
  @updateMark
  void loadStatusDataEnd(
    dynamic status,
    List? loadData, [
    dynamic stateData,
    bool handleData = true,
  ]) {
    StatusInfo? statusInfo =
        statusInfoList.firstWhereOrNull((element) => element.status == status);
    if (statusInfo != null) {
      if (statusInfo == currentStatusInfo) {
        //状态一致, 走默认处理即可
        loadDataEnd(loadData, stateData, handleData);
        updateState(); //更新状态
      } else {
        //状态不一致, 比如切换到其他类型了.
        if (handleData) {
          if (loadData is WidgetList) {
            if (statusInfo.requestPage.isFirstPage) {
              statusInfo.pageWidgetList.clear();
            }
            pageWidgetList.addAll(loadData);
          }
        }
        statusInfo.loadMoreWidgetState =
            scrollController.widgetStateIntercept.interceptor(
          statusInfo.requestPage,
          loadData,
          stateData,
        );
      }
    }
  }

  /// 切换当前的状态
  /// [status] 支持[StatusInfo]类型, 和自定义类型
  /// [forceLoad] 是否要强制请求加载
  /// [currentStatusInfo]
  /// [statusInfoList]
  @api
  @updateMark
  void switchStatus(dynamic status, {bool forceLoad = false}) {
    //debugger();
    StatusInfo? statusInfo = getStatusInfo(status);

    //save old status
    if (currentStatusInfo != null && currentStatusInfo != statusInfo) {
      currentStatusInfo?.pageWidgetList = pageWidgetList;
      currentStatusInfo?.requestPage = scrollController.requestPage;
      currentStatusInfo?.loadMoreWidgetState =
          scrollController.loadMoreStateValue.value;
    }
    //load new status
    currentStatusInfo = statusInfo;

    if (statusInfo == null) {
      //切换到了一个空的状态时
      updateAdapterState(WidgetBuildState.empty);
    } else {
      pageWidgetList = statusInfo.pageWidgetList;
      scrollController.requestPage = statusInfo.requestPage;
      scrollController.loadMoreStateValue.value =
          statusInfo.loadMoreWidgetState;

      var loadData = forceLoad /*|| !statusInfo.requestPage.isCurrentPage*/;
      if (isNullOrEmpty(pageWidgetList) ||
          statusInfo.requestPage.isFirstPage && forceLoad) {
        //切换到一个没有数据, 或者第一页的状态时, 需要重新加载数据
        if (!updateAdapterState(WidgetBuildState.loading) /*情感图会触发刷新回调 */) {
          //可能是相同情感图状态, 则需要手动触发加载数据
          onLoadStatusData(statusInfo.status);
        }
      } else if (loadData) {
        // 加载数据
        onLoadStatusData(statusInfo.status);
      } else {
        //直接显示内容
        updateAdapterState(WidgetBuildState.none);
      }
    }
  }

  /// 调用此方法, 开始加载状态列表
  /// [status] 支持[StatusInfo]类型, 和自定义类型
  /// [statusInfoList]
  @updateMark
  void startLoadStatusData(dynamic status) {
    StatusInfo? statusInfo = getStatusInfo(status);
    if (statusInfo != null) {
      onLoadStatusData(statusInfo.status);
    }
  }

  /// 调用此方法, 更新状态列表
  /// [stateData] 用来识别是否有错误
  /// [loadDataEnd]
  @callPoint
  @updateMark
  void loadStatusEnd(dynamic statusList, dynamic stateData) {
    // 错误处理
    if (stateData is Exception) {
      updateAdapterState(WidgetBuildState.error, stateData);
      return;
    }
    //状态数据处理
    statusInfoList.clear();
    for (var element in statusList) {
      statusInfoList.add(StatusInfo()..status = element);
    }
    if (currentStatusInfo != null) {
      if (!statusInfoList.contains(currentStatusInfo)) {
        currentStatusInfo = statusInfoList.firstOrNull;
      }
    }
    //默认选中第一个
    final oldIsNullOrEmpty = isNullOrEmpty(currentStatusInfo);
    currentStatusInfo ??= statusInfoList.firstOrNull;
    switchStatus(currentStatusInfo, forceLoad: oldIsNullOrEmpty);
  }

//endregion 状态控制
}

/// 当前页面的请求状态信息
class StatusInfo {
  /// 当前的状态, 自定义的状态, 比如分类的数据结构
  dynamic status;

  /// 当前状态的分页请求信息
  RequestPage requestPage = RequestPage();

  /// 当前状态已加载的小部件信息
  WidgetList pageWidgetList = [];

  /// 当前状态的加载更多状态
  WidgetBuildState loadMoreWidgetState = WidgetBuildState.none;
}

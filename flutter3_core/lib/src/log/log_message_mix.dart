import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/01
///
/// 日志消息状态页面混入
///
/// - [buildLogMessageListWidget] log对话样式
/// - [buildLogDataListWidget] 日志列表样式
/// - [addLastMessage]
mixin LogMessageStateMixin<T extends StatefulWidget> on State<T> {
  //MARK: - init

  @override
  void initState() {
    super.initState();
    autoScrollToBottom();
  }

  //MARK: - scroll

  //region 滚动体列表

  /// 是否自动滚动到底部
  final scrollToBottomLive = $live(true);

  bool get isScrollToBottom => scrollToBottomLive.value == true;

  set isScrollToBottom(bool value) {
    scrollToBottomLive <= value;
  }

  /// 滚动列表
  late final ScrollController logScrollController = ScrollController();
  late final List<LogScopeData> logDataList = [LogScopeData.message("欢迎访问!")];

  /// 过滤后的日志数据列表
  @api
  List<LogScopeData> filterLogDataList({
    String? filterType,
    String? filterContent,
  }) {
    final list = logDataList.filter(
      (e) =>
          (e.filterTypeList?.contains(filterType) == true ||
              isNil(filterType)) &&
          (isNil(filterContent) || e.content.contains(filterContent!) == true),
    );
    return list;
  }

  /// 构建消息类型列表小部件
  /// - 对话的样式
  @callPoint
  Widget buildLogMessageListWidget(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return ListView.builder(
      physics: kScrollPhysics,
      controller: logScrollController,
      itemBuilder: (context, index) {
        final item = logDataList.getOrNull(index);
        return item == null
            ? null
            : [
                item.time.text(
                  style: globalTheme.textDesStyle,
                  selectable: true,
                ),
                item.content.limit().text(
                  selectable: true,
                  textAlign: item.isReceived ? .start : .end,
                ),
              ].column(
                crossAxisAlignment: item.isReceived ? .start : .end,
              ) /*?.bounds()*/;
      },
    ).paddingOnly(all: kL);
  }

  /// 构建日志类型列表小部件
  /// - 纯列表形式
  /// - [filterType] 筛选类型
  /// - [filterContent] 过滤内容
  @callPoint
  Widget buildLogDataListWidget(
    BuildContext context,
    GlobalTheme globalTheme, {
    String? filterType,
    String? filterContent,
  }) {
    final list = filterLogDataList(
      filterType: filterType,
      filterContent: filterContent,
    );
    return ListView.builder(
      physics: kScrollPhysics,
      controller: logScrollController,
      itemBuilder: (context, index) {
        final item = list.getOrNull(index);
        return item == null
            ? null
            : [
                item.time.text(
                  style: globalTheme.textDesStyle,
                  selectable: true,
                ),
                item.content.limit().text(
                  selectable: true,
                  textColor: item.color,
                ),
              ].column(crossAxisAlignment: .start) /*?.bounds()*/;
      },
    ).paddingOnly(all: kL);
  }

  /// 添加一条记录消息, 并且滚动到底部
  @api
  void addLastMessage(String? message, {bool isReceived = false}) {
    //debugger(when: isReceived);
    if (message == null) {
      return;
    }
    logDataList.add(LogScopeData.message(message, isReceived: isReceived));
    updateState();
    autoScrollToBottom();
  }

  /// 添加一条日志记录, 并且滚动到底部
  @api
  void addLastLog(String? log, {String? filterType, bool isReceived = false}) {
    //debugger(when: isReceived);
    if (log == null) {
      return;
    }
    logDataList.add(
      LogScopeData.log(
        log,
        filterTypeList: [?filterType],
        isReceived: isReceived,
      ),
    );
    updateState();
    autoScrollToBottom();
  }

  /// 添加多条日志记录, 滚动到底部
  /// - [reset] 是否是重置?
  @api
  void addLogDatList(List<LogScopeData> logDataList, {bool? reset}) {
    if (reset == true) {
      this.logDataList.resetAll(logDataList);
    } else {
      this.logDataList.addAll(logDataList);
    }
    updateState();
    autoScrollToBottom();
  }

  /// 清除所有数据
  @api
  void clearLogData() {
    logDataList.clear();
    updateState();
  }

  /// 自动滚到到底部
  @api
  void autoScrollToBottom() {
    if (isScrollToBottom) {
      postFrame(() {
        logScrollController.scrollToBottom();
      });
    }
  }

  //endregion 滚动体列表
}

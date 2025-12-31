import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/01
///
/// 日志消息状态页面混入
///
/// - [buildLogMessageListWidget]
/// - [addLastMessage]
mixin LogMessageStateMixin<T extends StatefulWidget> on State<T> {
  //MARK: - init

  @override
  void initState() {
    super.initState();
    postFrame(() {
      scrollController.scrollToBottom();
    });
  }

  //MARK: - scroll

  //region 滚动体列表

  /// 滚动列表
  late final ScrollController scrollController = ScrollController();
  late final List<LogScopeData> logDataList = [LogScopeData.message("欢迎访问!")];

  /// 构建消息类型列表小部件
  /// - 对话的样式
  @callPoint
  Widget buildLogMessageListWidget(
    BuildContext context,
    GlobalTheme globalTheme,
  ) {
    return ListView.builder(
      physics: kScrollPhysics,
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = logDataList.getOrNull(index);
        return item == null
            ? null
            : [
                item.time.text(
                  style: globalTheme.textDesStyle,
                  selectable: true,
                ),
                item.content.text(
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
    final list = logDataList.filter(
      (e) =>
          (e.filterTypeList?.contains(filterType) == true ||
              isNil(filterType)) &&
          (isNil(filterContent) || e.content.contains(filterContent!) == true),
    );
    return ListView.builder(
      physics: kScrollPhysics,
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = list.getOrNull(index);
        return item == null
            ? null
            : [
                item.time.text(
                  style: globalTheme.textDesStyle,
                  selectable: true,
                ),
                item.content.text(selectable: true),
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
    postFrame(() {
      scrollController.scrollToBottom();
    });
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
    postFrame(() {
      scrollController.scrollToBottom();
    });
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
    postFrame(() {
      scrollController.scrollToBottom();
    });
  }

  /// 清除所有数据
  @api
  void clearLogData() {
    logDataList.clear();
    updateState();
  }

  //endregion 滚动体列表
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/30
///
/// - [LogScopeData] 日志数据
/// - [LogScopeController] 日志面板控制器
/// - [LogScope] 用来提供[LogScopeController]
/// - [LogPanelContainer] 用来承载[LogScope]

/// 日志数据
/// - [LogScopeController]
class LogScopeData {
  /// 日志的内容
  final String content;

  @tempFlag
  Color? _color;

  /// 获取内容匹配到的颜色
  Color? get color {
    if (_color != null) {
      return _color;
    }
    if (content.have(".*E->.*")) {
      _color = const Color(0xffCC666E);
    } else if (content.have(".*W->.*")) {
      _color = const Color(0xffE2B507);
    } else if (content.have(".*I->.*")) {
      _color = const Color(0xff3BDE09);
    } else if (content.have(".*D->.*")) {
      _color = const Color(0xff299999);
    } else if (content.have(".*V->.*")) {
      _color = const Color(0xff5394EC);
    } else if (content.have(".*T->.*")) {
      _color = const Color(0xFF9C27B0);
    }
    return _color;
  }

  //MARK: -

  /// 消息的时间, 13位毫秒时间戳
  final int timestamp;

  String get time => timestamp.toTimeString("yyyy-MM-dd HH:mm:ss.SSS");

  //MARK: -

  /// 用于过滤的类型
  final List<String>? filterTypeList;

  /// 是否是接收到的数据
  final bool isReceived;

  /// 消息类型的日志
  LogScopeData.message(
    this.content, {
    this.filterTypeList,
    this.isReceived = false,
  }) : timestamp = nowTimestamp();

  /// 日志类型
  LogScopeData.log(this.content, {this.filterTypeList, this.isReceived = false})
    : timestamp = nowTimestamp();
}

/// 控制器
/// - 用来控制显示和隐藏日志面板[LogPanelContainer]
/// - 显示之后, 用来收集日志并刷新日志面板
class LogScopeController {
  LogScopeController();

  //MARK: - config

  /// 日志数据最大数量
  @configProperty
  int logMaxCount = 100;

  /// 是否显示日志面板
  @configProperty
  final isShowPanelLive = $live(false);

  /// 是否暂停接收日志
  @configProperty
  final isPauseLogLive = $live(false);

  /// 日志数据列表
  @configProperty
  final logDataListLive = $live<List<LogScopeData>>([]);

  /// 过滤列表缓存
  /// - 防止跳动
  @tempFlag
  final List<String> _filterTypeList = [];

  /// 过滤类型列表
  @output
  List<String> get filterTypeList {
    final set = <String>{..._filterTypeList};
    for (final logData in logDataListLive.value ?? <LogScopeData>[]) {
      for (final filterType in logData.filterTypeList ?? <String>[]) {
        if (filterType.isNotEmpty) {
          set.add(filterType);
        }
      }
    }
    final list = set.toList();
    _filterTypeList.resetAll(list);
    return list;
  }

  //MARK: - api

  /// 开关显示日志面板
  @api
  void togglePanel() {
    isShowPanelLive <= !(isShowPanelLive.value == true);
    if (isShowPanelLive.value == true) {
      //op
    } else {
      //关闭日志时, 清空数据
      logDataListLive << [];
      assert(() {
        debugger();
        return true;
      }());
    }
  }

  /// 添加日志数据
  @api
  void addLogData(LogScopeData log) {
    if (isShowPanelLive.value == true && isPauseLogLive.value != true) {
      final list = logDataListLive.value ?? [];
      list.add(log);
      while (list.length > logMaxCount) {
        list.removeAt(0);
      }
      logDataListLive << list;
    }
  }
}

/// 日志域, 用来显示日志面板
/// - [LogScopeController]
class LogScope extends InheritedWidget {
  /// 日志过滤类型
  /// - http 请求
  static const String kHttp = "http";

  /// - 错误类型
  static const String kError = "error";

  /// - 请求类型 / 设备请求
  static const String kRequest = "request";

  /// - 通道类型
  static const String kChannel = "channel";

  @api
  static LogScopeController? get(BuildContext? context, {bool depend = false}) {
    if (depend) {
      return context?.dependOnInheritedWidgetOfExactType<LogScope>()?.control;
    } else {
      return context?.getInheritedWidgetOfExactType<LogScope>()?.control;
    }
  }

  //MARK:  -

  final LogScopeController? control;

  const LogScope({super.key, required this.control, required super.child});

  @override
  bool updateShouldNotify(covariant LogScope oldWidget) =>
      control != oldWidget.control;
}

/// [LogScopeController]的全局实例
@globalInstance
final $logController = LogScopeController();

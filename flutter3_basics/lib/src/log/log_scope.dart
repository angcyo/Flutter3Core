import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_basics/flutter3_basics.dart' hide ContextAction;

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

  //MARK: -

  /// 消息的时间, 13位毫秒时间戳
  final int timestamp;

  String get time => timestamp.toTimeString("yyyy-MM-dd HH:mm:ss.SSS");

  //MARK: -

  /// 用于过滤的类型
  final String? filterType;

  /// 是否是接收到的数据
  final bool isReceived;

  /// 消息类型的日志
  LogScopeData.message(this.content, {this.filterType, this.isReceived = false})
    : timestamp = nowTimestamp();

  /// 日志类型
  LogScopeData.log(this.content, {this.filterType, this.isReceived = false})
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
  final showPanelLive = $live(false);

  /// 日志数据列表
  @configProperty
  final logDataListLive = $live<List<LogScopeData>>([]);

  //MARK: - api

  /// 开关显示日志面板
  @api
  void togglePanel() {
    showPanelLive <= !(showPanelLive.value == true);
    if (showPanelLive.value == true) {
      //op
    } else {
      //关闭日志时, 清空数据
      logDataListLive << [];
    }
  }

  /// 添加日志数据
  @api
  void addLogData(LogScopeData log) {
    if (showPanelLive.value == true) {
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

/// 日志面板布局
class LogPanelContainer extends StatefulWidget {
  /// 控制器
  final LogScopeController? control;

  /// 显示内容
  final Widget child;

  const LogPanelContainer({super.key, this.control, required this.child});

  @override
  State<LogPanelContainer> createState() => _LogPanelContainerState();
}

class _LogPanelContainerState extends State<LogPanelContainer>
    with WidgetsBindingObserver, MediaQueryDataChangeMixin {
  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return LogScope(
              control: widget.control,
              child:
                  widget.control?.showPanelLive.build((ctx, showPanel) {
                    return showPanel
                        ? [
                            widget.child.expanded(),
                            LogPanelWidget(control: widget.control),
                          ].row()
                        : widget.child;
                  }) ??
                  widget.child,
            );
          },
        ),
      ],
    );
  }
}

/// 日志信息面板
class LogPanelWidget extends StatefulWidget {
  final LogScopeController? control;

  const LogPanelWidget({super.key, this.control});

  @override
  State<LogPanelWidget> createState() => _LogPanelWidgetState();
}

class _LogPanelWidgetState extends State<LogPanelWidget>
    with HookMixin, HookStateMixin, LogMessageStateMixin {
  @override
  void initState() {
    hookAny(
      widget.control?.logDataListLive.listen((data) {
        if (data != null && !isNil(data)) {
          addLogDatList(data, reset: true);
        }
      }, allowBackward: false),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return buildLogDataListWidget(context, globalTheme)
        .animatedContainer(width: $ecwBp())
        .material(color: globalTheme.surfaceBgColor);
  }
}

//MARK: - Shortcut

class LogPanelIntent extends Intent {
  final LogScopeController? control;

  const LogPanelIntent(this.control);
}

class LogPanelIntentAction extends ContextAction<LogPanelIntent> {
  @override
  Object? invoke(LogPanelIntent intent, [BuildContext? context]) {
    intent.control?.togglePanel();
    return intent;
  }
}

/// 扩展
extension LogPanelWidgetEx on Widget {
  /// 使用一个日志面板包裹
  Widget wrapLogPanel({LogScopeController? control}) {
    control ??= $logController;
    final child = LogPanelContainer(control: control, child: this);
    if (isDesktopOrWeb) {
      return child.shortcutActions([
        ShortcutAction(
          intent: LogPanelIntent(control),
          shortcut: SingleActivator(LogicalKeyboardKey.f12),
          action: LogPanelIntentAction(),
        ),
      ]);
    }
    return child;
  }
}

/// [LogScopeController]的全局实例
@globalInstance
final $logController = LogScopeController();

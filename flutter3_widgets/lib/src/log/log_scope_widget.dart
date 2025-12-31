import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_basics/flutter3_basics.dart' hide ContextAction;
import 'package:flutter3_widgets/flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/30
///
/// - [LogScopeData] 日志数据
/// - [LogScopeController] 日志面板控制器
/// - [LogScope] 用来提供[LogScopeController]
/// - [LogPanelContainer] 用来承载[LogScope]
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
    return SimpleApp(
      home:
          widget.control?.showPanelLive.build((ctx, showPanel) {
            return showPanel
                ? [
                    widget.child.expanded(),
                    //MARK: - app
                    LogPanelWidget(control: widget.control),
                  ].row()
                : widget.child;
          }) ??
          widget.child,
    );
    /*return LogScope(
      control: widget.control,
      child:
          widget.control?.showPanelLive.build((ctx, showPanel) {
            return showPanel
                ? [
                    widget.child.expanded(),
                    //MARK: - app
              */ /*LogPanelWidget(control: widget.control)*/ /*
                    SimpleApp(home: LogPanelWidget(control: widget.control)),
                  ].row()
                : widget.child;
          }) ??
          widget.child,
    );*/
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
  /// 过滤所有, 显示时使用 `All` 字符串
  static const kAll = "";

  /// 选中的过滤类型
  @configProperty
  String selectedFilterType = kAll;

  /// 需要过滤的内容
  @configProperty
  String filterContent = "";

  /// 过滤类型列表
  List<String> get filterTypeList => [kAll, ...?widget.control?.filterTypeList];

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
    return [
          buildHeaderTabWidget(context, globalTheme),
          buildInputFilterWidget(context, globalTheme),
          buildLogFilterWidget(context, globalTheme),
          Divider(height: 1),
          buildLogDataListWidget(
            context,
            globalTheme,
            filterType: selectedFilterType,
            filterContent: filterContent,
          ).expanded(),
        ]
        .column()!
        .animatedContainer(width: $ecwBp())
        .material(color: globalTheme.surfaceBgColor);
  }

  //MARK: - build

  /// 构建头部标签
  Widget buildHeaderTabWidget(BuildContext context, GlobalTheme globalTheme) {
    return [
      "LOG".text().insets(h: kX, v: kH).decoration(underlineDecoration()),
    ].row()!;
  }

  /// 构建输入过滤标签
  Widget buildInputFilterWidget(BuildContext context, GlobalTheme globalTheme) {
    return BorderSingleInputWidget(
      hintText: "过滤内容",
      maxLines: 1,
      maxLength: 100,
      text: filterContent,
      onChanged: (text) {
        filterContent = text;
        updateState();
      },
    );
  }

  /// 构建Log过滤
  Widget buildLogFilterWidget(BuildContext context, GlobalTheme globalTheme) {
    final radius = kDefaultBorderRadiusXX;
    return [
          for (final filterType in filterTypeList)
            (filterType == "" ? "All" : filterType)
                .text()
                .insets(h: kX, v: kM)
                .decoration(
                  selectedFilterType == filterType
                      ? fillDecoration(
                          color: globalTheme.lineColor,
                          radius: radius,
                        )
                      : strokeDecoration(
                          color: globalTheme.lineColor,
                          radius: radius,
                        ),
                )
                .inkWell(
                  selectedFilterType == filterType
                      ? null
                      : () {
                          setState(() {
                            selectedFilterType = filterType;
                          });
                        },
                  borderRadius: radius.borderRadius,
                ),
        ]
        .wrap()!
        .constrainedMax(minWidth: double.infinity)
        .insets(all: kM) /*.bounds()*/;
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

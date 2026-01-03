import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_basics/flutter3_basics.dart' hide ContextAction;
import 'package:flutter3_widgets/flutter3_widgets.dart';

import '../../assets_generated/assets.gen.dart';
import '../../flutter3_core.dart'
    show
        loadCoreAssetSvgPicture,
        fileFolder,
        cacheFolder,
        DebugFileListWidget,
        DebugFilePage;
import 'log_message_mix.dart';

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
  //MARK: - folder

  /// 文件文件夹
  @configProperty
  String? fileFolderPath;

  /// 缓存文件夹
  @configProperty
  String? cacheFolderPath;

  @override
  void initState() {
    fileFolder().then((value) {
      fileFolderPath = value.path;
    });
    cacheFolder().then((value) {
      cacheFolderPath = value.path;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    return SimpleApp(
      home:
          widget.control?.isShowPanelLive.build((ctx, showPanel) {
            return showPanel
                ? [
                    widget.child.expanded(),
                    //MARK: - app
                    buildPanelApp(context, globalTheme),
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

  //MARK : panel app

  /// 标签页集合
  late List<TabEntryInfo>? tabEntryList = [
    TabEntryInfo(
      tabInfo: LogPanelTabData(title: "Log"),
      fixed: true,
      tabBuilder: (ctx, child, index, data, isSelected) {
        return [
          "日志"
              .text()
              .insets(h: kX, v: kH)
              .decoration(isSelected == true ? underlineDecoration() : null),
        ].row()!;
      },
      contentBuilder: (ctx, child, index, data, isSelected) {
        return LogPanelWidget(control: widget.control, key: ValueKey("Log"));
      },
    ),
    TabEntryInfo(
      tabInfo: LogPanelTabData(title: "files"),
      fixed: true,
      tabBuilder: (ctx, child, index, data, isSelected) {
        return [
          "文件"
              .text()
              .insets(h: kX, v: kH)
              .decoration(isSelected == true ? underlineDecoration() : null),
        ].row()!;
      },
      contentBuilder: (ctx, child, index, data, isSelected) {
        return DebugFilePage(
          /*folderPath: fileFolderPath,*/
          initPath: fileFolderPath,
          key: ValueKey(fileFolderPath),
        );
      },
    ),
    TabEntryInfo(
      tabInfo: LogPanelTabData(title: "caches"),
      fixed: true,
      tabBuilder: (ctx, child, index, data, isSelected) {
        return [
          "缓存文件"
              .text()
              .insets(h: kX, v: kH)
              .decoration(isSelected == true ? underlineDecoration() : null),
        ].row()!;
      },
      contentBuilder: (ctx, child, index, data, isSelected) {
        return DebugFilePage(
          /*folderPath: cacheFolderPath,*/
          initPath: cacheFolderPath,
          key: ValueKey(cacheFolderPath),
        );
      },
    ),
    TabEntryInfo(
      tabInfo: LogPanelTabData(title: "tempFile"),
      fixed: true,
      tabBuilder: (ctx, child, index, data, isSelected) {
        return [
          "临时文件"
              .text()
              .insets(h: kX, v: kH)
              .decoration(isSelected == true ? underlineDecoration() : null),
        ].row()!;
      },
      contentBuilder: (ctx, child, index, data, isSelected) {
        return "临时文件".text();
      },
    ),
  ];

  late TabsManagerController controller = TabsManagerController(
    tabEntryList: tabEntryList,
  );

  Widget buildPanelApp(BuildContext context, GlobalTheme globalTheme) {
    return TabsManagerWidget(controller: controller)
        .animatedContainer(width: $ecwBp())
        .material(color: globalTheme.surfaceBgColor);
  }
}

/// - [TabEntryInfo.tabInfo]
class LogPanelTabData {
  final String title;

  const LogPanelTabData({required this.title});
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
        if (data != null) {
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
      buildInputFilterWidget(context, globalTheme),
      buildLogFilterWidget(context, globalTheme),
      Divider(height: 1),
      buildLogDataListWidget(
        context,
        globalTheme,
        filterType: selectedFilterType,
        filterContent: filterContent,
      ).expanded(),
    ].column()!;
  }

  //MARK: - build

  /// 构建输入过滤标签
  Widget buildInputFilterWidget(BuildContext context, GlobalTheme globalTheme) {
    return [
      BorderSingleInputWidget(
        hintText: "过滤内容",
        maxLines: 1,
        maxLength: 100,
        text: filterContent,
        onChanged: (text) {
          filterContent = text;
          updateState();
        },
      ).expanded(),
      //MARK: - scrollToBottom
      scrollToBottomLive
          .buildFn(
            () =>
                loadCoreAssetSvgPicture(
                      Assets.svg.scrollToBottom,
                      tintColor: context.isThemeDark
                          ? globalTheme.textTitleStyle.color
                          : null,
                      size: 14,
                    )!
                    .insets(all: 10)
                    .inkWell(() {
                      isScrollToBottom = !isScrollToBottom;
                    }, borderRadius: buttonRadius.borderRadius)
                    .decoration(
                      fillDecoration(
                        color: isScrollToBottom
                            ? globalTheme.pressColor
                            : Colors.transparent,
                        radius: buttonRadius,
                      ),
                    ),
          )
          .tooltip("锁定滚动到底部"),
      //MARK: - pause
      widget.control?.isPauseLogLive
          .buildFn(
            () =>
                loadCoreAssetSvgPicture(
                      Assets.svg.scrollPause,
                      tintColor: context.isThemeDark
                          ? globalTheme.textTitleStyle.color
                          : null,
                      size: 14,
                    )!
                    .insets(all: 10)
                    .inkWell(() {
                      widget.control!.isPauseLog = !widget.control!.isPauseLog;
                    }, borderRadius: buttonRadius.borderRadius)
                    .decoration(
                      fillDecoration(
                        color: widget.control!.isPauseLog
                            ? globalTheme.pressColor
                            : Colors.transparent,
                        radius: buttonRadius,
                      ),
                    ),
          )
          .tooltip("暂停接收日志"),
      //MARK: - clear
      loadCoreAssetSvgPicture(
            Assets.svg.coreClear,
            tintColor: context.isThemeDark
                ? globalTheme.textTitleStyle.color
                : null,
            size: 14,
          )!
          .insets(all: 10)
          .inkWell(() {
            widget.control?.clearLogData();
          }, borderRadius: buttonRadius.borderRadius)
          .tooltip("清除日志"),
      //MARK: - copy
      loadCoreAssetSvgPicture(
            Assets.svg.coreCopy,
            tintColor: context.isThemeDark
                ? globalTheme.textTitleStyle.color
                : null,
            size: 14,
          )!
          .insets(all: 10)
          .inkWell(() {
            final list = filterLogDataList(
              filterType: selectedFilterType,
              filterContent: filterContent,
            );
            buildString((builder) {
              for (final item in list) {
                builder.write(item.time);
                builder.write("/");
                builder.writeln(item.content);
              }
            }).copy();
          }, borderRadius: buttonRadius.borderRadius)
          .tooltip("复制日志"),
    ].row(gap: kL)!.insets(right: kL);
  }

  final buttonRadius = kDefaultBorderRadiusX;
  final filterRadius = kDefaultBorderRadiusXXX;

  /// 构建Log过滤
  Widget buildLogFilterWidget(BuildContext context, GlobalTheme globalTheme) {
    return [
          for (final filterType in filterTypeList)
            (filterType == "" ? "All" : filterType)
                .text()
                .insets(h: kX, v: kM)
                .decoration(
                  selectedFilterType == filterType
                      ? fillDecoration(
                          color: globalTheme.lineColor,
                          radius: filterRadius,
                        )
                      : strokeDecoration(
                          color: globalTheme.lineColor,
                          radius: filterRadius,
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
                  borderRadius: filterRadius.borderRadius,
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

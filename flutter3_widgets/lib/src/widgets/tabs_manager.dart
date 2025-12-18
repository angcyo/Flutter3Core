part of '../../flutter3_widgets.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/18
///
/// 多标签管理
/// - [TabEntryInfo] 被管理的标签信息
class TabsManagerController {
  /// 从[BuildContext]中获取到[TabsManagerController]
  static TabsManagerController? of(
    BuildContext context, {
    bool createDependency = false,
  }) {
    if (createDependency) {
      return context
          .dependOnInheritedWidgetOfExactType<TabsManagerControllerScope>()
          ?.controller;
    } else {
      return context
          .getInheritedWidgetOfExactType<TabsManagerControllerScope>()
          ?.controller;
    }
  }

  /// 标签列表
  final tabEntryListLive = $live<List<TabEntryInfo>>([]);

  /// 当前选中的标签
  final currentTabEntryLive = $live<TabEntryInfo?>(null);

  /// 标签数量
  int get tabCount => tabEntryListLive.value?.length ?? 0;

  TabsManagerController({
    List<TabEntryInfo>? tabEntryList,
    TabEntryInfo? currentTabEntry,
  }) {
    if (!isNil(tabEntryList)) {
      tabEntryListLive << (tabEntryList ?? []);
    }
    currentTabEntry ??= tabEntryList?.firstOrNull;
    if (currentTabEntry != null) {
      currentTabEntryLive << currentTabEntry;
    }
  }

  //MARK: - api

  /// 切换到指定的标签
  /// - [force] 是否强制选中
  @api
  bool switchTab(TabEntryInfo? tabEntry, {bool force = false}) {
    if (tabEntry == null) {
      return false;
    }
    if (!force && tabEntry == currentTabEntryLive.value) {
      assert(() {
        l.w("当前已是标签: ${currentTabEntryLive.value}");
        return true;
      }());
      return false;
    }
    currentTabEntryLive << tabEntry;
    tabEntryListLive.notify();
    return true;
  }

  /// 添加新的标签
  @api
  bool addTab(TabEntryInfo? tabEntry) {
    if (tabEntry == null) {
      return false;
    }
    tabEntryListLive << [...tabEntryListLive.value!, tabEntry];
    switchTab(tabEntry);
    return true;
  }

  /// 移除指定的标签
  /// - [direction] 移除之后, 默认选中右边的标签
  @api
  bool removeTab(TabEntryInfo? tabEntry, {AxisDirection direction = .right}) {
    if (tabEntry == null) {
      return false;
    }
    TabEntryInfo? beforeTabEntry;
    TabEntryInfo? afterTabEntry;

    final tabEntryList = tabEntryListLive.value!;
    List<TabEntryInfo> newTabEntryList = [];
    for (final (index, entry) in tabEntryList.indexed) {
      if (entry == tabEntry) {
        beforeTabEntry = tabEntryList.getOrNull(index - 1);
        afterTabEntry = tabEntryList.getOrNull(index + 1);
      } else {
        newTabEntryList.add(entry);
      }
    }
    tabEntryListLive << newTabEntryList;
    if (direction == .right) {
      switchTab(afterTabEntry ?? newTabEntryList.lastOrNull, force: true);
    } else {
      switchTab(beforeTabEntry ?? newTabEntryList.firstOrNull, force: true);
    }
    return true;
  }

  //MARK: - build

  /// 构建标签列表
  @api
  WidgetList buildTabList(
    BuildContext context, {
    TransformDataWidgetBuilder? transformWidgetBuilder,
  }) {
    return [
      for (final (index, entry) in tabEntryListLive.value!.indexed)
        transformWidgetBuilder?.call(
              context,
              entry.buildTabWidget(
                context,
                index,
                entry == currentTabEntryLive.value,
              ),
              index,
              entry,
              entry == currentTabEntryLive.value,
            ) ??
            entry.buildTabWidget(
              context,
              index,
              entry == currentTabEntryLive.value,
            ),
    ];
  }

  /// 构建内容列表
  @api
  WidgetList buildContentList(
    BuildContext context, {
    TransformDataWidgetBuilder? transformWidgetBuilder,
  }) {
    return [
      for (final (index, entry) in tabEntryListLive.value!.indexed)
        (transformWidgetBuilder?.call(
                  context,
                  entry.buildContentWidget(
                    context,
                    index,
                    entry == currentTabEntryLive.value,
                  ),
                  index,
                  entry,
                  entry == currentTabEntryLive.value,
                ) ??
                entry.buildContentWidget(
                  context,
                  index,
                  entry == currentTabEntryLive.value,
                ))
            .visible(visible: entry == currentTabEntryLive.value),
    ];
  }
}

/// 标签信息
class TabEntryInfo with EquatableMixin {
  //MARK: - config

  /// 标签的信息
  @configProperty
  final tabInfoLive = $live<dynamic>(null);

  /// 是否固定的标签, 固定的标签不能被移除
  @configProperty
  final fixedLive = $live<bool>(false);

  /// 标签小部件
  final Widget? tabWidget;

  /// 完全自定义的tab构建方法
  @configProperty
  final TransformDataWidgetBuilder? tabBuilder;

  /// 内容小部件
  final Widget? contentWidget;

  /// 完全自定义的内容构建方法
  @configProperty
  final TransformDataWidgetBuilder? contentBuilder;

  /// 是否固定的标签
  bool get isFixed => fixedLive.value == true;

  TabEntryInfo({
    this.tabWidget,
    this.tabBuilder,
    this.contentWidget,
    this.contentBuilder,
    dynamic tabInfo,
    bool fixed = false,
  }) {
    tabInfoLive << tabInfo;
    fixedLive << fixed;
  }

  //MARK: - build

  /// 构建tab
  @api
  Widget buildTabWidget(BuildContext context, int index, bool isSelected) {
    return tabInfoLive.buildFn(() {
      final child =
          tabWidget ??
          widgetOf(context, tabInfoLive.value, tryTextWidget: true) ??
          empty;
      if (tabBuilder != null) {
        return tabBuilder!.call(
          context,
          child,
          index,
          tabInfoLive.value,
          isSelected,
        );
      }
      return child;
    });
  }

  /// 构建内容
  @api
  Widget buildContentWidget(BuildContext context, int index, bool isSelected) {
    return contentWidget ??
        contentBuilder?.call(
          context,
          empty,
          index,
          tabInfoLive.value,
          isSelected,
        ) ??
        empty;
  }

  //MARK: - other

  @override
  String toString() {
    return 'TabEntryInfo{tabInfo: ${tabInfoLive.value}, fixed: ${fixedLive.value}}';
  }

  @override
  List<Object?> get props => [tabInfoLive];
}

/// 用于提供[TabsManagerController]的小部件
class TabsManagerControllerScope extends InheritedWidget {
  final TabsManagerController controller;

  const TabsManagerControllerScope({
    super.key,
    required super.child,
    required this.controller,
  });

  @override
  bool updateShouldNotify(TabsManagerControllerScope oldWidget) =>
      controller != oldWidget.controller;
}

/// 使用[TabsManagerController]管理标签页面的小部件
class TabsManagerWidget extends StatefulWidget {
  /// 管理器
  final TabsManagerController controller;

  /// 轴向
  /// - 标签与内容的布局排列方式
  final Axis axis;

  /// [Axis.horizontal]时的宽度
  final double tabWidth;

  /// [Axis.vertical]时的高度
  final double tabHeight;

  /// 标签的背景装饰
  final Decoration? tabDecoration;

  /// 选中的标签的背景装饰
  @defInjectMark
  final Decoration? tabSelectedDecoration;

  /// 内容的背景装饰
  final Decoration? contentDecoration;

  /// 创建新的标签
  /// - 自动出现+号
  final TabEntryInfo Function(BuildContext)? addNewTabAction;

  const TabsManagerWidget({
    super.key,
    required this.controller,
    this.axis = .vertical,
    this.tabWidth = 200,
    this.tabHeight = 36,
    this.tabDecoration,
    this.tabSelectedDecoration,
    this.contentDecoration,
    this.addNewTabAction,
  });

  @override
  State<TabsManagerWidget> createState() => _TabsManagerWidgetState();
}

class _TabsManagerWidgetState extends State<TabsManagerWidget>
    with HookMixin, HookStateMixin {
  /// 是否有创建标签的按钮
  bool get haveAddNewTab => widget.addNewTabAction != null;

  /// 圆角
  double get radius => widget.axis == .vertical ? 0.0 : 4.0;

  /// 标签项大小
  double? get tabItemWidth =>
      widget.axis == .horizontal ? widget.tabWidth : null;

  double? get tabItemHeight =>
      widget.axis == .vertical ? widget.tabHeight : null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = GlobalTheme.of(context);
    //MARK: - child
    final Widget child;
    if (widget.axis == .vertical) {
      child = [
        widget.controller.tabEntryListLive
            .buildFn(() {
              return buildTabList(
                context,
                globalTheme,
              ).scrollHorizontal(mainAxisSize: .max)!.matchParentWidth();
            })
            .size(height: widget.tabHeight)
            .decoration(widget.tabDecoration),
        widget.controller.tabEntryListLive
            .buildFn(() {
              return buildContentList(
                context,
                globalTheme,
              ).stack(fit: .expand)!;
            })
            .matchParentWidth()
            .decoration(widget.contentDecoration)
            .expanded(),
      ].column(mainAxisSize: .max)!;
    } else {
      child = [
        widget.controller.tabEntryListLive
            .buildFn(() {
              return buildTabList(
                context,
                globalTheme,
              ).scrollVertical(mainAxisSize: .max)!;
            })
            .size(width: widget.tabWidth)
            .decoration(widget.tabDecoration)
            .bounds(),
        widget.controller.tabEntryListLive
            .buildFn(() {
              return buildContentList(context, globalTheme).stack()!;
            })
            .matchParentHeight()
            .decoration(widget.contentDecoration)
            .bounds()
            .expanded(),
      ].row(mainAxisSize: .max)!;
    }
    return TabsManagerControllerScope(
      controller: widget.controller,
      child: child,
    );
  }

  //MARK: - build

  Color getHoverColor(BuildContext context, GlobalTheme globalTheme) {
    return globalTheme.itemWhiteSubBgColor.withAlpha(30);
  }

  /// 创建标签列表
  WidgetList buildTabList(BuildContext context, GlobalTheme globalTheme) {
    final tabList = widget.controller.buildTabList(
      context,
      transformWidgetBuilder: (context, child, index, entry, isSelected) {
        return child
            .box(width: tabItemWidth, height: tabItemHeight)
            .rowOf(
              isSelected == true && !entry.isFixed
                  ? buildCloseTabButton(context, globalTheme, entry)
                  : empty,
            )
            .decoration(
              isSelected == true
                  ? widget.tabSelectedDecoration ??
                        fillDecoration(
                          radius: radius,
                          color: getHoverColor(context, globalTheme),
                        )
                  : null,
            )
            .inkWell(
              () {
                widget.controller.switchTab(entry);
              },
              radius: radius,
              hoverColor: getHoverColor(context, globalTheme),
            )
            .material();
      },
    );
    if (haveAddNewTab) {
      tabList.add(buildAddNewTabButton(context, globalTheme));
    }
    return tabList.filterAndFillGap(
      gapWidget: widget.axis == .vertical
          ? vLine(context, color: getHoverColor(context, globalTheme))
          : hLine(context, color: getHoverColor(context, globalTheme)),
    );
  }

  /// 创建内容列表
  WidgetList buildContentList(BuildContext context, GlobalTheme globalTheme) {
    final contentList = widget.controller.buildContentList(context);
    return contentList;
  }

  /// 创建添加标签按钮
  Widget buildAddNewTabButton(BuildContext context, GlobalTheme globalTheme) {
    return Icon(Icons.add, color: Colors.white)
        .box(width: tabItemWidth, height: tabItemHeight)
        .insets(h: kX)
        .inkWell(
          () {
            widget.controller.addTab(widget.addNewTabAction!(context));
          },
          radius: radius,
          hoverColor: getHoverColor(context, globalTheme),
        )
        .material();
  }

  /// 创建添加标签按钮
  Widget buildCloseTabButton(
    BuildContext context,
    GlobalTheme globalTheme,
    TabEntryInfo entry,
  ) {
    return Icon(Icons.close, color: Colors.white, size: 16)
        .insets(all: 4)
        .inkWellCircle(
          () {
            widget.controller.removeTab(entry);
          },
          radius: radius,
          hoverColor: getHoverColor(context, globalTheme),
        )
        .material();
  }
}

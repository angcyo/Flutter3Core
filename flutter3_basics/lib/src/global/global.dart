part of flutter3_basics;

/// 全局配置, 全局入口
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

/// 全局入口[Widget]
class GlobalApp extends StatefulWidget {
  const GlobalApp({
    super.key,
    required this.app,
    this.globalConfig,
  });

  final Widget app;
  final GlobalConfig? globalConfig;

  /// 打印所有的祖先元素和子元素
  static logWidget([Duration? delay, BuildContext? context]) {
    BuildContext? ctx = context ?? GlobalConfig.def.globalContext;
    if (ctx == null || delay != null) {
      delayCallback(() {
        logWidget(null, ctx);
      }, delay);
    } else {
      _logWidget(ctx);
    }
  }

  static _logWidget(BuildContext context) {
    _logAncestorWidget(context);
    _logChildWidget(context);
  }

  /// 打印所有祖先元素
  /// [root].[RenderView]->[View]->[_ViewScope]->[_MediaQueryFromView]->[MediaQuery]
  static _logAncestorWidget(BuildContext context) {
    context.visitAncestorElements((element) {
      if (element is StatefulElement) {}
      return element.owner != null;
    });
  }

  ///
  /// 打印所有子元素
  /// 0:[GlobalConfigScope] 1:[MyApp] 2:[MaterialApp] 3:[ScrollConfiguration] 4:[HeroControllerScope] 5:[Focus] 6:[_FocusInheritedScope] 7:[Semantics] 8:[WidgetsApp]√ 9:[RootRestorationScope] 10:[UnmanagedRestorationScope]
  /// 11:[RestorationScope] 12:[UnmanagedRestorationScope] 13:[SharedAppData] 14:[_SharedAppModel] 15:[Shortcuts] 16:[Focus] 17:[_FocusInheritedScope] 18:[Semantics] 19:[DefaultTextEditingShortcuts] 20:[Shortcuts]
  /// 21:[Focus] 22:[_FocusInheritedScope] 23:[Semantics] 24:[Actions] 25:[_ActionsScope] 26:[FocusTraversalGroup] 27:[Focus] 28:[_FocusInheritedScope] 29:[TapRegionSurface] 30:[ShortcutRegistrar]
  /// 31:[_ShortcutRegistrarScope] 32:[Shortcuts] 33:[Focus] ... 36:[Localizations] ... 39:[Directionality] 40:[Title]√ 41:[CheckedModeBanner]√ 42:[Banner] 43:[CustomPaint] 44:[DefaultTextStyle] 45:[Builder] 46:[ScaffoldMessenger]
  /// ... 48:[DefaultSelectionStyle] 49:[AnimatedTheme] 50:[Theme] 51:[_InheritedTheme] 52:[CupertinoTheme] 53:[_InheritedCupertinoTheme]
  /// 分水岭:
  /// 54:[IconTheme] 55:[FocusScope] ... 60:[Navigator]√ 61:[HeroController] 62:[Listener] 63:[AbsorbPointer] 64:[FocusTraversalGroup] 65:[Focus] ... 69:[UnmanagedRestorationScope] 70:[Overlay]√
  /// 71:[_Theater] 72:[_OverlayEntryWidget] 73:[TickerMode] ... 77:[_ModalScope] 78:[AnimatedBuilder] 79:[RestorationScope] 80:[UnmanagedRestorationScope] 81:[_ModalScopeStatus].[ModalRoute]√ 82:[Offstage] 83:[PageStorage] ... 85:[Actions] 86:[ConstrainedBox]
  /// ... 93:[_ZoomPageTransition] 94:[DualTransitionBuilder] 95:[_ZoomEnterTransition] 96:[SnapshotWidget] 97:[_ZoomExitTransition] 98:[SnapshotWidget] 99:[DualTransitionBuilder] ... 105:[IgnorePointer]
  /// 分水岭:
  /// 109:[MainAbc]√ 110:[Scaffold] 111:[_ScaffoldScope] 112:[ScrollNotificationObserver] 113:[NotificationListener].[ScrollMetricsNotification] 114:[NotificationListener].[ScrollNotification] 115:[_ScrollNotificationObserverScope]
  /// 116:[Material] 117:[AnimatedPhysicalModel] 118:[PhysicalModel] 119:[NotificationListener].[LayoutChangedNotification] 120:[_InkFeatures] 121:[AnimatedDefaultTextStyle] 122:[DefaultTextStyle] ... 123:[Actions] ... 126:[CustomMultiChildLayout]
  /// 127:[LayoutId] 128:[MediaQuery] 129:[_BodyBuilder] 130:[KeyedSubtree] 131:[CustomScrollView] 132:[PrimaryScrollController] 133:[Scrollable] 134:[StretchingOverscrollIndicator] 135:[NotificationListener].[ScrollNotification] 136:[AnimatedBuilder]
  /// 137:[ClipRect] 138:[Transform] 139:[NotificationListener].[ScrollMetricsNotification] 140:[_ScrollSemantics] 141:[_ScrollScope] 142:[Listener] 143:[RawGestureDetector] ... 148:[Viewport] 149:[SliverList] 150:[KeyedSubtree]
  /// 151:[AutomaticKeepAlive] 152:[KeepAlive] 153:[NotificationListener].[KeepAliveNotification] 154:[_SelectionKeepAlive]
  /// home只有一个[Placeholder]的情况下:
  /// 109:[Placeholder] 110:[LimitedBox] 111:[CustomPaint]
  ///
  static _logChildWidget(BuildContext context) {
    context.eachVisitChildElements((element, depth, childIndex) {
      l.w('[$depth:$childIndex]:[$element]');
      if (element is StatefulElement) {}
      return element.owner != null;
    });
  }

  @override
  State<GlobalApp> createState() => _GlobalAppState();
}

class _GlobalAppState extends State<GlobalApp> {
  @override
  Widget build(BuildContext context) {
    GlobalConfig config = widget.globalConfig ?? GlobalConfig.def;
    config.globalContext = context;
    //GlobalApp.logWidget(const Duration(milliseconds: 16));
    return GlobalConfigScope(
      globalConfig: widget.globalConfig ?? GlobalConfig.def,
      child: widget.app,
    );
  }
}

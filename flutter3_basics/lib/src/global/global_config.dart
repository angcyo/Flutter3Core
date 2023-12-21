part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

@dp
const double kS = 2;
const double kM = 4;
const double kL = 6;
const double kH = 8;
const double kX = 12;
const double kXh = 16;
const double kXxh = 32;
const double kXxxh = 48;

/// [kMinInteractiveDimension] 最小交互高度
const double kMinInteractiveHeight = 36;

/// [kToolbarHeight]
/// [kInteractiveHeight]
const double kTabHeight = 46;

/// 设计最佳最小交互高度
const double kInteractiveHeight = kMinInteractiveDimension;

/// 默认的模糊半径
const double kDefaultBlurRadius = 4.0;

/// 默认的高度
const double kDefaultElevation = 4.0;

const double kDefaultBorderRadius = 2.0;
const double kDefaultBorderRadiusL = 4.0;
const double kDefaultBorderRadiusH = 6.0;
const double kDefaultBorderRadiusX = 8.0;
const double kDefaultBorderRadiusXX = 12.0;
const double kDefaultBorderRadiusXXX = 24.0;

/// 打开[url]的回调方法
typedef GlobalOpenUrlFn = Future<bool> Function(
    BuildContext? context, String? url);

/// 带参数的[WidgetBuilder]
typedef WidgetArgumentBuilder = Widget Function<T>(
    BuildContext context, T? arg);

/// 写入文件的回调方法
typedef GlobalWriteFileFn = Future<String?> Function(
    String fileName, String? folder, Object? content);

/// 获取[GlobalConfig]的方法
typedef GlobalConfigGetFn = GlobalConfig Function();

/// [AppBar]构建器函数
typedef AppBarBuilderFn = PreferredSizeWidget? Function(
  BuildContext context,
  Object? page, {
  Widget? leading,
  Widget? title,
  PreferredSizeWidget? bottom,
  Color? backgroundColor,
  Color? foregroundColor,
  double? elevation,
  double? scrolledUnderElevation,
  Color? shadowColor,
  Widget? flexibleSpace,
  bool? centerTitle,
  double? titleSpacing,
});

/// [GlobalConfig.allModalRouteList]
ModalRoute? get lastModalRoute => GlobalConfig.allModalRouteList().lastOrNull;

/// [GlobalConfig.findOverlayState]
OverlayState? get overlayState => GlobalConfig.def.findOverlayState();

/// [GlobalConfig.findNavigatorState]
NavigatorState? get navigatorState => GlobalConfig.def.findNavigatorState();

/// 快速打开url
@dsl
Future<bool> openWebUrl(String? url, [BuildContext? context]) async {
  if (context == null) {
    var fn = GlobalConfig.def.openUrlFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(GlobalConfig.def.globalContext, url);
  } else {
    return context.openWebUrl(url);
  }
}

extension GlobalConfigEx on BuildContext {
  /// [GlobalConfig.of]
  GlobalConfig globalConfig({bool depend = false}) =>
      GlobalConfig.of(this, depend: depend);

  /// [GlobalConfig.openUrlFn]
  Future<bool> openWebUrl(String? url) async {
    var fn = GlobalConfig.of(this).openUrlFn ?? GlobalConfig.def.openUrlFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(this, url);
  }
}

/// 全局配置, 提供一个全局配置[GlobalConfig]
class GlobalConfigScope extends InheritedWidget {
  const GlobalConfigScope({
    super.key,
    required super.child,
    this.globalConfig,
    this.globalConfigGet,
  });

  /// 配置存放
  final GlobalConfig? globalConfig;

  final GlobalConfigGetFn? globalConfigGet;

  /// get
  GlobalConfig? get getGlobalConfig => globalConfig ?? globalConfigGet?.call();

  @override
  bool updateShouldNotify(covariant GlobalConfigScope oldWidget) =>
      isDebug ||
      globalConfig != oldWidget.globalConfig ||
      globalConfigGet != oldWidget.globalConfigGet;
}

class GlobalConfig with Diagnosticable, OverlayManage {
  /// 全局的上下文
  BuildContext? globalContext;

  //region ThemeData

  /// 全局的主题样式
  ThemeData themeData = ThemeData();

  /// 全局主题配置
  GlobalTheme globalTheme = GlobalTheme();

  //endregion ThemeData

  GlobalConfig({
    this.globalContext,
  });

  /// 全局默认
  static GlobalConfig? _def;

  /// 全局app临时全局配置
  static GlobalConfig? app;

  /// 获取全局配置
  static GlobalConfig get def => app ?? (_def ??= GlobalConfig());

  /// 获取全局配置
  /// 使用[GlobalConfigScope]可以覆盖[GlobalConfig]
  /// 请勿在[State.dispose]方法中调用此方法
  /// ```
  /// The following assertion was thrown while finalizing the widget tree:
  /// Looking up a deactivated widget's ancestor is unsafe.
  /// At this point the state of the widget's element tree is no longer stable.
  /// To safely refer to a widget's ancestor in its dispose() method, save a reference to the ancestor by
  /// calling dependOnInheritedWidgetOfExactType() in the widget's didChangeDependencies() method.
  /// ```
  static GlobalConfig of(BuildContext? context, {bool depend = false}) {
    GlobalConfig? globalConfig;
    if (depend) {
      globalConfig = (context ?? GlobalConfig.def.globalContext)
          ?.dependOnInheritedWidgetOfExactType<GlobalConfigScope>()
          ?.getGlobalConfig;
    } else {
      globalConfig = context
          ?.findAncestorWidgetOfExactType<GlobalConfigScope>()
          ?.getGlobalConfig;
    }
    return globalConfig ?? GlobalConfig.def;
  }

  /// 获取当前程序中的所有路由
  static List<ModalRoute> allModalRouteList() =>
      GlobalConfig.def.findModalRouteList();

  /// 注册一个全局的打开url方法, 一般是跳转到web页面
  /// 打开url
  GlobalOpenUrlFn? openUrlFn = (context, url) {
    l.w("企图打开url:$url from:$context");
    return Future.value(false);
  };

  /// 注册一个全局写入文件内容的方法, 返回文件路径
  GlobalWriteFileFn? writeFileFn = (fileName, folder, content) async {
    if (kDebugMode) {
      print("企图写入文件:$fileName ->$content");
    }
    //return Future.error(RException("未注册写入文件方法"), StackTrace.current);
    return Future.value(null);
  };

  //region Widget

  /// 全局的图片占位小部件
  WidgetArgumentBuilder imagePlaceholderBuilder = <T>(context, arg) {
    var color = GlobalTheme.of(context).imagePlaceholderColor;
    //纯色背景小部件
    return Container(
      color: color,
    );
  };

  /// 全局的Loading指示器
  WidgetBuilder loadingIndicatorBuilder = (context) {
    return const LoadingIndicator();
  };

  /// 全局的错误占位小部件
  WidgetArgumentBuilder errorPlaceholderBuilder = <T>(context, error) {
    return const Icon(Icons.error);
  };

  /// 全局的加载[Overlay]提示
  /// [OverlayEntry]
  WidgetBuilder loadingOverlayWidgetBuilder = (context) {
    Widget loadingIndicator =
        GlobalConfig.of(context).loadingIndicatorBuilder(context);
    return Container(
      alignment: Alignment.center,
      child: SizedBox.fromSize(
        size: kDefaultLoadingSize,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(80),
            borderRadius: BorderRadius.circular(8),
          ),
          child: loadingIndicator,
        ),
      ),
    );
  };

  //endregion Widget

  //region AppBar

  /// 用来创建自定义的[AppBar]左边的返回小部件
  /// [page] 用来识别界面, 做一些特殊处理
  /// @return null 使用系统默认的
  Widget? Function(BuildContext context, Object? page) appBarLeadingBuilder = (
    context,
    state,
  ) {
    return null;
  };

  /// 用来创建[AppBar]
  /// [AppBarTheme] 相关默认样式在此声明, 可以通过[Theme]小部件覆盖
  /// [scrolledUnderElevation] 滚动时, 阴影的高度
  /// [backgroundColor] 透明的背景颜色, 会影响Android状态栏的颜色
  /// [flexibleSpace] 纯白色的[AppBar]推荐使用此属性设置白色, 否则会和底色叠加.
  /// [bottom] [AppBar.bottom]属性[PreferredSizeWidget]
  /// [copyWith]
  late AppBarBuilderFn appBarBuilder = (
    context,
    state, {
    leading,
    title,
    bottom,
    backgroundColor,
    foregroundColor,
    elevation,
    scrolledUnderElevation,
    shadowColor,
    flexibleSpace,
    centerTitle,
    titleSpacing,
  }) {
    debugger();
    var globalConfig = GlobalConfig.of(context);
    var globalTheme = GlobalTheme.of(context);
    elevation ??= globalConfig.themeData.appBarTheme.elevation;
    return AppBar(
      title: title,
      leading: leading ??
          (context.isAppBarDismissal
              ? appBarLeadingBuilder(context, state)
              : null),
      bottom: bottom,
      elevation: elevation,
      shadowColor: shadowColor ?? globalTheme.appBarShadowColor,
      backgroundColor: backgroundColor ?? globalTheme.appBarBackgroundColor,
      foregroundColor: foregroundColor ?? globalTheme.appBarForegroundColor,
      scrolledUnderElevation: scrolledUnderElevation ?? elevation,
      flexibleSpace: flexibleSpace ??
          (backgroundColor == null
              ? ((globalTheme.appBarGradientBackgroundColorList == null
                  ? null
                  : linearGradientWidget(
                      globalTheme.appBarGradientBackgroundColorList!)))
              : null),
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
    );
  };

  //endregion AppBar

  //region Overlay

  /// [OverlayManage]

  //endregion Overlay

  //region app

  /// 从上往下查找 [WidgetsApp]
  /// [Overlay.of]
  Element? findWidgetsAppElement() {
    var element = globalContext?.findElementOfWidget<WidgetsApp>();
    return element;
  }

  /// 从上往下查找 [OverlayState]
  /// [Overlay.of]
  OverlayState? findOverlayState() {
    var element = globalContext?.findElementOfWidget<Overlay>();
    if (element is StatefulElement) {
      return element.state as OverlayState;
    }
    return null;
  }

  /// 从上往下查找 [NavigatorState]
  /// [Navigator.of]
  NavigatorState? findNavigatorState() {
    var element = globalContext?.findElementOfWidget<Navigator>();
    if (element is StatefulElement) {
      return element.state as NavigatorState;
    }
    return null;
  }

  /// 从上往下查找所有[ModalRoute]
  List<ModalRoute> findModalRouteList() {
    List<Element> routeElementList = [];
    List<ModalRoute> result = [];
    globalContext?.eachVisitChildElements((element, depth, childIndex) {
      if ("$element".startsWith("_ModalScopeStatus(")) {
        routeElementList.add(element);
        return false;
      }
      return true;
    });
    for (var element in routeElementList) {
      //获取第一个子元素
      var isAdd = false;
      element.visitChildElements((element) {
        if (!isAdd) {
          var route = ModalRoute.of(element);
          route?.let<ModalRoute>((it) {
            isAdd = true;
            result.add(it);
          });
        }
      });
    }
    return result;
  }

  //endregion app

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('GlobalConfig', "~GlobalConfig~"));
  }

  //

  /// 复制
  GlobalConfig copyWith({
    BuildContext? globalContext,
    ThemeData? themeData,
    GlobalTheme? globalTheme,
    GlobalOpenUrlFn? openUrlFn,
    GlobalWriteFileFn? writeFileFn,
    WidgetArgumentBuilder? imagePlaceholderBuilder,
    WidgetBuilder? loadingIndicatorBuilder,
    WidgetArgumentBuilder? errorPlaceholderBuilder,
    WidgetBuilder? loadingOverlayWidgetBuilder,
    AppBarBuilderFn? appBarBuilder,
  }) {
    return GlobalConfig(
      globalContext: globalContext ?? this.globalContext,
    )
      ..themeData = themeData ?? this.themeData
      ..globalTheme = globalTheme ?? this.globalTheme
      ..openUrlFn = openUrlFn ?? this.openUrlFn
      ..writeFileFn = writeFileFn ?? this.writeFileFn
      ..imagePlaceholderBuilder =
          imagePlaceholderBuilder ?? this.imagePlaceholderBuilder
      ..loadingIndicatorBuilder =
          loadingIndicatorBuilder ?? this.loadingIndicatorBuilder
      ..errorPlaceholderBuilder =
          errorPlaceholderBuilder ?? this.errorPlaceholderBuilder
      ..loadingOverlayWidgetBuilder =
          loadingOverlayWidgetBuilder ?? this.loadingOverlayWidgetBuilder
      ..appBarBuilder = appBarBuilder ?? this.appBarBuilder;
  }
}

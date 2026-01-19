part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

/// 带参数的[WidgetBuilder]
typedef WidgetArgumentBuilder =
    Widget Function<T>(BuildContext context, T? arg);

/// 全局打开[url]的回调方法, 返回成功or失败
typedef GlobalOpenUrlFn =
    Future<bool> Function(BuildContext? context, String? url, Object? meta);

/// 全局写入文件的回调方法, 返回文件路径
typedef GlobalWriteFileFn =
    Future<String?> Function(String fileName, String? folder, dynamic content);

/// 全局分享[data]的回调方法, 返回成功or失败
typedef GlobalShareDataFn =
    Future<bool> Function(BuildContext? context, dynamic data);

/// 获取[GlobalConfig]的方法
typedef GlobalConfigGetFn = GlobalConfig Function();

/// 进度小部件构建器
/// [progress] 进度[0~1]
typedef ProgressWidgetBuilder =
    Widget Function(
      BuildContext context,
      dynamic data,
      double? progress,
      Color? color,
    );

/// [AppBar]构建器函数
typedef AppBarBuilderFn =
    PreferredSizeWidget? Function(
      BuildContext context,
      Object? page, {
      bool? useSliverAppBar,
      Widget? leading,
      Widget? dismissal,
      bool? automaticallyImplyLeading,
      Widget? title,
      List<Widget>? actions,
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

/// [AppBar]左边构建器函数, 在可以back的时候调用
typedef AppBarDismissalBuilderFn =
    Widget? Function(BuildContext context, dynamic page);

/// [GlobalConfig.allModalRouteList]
ModalRoute? get lastModalRoute =>
    GlobalConfig.allModalRouteList().lastOrNull?.$1;

/// [GlobalConfig.findOverlayState]
OverlayState? get overlayState => GlobalConfig.def.findOverlayState();

/// [GlobalConfig.findNavigatorState]
NavigatorState? get navigatorState => GlobalConfig.def.findNavigatorState();

/// 快速打开url
@dsl
Future<bool> openWebUrl(
  String? url, [
  BuildContext? context,
  Object? meta,
]) async {
  if (context == null) {
    final fn = GlobalConfig.def.openUrlFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(GlobalConfig.def.globalContext, url, meta);
  } else {
    return context.openWebUrl(url, meta: meta);
  }
}

/// 快速打开file path
/// - 支持文件路径
/// - 支持文件夹路径
@dsl
Future<bool> openFilePath(
  String? filePath, [
  BuildContext? context,
  Object? meta,
]) async {
  if (context == null) {
    final fn = GlobalConfig.def.openFileFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(GlobalConfig.def.globalContext, filePath, meta);
  } else {
    return context.openFilePath(filePath, meta: meta);
  }
}

/// 快速另存为保存/分享file path
///  - save as
///  - share
@dsl
Future<bool> saveFilePath(
  String? filePath, [
  BuildContext? context,
  Object? meta,
]) async {
  if (context == null) {
    final fn = GlobalConfig.def.saveFileFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(GlobalConfig.def.globalContext, filePath, meta);
  } else {
    return context.saveFilePath(filePath, meta: meta);
  }
}

extension GlobalConfigEx on BuildContext {
  /// [GlobalConfig.of]
  GlobalConfig globalConfig({bool depend = false}) =>
      GlobalConfig.of(this, depend: depend);

  /// [GlobalConfig.openUrlFn]
  Future<bool> openWebUrl(String? url, {Object? meta}) async {
    var fn = GlobalConfig.of(this).openUrlFn ?? GlobalConfig.def.openUrlFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(this, url, meta);
  }

  /// [GlobalConfig.openFileFn]
  Future<bool> openFilePath(String? filePath, {Object? meta}) async {
    var fn = GlobalConfig.of(this).openFileFn ?? GlobalConfig.def.openFileFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(this, filePath, meta);
  }

  /// [GlobalConfig.saveFileFn]
  Future<bool> saveFilePath(String? filePath, {Object? meta}) async {
    var fn = GlobalConfig.of(this).saveFileFn ?? GlobalConfig.def.saveFileFn;
    if (fn == null) {
      return false;
    }
    return await fn.call(this, filePath, meta);
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

/// 全局配置
///
/// - [GlobalConfig.initGlobalTheme]初始化主题属性
/// - [GlobalConfig.notifyThemeChanged]通知主题属性改变
///
/// - [GlobalConfigScope]
/// - [GlobalAppStateMixin]
///
/// ```
/// final navigator = GlobalConfig.def.findNavigatorState();
/// ```
class GlobalConfig with Diagnosticable, OverlayManage {
  //region context

  /// 全局的上下文, 在[WidgetsApp]顶上
  ///
  /// - [findNavigatorState] 获取导航器
  /// - [findOverlayState] 获取Overlay
  BuildContext? globalTopContext;

  /// 全局的上下文, 在[WidgetsApp]下
  ///
  /// - 此上下文可以获取到导航[Navigator]/覆盖层[Overlay]
  BuildContext? globalAppContext;

  /// 全局的上下文[globalAppContext]->[globalTopContext]
  BuildContext? get globalContext => globalAppContext ?? globalTopContext;

  /// 全局App上下文变化监听
  /// - [addOnGlobalAppContextChanged]
  Set<ContextAction> onGlobalAppContextChangedActions = {};

  /// 更新全局App上下文, 同时通知监听者
  /// - [onGlobalAppContextChangedActions]
  @callPoint
  void updateGlobalAppContext(BuildContext context) {
    assert(() {
      l.i('更新全局App上下文为->${context.widget.runtimeType}(${context.classHash()})');
      return true;
    }());
    globalAppContext = context;
    for (final action in onGlobalAppContextChangedActions) {
      try {
        action(context);
      } catch (e) {
        assert(() {
          print(e);
          return true;
        }());
      }
    }
  }

  /// 添加一个全局上下文改变回调
  /// - [updateGlobalAppContext]
  /// - [addOnGlobalAppContextChanged]
  @api
  void addOnGlobalAppContextChanged(ContextAction action) {
    onGlobalAppContextChangedActions.add(action);
    final context = globalAppContext;
    if (context != null) {
      try {
        action(context);
      } catch (e) {
        assert(() {
          print(e);
          return true;
        }());
      }
    }
  }

  //endregion context

  //region Router

  /// https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
  GlobalKey<NavigatorState>? _rootNavigatorKey;

  /// https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
  GlobalKey<NavigatorState>? _shellNavigatorKey;

  GlobalKey<NavigatorState> get rootNavigatorKey {
    return _rootNavigatorKey ??= GlobalKey<NavigatorState>();
  }

  GlobalKey<NavigatorState>? get shellNavigatorKey {
    return _shellNavigatorKey ??= GlobalKey<NavigatorState>();
  }

  //endregion Router

  //region ThemeData

  /// 主题模式
  /// - [ThemeMode.system] 系统模式
  /// - [ThemeMode.light] 亮色模式
  /// - [ThemeMode.dark] 暗色模式
  @configProperty
  ThemeMode themeMode = ThemeMode.system;

  /// 当前语言, 不指定则使用系统语言
  /// ```
  /// [List<Locale>][zh_Hans_CN, en_US, zh_Hant_TW, ja_JP, zh_Hant_MO, zh_Hant_HK, zh_Hans_SG, yue_HK]
  /// ```
  ///
  /// ```
  /// const locale = Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN');
  /// ```
  /// [L10nStringEx.toLocale]
  /// [Locale.fromSubtags]
  @configProperty
  Locale? locale;

  /// 主题改变通知, 收到通知后需要重建页面
  /// - 暗色模式改变
  /// - 语言改变
  /// - 主题色改变
  ///
  /// - 调用[updateThemeAction]更新主题
  ///   - [notifyThemeChanged]通知监听者
  /// - 使用全局的[$onGlobalThemeChanged]方法快速监听主题改变
  /// - 或者使用[State]混入[GlobalAppStateMixin]自动刷新界面
  final themeStreamOnce = $liveOnce<GlobalConfig>();

  /// 全局的主题样式
  /// [ThemeData]
  /// [ThemeData.textTheme]->[TextTheme]
  /// [TextTheme.displayLarge]->[TextStyle]
  /// [TextStyle.fontFamily]->[String] 字体
  ThemeData? themeData;

  /// 当前的全局主题配置
  GlobalTheme globalTheme = GlobalTheme();

  /// 当前是否是暗色主题模式
  bool get isThemeDark =>
      !isThemeLight() /*themeData?.brightness == Brightness.dark*/;

  /// 当前是否是亮色主题模式
  @api
  bool isThemeLight([BuildContext? context]) {
    if (themeMode == ThemeMode.system) {
      context ??= globalContext;
      if (context == null) {
        return true;
      }
      final platformBrightness = MediaQuery.platformBrightnessOf(context);
      return platformBrightness == Brightness.light;
    }
    return themeMode == ThemeMode.light;
  }

  /// 初始化主题
  /// - [locale] 指定当前语言, 不指定则使用系统
  /// - [themeMode] 指定当前主题模式, 不指定则使用系统
  /// - [onGetGlobalTheme] 获取自定义的主题样式[GlobalTheme]
  ///   - [GlobalTheme]
  ///   - [GlobalThemeDark]
  /// - [onGetThemeData] 根据当前主题模式和主题色, 获取[Flutter]需要的主题样式[ThemeData]
  @api
  ThemeData initGlobalTheme(
    BuildContext? context,
    ThemeData Function(
      GlobalTheme globalTheme,
      bool isLight,
      ThemeMode themeMode,
    )
    onGetThemeData, {
    @defInjectMark GlobalTheme Function(bool isLight)? onGetGlobalTheme,
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    //语言 / 暗色模式
    this.locale = locale ?? this.locale;
    this.themeMode = themeMode ?? this.themeMode;

    //主题样式
    final isLight = isThemeLight(context);

    final globalTheme =
        onGetGlobalTheme?.call(isLight) ??
        (isLight ? GlobalTheme() : GlobalThemeDark());
    this.globalTheme = globalTheme;

    //主题数据
    final themeData = onGetThemeData(globalTheme, isLight, this.themeMode);
    this.themeData = themeData;

    return themeData;
  }

  /// 包裹一个主题更改操作
  @api
  void updateThemeAction(FutureVoidAction action) async {
    await action();
    notifyThemeChanged();
  }

  /// 改变主题属性之后, 调用此方法通知
  /// 通知主题发生了改变
  /// [GlobalAppStateMixin]
  @api
  void notifyThemeChanged() {
    themeStreamOnce.updateValue(this);
  }

  //endregion ThemeData

  //region tablet平板适配

  /// 是否处于平板模式, 开启平板适配, 并且是平板设备
  bool get isInTabletModel {
    return isAdaptiveTablet && (isTabletWindow || forceTabletDevice);
  }

  /// 是否处于平板模式下的宽屏模式
  bool get isInTabletLandscapeModel {
    return isAdaptiveTablet &&
        isTabletLandscape &&
        isAdaptiveTabletLandscapeModel;
  }

  /// 是否需要适配平板设备
  /// - 平板布局, 否则常规的手机布局
  /// - [isTabletWindow]
  @configProperty
  bool isAdaptiveTablet = isDesktopOrWeb;

  /// 是否要适配平板设备下的宽屏模式, 需要先开启平板适配
  /// - 宽屏模式, 可能理解为pc端布局
  /// - [isAdaptiveTablet]
  @configProperty
  bool isAdaptiveTabletLandscapeModel = isDesktopOrWeb;

  /// 是否强制标识为平板设备
  /// - [isTabletWindow]
  @configProperty
  bool forceTabletDevice = isDesktopOrWeb;

  //endregion tablet平板适配

  GlobalConfig({this.globalTopContext, this.globalAppContext});

  GlobalConfig._() {
    assert(() {
      debugPrint('初始化默认的[${classHash()}]');
      return true;
    }());
  }

  /// 全局默认
  static GlobalConfig? _def;

  /// 全局app临时全局配置
  static GlobalConfig? appDef;

  /// 获取全局配置
  static GlobalConfig get def => appDef ?? (_def ??= GlobalConfig._());

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
    GlobalConfig? result;
    if (depend) {
      result = (context ?? GlobalConfig.def.globalTopContext)
          ?.dependOnInheritedWidgetOfExactType<GlobalConfigScope>()
          ?.getGlobalConfig;
    } else {
      result = context
          ?.getInheritedWidgetOfExactType<GlobalConfigScope>()
          ?.getGlobalConfig;
    }
    //debugger(when: $globalDebugLabel != null && result == null);
    return result ?? GlobalConfig.def;
  }

  /// 获取当前程序中的所有路由
  static List<(ModalRoute, Element?)> allModalRouteList() =>
      GlobalConfig.def.findModalRouteList();

  /// 获取当前配置下, 是否是debug模式
  /// 返回null, 表示不确定
  /// [isDebug]
  /// [isDebugFlag]
  ResultCallback<bool?>? isDebugFlagFn = () {
    return null;
  };

  /// 注册一个全局的打开[filePath]方法, 可以是内部打开文件/也可以使用系统本机打开
  /// - 支持文件路径
  /// - 支持文件夹路径
  /// ```
  /// GlobalConfig.def.openFileFn = (context, url) {
  ///   ...
  ///   return Future.value(true);
  /// };
  /// ```
  /// [openFilePath]
  @allPlatformFlag
  GlobalOpenUrlFn? openFileFn = (context, filePath, meta) {
    l.w("企图打开filePath:$filePath from:$context meta:$meta");
    if (filePath != null && isDesktopOrWeb) {
      if (Platform.isWindows) {
        Process.run('explorer.exe', [filePath]);
      } else if (Platform.isMacOS) {
        Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [filePath]);
      }
      return Future.value(true);
    }
    return Future.value(false);
  };

  /// 注册一个全局的保存[filePath]方法
  /// - 移动端分享文件
  /// - 桌面端调用系统保存文件弹窗
  ///   - [meta] 桌面端对话框的标题
  /// ```
  /// GlobalConfig.def.saveFileFn = (context, filePath, meta) async {
  ///   if (filePath == null || isNil(filePath)) {
  ///     return false;
  ///   }
  ///   if (isDesktopOrWeb) {
  ///     final savePath = await saveFile(
  ///       dialogTitle: meta?.toString(),
  ///       fileName: filePath.fileName(),
  ///     );
  ///     if (savePath != null) {
  ///       return (await filePath.copyTo(savePath)) != null;
  ///     } else {
  ///       return false;
  ///     }
  ///   }
  ///   return filePath.shareFile();
  /// };
  /// ```
  /// [saveFilePath] - 全局入口方法
  @allPlatformFlag
  GlobalOpenUrlFn? saveFileFn = (context, filePath, meta) {
    l.w("企图保存filePath:$filePath from:$context meta:$meta");
    return Future.value(false);
  };

  /// 注册一个全局的打开url方法, 一般是跳转到web页面
  /// 打开url
  ///
  /// ```
  /// GlobalConfig.def.openUrlFn = (context, url, meta) {
  ///     if (isDesktopOrWeb) {
  ///       url?.launch(mode: LaunchMode.platformDefault);
  ///     } else {
  ///       context?.openSingleWebView(url);
  ///     }
  ///   return Future.value(true);
  /// };
  /// ```
  GlobalOpenUrlFn? openUrlFn = (context, url, meta) {
    l.w("企图打开url:$url from:$context meta:$meta");
    if (url != null && isDesktopOrWeb) {
      //final Uri uri = Uri.parse(url);
      if (Platform.isWindows) {
        // Windows 命令行中，start 命令第一个参数如果是引号会被当作窗口标题
        // 因此这里传入一个空字符串作为标题占位符
        Process.run('cmd', ['/c', 'start', '', url]);
      } else if (Platform.isMacOS) {
        Process.run('open', [url]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [url]);
      }
      return Future.value(true);
    }
    return Future.value(false);
  };

  /// 注册一个全局写入文件内容的方法, 返回文件路径
  GlobalWriteFileFn? writeFileFn = (fileName, folder, content) async {
    l.w("企图写入文件:$fileName ->$content");
    //return Future.error(RException("未注册写入文件方法"), StackTrace.current);
    return Future.value(null);
  };

  /// 注册一个全局的分享数据的方法, 一般是调用系统分享
  /// 分享数据给第三方app
  GlobalShareDataFn? shareDataFn = (context, data) {
    l.w("企图分享数据:$data");
    return Future.value(false);
  };

  /// 注册一个全局的分享日志数据的方法
  /// 将app日志打包之后分享
  /// [shareDataFn]
  /// [shareAppLog]
  GlobalShareDataFn? shareAppLogFn = (context, data) {
    l.w("企图分享App日志:$data");
    return Future.value(false);
  };

  //region Widget

  /// 全局的图片占位小部件
  WidgetArgumentBuilder imagePlaceholderBuilder = <T>(context, arg) {
    var color = GlobalTheme.of(context).imagePlaceholderColor;
    //纯色背景小部件
    return Container(color: color);
  };

  /// 全局的Loading指示器
  /// [OverlayEntry.type]
  /// [OverlayEntry]
  ///
  /// [WidgetStateBuildWidgetState]
  ///
  /// [LoadingIndicator]
  /// - [CircularProgressIndicator]
  /// - [StrokeLoadingWidget]
  ///
  /// [loadingOverlayWidgetBuilder]
  ///
  @minifyProguardFlag
  ProgressWidgetBuilder loadingIndicatorBuilder =
      (context, data, progress, color) {
        //debugger();
        //是否使用系统样式的加载小部件
        final dataStr = "$data".toLowerCase();
        final useSystemStyle =
            !dataStr.contains("overlay") || dataStr.contains("system");
        return LoadingIndicator(
          progressValue: progress,
          useSystemStyle: useSystemStyle,
          color: color,
        );
      };

  /// 全局的无数据占位小部件
  /// - [data] 额外的提示文本或小部件
  ///   - 支持[Widget]
  ///   - 支持[Object]
  ///
  /// [WidgetStateBuildWidgetState]
  WidgetArgumentBuilder emptyPlaceholderBuilder = <T>(context, data) {
    //debugger();
    final icon =
        loadAssetImageWidget(
          libAssetsStateNoDataKey,
          package: 'flutter3_basics',
        )?.constrainedMax(
          maxWidth: kStateImageSize,
          maxHeight: kStateImageSize,
        ) ??
        const Icon(Icons.privacy_tip);

    if (data == null) {
      return icon;
    }

    return [
      icon,
      if (data is Widget) data,
      if (data is! Widget)
        "$data".text(textAlign: TextAlign.center).paddingAll(kX),
    ].column()!;
  };

  /// 全局的错误占位小部件
  ///
  /// [WidgetStateBuildWidgetState]
  WidgetArgumentBuilder errorPlaceholderBuilder = <T>(context, error) {
    final icon =
        loadAssetImageWidget(
          libAssetsStateLoadErrorKey,
          package: 'flutter3_basics',
        )?.constrainedMax(
          maxWidth: kStateImageSize,
          maxHeight: kStateImageSize,
        ) ??
        const Icon(Icons.error);

    if (error == null) {
      return icon;
    }

    return [
      icon,
      if (error is Widget) error,
      "$error".text(textAlign: TextAlign.center).paddingAll(kX),
    ].column()!;
  };

  /// 全局的加载[Overlay]提示
  /// [OverlayEntry]
  /// [showLoading]
  ProgressWidgetBuilder loadingOverlayWidgetBuilder =
      (context, data, progress, color) {
        final loadingIndicator = GlobalConfig.of(
          context,
        ).loadingIndicatorBuilder(context, data, progress, color);
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
  AppBarDismissalBuilderFn appBarDismissalBuilder = (context, state) {
    return null;
  };

  /// 用来创建[AppBar]
  /// - [AppBarTheme] 相关默认样式在此声明, 可以通过[Theme]小部件覆盖
  /// - [scrolledUnderElevation] 滚动时, 阴影的高度
  /// - [backgroundColor] 透明的背景颜色, 会影响Android状态栏的颜色
  /// - [flexibleSpace] 纯白色的[AppBar]推荐使用此属性设置白色, 否则会和底色叠加.
  /// - [bottom].[AppBar.bottom]属性[PreferredSizeWidget]
  ///
  /// - [leading].[AppBar.leading]属性
  /// - [dismissal] 在可以back的情况下显示的返回按钮
  ///
  /// - [copyWith]
  ///
  /// - [AppBar]
  /// - [PreferredSizeSliverAppBar]
  late AppBarBuilderFn appBarBuilder =
      (
        context,
        state, {
        useSliverAppBar,
        leading,
        dismissal,
        automaticallyImplyLeading,
        title,
        actions,
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
        //debugger();
        final globalConfig = GlobalConfig.of(context);
        final globalTheme = GlobalTheme.of(context);
        elevation ??= globalConfig.themeData?.appBarTheme.elevation;
        scrolledUnderElevation ??=
            globalConfig.themeData?.appBarTheme.scrolledUnderElevation;
        //debugger();
        if (useSliverAppBar == true) {
          return PreferredSizeSliverAppBar(
            title: title,
            automaticallyImplyLeading: automaticallyImplyLeading ?? true,
            leading: leading is IgnoreWidget
                ? null
                : leading ??
                      (context.isAppBarDismissal
                          ? dismissal ?? appBarDismissalBuilder(context, state)
                          : null),
            actions: actions,
            bottom: bottom,
            elevation: elevation,
            shadowColor: shadowColor ?? globalTheme.appBarShadowColor,
            backgroundColor:
                backgroundColor ?? globalTheme.appBarBackgroundColor,
            foregroundColor:
                foregroundColor ?? globalTheme.appBarForegroundColor,
            scrolledUnderElevation: scrolledUnderElevation ?? elevation,
            flexibleSpace:
                flexibleSpace ??
                (backgroundColor == null
                    ? ((globalTheme.appBarGradientBackgroundColorList == null
                          ? null
                          : linearGradientWidget(
                              globalTheme.appBarGradientBackgroundColorList!,
                            )))
                    : null),
            centerTitle: centerTitle,
            titleSpacing: titleSpacing,
            floating: true,
            pinned: false,
          );
        }

        return AppBar(
          title: title,
          automaticallyImplyLeading: automaticallyImplyLeading ?? true,
          leading: leading is IgnoreWidget
              ? null
              : leading ??
                    (context.isAppBarDismissal
                        ? dismissal ?? appBarDismissalBuilder(context, state)
                        : null),
          actions: actions,
          elevation: elevation,
          scrolledUnderElevation: scrolledUnderElevation ?? elevation,
          bottom: bottom,
          shadowColor: shadowColor ?? globalTheme.appBarShadowColor,
          backgroundColor: backgroundColor ?? globalTheme.appBarBackgroundColor,
          foregroundColor: foregroundColor ?? globalTheme.appBarForegroundColor,
          flexibleSpace:
              flexibleSpace ??
              (backgroundColor == null
                  ? ((globalTheme.appBarGradientBackgroundColorList == null
                        ? null
                        : linearGradientWidget(
                            globalTheme.appBarGradientBackgroundColorList!,
                          )))
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
  Element? findWidgetsAppElement([BuildContext? context]) {
    final element = (context ?? globalTopContext)
        ?.findElementOfWidget<WidgetsApp>();
    return element;
  }

  /// 获取一个浮窗[OverlayState]状态
  OverlayState? getOverlayState([BuildContext? context]) {
    context ??= globalAppContext;
    if (context != null) {
      return Overlay.of(context);
    }
    return findOverlayState();
  }

  /// 从上往下查找 [OverlayState]
  /// [Overlay.of]
  OverlayState? findOverlayState([BuildContext? context]) {
    var element = (context ?? globalTopContext)?.findElementOfWidget<Overlay>();
    if (element is StatefulElement) {
      return element.state as OverlayState;
    }
    return null;
  }

  /// 获取一个导航[NavigatorState]状态
  NavigatorState? getNavigatorState([BuildContext? context]) {
    context ??= globalAppContext;
    if (context != null) {
      return Navigator.of(context);
    }
    return findNavigatorState();
  }

  /// 从上往下查找 [NavigatorState]
  /// [Navigator.of]
  NavigatorState? findNavigatorState([BuildContext? context]) =>
      (context ?? globalTopContext)?.findNavigatorState();

  /// 从上往下查找所有[ModalRoute], 查找所有路由器.
  /// release之后,字符串是否会变化?
  /// [ContextEx.findFirstNotSystemElement]
  @minifyProguardFlag
  List<(ModalRoute, Element?)> findModalRouteList([BuildContext? context]) {
    List<Element> routeElementList = [];
    List<(ModalRoute, Element?)> result = [];
    (context ?? globalTopContext)?.eachVisitChildElements((
      element,
      depth,
      childIndex,
    ) {
      /*if (element.runtimeType == StatefulElement ||
          element.runtimeType == StatelessElement ||
          element.runtimeType == InheritedElement) {
      } else {
        l.d(element.runtimeType);
      }*/
      if (element.widget.runtimeType.toString().toLowerCase().contains(
        "ModalScopeStatus".toLowerCase(),
      )) {
        routeElementList.add(element);
        return false;
      }
      /*if ("$element".startsWith("_ModalScopeStatus(") ||
          "$element"
              .toLowerCase()
              .contains("_ModalScopeStatus(".toLowerCase())) {
        routeElementList.add(element);
        return false;
      }*/
      return true;
    });
    for (final element in routeElementList) {
      //获取第一个子元素
      var isAdd = false;

      ModalRoute? findRoute;

      element.visitChildElements((element) {
        if (!isAdd) {
          final route = ModalRoute.of(element);
          if (route != null) {
            isAdd = true;
            findRoute = route;
            /*final firstElement = element.findFirstNotSystemElement();
            result.add((route, firstElement));*/
          }
        }
      });
      if (findRoute != null) {
        //debugger();
        final firstElement = element.findFirstNotSystemElement();
        result.add((findRoute!, firstElement ?? element));
      }
    }
    return result;
  }

  /// 获取一个[Locale]
  Locale? getLocale([BuildContext? context]) {
    context ??= globalAppContext;
    if (context != null) {
      return Localizations.maybeLocaleOf(context) ?? findLocale();
    }
    return findLocale();
  }

  /// 从上往下查找 [Localizations]
  /// [Localizations.localeOf]
  /// [Localizations.maybeLocaleOf]
  Locale? findLocale([BuildContext? context]) {
    //final element = globalTopContext?.findElementOfWidget<Localizations>();
    final element = (context ?? globalTopContext)
        ?.findElementOfWidget<Title>(); //通过title元素获取
    Locale? result;
    if (element is StatefulElement) {
      //_LocalizationsState 无法访问, 通过子元素访问
      element.visitChildElements((element) {
        result = Localizations.maybeLocaleOf(element) ?? result;
      });
    } else if (element != null) {
      result = Localizations.maybeLocaleOf(element) ?? result;
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
    BuildContext? globalTopContext,
    BuildContext? globalAppContext,
    ThemeMode? themeMode,
    Locale? locale,
    ThemeData? themeData,
    GlobalTheme? globalTheme,
    GlobalOpenUrlFn? openFileFn,
    GlobalOpenUrlFn? saveFileFn,
    GlobalOpenUrlFn? openUrlFn,
    GlobalShareDataFn? shareDataFn,
    GlobalWriteFileFn? writeFileFn,
    WidgetArgumentBuilder? imagePlaceholderBuilder,
    ProgressWidgetBuilder? loadingIndicatorBuilder,
    WidgetArgumentBuilder? errorPlaceholderBuilder,
    ProgressWidgetBuilder? loadingOverlayWidgetBuilder,
    AppBarBuilderFn? appBarBuilder,
    AppBarDismissalBuilderFn? appBarDismissalBuilder,
  }) {
    return GlobalConfig(
        globalTopContext: globalTopContext ?? this.globalTopContext,
        globalAppContext: globalAppContext ?? this.globalAppContext,
      )
      ..themeMode = themeMode ?? this.themeMode
      ..locale = locale ?? this.locale
      ..themeData = themeData ?? this.themeData
      ..globalTheme = globalTheme ?? this.globalTheme
      ..openFileFn = openFileFn ?? this.openFileFn
      ..saveFileFn = saveFileFn ?? this.saveFileFn
      ..openUrlFn = openUrlFn ?? this.openUrlFn
      ..shareDataFn = shareDataFn ?? this.shareDataFn
      ..writeFileFn = writeFileFn ?? this.writeFileFn
      ..imagePlaceholderBuilder =
          imagePlaceholderBuilder ?? this.imagePlaceholderBuilder
      ..loadingIndicatorBuilder =
          loadingIndicatorBuilder ?? this.loadingIndicatorBuilder
      ..errorPlaceholderBuilder =
          errorPlaceholderBuilder ?? this.errorPlaceholderBuilder
      ..loadingOverlayWidgetBuilder =
          loadingOverlayWidgetBuilder ?? this.loadingOverlayWidgetBuilder
      ..appBarBuilder = appBarBuilder ?? this.appBarBuilder
      ..appBarDismissalBuilder =
          appBarDismissalBuilder ?? this.appBarDismissalBuilder;
  }
}

//--

//region 全局

/// 注册一个全局App上下文改变的监听[ContextAction]
void $onGlobalAppContextChanged(ContextAction action) {
  GlobalConfig.def.addOnGlobalAppContextChanged(action);
}

/// 注册一个主题改变的监听[GlobalConfig]
/// [GlobalAppStateMixin]
StreamSubscription<GlobalConfig?> $onGlobalThemeChanged(
  ValueCallback<GlobalConfig> action,
) {
  return GlobalConfig.def.themeStreamOnce.listen((data) {
    if (data is GlobalConfig) {
      action(data);
    }
  });
}

/// [PlaceholderBuildContext]
BuildContext $placeholderContext = PlaceholderBuildContext();

/// 占位符上下文
class PlaceholderBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    //no op
    assert(() {
      l.w("${classHash()} noSuchMethod: ${invocation.memberName}");
      return true;
    }());
  }
}

//endregion 全局

//region Mixin

/// 混入一个主题改变回调
/// [GlobalConfig]
mixin GlobalAppStateMixin<T extends StatefulWidget> on State<T> {
  /// 订阅全局主题改变
  StreamSubscription<GlobalConfig?>? _subscription;

  @override
  void initState() {
    _subscription = $onGlobalThemeChanged((config) {
      //主题改变后, 持久化
      onGlobalThemeChanged(config);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  //MARK: - override

  @overridePoint
  void onGlobalThemeChanged(GlobalConfig config) {
    updateState();
  }
}

extension ThemeModeEx on ThemeMode {
  /// 获取当前主题的亮度
  Brightness get brightness => this == ThemeMode.system
      ? platformBrightness
      : this == ThemeMode.light
      ? Brightness.light
      : Brightness.dark;
}

//endregion Mixin

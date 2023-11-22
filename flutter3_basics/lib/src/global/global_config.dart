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
const double kDefaultBlurRadius = 4.0;
const double kDefaultBorderRadiusX = 6.0;
const double kDefaultBorderRadiusXX = 12.0;
const double kDefaultBorderRadiusXXX = 24.0;

/// 打开[url]的回调方法
typedef GlobalOpenUrlFn = Future<bool> Function(
    BuildContext? context, String? url);

/// 带参数的[WidgetBuilder]
typedef WidgetArgumentBuilder = Widget Function<T>(
    BuildContext context, T? arg);

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
    required this.globalConfig,
  });

  /// 配置存放
  final GlobalConfig globalConfig;

  @override
  bool updateShouldNotify(covariant GlobalConfigScope oldWidget) =>
      isDebug || globalConfig != oldWidget.globalConfig;
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

  static GlobalConfig get def => _def ??= GlobalConfig();

  /// 获取全局配置
  /// 使用[GlobalConfigScope]可以覆盖[GlobalConfig]
  static GlobalConfig of(BuildContext? context, {bool depend = false}) {
    GlobalConfig? globalConfig;
    if (depend) {
      globalConfig = (context ?? GlobalConfig.def.globalContext)
          ?.dependOnInheritedWidgetOfExactType<GlobalConfigScope>()
          ?.globalConfig;
    } else {
      globalConfig = context
          ?.findAncestorWidgetOfExactType<GlobalConfigScope>()
          ?.globalConfig;
    }
    return globalConfig ?? GlobalConfig.def;
  }

  /// 注册一个全局的打开url方法, 一般是跳转到web页面
  /// 打开url
  GlobalOpenUrlFn? openUrlFn = (context, url) {
    l.w("企图打开url:$url from:$context");
    return Future.value(false);
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
  WidgetBuilder loadingWidgetBuilder = (context) {
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

  /// 用来创建[AppBar]
  /// [AppBarTheme] 相关默认样式在此声明, 可以通过[Theme]小部件覆盖
  /// [scrolledUnderElevation] 滚动时, 阴影的高度
  /// [backgroundColor] 透明的背景颜色, 会影响Android状态栏的颜色
  PreferredSizeWidget? Function(
    BuildContext context,
    State state, {
    Widget? leading,
    Widget? title,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    double? scrolledUnderElevation,
    Color? shadowColor,
  }) appBarBuilder = (
    context,
    state, {
    leading,
    title,
    backgroundColor,
    foregroundColor,
    elevation,
    scrolledUnderElevation,
    shadowColor,
  }) {
    var globalTheme = GlobalTheme.of(context);
    return AppBar(
      title: title,
      leading: leading,
      elevation: elevation,
      shadowColor: shadowColor ?? globalTheme.shadowColor,
      backgroundColor: backgroundColor ?? globalTheme.themeWhiteColor,
      foregroundColor: foregroundColor ?? globalTheme.textPrimaryStyle.color,
      scrolledUnderElevation:
          scrolledUnderElevation ?? (elevation == 0 ? 0 : null),
    );
  };

  //endregion AppBar

  //region Overlay

  /// [OverlayManage]

  //endregion Overlay

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('GlobalConfig', "~GlobalConfig~"));
  }
}

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

class GlobalConfig with Diagnosticable, OverlayManage {
  GlobalConfig._();

  /// 全局默认
  static GlobalConfig? _def;

  static GlobalConfig get def => _def ??= GlobalConfig._();

  /// 获取全局配置
  /// 使用[GlobalAppConfig]可以覆盖[GlobalConfig]
  static GlobalConfig of(BuildContext? context, {bool depend = false}) {
    GlobalConfig? globalConfig;
    if (depend) {
      globalConfig = (context ?? GlobalConfig.def.globalContext)
          ?.dependOnInheritedWidgetOfExactType<GlobalAppConfig>()
          ?.globalConfig;
    } else {
      globalConfig = context
          ?.findAncestorWidgetOfExactType<GlobalAppConfig>()
          ?.globalConfig;
    }
    return globalConfig ?? GlobalConfig.def;
  }

  /// 全局的上下文
  BuildContext? globalContext;

  /// 注册一个全局的打开url方法, 一般是跳转到web页面
  /// 打开url
  GlobalOpenUrlFn? openUrlFn = (context, url) {
    l.w("企图打开url:$url from:$context");
    return Future.value(false);
  };

  //region ThemeData

  /// 全局的主题样式
  ThemeData themeData = ThemeData();

  /// 全局主题配置
  GlobalTheme globalThemeConfig = GlobalTheme();

  //endregion ThemeData

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

  //region Overlay

  /// [OverlayManage]

  //endregion Overlay

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('GlobalConfig', "~GlobalConfig~"));
  }
}

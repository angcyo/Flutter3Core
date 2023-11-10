part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

typedef GlobalOpenUrlFn = Future<bool> Function(
    BuildContext? context, String? url);

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

class GlobalConfig with Diagnosticable {
  GlobalConfig._();

  /// 全局默认
  static GlobalConfig? _def;

  static GlobalConfig get def => _def ??= GlobalConfig._();

  /// 获取全局配置
  /// 使用[GlobalAppConfig]可以覆盖[GlobalConfig]
  static GlobalConfig of(BuildContext context, {bool depend = false}) {
    GlobalConfig? globalConfig;
    if (depend) {
      globalConfig = context
          .dependOnInheritedWidgetOfExactType<GlobalAppConfig>()
          ?.globalConfig;
    } else {
      globalConfig = context
          .findAncestorWidgetOfExactType<GlobalAppConfig>()
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('GlobalConfig', "~GlobalConfig~"));
  }
}

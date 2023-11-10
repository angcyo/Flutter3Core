part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/10
///

extension GlobalConfigEx on BuildContext {
  /// [GlobalConfig.of]
  GlobalConfig globalConfig({bool depend = false}) =>
      GlobalConfig.of(this, depend: depend);
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('GlobalConfig', "~GlobalConfig~"));
  }
}

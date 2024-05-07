part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/23
///
/// Core一些持久化的key
final class CoreKeys {
  CoreKeys._();

  /// 测试数据
  String? get test => "test".hiveGet<String>(null);

  set test(String? value) {
    "test".hivePut(value);
  }

  /// 当前是否是调试标识
  bool get isDebugFlag => "isDebugFlag".hiveGet<bool>(isDebug) ?? isDebug;
}

/// CoreKeys的实例
@globalInstance
final coreKeys = CoreKeys._();

/// [isDebug]
/// [CoreKeys.isDebugFlag]
bool get isDebugFlag =>
    GlobalConfig.def.isDebugFlagFn?.call() ?? coreKeys.isDebugFlag;

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
}

/// CoreKeys的实例
@globalInstance
final coreKeys = CoreKeys._();

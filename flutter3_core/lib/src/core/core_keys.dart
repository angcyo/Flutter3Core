part of '../../flutter3_core.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/23
///
/// Core一些持久化的key
final class CoreKeys {
  CoreKeys._();

  /// 未设备分配一个uuid
  String get deviceUuid => "deviceUuid".hiveGet<String>(null) ?? $uuid;

  /// 初始化设备uuid
  void initDeviceUuid() {
    if (!"deviceUuid".hiveHaveKey()) {
      "deviceUuid".hivePut($uuid);
    }
  }

  /// 保存的值可以是true, false, 表示是否同意了隐私政策
  /// 也可以保存具体的版本信息, 表示同意了某个版本的隐私政策
  /// [Compliance]
  String get complianceAgree => "complianceAgree".hiveGet<String>() ?? "";

  set complianceAgree(String? value) {
    "complianceAgree".hivePut(value);
  }

  /// 测试数据
  String? get test => "test".hiveGet<String>(null);

  set test(String? value) {
    "test".hivePut(value);
  }

  /// 当前是否是调试标识
  bool get isDebugFlag => "isDebugFlag".hiveGet<bool>(isDebug) ?? isDebug;

  /// 平板尺寸阈值
  double? get tabletInchThreshold => "tabletInchThreshold".hiveGet<double>();
}

/// 是否是平板
bool get isTabletDevice => deviceInch >= ($coreKeys.tabletInchThreshold ?? 7);

/// CoreKeys的实例
@globalInstance
final $coreKeys = CoreKeys._();

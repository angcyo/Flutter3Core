part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/10/31
///
/// 全局初始化相关操作
@initialize
final beforeGlobalInitializeList = <FutureVoidAction>[];
@initialize
final afterGlobalInitializeList = <FutureVoidAction>[];
@complianceFlag
@initialize
final complianceGlobalInitializeList = <FutureVoidAction>[];

/// 注册一个全局初始化方法
@api
void $registerGlobalInitialize(
  FutureVoidAction action, {
  bool? before,
  bool? after,
}) {
  if (before ?? true) {
    beforeGlobalInitializeList.add(action);
  }
  if (after ?? false) {
    afterGlobalInitializeList.add(action);
  }
}

/// 注册一个合规之后的初始化方法
@api
@complianceFlag
void $registerGlobalComplianceInitialize(FutureVoidAction action) {
  complianceGlobalInitializeList.add(action);
}

/// 执行全局初始化方法
@initialize
@callPoint
Future<void> executeGlobalInitialize({
  bool? before,
  bool? after,
  bool? compliance,
}) async {
  if (before ?? false) {
    for (final element in beforeGlobalInitializeList) {
      await element();
    }
  }
  if (after ?? false) {
    for (final element in afterGlobalInitializeList) {
      await element();
    }
  }
  if (compliance ?? false) {
    for (final element in complianceGlobalInitializeList) {
      await element();
    }
  }
}

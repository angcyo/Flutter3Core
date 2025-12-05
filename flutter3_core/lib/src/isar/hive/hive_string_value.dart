part of '../../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/05
///
/// - get 自动从hive中读取
/// - set 自动存入hive
@immutable
final class HiveStringValue {
  final String key;

  const HiveStringValue(this.key);

  //MARK: - setter

  /// 赋值
  String? operator <<(String? value) {
    key.hivePut(value);
    return value;
  }

  /// 赋值
  String? set(String? value) => this << value;

  //MARK: - getter

  /// 获取
  String? get value => key.hiveGet();

  /// 获取
  String? get() => value;
}

/// [HiveStringValue]
HiveStringValue $hiveString(String? key) => HiveStringValue(key ?? $uuid);

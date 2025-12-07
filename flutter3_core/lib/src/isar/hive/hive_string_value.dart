part of '../../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/05
///
/// - get 自动从hive中读取
/// - set 自动存入hive
@immutable
final class HiveStringValue {
  /// 关键key
  final String key;

  /// 将这个值转存到另一个key中
  final String? relayKey;

  /// 默认值
  final String? def;

  const HiveStringValue(this.key, {this.def, this.relayKey});

  //MARK: - setter

  /// 赋值
  String? operator <<(String? value) {
    key.hivePut(value);
    relayKey?.hivePut(value);
    return value;
  }

  /// 赋值
  String? set(String? value) => this << value;

  //MARK: - getter

  /// 获取
  String? get value => key.hiveGet() ?? def;

  /// 获取
  String? get() => value;
}

/// [HiveStringValue]
HiveStringValue $hiveString(String? key, {String? def, String? relayKey}) =>
    HiveStringValue(key ?? $uuid, def: def, relayKey: relayKey);

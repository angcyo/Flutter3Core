part of '../../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/01
///
/// - [HiveStringValue]
/// - [HiveValue]
@immutable
@hiveFlag
final class HiveValue<T> {
  /// 关键key
  final String key;

  /// 将这个值转存到另一个key中
  final String? relayKey;

  /// 默认值
  final T? def;

  const HiveValue(this.key, {this.def, this.relayKey});

  //MARK: - setter

  /// 赋值
  T? operator <<(T? value) {
    key.hivePut(value);
    relayKey?.hivePut(value);
    return value;
  }

  /// 赋值
  T? set(T? value) => this << value;

  //MARK: - getter

  /// 获取
  T? get value => key.hiveGet() ?? def;

  /// 获取
  T? get() => value;

  //MARK: - other

  /// 判断是否和String对象相等
  bool isEqual(String? value) => value == this.value;

  @override
  bool operator ==(Object other) {
    if (other is HiveValue) {
      return other.value == value;
    }
    return this == other;
  }

  @override
  int get hashCode => value?.hashCode ?? super.hashCode;
}

/// [HiveValue]
HiveValue<T> $hiveValue<T>(String? key, {T? def, String? relayKey}) =>
    HiveValue(key ?? $uuid, def: def, relayKey: relayKey);

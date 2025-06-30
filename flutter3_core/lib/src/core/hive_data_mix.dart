part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/24
///
/// 自动持久化的[LiveStream]
/// 存储时: 优先调用对象的[toJson]方法, 转成[Map], 然后存储对应的json字符串.
/// 读取时: 将读到的字符串数据进行jsonDecode, 返回json obj.
///
/// [LiveStreamController]
class HiveLiveStream<T> extends LiveStreamController<T> {
  /// 持久化时的key
  @configProperty
  final String? hiveKey;

  /// 将json转换成对象[T]
  @configProperty
  final T? Function(dynamic json)? onConvertJsonToObj;

  /// 只在第一次初始化时, 触发.
  @configProperty
  final ValueCallback<T>? onInitValueAction;

  /// [autoInitHiveValue] 是否自动初始化数据
  HiveLiveStream(
    this.hiveKey,
    super.initialValue, {
    this.onInitValueAction,
    this.onConvertJsonToObj,
    bool autoInitHiveValue = true,
    super.autoClearValue = false,
    super.onUpdateValueAction,
  }) {
    final key = hiveKey;
    //debugger();
    if (autoInitHiveValue && key != null) {
      final value = readHiveValue();
      if (value != null) {
        latestValue = value;
        controller.add(value);
        onInitValueAction?.call(value);
      }
    }
  }

  @override
  void onValueChanged(T value) {
    super.onValueChanged(value);
    //debugger();
    final key = hiveKey;
    if (key != null) {
      assert(() {
        l.v("[$runtimeType]更新[$key]->$value");
        return true;
      }());
      if (value == null) {
        key.hiveDelete();
      } else {
        if (isBaseType(value)) {
          key.hivePut(value);
        } else {
          Object? obj;
          try {
            obj = value.toJson();
          } catch (e) {
            obj = value;
          }
          try {
            key.hivePut(jsonEncode(obj)); //存储json string
          } catch (e) {
            assert(() {
              print(e);
              return true;
            }());
          }
        }
      }
    }
  }

  /// 读取持久化的数据
  T? readHiveValue() {
    final key = hiveKey;
    if (key == null) {
      return null;
    } else {
      final value = key.hiveGet();
      if (value == null) {
        return null;
      } else {
        if (isBaseType(value)) {
          if (value is String) {
            try {
              final jsonObj = jsonDecode(value);
              return onConvertJsonToObj?.call(jsonObj);
            } catch (e) {
              assert(() {
                print(e);
                return true;
              }());
              return null;
            }
          }
          return value;
        }
      }
    }
    return null;
  }
}

/// [HiveLiveStream]
HiveLiveStream<T?> $hiveLive<T>(
  String? hiveKey,
  T? Function(dynamic json)? onConvertJsonToObj, {
  T? initialValue,
  ValueCallback<T?>? onInitValueAction,
  bool autoInitHiveValue = true,
  //--
  ValueCallback<T?>? onUpdateValueAction,
  bool autoClearValue = false,
}) =>
    HiveLiveStream<T?>(
      hiveKey,
      initialValue,
      autoInitHiveValue: autoInitHiveValue,
      onInitValueAction: onInitValueAction,
      onConvertJsonToObj: onConvertJsonToObj,
      onUpdateValueAction: onUpdateValueAction,
      autoClearValue: autoClearValue,
    );

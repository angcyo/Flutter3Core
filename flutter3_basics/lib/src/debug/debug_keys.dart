part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/23
///
///
typedef DebugKeyChanged = void Function(String key, dynamic value);
typedef DebugValueChanged = void Function(dynamic value);

final class DebugKeys {
  /// 声明一个监听key/value变化的对象
  static final List<DebugKeyChanged> _debugKeyChangedList = [];
  static final Map<String, List<DebugValueChanged>> _debugValueChangedMap = {};

  /// 通知调试[key]发生了变化时回调
  static void notifyDebugKeyChanged(String key, dynamic value) {
    //通知所有的监听者
    for (var element in _debugKeyChangedList) {
      try {
        element(key, value);
      } catch (e) {
        assert(() {
          l.d(e);
          return true;
        }());
      }
    }
    //通知指定key的所有监听者
    DebugKeys._debugValueChangedMap[key]?.forEach((element) {
      try {
        element(value);
      } catch (e) {
        assert(() {
          l.d(e);
          return true;
        }());
      }
    });
  }
}

extension DebugKeysEx on String {
  /// [notifyDebugKeyChanged]
  void notifyDebugValueChanged(dynamic value) {
    DebugKeys.notifyDebugKeyChanged(this, value);
  }
}

/// 注册一个key变化监听回调
void registerDebugKeyChanged(DebugKeyChanged debugKeyChanged) {
  if (!DebugKeys._debugKeyChangedList.contains(debugKeyChanged)) {
    DebugKeys._debugKeyChangedList.add(debugKeyChanged);
  }
}

/// 注销一个key变化监听回调
void unregisterDebugKeyChanged(DebugKeyChanged debugKeyChanged) {
  DebugKeys._debugKeyChangedList.remove(debugKeyChanged);
}

/// 注册一个value变化监听回调
void registerDebugValueChanged(
    String? key, DebugValueChanged debugValueChanged) {
  if (key != null) {
    List<DebugValueChanged> list = DebugKeys._debugValueChangedMap[key] ?? [];
    if (!list.contains(debugValueChanged)) {
      list.add(debugValueChanged);
    }
    DebugKeys._debugValueChangedMap[key] = list;
  }
}

/// 注销一个value变化监听回调
void unregisterDebugValueChanged(
    String? key, DebugValueChanged debugValueChanged) {
  if (key != null) {
    DebugKeys._debugValueChangedMap[key]?.remove(debugValueChanged);
  }
}

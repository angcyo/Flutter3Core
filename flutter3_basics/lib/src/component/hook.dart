part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/09
///
/// hook 需要自动释放的资源
/// 支持hook的资源:
///  - [StreamSubscription]
///  - [Listenable]
///  - [AnimationController]
///
/// [ListenableMixin]
/// [StreamSubscriptionMixin]
/// [AnimationMixin]
mixin HookMixin<T extends StatefulWidget> on State<T> {
  /// 资源
  @autoDispose
  late final List<dynamic> _hookAnyList = [];

  /// 资源
  @autoDispose
  late final Map<Listenable, VoidCallback> _hookAnyListenableMap = {};

  /// 资源
  /// hive key 改变通知
  @autoDispose
  late final Map<String, DebugValueChanged> _hookAnyKeyMap = {};

  //--

  /// 在[dispose]时, 释放所有hook的资源
  /// - [StreamSubscription]
  /// - [AnimationController]
  /// - cancel
  /// - dispose
  @api
  @autoDispose
  void hookAny(dynamic any) {
    _hookAnyList.add(any);
  }

  /// 在[dispose]时, 释放所有hook的资源
  /// [key] - [DebugKeysEx]
  /// [action] - [DebugValueChanged]
  @api
  @autoDispose
  void hookAnyKey(String key, VoidCallback action) {
    debugValueChanged(value) {
      action();
    }

    key.onDebugValueChanged(debugValueChanged);
    _hookAnyKeyMap[key] = debugValueChanged;
  }

  /// [hookAny]
  @api
  @autoDispose
  void hookAnyListenable(Listenable? value, VoidCallback action) {
    if (value == null) {
      return;
    }
    final oldListener = _hookAnyListenableMap[value];
    if (oldListener != null) {
      value.removeListener(oldListener);
    }
    _hookAnyListenableMap[value] = action;
    value.addListener(action);
  }

  ///监听[ValueListenable]的改变, 自动[dispose]
  ///自动转换成指定类型的数据结构[Data]
  @api
  @callPoint
  @autoDispose
  void hookAnyListenableValue<Data>(
      Listenable? value, ValueCallback<Data> action) {
    if (value == null) {
      return;
    }
    final oldListener = _hookAnyListenableMap[value];
    if (oldListener != null) {
      value.removeListener(oldListener);
    }
    valueAction() {
      if (value is ValueListenable) {
        try {
          action(value.value as Data);
        } catch (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
        }
      }
    }

    _hookAnyListenableMap[value] = valueAction;
    value.addListener(valueAction);
  }

  @override
  void dispose() {
    disposeAny();
    disposeAnyListenable();
    disposeAnyKey();
    super.dispose();
  }

  /// 释放
  void disposeAny() {
    try {
      for (final any in _hookAnyList) {
        try {
          if (any is StreamSubscription) {
            any.cancel();
          } else if (any is AnimationController) {
            any.dispose();
          } else {
            //兜底
            try {
              any.cancel();
            } catch (e) {
              //no op
            }
            try {
              any.dispose();
            } catch (e) {
              //no op
            }
          }
        } catch (e) {
          assert(() {
            l.e(e);
            return true;
          }());
        }
      }
    } finally {
      _hookAnyList.clear();
    }
  }

  /// 释放
  void disposeAnyListenable() {
    try {
      for (final key in _hookAnyListenableMap.keys) {
        try {
          final value = _hookAnyListenableMap[key];
          if (value != null) {
            key.removeListener(value);
          }
        } catch (e) {
          assert(() {
            l.e(e);
            return true;
          }());
        }
      }
    } finally {
      _hookAnyListenableMap.clear();
    }
  }

  /// 释放
  void disposeAnyKey() {
    try {
      for (final key in _hookAnyKeyMap.keys) {
        try {
          final value = _hookAnyKeyMap[key];
          if (value is DebugValueChanged) {
            key.removeDebugValueChanged(value);
          }
        } catch (e) {
          assert(() {
            l.e(e);
            return true;
          }());
        }
      }
    } finally {
      _hookAnyKeyMap.clear();
    }
  }
}

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
///
/// [HookStateMixin]
mixin HookMixin {
  /// 资源
  @autoDispose
  List<dynamic>? _hookAnyList;

  /// 带key的资源
  /// - [_hookAnyList]
  @autoDispose
  Map<String, List<dynamic>>? _hookAnyByKeyMap;

  /// 资源
  @autoDispose
  Map<Listenable, VoidCallback>? _hookAnyListenableMap;

  /// 资源
  /// hive key 改变通知
  @autoDispose
  Map<String, DebugValueChanged>? _hookAnyKeyMap;

  //region --hook--

  /// 在[dispose]时, 释放所有hook的资源
  /// - [StreamSubscription]
  /// - [AnimationController]
  /// - cancel
  /// - dispose
  @api
  @autoDispose
  void hookAny(dynamic any) {
    _hookAnyList ??= [];
    _hookAnyList?.add(any);
  }

  /// - [hookAnyByKey]
  /// - [disposeAnyByKey]
  @api
  @autoDispose
  void hookAnyByKey(String key, dynamic any) {
    _hookAnyByKeyMap ??= {};
    _hookAnyByKeyMap?.putIn(key, any, () => []);
  }

  /// 释放
  @api
  void disposeAnyByKey(String key) {
    try {
      if (_hookAnyByKeyMap != null) {
        final list = _hookAnyByKeyMap?.remove(key);
        if (list != null) {
          for (final any in list) {
            _disposeAny(any);
          }
        }
      }
    } catch (e, s) {
      //
    }
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
    _hookAnyKeyMap ??= {};
    _hookAnyKeyMap?[key] = debugValueChanged;
  }

  /// [hookAny]
  @api
  @autoDispose
  void hookAnyListenable(Listenable? value, VoidCallback action) {
    if (value == null) {
      return;
    }
    _hookAnyListenableMap ??= {};
    final oldListener = _hookAnyListenableMap?[value];
    if (oldListener != null) {
      value.removeListener(oldListener);
    }
    _hookAnyListenableMap?[value] = action;
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
    _hookAnyListenableMap ??= {};
    final oldListener = _hookAnyListenableMap?[value];
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

    _hookAnyListenableMap?[value] = valueAction;
    value.addListener(valueAction);
  }

  //endregion --hook--

  //region --dispose--

  /// 释放所有hook的资源
  @callPoint
  void disposeHook() {
    disposeAny();
    disposeAnyByKeyAll();
    disposeAnyListenable();
    disposeAnyKey();
  }

  /// 释放
  void disposeAny() {
    try {
      if (_hookAnyList != null) {
        for (final any in _hookAnyList!) {
          _disposeAny(any);
        }
      }
    } finally {
      _hookAnyList?.clear();
    }
  }

  /// 释放
  void disposeAnyListenable() {
    try {
      if (_hookAnyListenableMap != null) {
        for (final key in _hookAnyListenableMap!.keys) {
          try {
            final value = _hookAnyListenableMap?[key];
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
      }
    } finally {
      _hookAnyListenableMap?.clear();
    }
  }

  /// 释放
  void disposeAnyByKeyAll() {
    try {
      if (_hookAnyByKeyMap != null) {
        for (final key in _hookAnyByKeyMap!.keys) {
          disposeAnyByKey(key);
        }
      }
    } finally {
      _hookAnyByKeyMap?.clear();
    }
  }

  /// 释放
  void disposeAnyKey() {
    try {
      if (_hookAnyKeyMap != null) {
        for (final key in _hookAnyKeyMap!.keys) {
          try {
            final value = _hookAnyKeyMap?[key];
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
      }
    } finally {
      _hookAnyKeyMap?.clear();
    }
  }

  void _disposeAny(dynamic any) {
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

//endregion --dispose--
}

/// [HookMixin]
mixin HookStateMixin<T extends StatefulWidget> on State<T>, HookMixin {
  @override
  void dispose() {
    disposeHook();
    super.dispose();
  }
}

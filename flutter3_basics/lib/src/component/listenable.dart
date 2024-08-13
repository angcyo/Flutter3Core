part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/13
///
/// [Listenable]
mixin ListenableMixin<T extends StatefulWidget> on State<T> {
  late final Map<Listenable, VoidCallback> _listenableMap = {};

  ///监听[Listenable]的改变, 自动[dispose]
  @api
  @callPoint
  @autoDispose
  void hookListenable(Listenable? value, VoidCallback action) {
    if (value == null) {
      return;
    }
    final oldListener = _listenableMap[value];
    if (oldListener != null) {
      value.removeListener(oldListener);
    }
    _listenableMap[value] = action;
    value.addListener(action);
  }

  ///监听[ValueListenable]的改变, 自动[dispose]
  @api
  @callPoint
  @autoDispose
  void hookValueListenable<Data>(
      Listenable? value, ValueCallback<Data> action) {
    if (value == null) {
      return;
    }
    final oldListener = _listenableMap[value];
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

    _listenableMap[value] = valueAction;
    value.addListener(valueAction);
  }

  @override
  void dispose() {
    _listenableMap.forEach((key, value) {
      key.removeListener(value);
    });
    _listenableMap.clear();
    super.dispose();
  }
}

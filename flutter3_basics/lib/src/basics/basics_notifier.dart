part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/21
///
/// - [UpdateValueNotifier]
/// - [LoadingValueNotifier]
mixin NotifierMixin on ChangeNotifier {
  /// 是否已经被销毁
  bool _isNotifierDisposed = false;

  @override
  bool get hasListeners {
    if (_isNotifierDisposed) return false;
    return super.hasListeners;
  }

  @override
  void notifyListeners() {
    if (_isNotifierDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isNotifierDisposed = true;
    super.dispose();
  }

  //MARK: - listener

  /// 监听器列表
  List<VoidCallback?> listeners = [];

  /// 最后一个监听器
  VoidCallback? get lastListener => listeners.lastOrNull;

  @override
  void addListener(ui.VoidCallback listener) {
    super.addListener(listener);
    listeners.add(listener);
  }

  @override
  void removeListener(ui.VoidCallback listener) {
    listeners.remove(listener);
    super.removeListener(listener);
  }
}

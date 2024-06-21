part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/21
///

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
}

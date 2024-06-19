part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/19
///
/// 隐私合规管理
/// 在用户未同意隐私政策时, 不允许进行隐私相关的操作
/// 用户同意隐私政策之后, 调用[]方法, 进行相关初始化操作.
class Compliance {
  static final Compliance _instance = Compliance._();

  Compliance._();

  factory Compliance() => _instance;

  /// 是否已经同意了隐私政策
  bool _isAgree = false;

  /// 是否已经同意了隐私政策
  bool get isAgree => _isAgree;

  /// 同意隐私政策
  @api
  void agree() {
    _isAgree = true;
    _handlePendingCompleter(_isAgree);
  }

  /// 拒绝隐私政策
  @api
  void reject() {
    _isAgree = false;
    _handlePendingCompleter(_isAgree);
  }

  /// 检查隐私政策, 如果需要的话
  /// 自动处理[action]的返回值
  @api
  Future checkIfNeed(FutureVoidAction action) async {
    if (_isAgree) {
      return;
    }
    final result = await action();
    if (result is bool) {
      if (result) {
        agree();
      } else {
        reject();
      }
    }
  }

  /// 等待隐私政策同意
  final List<Completer> _pendingCompleterList = [];

  /// 处理等待中的[Completer]
  void _handlePendingCompleter(bool agree) {
    try {
      for (final completer in _pendingCompleterList) {
        try {
          completer.complete(agree);
        } catch (e) {
          assert(() {
            printError(e);
            return true;
          }());
        }
      }
    } catch (e) {
      assert(() {
        printError(e);
        return true;
      }());
    } finally {
      _pendingCompleterList.clear();
    }
  }

  /// 等待隐私政策的返回
  /// 如果同意了, 则直接返回true
  /// 如果拒绝了, 返回false
  /// [action] 同意与否执行的操作
  /// [checkIfNeed]
  @api
  Future<bool> wait([FutureBoolAction? action]) async {
    if (isAgree) {
      action?.call(isAgree);
      return true;
    }
    final completer = Completer<bool>();
    _pendingCompleterList.add(completer);
    final result = await completer.future;
    action?.call(isAgree);
    return result;
  }
}

/// 隐私合规管理
final Compliance $compliance = Compliance._instance;

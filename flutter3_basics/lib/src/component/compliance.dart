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
  void agree(BuildContext? context) {
    _isAgree = true;
    _handlePendingCompleter(context, _isAgree);
  }

  /// 拒绝隐私政策
  @api
  void reject(BuildContext? context) {
    _isAgree = false;
    _handlePendingCompleter(context, _isAgree);
  }

  /// 检查隐私政策, 如果需要的话
  /// 自动处理[action]的返回值
  ///
  /// - 如果已经同意了隐私政策, 则直接返回
  /// - 如果同意了隐私政策, 则执行[agree]
  /// - 如果拒绝了隐私政策, 则执行[reject]
  ///
  @api
  Future checkIfNeed(BuildContext? context, FutureVoidAction action) async {
    if (_isAgree) {
      return;
    }
    final result = await action();
    if (result is bool) {
      if (result) {
        agree(context);
      } else {
        reject(context);
      }
    }
  }

  /// 等待隐私政策同意
  final List<Completer> _pendingCompleterList = [];

  /// 处理等待中的[Completer]
  void _handlePendingCompleter(BuildContext? context, bool agree) {
    //debugger();
    try {
      for (final completer in _pendingCompleterList) {
        try {
          completer.complete(context);
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
  Future wait([ComplianceAction? action]) async {
    if (isAgree) {
      return action?.call(null, isAgree);
    }
    final completer = Completer<BuildContext?>();
    _pendingCompleterList.add(completer);
    final context = await completer.future;
    return action?.call(context, isAgree);
  }
}

/// 合规返回回调
typedef ComplianceAction = FutureOr Function(BuildContext? context, bool value);

/// 隐私合规管理
final Compliance $compliance = Compliance._instance;

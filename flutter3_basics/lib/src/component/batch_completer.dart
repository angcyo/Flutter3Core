part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/16
///

typedef BatchResult<T> = (T? value, dynamic error);

/// 批量完成器, 当收集到指定数量的结果时, 自动执行完成回调
/// [Completer]
class BatchCompleter<T> {
  BatchCompleter(this.count);

  /// 需要收集的结果数量
  final int count;

  /// 收集到的结果
  final List<BatchResult<T>> _resultList = [];

  final Completer<List<BatchResult<T>>> _completer =
      Completer<List<BatchResult<T>>>();

  /// 完成的Future
  Future<List<BatchResult<T>>> get future => _completer.future;

  /// 添加一个结果
  @api
  void addResult(T result, [dynamic error]) {
    if (_completer.isCompleted) {
      assert(() {
        l.w('BatchCompleter is completed.');
        return true;
      }());
    } else {
      _resultList.add((result, error));
      if (_resultList.length >= count) {
        _completer.complete(_resultList);
      }
    }
  }

  /// 添加一个错误
  @api
  void addError(dynamic error) {
    if (_completer.isCompleted) {
      assert(() {
        l.w('BatchCompleter is completed.');
        return true;
      }());
    } else {
      _resultList.add((null, error));
      if (_resultList.length >= count) {
        _completer.complete(_resultList);
      }
    }
  }
}

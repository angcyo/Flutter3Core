part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/16
///

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
  void addResult(String key, dynamic request, T response,
      [dynamic error, StackTrace? stackTrace]) {
    if (_completer.isCompleted) {
      assert(() {
        l.w('BatchCompleter is completed.');
        return true;
      }());
    } else {
      _resultList.add(BatchResult(key, request, response, error, stackTrace));
      if (_resultList.length >= count) {
        _completer.complete(_resultList);
      }
    }
  }

  /// 添加一个错误
  @api
  void addError(
    String key,
    dynamic request,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    if (_completer.isCompleted) {
      assert(() {
        l.w('BatchCompleter is completed.');
        return true;
      }());
    } else {
      _resultList.add(BatchResult(
        key,
        request,
        null,
        error,
        stackTrace ?? StackTrace.current,
      ));
      if (_resultList.length >= count) {
        _completer.complete(_resultList);
      }
    }
  }
}

/// 批量请求和请求的返回结果
class BatchResult<T> {
  const BatchResult(
    this.key,
    this.request,
    this.response,
    this.error,
    this.stackTrace,
  );

  /// [key] 唯一标识, 请求对应的key, 通常是设备id
  /// 用来标识请求的唯一性
  final String key;

  /// 请求
  final dynamic request;

  /// [request] 的请求结果
  final T? response;

  /// [error] 请求错误
  final dynamic error;

  /// [stackTrace] 错误堆栈
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'BatchResult{key:$key, request:$request response:$response, error:$error, stackTrace:$stackTrace}';
  }
}

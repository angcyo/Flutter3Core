part of flutter3_basics;

///
/// https://blog.csdn.net/weixin_41735943/article/details/119168792
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/08
///

/// 等待异步内容完成
/// [Completer]
/*class AsyncOperation {
  final Completer _completer = Completer();

  Future<T> doOperation() {
    _startOperation();
    return _completer.future; // Send future object back to client.
  }

  // Something calls this when the value is ready.
  void _finishOperation(T result) {
    _completer.complete(result);
  }

  // If something goes wrong, call this.
  void _errorHappened(error) {
    _completer.completeError(error);
  }
}*/

/// 等待异步内容完成
Future<T> awaitFor<T>(Function(Function(T) action) doOperation) {
  var completer = Completer<T>();
  doOperation((result) => completer.complete(result));
  return completer.future;
}

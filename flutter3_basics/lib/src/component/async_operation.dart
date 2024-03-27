part of flutter3_basics;

///
/// https://blog.csdn.net/weixin_41735943/article/details/119168792
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/08
///
/// ```
/// /// image util.
/// class _ImageUtil {
///   late ImageStreamListener listener;
///   late ImageStream imageStream;
///
///   /// get image size.
///   Future<Rect>? getImageSize(Image? image) {
///     if (image == null) {
///       return null;
///     }
///     Completer<Rect> completer = Completer<Rect>();
///     listener = ImageStreamListener(
///       (ImageInfo info, bool synchronousCall) {
///         imageStream.removeListener(listener);
///         if (!completer.isCompleted) {
///           completer.complete(Rect.fromLTWH(
///               0, 0, info.image.width.toDouble(), info.image.height.toDouble()));
///         }
///       },
///       onError: (dynamic exception, StackTrace? stackTrace) {
///         imageStream.removeListener(listener);
///         if (!completer.isCompleted) {
///           completer.completeError(exception, stackTrace);
///         }
///       },
///     );
///     imageStream = image.image.resolve(ImageConfiguration());
///     imageStream.addListener(listener);
///     return completer.future;
///   }
/// }
/// ```
///
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

/// 等待异步操作完成
Future<T> awaitFor<T>(Function(Function(T) action) doOperation) {
  var completer = Completer<T>();
  try {
    doOperation((result) => completer.complete(result));
  } catch (e) {
    assert(() {
      l.e("$e");
      return true;
    }());
    completer.completeError(e, StackTrace.current);
  }
  return completer.future;
}

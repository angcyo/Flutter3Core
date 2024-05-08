part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/31
///
/// 用来实现[Future]取消, 使用[Future.any]来实现
/// 参考dio的[CancelToken]
class FutureCancelToken {
  /// 用来发送取消信号的[Completer]
  final Completer<FutureCancelException> _completer =
      Completer<FutureCancelException>();

  FutureCancelException? _cancelException;

  /// 是否已经取消
  bool get isCanceled => _cancelException != null;

  /// When cancelled, this future will be resolved.
  Future<FutureCancelException> get whenCancel => _completer.future;

  /// 使用给定的原因, 取消[Future]
  /// Cancel the request with the given [reason].
  void cancel([Object? reason]) {
    if (!isCanceled && !_completer.isCompleted) {
      _cancelException = FutureCancelException(
        reason,
        StackTrace.current,
      );
      _completer.complete(_cancelException);
    }
  }
}

/// [Future]被取消时, 传递的异常信息
/// [StackTrace.current]
class FutureCancelException implements Exception {
  final Object? reason;
  final StackTrace? stackTrace;

  FutureCancelException(this.reason, this.stackTrace);

  @override
  String toString() {
    return 'FutureCancelException{reason:$reason}';
  }
}

extension FutureCancelEx<T> on Future<T> {
  //FutureCancelToken hookCancelToken = FutureCancelToken();

  /// 使用[cancelToken]实现当前[Future]的取消操作
  /// 监听取消[Future]执行
  Future<T> listenCancel<T>(FutureCancelToken? cancelToken) {
    // 只要有一个完成, 就算完成.
    // 所以取消Future先完成, 就可以取消后面的Future执行
    return Future.any([
      if (cancelToken != null) cancelToken.whenCancel.then((e) => throw e),
      this as Future<T>,
    ]);
  }
}

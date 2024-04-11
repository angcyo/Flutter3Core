part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

/// [Exception] 异常
class RException implements Exception {
  /// 异常的原因
  final dynamic cause;

  /// 异常的消息
  final String? message;

  final StackTrace? stackTrace;

  RException({
    this.message,
    this.cause,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return message ?? cause ?? super.toString();
  }
}

/// [Error] 错误
class RError extends Error {
  /// 错误的原因
  final dynamic cause;

  /// 错误的消息
  final String? message;

  RError({this.message, this.cause});

  @override
  String toString() {
    return message ?? cause ?? super.toString();
  }
}

/// 超时异常
class RTimeoutException extends RException {
  RTimeoutException({super.message, super.cause, super.stackTrace});
}

/// 操作被取消的异常
class RCancelException extends RException {
  RCancelException({super.message, super.cause, super.stackTrace});
}

/// 无效的操作异常
class RInvalidException extends RException {
  RInvalidException({super.message, super.cause, super.stackTrace});
}

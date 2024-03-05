part of flutter3_basics;

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

  RException({this.message, this.cause});

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

part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

/// [Error]
/// [Exception]
class RException implements Exception {
  final dynamic cause;
  final String? message;

  RException(this.message, {this.cause});

  @override
  String toString() {
    return message ?? cause ?? super.toString();
  }
}

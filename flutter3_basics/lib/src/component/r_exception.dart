part of flutter3_basics;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

/// [Error]
/// [Exception]
class RException implements Exception {
  final String? message;

  RException([this.message]);

  @override
  String toString() {
    return message ?? super.toString();
  }
}

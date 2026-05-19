part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/20
///
/// [RException]
class RHttpException implements Exception {
  /// 网络状态码
  final int? statusCode;

  /// 异常的消息
  final String? message;

  /// 异常对象
  final Object? error;

  /// 是否是授权失败401的错误
  bool get isAuthError => statusCode == 401;

  /// 请求的响应对象
  Response? get response {
    final err = error;
    if (err is DioException) {
      return err.response;
    }
    return null;
  }

  /// 获取响应头
  String? getResponseHeader(String? key) {
    if (key == null) {
      return null;
    }
    final response = this.response;
    if (response != null) {
      return response.headers.value(key);
    }
    return null;
  }

  RHttpException({this.statusCode, this.message, this.error});

  @override
  String toString() {
    return 'RHttpException[$statusCode]->$message';
  }
}

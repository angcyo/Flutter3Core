part of flutter3_http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/04
///

class TokenInterceptor extends Interceptor {
  /// 配置token
  /// [options] 请求配置
  /// [RequestOptions.headers] 配置token的回调
  void Function(RequestOptions options)? configToken;

  /// token是否失效
  bool Function(Response response)? isTokenInvalid;

  TokenInterceptor({
    this.configToken,
    this.isTokenInvalid,
  }) {
    isTokenInvalid ??= (response) {
      if (response.statusCode == 401) {
        l.w("token失效");
        return true;
      }
      return false;
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    configToken?.call(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    isTokenInvalid?.call(response);
  }
}

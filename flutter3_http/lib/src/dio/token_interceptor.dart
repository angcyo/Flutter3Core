part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/04
///

/// token拦截器
/// 401重新请求token
/// https://github.com/cfug/dio/issues/195
/// dio 拦截器实现 token 失效刷新
/// https://juejin.cn/post/6844903785823731726
class TokenInterceptor extends Interceptor {
  /// 配置token
  /// [options] 请求配置
  /// [RequestOptions.headers] 配置token的回调
  void Function(RequestOptions options)? configToken;

  /// token是否失效
  bool Function(Response response)? isTokenInvalid;

  /// 刷新token
  /// @return true:表示刷新成功, false/null: 默认处理
  Future<bool> Function(Response response)? refreshToken;

  TokenInterceptor({
    this.configToken,
    this.isTokenInvalid,
    this.refreshToken,
  }) {
    isTokenInvalid ??= (response) {
      if (response.statusCode == 401) {
        assert(() {
          l.w("token失效, 请重新登录!");
          return true;
        }());
        return true;
      }
      return false;
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    try {
      configToken?.call(options);
    } catch (e) {
      l.w('配置token失败[${options.uri}]:$e↓');
      printError(e);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    var refreshToken = await checkOrRefreshToken(response);
    if (refreshToken == true) {
      //重新请求
      var newResponse = await rDio.reRequest(response.requestOptions);
      super.onResponse(newResponse, handler);
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var refreshToken = await checkOrRefreshToken(err.response);
    if (refreshToken == true) {
      //重新请求
      var newResponse = await rDio.reRequest(err.requestOptions);
      handler.resolve(newResponse);
      return;
    }
    super.onError(err, handler);
  }

  /// 检查或者请求刷新token
  /// @return true token刷新成功
  Future<bool?> checkOrRefreshToken(Response? response) async {
    if (response == null) {
      return null;
    }
    if (isTokenInvalid?.call(response) == true) {
      //token失效, 请求新的token
      return await refreshToken?.call(response) ?? false;
    } else {
      //token有效
      return null;
    }
  }
}

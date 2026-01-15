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
  /// 当前接口禁止验证Token
  /// String:String
  static const String kNoTokenVerify = 'noTokenVerify';

  /// 当前接口禁止请求刷新token
  /// String:String
  static const String kNoRefreshTokenKey = 'noRefreshToken';

  //--

  /// 配置token
  /// [options] 请求配置
  /// [RequestOptions.headers] 配置token的回调
  void Function(RequestOptions options)? configToken;

  /// token是否失效
  bool Function(Response response)? isTokenInvalid;

  /// 刷新token
  /// @return true:表示刷新成功, false/null: 默认处理
  Future<bool> Function(Response response)? refreshToken;

  TokenInterceptor({this.configToken, this.isTokenInvalid, this.refreshToken}) {
    isTokenInvalid ??= (response) {
      if (response.statusCode == 401 && response.isSameOrigin()) {
        assert(() {
          l.w("token失效, 请重新登录!");
          return true;
        }());
        debugger();
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
    } catch (e, s) {
      debugger();
      l.w('配置token失败[${options.uri}]:$e↓');
      printError(e, s);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final refreshToken = await checkOrRefreshToken(
      response.requestOptions,
      response,
    );
    if (refreshToken == true) {
      //刷新了token, 则重新请求
      final newResponse = await rDio.reRequest(response.requestOptions);
      super.onResponse(newResponse, handler);
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final refreshToken = await checkOrRefreshToken(
      err.requestOptions,
      err.response,
    );
    if (refreshToken == true) {
      //刷新了token, 则重新请求
      final newResponse = await rDio.reRequest(err.requestOptions);
      handler.resolve(newResponse);
      return;
    }
    super.onError(err, handler);
  }

  /// 检查或者请求刷新token
  /// @return true token刷新成功
  Future<bool?> checkOrRefreshToken(
    RequestOptions requestOptions,
    Response? response,
  ) async {
    if (response == null || !response.isSameOrigin() || refreshToken == null) {
      return null;
    }
    final noTokenVerify =
        requestOptions.getQuery(kNoTokenVerify)?.toBoolOrNull() == true;
    if (!noTokenVerify && isTokenInvalid?.call(response) == true) {
      debugger();
      //token失效, 请求新的token, 刷新token请求
      final value = response.getQuery(kNoRefreshTokenKey);
      if (value != null && value.toBoolOrNull() == true) {
        //不重新请求token
        return null;
      }
      return await refreshToken?.call(response);
    } else {
      //token有效
      return null;
    }
  }
}

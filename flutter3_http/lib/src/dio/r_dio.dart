part of flutter3_http;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

/// 全局单例
/// [DioScope]
final RDio rDio = RDio();
final LogFileInterceptor _logFileInterceptor = LogFileInterceptor();

/// 默认的超时时长, s
const kDefTimeout = 10;

class RDio {
  /// 获取一个上层提供的[RDio],如果有.
  /// 如果有没有则返回单例
  static RDio get({BuildContext? context, bool depend = false}) {
    if (depend) {
      return context?.dependOnInheritedWidgetOfExactType<DioScope>()?.rDio ??
          rDio;
    } else {
      return context?.getInheritedWidgetOfExactType<DioScope>()?.rDio ?? rDio;
    }
  }

  /// dio对象
  late final Dio _dio = Dio()
        ..options.connectTimeout = const Duration(seconds: kDefTimeout)
        ..options.sendTimeout = const Duration(seconds: kDefTimeout)
        ..options.receiveTimeout = const Duration(seconds: kDefTimeout) //超时设置
      ;

  /*..httpClientAdapter = Http2Adapter(
      ConnectionManager(idleTimeout: const Duration(seconds: 10)),
    )*/

  /// 获取一个dio对象, 并设置[baseUrl]
  Dio get dio => _dio
        ..options.baseUrl = Http.getBaseUrl?.call() ?? ""
        ..interceptors.remove(_logFileInterceptor)
        ..interceptors.add(_logFileInterceptor) //日志拦截器需要放在最后
      ;

  /// 添加一个拦截器, 调用此方法. 方便调试
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  /// 移除一个拦截器
  void removeInterceptor(Interceptor interceptor) {
    dio.interceptors.remove(interceptor);
  }

  /// 重新请求
  Future<Response<T>> reRequest<T>(RequestOptions options) =>
      dio.fetch(options);
}

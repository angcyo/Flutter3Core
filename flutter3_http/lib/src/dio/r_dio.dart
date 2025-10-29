part of '../../flutter3_http.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///
/// 全局的网络请求封装,
/// # 拦截器
/// - [LogFileInterceptor] -默认添加
/// - [AppInfoInterceptor] -默认添加
/// - [TokenInterceptor]
///
/// # Host
/// 可以通过[Http.baseUrl]进行配置.
/// [$host]可以获取当前配置的host.
///
/// # 进行请求
/// [DioStringEx]
///
/// ```
/// "/xxx".get().http((value, error){});
/// "/xxx".post().http((value, error){});
/// ```

/// 全局单例
/// [DioScope]
final RDio rDio = RDio();
final LogFileInterceptor _logFileInterceptor = LogFileInterceptor();

/// 默认的超时时长, s
const kDefTimeout = 10;

class RDio {
  /// 获取一个上层提供的[RDio],如果有.
  /// 如果有没有则返回单例
  ///
  /// ```
  /// Error: Requested the Locale of a context that does not include a Localizations ancestor.
  /// To request the Locale, the context used to retrieve the Localizations widget must be that of a widget that is a descendant of a Localizations widget.
  /// ```
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
  ///
  /// [AppInfoInterceptor]
  /// [LogFileInterceptor]
  /// [TokenInterceptor]
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

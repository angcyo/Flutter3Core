part of flutter3_http;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

/// 全局单例
/// [DioScope]
final RDio rDio = RDio();

class RDio {
  /// dio对象
  late final Dio dio = Dio()
        ..options.baseUrl = Http.getBaseUrl?.call() ?? ""
        ..options.connectTimeout = const Duration(seconds: 5) //5s
        ..options.sendTimeout = const Duration(seconds: 5)
        ..options.receiveTimeout = const Duration(seconds: 5) //3s
        ..interceptors.add(LogFileInterceptor())

      /*..httpClientAdapter = Http2Adapter(
      ConnectionManager(idleTimeout: const Duration(seconds: 10)),
    )*/
      ;

  /// 获取一个上层提供的[RDio],如果有.
  /// 如果有没有则返回单例
  static RDio get({BuildContext? context, bool depend = false}) {
    if (depend) {
      return context?.dependOnInheritedWidgetOfExactType<DioScope>()?.rDio ??
          rDio;
    } else {
      return context?.findAncestorWidgetOfExactType<DioScope>()?.rDio ?? rDio;
    }
  }
}

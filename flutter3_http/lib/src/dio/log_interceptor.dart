import 'package:dio/dio.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

class LogFileInterceptor extends Interceptor {
  final Map<int, String> uuidMap = {};
  final bool toFile;

  LogFileInterceptor({
    this.toFile = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print("错误:${err.requestOptions.uri}");
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    var hashCode = options.hashCode;
    var id = uuid();
    uuidMap[hashCode] = id;
    var log = stringBuilder((builder) {
      builder.appendLine("-->$id");
      builder.appendLine("[${options.method}]${options.uri}");
      builder.append(
        'responseType:',
        options.responseType.toString(),
        lineSeparator,
      );
      builder.append(
          'followRedirects:', options.followRedirects, lineSeparator);
      builder.append(
          'persistentConnection:', options.persistentConnection, lineSeparator);
      builder.append('connectTimeout:', options.connectTimeout, lineSeparator);
      builder.append('sendTimeout:', options.sendTimeout, lineSeparator);
      builder.append('receiveTimeout:', options.receiveTimeout, lineSeparator);
      builder.append('receiveDataWhenStatusError:',
          options.receiveDataWhenStatusError, lineSeparator);
      builder.append('extra:', options.extra, lineSeparator);
      builder.appendLine('headers↓');
      options.headers
          .forEach((key, v) => builder.append(' $key:', v, lineSeparator));
      if (options.data != null) {
        builder.appendLine('data↓');
        builder.appendAll(options.data);
      }
    });
    if (toFile) {
      GlobalConfig.def.writeFileFn?.call('http.log', 'log', log);
    }
    l.d(log);
  }

  void _logResponse(Response response) {
    var hashCode = response.requestOptions.hashCode;
    var id = uuidMap[hashCode];
    var log = stringBuilder((builder) {
      builder.appendLine("<--$id");
      builder
          .appendLine("[${response.statusCode}]${response.requestOptions.uri}");
      if (response.isRedirect == true) {
        builder.append('redirect:', response.realUri, lineSeparator);
      }
      builder.appendLine('headers↓');
      response.headers
          .forEach((key, v) => builder.append(' $key:', v, lineSeparator));
      builder.appendLine('data↓');
      builder.appendAll(response.toString());
    });
    if (toFile) {
      GlobalConfig.def.writeFileFn?.call('http.log', 'log', log);
    }
    l.d(log);
  }
}

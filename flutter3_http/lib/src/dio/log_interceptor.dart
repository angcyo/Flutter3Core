import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

/// [LogInterceptor]
class LogFileInterceptor extends Interceptor {
  final Map<int, (String id, int startTime)> uuidMap = {};
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
    //debugger();
    _logResponse(response);
    super.onResponse(response, handler);
    //debugger();
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    var hashCode = err.requestOptions.hashCode;
    var value = uuidMap.remove(hashCode);
    var log = stringBuilder((builder) {
      if (value == null) {
        builder.appendLine("<--${err.requestOptions.uri}");
      } else {
        builder.appendLine("<--${value.$1} ${LTime.diffTime(value.$2)}");
      }
      builder.appendLine("$err");
      if (err.response != null) {
        builder.append(_responseLog(err.response!));
      }
    });
    _printLog(log);
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    var hashCode = options.hashCode;
    var id = uuid();

    //添加请求头
    options.headers["log-uuid"] = id;
    options.headers["request-time"] = nowTime(); //请求时间

    uuidMap[hashCode] = (id, nowTime());
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
        builder.appendLine('data(${options.data.runtimeType})↓');
        builder.appendAll(options.data);
      }
    });
    _printLog(log);
  }

  void _logResponse(Response response) {
    var hashCode = response.requestOptions.hashCode;
    var value = uuidMap.remove(hashCode);
    var log = stringBuilder((builder) {
      builder.appendLine("<--${value?.$1} ${LTime.diffTime(value?.$2)}");
      builder.append(_responseLog(response));
    });
    _printLog(log);
  }

  String _responseLog(Response response) {
    var log = stringBuilder((builder) {
      builder
          .appendLine("[${response.statusCode}]${response.requestOptions.uri}");
      if (response.isRedirect == true) {
        builder.append('redirect:', response.realUri, lineSeparator);
      }
      builder.appendLine('headers↓');
      response.headers
          .forEach((key, v) => builder.append(' $key:', v, lineSeparator));
      builder.appendLine('data(${response.data.runtimeType})↓');
      builder.appendAll(response.toString());
    });
    return log;
  }

  void _printLog(String log) {
    //debugger();
    if (toFile) {
      GlobalConfig.def.writeFileFn?.call('http.log', 'log', log);
    }
    l.d(log);
  }
}

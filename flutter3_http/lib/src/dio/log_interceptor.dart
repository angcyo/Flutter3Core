import 'package:dio/dio.dart';
import 'package:flutter3_basics/flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///
/// ```
/// 通过在url后面拼接`noLogPrint=true`可以关闭日志输出
/// ```
///
/// [RequestOptions.extra]
///
/// [LogInterceptor]
class LogFileInterceptor extends Interceptor {
  /// 禁止打印日志
  static const String kNoLogPrintKey = 'noLogPrint';

  /// 禁止打印请求日志
  static const String kNoRequestLogPrintKey = 'noRequestLogPrint';

  /// 禁止打印响应日志
  static const String kNoResponseLogPrintKey = 'noResponseLogPrint';

  /// 禁止日志写入文件
  static const String kNoLogFileKey = 'noLogFile';
  final Map<int, (String id, int startTime)> uuidMap = {};
  final bool toFile;
  final bool toPrint;

  LogFileInterceptor({this.toFile = true, this.toPrint = true});

  /// ```
  /// handler.resolve(response);
  /// ```
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
    final options = err.requestOptions;
    final queryParameters = options.uri.queryParameters;
    final noLogPrint =
        queryParameters[kNoLogPrintKey]?.toBoolOrNull() ??
        options.extra[kNoLogPrintKey]?.toBoolOrNull() ??
        !toPrint;
    final noLogFile =
        queryParameters[kNoLogFileKey]?.toBoolOrNull() ??
        options.extra[kNoLogFileKey]?.toBoolOrNull() ??
        !toFile;

    final hashCode = options.hashCode;
    final value = uuidMap.remove(hashCode);
    final log = stringBuilder((builder) {
      if (value == null) {
        builder.appendLine(
          "<--${err.requestOptions.uri}(Dio异常[${err.response?.statusCode}])",
        );
      } else {
        builder.appendLine(
          "<--${value.$1} ${LTime.diffTime(value.$2)}(Dio异常[${err.response?.statusCode}])",
        );
      }
      builder.appendLine("error->$err");
      if (err.response != null) {
        builder.append("response->");
        builder.append(_responseLog(err.response!));
      }
    });
    _printLog(log, toFile: noLogFile == false, toPrint: noLogPrint == false);
    super.onError(err, handler);
    assert(() {
      l.e(
        "${err.response?.statusCode?.toString().connect("]", "[")}"
        "请求失败[${err.requestOptions.uri}]->$err",
      );
      return true;
    }());
  }

  void _logRequest(RequestOptions options) {
    final hashCode = options.hashCode;
    final id = $uuid;

    //日志输出控制
    final queryParameters = options.uri.queryParameters;
    final noLogPrint =
        queryParameters[kNoLogPrintKey]?.toBoolOrNull() ??
        options.extra[kNoLogPrintKey]?.toBoolOrNull() ??
        !toPrint;
    final noLogFile =
        queryParameters[kNoLogFileKey]?.toBoolOrNull() ??
        options.extra[kNoLogFileKey]?.toBoolOrNull() ??
        !toFile;
    final noRequestLogPrint =
        queryParameters[kNoRequestLogPrintKey]?.toBoolOrNull() ??
        options.extra[kNoRequestLogPrintKey]?.toBoolOrNull() ??
        !toPrint;

    //添加请求头
    options.headers["logUuid"] = id;
    options.headers["requestTime"] = nowTimestamp(); //请求时间

    uuidMap[hashCode] = (id, nowTimestamp());
    final log = stringBuilder((builder) {
      builder.appendLine("-->$id");
      builder.appendLine("[${options.method}]${options.uri}");
      builder.appendLine('options[${options.runtimeType}]↓');
      builder.append(
        'responseType:',
        options.responseType.toString(),
        lineSeparator,
      );
      builder.append(
        'followRedirects:',
        options.followRedirects,
        lineSeparator,
      );
      builder.append(
        'persistentConnection:',
        options.persistentConnection,
        lineSeparator,
      );
      builder.append('connectTimeout:', options.connectTimeout, lineSeparator);
      builder.append('sendTimeout:', options.sendTimeout, lineSeparator);
      builder.append('receiveTimeout:', options.receiveTimeout, lineSeparator);
      builder.append(
        'receiveDataWhenStatusError:',
        options.receiveDataWhenStatusError,
        lineSeparator,
      );
      builder.append('extra:', options.extra, lineSeparator);
      builder.appendLine('headers[${options.headers.length}]↓');
      options.headers.forEach(
        (key, v) => builder.append(' $key:', v, lineSeparator),
      );
      final data = options.data;
      if (data != null) {
        //debugger();
        builder.appendLine('options.data(${data.runtimeType})↓');
        if (data is FormData) {
          builder.appendAll(data.fields);
        } else if (data is Iterable<int>) {
          builder.appendAll(data.length.toSizeStr(space: " "));
        } else {
          builder.appendAll(data);
        }
      }
    });
    _printLog(
      log,
      toFile: noLogFile == false,
      toPrint: noLogPrint == false && noRequestLogPrint == false,
    );
  }

  void _logResponse(Response response) {
    final options = response.requestOptions;
    final queryParameters = options.uri.queryParameters;
    final noLogPrint =
        queryParameters[kNoLogPrintKey]?.toBoolOrNull() ??
        options.extra[kNoLogPrintKey]?.toBoolOrNull() ??
        !toPrint;
    final noLogFile =
        queryParameters[kNoLogFileKey]?.toBoolOrNull() ??
        options.extra[kNoLogFileKey]?.toBoolOrNull() ??
        !toFile;
    final noResponseLogPrint =
        queryParameters[kNoResponseLogPrintKey]?.toBoolOrNull() ??
        options.extra[kNoResponseLogPrintKey]?.toBoolOrNull() ??
        !toPrint;

    final hashCode = options.hashCode;
    final value = uuidMap.remove(hashCode);
    final log = stringBuilder((builder) {
      builder.appendLine("<--${value?.$1} ${LTime.diffTime(value?.$2)}");
      builder.append(_responseLog(response));
    });
    _printLog(
      log,
      toFile: noLogFile == false,
      toPrint: noLogPrint == false && noResponseLogPrint == false,
    );
  }

  String _responseLog(Response response) {
    var log = stringBuilder((builder) {
      builder.appendLine(
        "[${response.statusCode}]${response.requestOptions.uri}",
      );
      if (response.isRedirect == true) {
        builder.append('redirect:', response.realUri, lineSeparator);
      }
      builder.appendLine('headers↓');
      response.headers.forEach(
        (key, v) => builder.append(' $key:', v, lineSeparator),
      );
      final data = response.data;
      builder.appendLine('response.data(${data.runtimeType})↓');
      if (data is Iterable<int>) {
        builder.appendAll(data.length.toSizeStr(space: " "));
      } else {
        builder.appendAll(response.toString());
      }
    });
    return log;
  }

  void _printLog(String log, {bool? toFile, bool? toPrint}) {
    //debugger();
    if (toFile ?? this.toFile) {
      GlobalConfig.def.writeFileFn?.call('http.log', 'log', log);
    }
    if (toPrint ?? this.toPrint) {
      l.d(log);
    }
  }
}

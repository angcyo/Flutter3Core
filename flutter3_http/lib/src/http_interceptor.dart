part of '../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/08
///
/// 仿dio库, 实现的http库的拦截器
/// - [HttpRequest]
/// - [HttpResponse]
class HttpInterceptorManager {
  /// 拦截器集合
  final List<HttpInterceptor> interceptors = [];

  //

  /// 获取被拦截掉的请求体数据
  @output
  Uint8List? get requestBodyBytes {
    for (final interceptor in interceptors) {
      if (interceptor is HttpLogInterceptor) {
        if (!isNil(interceptor.requestBodyBytes)) {
          return interceptor.requestBodyBytes;
        }
      }
    }
    return null;
  }

  /// 入口, 处理[HttpRequest]
  ///
  /// - [RHttpException] 异常
  @api
  Future<HttpResponse> handleRequest(
    HttpRequest request,
    FutureOr Function(HttpRequest request) handleRequestAction,
  ) async {
    // Build a request flow in which the processors(interceptors)
    // execute in FIFO order.
    Future<dynamic> future = Future<dynamic>(
      () => HttpInterceptorState(request),
    );

    // Add request interceptors into the request flow.
    for (final interceptor in interceptors) {
      final fun = interceptor is HttpQueuedInterceptor
          ? interceptor._handleRequest
          : interceptor.onRequest;
      future = future.then((_) async => fun(request));
    }

    //开始处理请求...
    future = future.then((_) async => handleRequestAction(request));
    //await handleRequestAction(request);

    // Add response interceptors into the request flow
    for (final interceptor in interceptors) {
      final fun = interceptor is HttpQueuedInterceptor
          ? interceptor._handleResponse
          : interceptor.onResponse;
      future = future.then((_) async => fun(request));
    }

    // Add error handlers into the request flow.
    for (final interceptor in interceptors) {
      final fun = interceptor is HttpQueuedInterceptor
          ? interceptor._handleError
          : interceptor.onError;
      future = future.catchError(
        (e) async => fun(request, RHttpException(error: e)),
      );
    }

    // Normalize errors, converts errors to [DioException].
    try {
      final data = await future;
      return request.response;
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      throw RHttpException(error: e);
    }
  }
}

/// The signature of [Interceptor.onRequest].
typedef HttpInterceptorSendCallback = FutureOr Function(HttpRequest request);

/// The signature of [Interceptor.onResponse].
typedef HttpInterceptorSuccessCallback =
    FutureOr Function(HttpResponse response);

/// The signature of [Interceptor.onError].
typedef HttpInterceptorErrorCallback =
    FutureOr Function(HttpRequest request, RHttpException err);

enum HttpInterceptorResultType {
  next,
  resolve,
  resolveCallFollowing,
  reject,
  rejectCallFollowing,
}

class HttpInterceptorState<T> {
  const HttpInterceptorState(
    this.data, [
    this.type = HttpInterceptorResultType.next,
  ]);

  final T data;
  final HttpInterceptorResultType type;

  @override
  String toString() => 'HttpInterceptorState<$T>(type: $type, data: $data)';
}

//MARK: - HttpInterceptor

/// 拦截器
/// - [Interceptor] dio
class HttpInterceptor {
  @configProperty
  final FutureOr Function(HttpRequest request)? onRequestAction;
  @configProperty
  final FutureOr Function(HttpRequest request)? onResponseAction;
  @configProperty
  final FutureOr Function(HttpRequest request, RHttpException err)?
  onErrorAction;

  const HttpInterceptor({
    this.onRequestAction,
    this.onResponseAction,
    this.onErrorAction,
  });

  @mustCallSuper
  FutureOr onRequest(HttpRequest request) {
    return onRequestAction?.call(request);
  }

  @mustCallSuper
  FutureOr onResponse(HttpRequest request) {
    return onResponseAction?.call(request);
  }

  @mustCallSuper
  FutureOr onError(HttpRequest request, RHttpException err) {
    return onErrorAction?.call(request, err);
  }
}

/// - [QueuedInterceptor] dio
class HttpQueuedInterceptor extends HttpInterceptor {
  FutureOr _handleRequest(HttpRequest request) {}

  FutureOr _handleResponse(HttpRequest request) {}

  FutureOr _handleError(HttpRequest request, RHttpException err) {}
}

//MARK: -

/// - [LogFileInterceptor]
class HttpLogInterceptor extends HttpInterceptor {
  final void Function(String log)? printRequestLogAction;
  final void Function(String log)? printResponseLogAction;

  /// 获取到的请求体数据
  final ValueCallback<Uint8List?>? onRequestBodyCallback;

  HttpLogInterceptor({
    this.printRequestLogAction,
    this.printResponseLogAction,
    this.onRequestBodyCallback,
    super.onRequestAction,
    super.onResponseAction,
    super.onErrorAction,
  });

  @override
  FutureOr onRequest(HttpRequest request) async {
    final result = super.onRequest(request);
    await _logRequest(request);
    return result;
  }

  @override
  FutureOr onResponse(HttpRequest request) async {
    final result = super.onResponse(request);
    await _logResponse(request);
    return result;
  }

  /// 请求体数据
  @output
  Uint8List? requestBodyBytes;

  FutureOr _logRequest(HttpRequest request) async {
    final bytes = await request.bytes;
    requestBodyBytes = bytes;
    onRequestBodyCallback?.call(bytes);
    //debugger();
    final log = stringBuilder((builder) {
      builder.appendLine(
        "-->[${request.method}]${request.requestedUri} ${request.protocolVersion} ${request.contentLength.toSizeStr()}",
      );
      request.connectionInfo?.let(
        (it) => builder.appendLine(
          "From: ${it.remoteAddress.address}:${it.remotePort} / ${it.localPort}",
        ),
      );
      request.headers.forEach(
        (key, v) => builder.append(' $key:', v, lineSeparator),
      );
      if (!isNil(bytes)) {
        builder.append(bytes.utf8Str);
      }
    });
    if (printRequestLogAction == null) {
      l.d(log, filterType: LogScope.kHttp);
    } else {
      printRequestLogAction?.call(log);
    }
  }

  FutureOr _logResponse(HttpRequest request) async {
    //debugger();
    final response = request.response;
    final log = stringBuilder((builder) {
      builder.appendLine(
        "<--[${response.statusCode}]${request.requestedUri} ${response.contentLength.toSizeStr()}",
      );
      response.headers.forEach(
        (key, v) => builder.append(' $key:', v, lineSeparator),
      );
    });
    if (printResponseLogAction == null) {
      l.d(log, filterType: LogScope.kHttp);
    } else {
      printResponseLogAction?.call(log);
    }
  }
}

extension HttpRequestEx on HttpRequest {
  /// 监听请求体数据
  /// - 只能监听一次. `Bad state: Stream has already been listened to.`
  Future<Uint8List> get bytes {
    final completer = Completer<Uint8List>();
    final sink = BytesBuilder();

    //StreamSplitter(this);
    //pipe(streamConsumer)
    //fold(initialValue, combine)

    listen(
      sink.add,
      onDone: () => completer.complete(sink.takeBytes()),
      onError: completer.completeError,
      cancelOnError: true,
    );
    return completer.future;
  }
}

extension HttpResponseEx on HttpResponse {}

part of '../../flutter3_http.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

class DioScope extends InheritedWidget {
  /// 获取一个上层提供的dio
  static RDio? of(BuildContext context, {bool depend = false}) {
    if (depend) {
      return context.dependOnInheritedWidgetOfExactType<DioScope>()?.rDio;
    } else {
      return context.getInheritedWidgetOfExactType<DioScope>()?.rDio;
    }
  }

  final RDio rDio;

  const DioScope({
    super.key,
    required super.child,
    required this.rDio,
  });

  @override
  bool updateShouldNotify(DioScope oldWidget) => rDio != oldWidget.rDio;
}

extension DioMapEx on Map<String, dynamic> {
  /// 转换为[FormData]
  /// 通过 [FormData] 上传多个文件:
  /// ```
  /// final formData = FormData.fromMap({
  ///   'name': 'dio',
  ///   'date': DateTime.now().toIso8601String(),
  ///   'file': await MultipartFile.fromFile('./text.txt', filename: 'upload.txt'),
  ///   'files': [
  ///     await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
  ///     await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
  ///   ]
  /// });
  /// final response = await dio.post('/info', data: formData);
  /// ```
  FormData toFormData() => FormData.fromMap(this);
}

/// 请求的子路径需要以`/`开头
/// https://github.com/cfug/dio/blob/main/dio/README-ZH.md
extension DioStringEx on String {
  /// get请求
  /// [context] 用来获取dio
  /// [data] 请求体 [DioMixin._transformData]
  Future<Response<T>> get<T>({
    BuildContext? context,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await RDio.get(context: context).dio.get<T>(
          this,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return response;
  }

  /// 获取http字符串内容
  /// [HttpStringEx.httpGetContent]
  Future<String?> dioGetString({
    BuildContext? context,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await RDio.get(context: context).dio.get<String>(
          this,
          queryParameters: queryParameters,
          options: (options ?? Options())..responseType = ResponseType.plain,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return response.data;
  }

  /// 获取http字节数据
  /// [HttpStringEx.httpGetBytes]
  Future<Uint8List?> dioGetBytes({
    BuildContext? context,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await RDio.get(context: context).dio.get(
          this,
          queryParameters: queryParameters,
          options: (options ?? Options())..responseType = ResponseType.bytes,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return Uint8List.fromList(response.data);
  }

  /// post请求
  /// [context] 用来获取dio
  /// [data] 请求体 [DioMixin._transformData]
  Future<Response<T>> post<T>({
    BuildContext? context,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await RDio.get(context: context).dio.post<T>(
          this,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
    return response;
  }

  /// put请求
  /// [context] 用来获取dio
  /// [data] 请求体 [DioMixin._transformData]
  Future<Response<T>> put<T>({
    BuildContext? context,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await RDio.get(context: context).dio.put<T>(
          this,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return response;
  }

  /// 下载
  /// [context] 用来获取dio
  /// [data] 请求体 [DioMixin._transformData]
  /// [savePath] 保存路径
  /// [getSavePath] 异步获取保存路径
  /// https://pub.dev/packages/network_to_file_image
  Future<Response> download({
    String? savePath,
    Future<String>? getSavePath,
    BuildContext? context,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    var dio = RDio.get(context: context).dio;
    var saveTo = savePath ?? (await getSavePath);
    final response = dio.download(
      this,
      saveTo,
      onReceiveProgress: (count, total) {
        assert(() {
          if (total > 0) {
            l.d("下载进度:$count/$total ${count.toSizeStr()}/${total.toSizeStr()} ${(count / total * 100).toDigits(digits: 2)}% \n[$this]->[$saveTo]");
          } else {
            l.d("下载进度:$count ${count.toSizeStr()} \n[$this]->[$saveTo]");
          }
          return true;
        }());
        onReceiveProgress?.call(count, total);
      },
      lengthHeader: lengthHeader,
      deleteOnError: deleteOnError,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      data: data,
      options: options,
    );
    //debugger();
    return response;
  }
}

extension DioFutureResponseEx<T> on Future<T> {
  /// 解析网络请求返回的[Response]数据
  /// 转换成[response.data]转换成简单的Bean
  /// ```
  /// UserBean.fromJson(value)
  /// ```
  /// 转换成[response.data]转换成集合的Bean
  /// ```
  /// value.map<ConnectDeviceBean>((e) => ConnectDeviceBean.fromJson(e))
  ///      .toList();
  ///
  /// (value as Iterable?)?.mapToList<ConnectDeviceBean>((e) => ConnectDeviceBean.fromJson(e))
  /// ```
  /// [throwError] 遇到错误时, 是否抛出异常
  Future http(
    ValueErrorCallback? callback, {
    HttpResultHandle? resultHandle,
    bool? showErrorToast,
    bool? throwError,
    String? codeKey,
    String? dataKey,
    String? messageKey,
  }) async {
    //debugger();
    resultHandle ??= HttpResultHandle();
    resultHandle.codeKey = codeKey ?? resultHandle.codeKey;
    resultHandle.dataKey = dataKey ?? resultHandle.dataKey;
    resultHandle.messageKey = messageKey ?? resultHandle.messageKey;
    resultHandle.showErrorToast = showErrorToast ?? resultHandle.showErrorToast;
    return get((response, error) {
      //debugger();
      if (error != null) {
        callback?.call(response, resultHandle!.handleError(error));
        if (throwError == true) {
          throw error;
        }
        return null;
      } else if (response == null) {
        var exception = RException(message: "response is null", cause: error);
        callback?.call(response, resultHandle!.handleError(exception));
        if (throwError == true) {
          throw exception;
        }
        return null;
      } else {
        var data = resultHandle!.handleResponse(response);
        callback?.call(data, null);
        return data;
      }
    }).catchError((error) {
      //debugger();
      callback?.call(null, resultHandle!.handleError(error));
      if (throwError == true) {
        throw error;
      }
    });
  }
}

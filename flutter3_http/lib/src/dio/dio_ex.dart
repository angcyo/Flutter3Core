part of flutter3_http;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

class DioScope extends InheritedWidget {
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

/// https://github.com/cfug/dio/blob/main/dio/README-ZH.md
extension DioStringEx on String {
  /// get请求
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

  /// post请求
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
    //debugger();
    return response;
  }

  /// put请求
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
  /// [data] 请求体 [DioMixin._transformData]
  /// [savePath] 保存路径
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
        if (total > 0) {
          l.d("下载进度:$count/$total ${count.toFileSizeStr()}/${total.toFileSizeStr()} ${(count / total * 100).toDigits(digits: 2)}% \n[$this]->[$saveTo]");
        } else {
          l.d("下载进度:$count ${count.toFileSizeStr()} \n[$this]->[$saveTo]");
        }
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

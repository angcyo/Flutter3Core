part of '../../flutter3_http.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/11/25
///

/// [Response]
typedef DioResponse<T> = Response<T>;

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
/// Dio使用文档 https://github.com/cfug/dio/blob/main/dio/README-ZH.md
extension DioStringEx on String {
  /// get请求
  /// [context] 用来获取dio
  /// [body] 请求体 [DioMixin._transformData]
  ///
  /// ```
  /// GridOptionBean.fromJson(res.data);
  /// ```
  ///
  /// [Response.data]数据类型通常是[_Map<String, dynamic>]
  /// @return [Response<dynamic>]
  ///
  Future<Response<T>> get<T>({
    Object? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final response = await RDio.get(context: context).dio.get<T>(
          transformUrl(),
          data: body,
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
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final response = await RDio.get(context: context).dio.get<String>(
          transformUrl(),
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
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final response = await RDio.get(context: context).dio.get(
          transformUrl(),
          queryParameters: queryParameters,
          options: (options ?? Options())..responseType = ResponseType.bytes,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return Uint8List.fromList(response.data);
  }

  /// 获取http对应的图片数据
  /// [HttpStringEx.httpGetBytes]
  Future<UiImage?> dioGetImage({
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final bytes = await dioGetBytes(
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      context: context,
    );
    return bytes?.toImage();
  }

  /// post请求
  /// [context] 用来获取dio
  /// [body] 请求体 [DioMixin._transformData]
  ///   - 支持[FormData]
  /// [Response.data]数据类型通常是[_Map<String, dynamic>]
  Future<Response<T>> post<T>({
    Object? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final response = await RDio.get(context: context).dio.post<T>(
          transformUrl(),
          data: body,
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
  /// [body] 请求体 [DioMixin._transformData]
  Future<Response<T>> put<T>({
    Object? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final response = await RDio.get(context: context).dio.put<T>(
          transformUrl(),
          data: body,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
    //debugger();
    return response;
  }

  /// 使用post请求, 上传文件
  /// [body] 完全自定义的上传数据, 此时[filePath].[filePathList].[formMap]失效
  /// [filePath] 单位件上传
  /// [filePathList] 多文件上传
  /// [formMap] 除了文件外, 额外的表单数据
  /// https://github.com/FlutterStudioIst/dio/blob/main/dio/README-ZH.md#%E5%8F%91%E9%80%81-formdata
  Future<Response<T>> upload<T>({
    Object? body,
    String? filePath,
    String filePathKey = 'file',
    List<String>? filePathList,
    String filePathListKey = 'files',
    Map<String, dynamic>? formMap,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    BuildContext? context,
  }) async {
    final formData = FormData.fromMap({
      'name': 'flutter-dio-angcyo',
      'date': DateTime.now().toIso8601String(),
      filePathKey: filePath == null
          ? null
          : await MultipartFile.fromFile(
              filePath,
              filename: filePath.toFile().filename,
            ),
      filePathListKey: filePathList == null
          ? null
          : [
              for (final filePath in filePathList)
                await MultipartFile.fromFile(
                  filePath,
                  filename: filePath.toFile().filename,
                ),
            ],
      ...?formMap,
    });
    return post<T>(
      body: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      context: context,
    );
  }

  /// 下载
  /// [context] 用来获取dio
  /// [data] 请求体 [DioMixin._transformData]
  /// [savePath] 保存路径
  /// [getSavePath] 异步获取保存路径
  /// [cancelToken] 取消请求的token
  /// [deleteOnError] 是否在下载失败时, 删除文件
  /// [overwrite] 是否覆盖已存在的文件
  /// https://pub.dev/packages/network_to_file_image
  ///
  /// [Dio.download]
  ///
  Future<Response> download({
    String? savePath,
    Future<String>? getSavePath,
    BuildContext? context,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    bool overwrite = false,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
    bool debugLog = false, //debug模式下, 是否打印日志
  }) async {
    final dio = RDio.get(context: context).dio;
    final saveFilePath = savePath ?? (await getSavePath);
    if (overwrite == false && saveFilePath?.isExistsSync() == true) {
      //文件已经存在
      final length = saveFilePath!.length;
      onReceiveProgress?.call(length, length);
      return Response(
          requestOptions: RequestOptions(path: this), data: saveFilePath);
    }
    final response = dio.download(
      transformUrl(),
      saveFilePath,
      onReceiveProgress: (count, total) {
        assert(() {
          if (debugLog) {
            if (total > 0) {
              // 日志限流
              l.d("下载进度:$count/$total ${count.toSizeStr()}/${total.toSizeStr()} ${(count / total * 100).toDigits(digits: 2)}% \n[$this]->[$saveFilePath]");
            } else {
              l.d("下载进度:$count ${count.toSizeStr()} \n[$this]->[$saveFilePath]");
            }
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
    List<String>? codeKeyList,
    List<String>? dataKeyList,
    List<String>? messageKeyList,
    bool? useDataCodeStatus,
    String? debugLabel,
  }) async {
    //debugger();
    final handle = resultHandle ?? HttpResultHandle();
    handle.codeKeyList = codeKeyList ?? handle.codeKeyList;
    handle.dataKeyList = dataKeyList ?? handle.dataKeyList;
    handle.messageKeyList = messageKeyList ?? handle.messageKeyList;
    handle.showErrorToast = showErrorToast ?? handle.showErrorToast;
    handle.useDataCodeStatus = useDataCodeStatus ?? handle.useDataCodeStatus;
    return get((response, error) {
      debugger(when: debugLabel != null);
      if (error != null) {
        //有错误
        final err = handle.handleError(error);
        callback?.call(response, err);
        if (throwError == true) {
          throw error;
        }
        return null;
      } else if (response == null) {
        //没有数据
        final exception =
            RHttpException(message: "response is null", error: error);
        final err = handle.handleError(exception);
        final callbackValue = callback?.call(response, err);
        if (throwError == true) {
          throw exception;
        }
        return callbackValue;
      } else {
        //有数据
        final data = handle.handleResponse(response);
        final callbackValue = callback?.call(data, null);
        return callbackValue ?? data;
      }
    }).catchError((error) {
      //debugger();
      final err = handle.handleError(error);
      callback?.call(null, err);
      if (throwError == true) {
        throw error;
      }
    });
  }
}

extension RequestOptionsEx on RequestOptions {
  /// 获取对应的选项, 从以下源中获取
  /// - [Response.requestOptions.extra]
  /// - [Uri.queryParameters]
  String? getQuery(String? key) {
    final options = this;
    final queryParameters = options.uri.queryParameters;
    return queryParameters.containsKey(key)
        ? queryParameters[key]
        : options.extra[key]?.toString() ?? options.headers[key]?.toString();
  }

  /// 是否是同源地址
  bool isSameOrigin() {
    final origin = baseUrl;
    final host = uri.host;
    //debugger();
    return origin.uri?.host == host;
  }
}

/// [DioStringEx.get]
/// [DioFutureResponseEx.http]
extension ResponseEx<T> on Response<T> {
  /// 获取对应的选项, 从以下源中获取
  /// - [Response.requestOptions.extra]
  /// - [Uri.queryParameters]
  String? getQuery(String? key) => requestOptions.getQuery(key);

  /// 是否是同源地址
  bool isSameOrigin() {
    final origin = requestOptions.baseUrl;
    final host = realUri.host;
    //debugger();
    return origin.uri?.host == host;
  }
}

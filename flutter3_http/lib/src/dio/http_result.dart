part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///
/// 用来解析网络请求返回的[Response]
/// ```
/// {"errMsg":"操作成功","code":200,"data":{"id":18434,"nickname":"8️⃣🅱️Q了","say":null}}
/// ```
class HttpResultHandle {
  static const kDefHttpErrorMessage = "Network error!";
  static const kDefHttpDataCodeKeyList = ["code"];
  static const kDefHttpDataDataKeyList = ["data"];
  static const kDefHttpDataMessageKeyList = ["msg", "errMsg", "error"];

  /// json当中对应的资源key
  List<String>? codeKeyList = kDefHttpDataCodeKeyList;
  List<String>? dataKeyList = kDefHttpDataDataKeyList;
  List<String>? messageKeyList = kDefHttpDataMessageKeyList;

  /// 默认的错误消息
  @configProperty
  String? defHttpErrorMessage = kDefHttpErrorMessage;

  /// 是否要显示错误提示
  @configProperty
  bool showErrorToast = true;

  /// 如果返回的是字符串类型, 是否需要使用json解码
  @configProperty
  bool needJsonDecode = true;

  /// 使用数据code码来判断请求是否成功
  /// [codeKey]
  @configProperty
  bool useDataCodeStatus = true;

  /// 处理当前[code]码是否表示成功
  late bool Function(dynamic code) isSuccessCode = (code) =>
      code is int && code >= 200 && code < 300;

  /// 处理网络请求返回的数据
  late dynamic Function(dynamic response) handleResponse = (response) {
    //debugger();

    //状态码和数据
    int? code;
    dynamic data;

    //MARK: - response
    if (response is Response) {
      code = response.statusCode ?? 0;
      if (isSuccessCode(code)) {
        data = response.data;
      }
    } else if (response is http.Response) {
      //throw RException(message: "无法解析的数据类型");
      code = response.statusCode;
      if (isSuccessCode(code)) {
        data = response.body;
      }
    } else {
      assert(() {
        l.w("未处理的response类型[${response.runtimeType}]");
        return true;
      }());
      return response;
    }

    //MARK: - handle
    if (isSuccessCode(code)) {
      //http 状态成功
      if (needJsonDecode && data is String) {
        data = jsonDecode(data);
      }
      if (data is! Map) {
        return data;
      } else {
        if (useDataCodeStatus) {
          //需要判断逻辑code码
          if (!isNil(codeKeyList)) {
            final dataCode = data.getValue(codeKeyList);
            if (isSuccessCode(dataCode)) {
              //成功
              return isNil(dataKeyList)
                  ? data
                  : data.getValue(dataKeyList, data);
            } else {
              throw RHttpException(
                message:
                    (isNil(messageKeyList)
                        ? null
                        : data.getValue(messageKeyList, defHttpErrorMessage)) ??
                    defHttpErrorMessage,
                statusCode: dataCode,
                error: data,
              );
            }
          } else {
            return isNil(dataKeyList) ? data : data.getValue(dataKeyList, data);
          }
        } else {
          //不需要判断逻辑code码, 则直接返回数据
          return data;
        }
      }
    } else {
      assert(() {
        l.w("网络请求状态码[$code]");
        return true;
      }());
      //debugger();
      final error = switch (null) {
        _ when response is Response => response.statusMessage,
        _ when response is http.Response => response.reasonPhrase,
        _ => null,
      };
      throw RHttpException(
        message: "[$response]code[$code]${error ?? ""}",
        statusCode: code,
        error: response,
      );
    }
  };

  /// 处理网络错误信息, 返回处理后的错误提示信息
  /// [Exception]
  /// [DioException]
  late dynamic Function(dynamic error) handleError = (error) {
    //debugger();
    var tip = defHttpErrorMessage;
    int? statusCode;
    if (error is DioException) {
      statusCode = error.response?.statusCode;
      final data = error.response?.data;
      String? errorMessage;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage ??= defHttpErrorMessage;
      } else if (data is Map<String, dynamic>) {
        errorMessage ??= data.getValue(messageKeyList);
      }
      tip = errorMessage ?? error.message ?? tip;
    } else if (error is RHttpException) {
      tip = error.message ?? tip;
      statusCode = error.statusCode;
      error = error.error;
    } else {
      tip = error?.toString() ?? tip;
    }
    if (showErrorToast) {
      toastBlur(text: tip.toString());
    }
    return RHttpException(message: tip, statusCode: statusCode, error: error);
  };
}

/// 网络请求返回的数据处理回调
typedef HttpValueCallback<T> =
    dynamic Function(T? value, RHttpException? error);

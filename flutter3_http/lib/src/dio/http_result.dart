part of flutter3_http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

const kDefHttpErrorMessage = "network error";

/// 用来解析网络请求返回的[Response]
/// ```
/// {"errMsg":"操作成功","code":200,"data":{"id":18434,"nickname":"8️⃣🅱️Q了","say":null}}
/// ```
class HttpResultHandle {
  String codeKey = "code";
  String dataKey = "data";
  String messageKey = "errMsg";

  /// 是否要显示错误提示
  bool showErrorToast = true;

  /// 处理网络请求返回的数据
  late dynamic Function(dynamic response) handleResponse = (response) {
    //debugger();
    if (response is Response) {
      var code = response.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        //成功
        var data = response.data;
        var dataCode = data[codeKey];
        if (dataCode is int && dataCode >= 200 && dataCode < 300) {
          //成功
          return data[dataKey];
        } else {
          throw RException(message: data[messageKey] ?? kDefHttpErrorMessage);
        }
      } else {
        throw RException(message: "[$code]${response.statusMessage}");
      }
    }
    throw RException(message: "无法解析的数据类型");
  };

  /// 处理网络错误信息, 返回处理后的错误提示信息
  /// [Exception]
  /// [DioException]
  late dynamic Function(dynamic error) handleError = (error) {
    //debugger();
    var tip = kDefHttpErrorMessage;
    if (error is DioException) {
      var errorMessage = error.response?.data[messageKey];
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage ??= kDefHttpErrorMessage;
      }
      tip = errorMessage ?? error.message ?? tip;
    }
    /*else if (error is Exception) {
      tip = error.toString();
    } */
    else {
      tip = error?.toString() ?? tip;
    }
    if (showErrorToast) {
      toastBlur(text: tip.toString());
    }
    return RException(message: tip, cause: error);
  };
}

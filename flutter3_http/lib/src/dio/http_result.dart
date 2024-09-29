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
  static const kDefHttpErrorMessage = "network error";
  static const kDefHttpDataCodeKey = "code";
  static const kDefHttpDataDataKey = "data";
  static const kDefHttpDataMessageKey = "errMsg";

  /// json当中对应的资源key
  String? codeKey = kDefHttpDataCodeKey;
  String? dataKey = kDefHttpDataDataKey;
  String? messageKey = kDefHttpDataMessageKey;

  /// 默认的错误消息
  String? defHttpErrorMessage = kDefHttpErrorMessage;

  /// 是否要显示错误提示
  bool showErrorToast = true;

  /// 处理网络请求返回的数据
  late dynamic Function(dynamic response) handleResponse = (response) {
    //debugger();
    if (response is Response) {
      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        //成功
        final data = response.data;
        if (data is! Map) {
          return data;
        } else if (codeKey != null) {
          //需要判断逻辑code码
          final dataCode = data[codeKey];
          if (dataCode is int && dataCode >= 200 && dataCode < 300) {
            //成功
            return dataKey == null ? data : data[dataKey];
          } else {
            throw RException(
                message: (messageKey == null ? null : data[messageKey]) ??
                    defHttpErrorMessage);
          }
        } else {
          return dataKey == null ? data : data[dataKey];
        }
      } else {
        throw RException(message: "[$code]${response.statusMessage}");
      }
    } else {
      //throw RException(message: "无法解析的数据类型");
      return response;
    }
  };

  /// 处理网络错误信息, 返回处理后的错误提示信息
  /// [Exception]
  /// [DioException]
  late dynamic Function(dynamic error) handleError = (error) {
    //debugger();
    var tip = defHttpErrorMessage;
    if (error is DioException) {
      var errorMessage = error.response?.data[messageKey];
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        errorMessage ??= defHttpErrorMessage;
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

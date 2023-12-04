part of flutter3_http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

const kDefHttpErrorMessage = "网络正忙";

/// 用来解析网络请求返回的[Response]
/// ```
/// {"errMsg":"操作成功","code":200,"data":{"id":18434,"nickname":"8️⃣🅱️Q了","say":null}}
/// ```
class HttpResult {
  String codeKey = "code";
  String dataKey = "data";
  String messageKey = "errMsg";

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
          throw RException(data[messageKey] ?? kDefHttpErrorMessage);
        }
      } else {
        throw RException("[$code]${response.statusMessage}");
      }
    }
    throw RException("无法解析的数据类型");
  };

  /// 处理网络错误信息
  /// [Exception]
  /// [DioException]
  late void Function(dynamic error) handleError = (error) {
    var tip = kDefHttpErrorMessage;
    if (error is DioException) {
      var errorMessage = error.response?.data[messageKey];
      tip = errorMessage ?? error.message ?? kDefHttpErrorMessage;
    } else {
      tip = error.toString();
    }
    toast(
      tip.text(textAlign: TextAlign.center),
      position: OverlayPosition.center,
    );
  };
}

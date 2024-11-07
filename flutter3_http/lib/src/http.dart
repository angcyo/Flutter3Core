part of '../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///
/// [NetworkImage] 网络图片请求
/// [HttpClient].[HttpClientRequest].[HttpClientResponse]
/// [HttpStatus] http状态码
class Http {
  /// api host, 不需要/结尾
  static String? baseUrl;

  /// 获取一个[baseUrl]
  static String? Function()? getBaseUrl = () => baseUrl;
}

/// api host, 不需要/结尾
String? get $host => Http.getBaseUrl?.call() ?? Http.baseUrl;

extension HttpUriEx on Uri {
  /// 获取uri对应的查询参数
  /// [queryParameters]
  /*Map<String, String?> get queryMap {
    final map = <String, String?>{};
    queryParameters.forEach((key, value) {
      map[key] = value;
    });
    return map;
  }*/

  /// 获取http字节内容
  Future<Uint8List?> httpGetBytes({Map<String, String>? headers}) async {
    Uint8List? result;
    final HttpClient httpClient = HttpClient();
    //final Uri uri = Uri.base.resolve(url);
    try {
      final HttpClientRequest request = await httpClient.getUrl(this);
      if (headers != null) {
        headers.forEach((String key, String value) {
          request.headers.add(key, value);
        });
      }
      final HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        //throw HttpException('Could not get network asset', uri: this);
        result = await consolidateHttpClientResponseBytes(response);
      }
    } finally {
      httpClient.close();
    }
    return result;
  }

  ///获取http字符串内容
  Future<String?> httpGetContent({
    Encoding defaultEncoding = utf8,
    Map<String, String>? headers,
  }) async {
    String? content = data?.contentAsString(encoding: defaultEncoding);
    if (content == null) {
      final client = http.Client();
      try {
        final response = await client.get(this, headers: headers);
        //response.statusCode
        final ct = response.headers['content-type'];
        if (ct == null || !ct.toLowerCase().contains('charset')) {
          //Use default if not specified in content-type header
          content = defaultEncoding.decode(response.bodyBytes);
        } else {
          content = response.body;
        }
      } finally {
        client.close();
      }
    }
    return content;
  }
}

extension HttpStringEx on String {
  /// this == host
  /// 拼接`host/path`
  String connectUrl(String? path) {
    if (path == null || isNil(path)) {
      return this;
    }
    String result = this;
    //移除末尾的/
    if (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    if (path.startsWith('/')) {
      //移除开头的/
      path = path.substring(1);
    }
    if (path.isNotEmpty) {
      result = '$result/$path';
    }
    return result;
  }

  /// this == path
  /// [api]服务器忌口地址, 不指定则默认是[Http.getBaseUrl]
  @callPoint
  String toApi([
    String? api,
    bool? isSecureProtocol,
    String protocol = "http",
  ]) {
    if (startsWith('$protocol://') || startsWith('${protocol}s://')) {
      //this 已经是一个url, 则直接返回
      return this;
    }

    //主机
    api ??= Http.getBaseUrl?.call() ?? '';
    if (api.startsWith('$protocol://') || api.startsWith('${protocol}s://')) {
    } else {
      api =
          isSecureProtocol == true ? "${protocol}s://$api" : "$protocol://$api";
    }

    //开始拼接
    var base = api;
    var path = this;
    if (base.isNotEmpty) {
      if (base.endsWith('/')) {
        //base移除末尾的/
        base = base.substring(0, base.length - 1);
      }
      if (path.startsWith('/')) {
        path = path.substring(1);
      }
      return '$base/$path';
    }
    return this;
  }

  /// [HttpUriEx.httpGetContent]
  Future<String?> httpGetContent({
    Encoding defaultEncoding = utf8,
    Map<String, String>? headers,
  }) async =>
      Uri.parse(this).httpGetContent(
        defaultEncoding: defaultEncoding,
        headers: headers,
      );

  /// [HttpUriEx.httpGetBytes]
  Future<Uint8List?> httpGetBytes({Map<String, String>? headers}) async =>
      Uri.parse(this).httpGetBytes(headers: headers);
}

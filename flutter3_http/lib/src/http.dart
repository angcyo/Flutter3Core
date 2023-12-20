part of flutter3_http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

class Http {
  /// api host, 不需要/结尾
  static String? baseUrl;

  /// 获取一个[baseUrl]
  static String? Function()? getBaseUrl = () => baseUrl;
}

/// api host, 不需要/结尾
String? get host => Http.getBaseUrl?.call() ?? Http.baseUrl;

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
  Future<Uint8List?> getHttpBytes({Map<String, String>? headers}) async {
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
  Future<String?> getHttpContent({
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
  /// 拼接接口
  String toApi(String api) {
    if (api.startsWith('http://') || api.startsWith('https://')) {
      return api;
    }
    var base = Http.getBaseUrl?.call() ?? '';
    if (base.isNotEmpty) {
      if (base.endsWith('/')) {
        base = base.substring(0, base.length - 1);
      }
      if (api.startsWith('/')) {
        api = api.substring(1);
      }
      return '$base/$api';
    }
    return api;
  }

  /// [HttpUriEx.getHttpContent]
  Future<String?> getHttpContent({
    Encoding defaultEncoding = utf8,
    Map<String, String>? headers,
  }) async =>
      Uri.parse(this).getHttpContent(
        defaultEncoding: defaultEncoding,
        headers: headers,
      );

  /// [HttpUriEx.getHttpBytes]
  Future<Uint8List?> getHttpBytes({Map<String, String>? headers}) async =>
      Uri.parse(this).getHttpBytes(headers: headers);
}

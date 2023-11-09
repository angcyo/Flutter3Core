part of flutter3_http;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/09
///

extension HttpUriEx on Uri {
  ///获取http内容
  Future<String?> getHttpContent({
    Encoding defaultEncoding = utf8,
    Map<String, String>? httpHeaders,
  }) async {
    String? content = data?.contentAsString(encoding: defaultEncoding);
    if (content == null) {
      final client = http.Client();
      try {
        final response = await client.get(this, headers: httpHeaders);
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
  ///获取http内容
  Future<String?> getHttpContent({
    Encoding defaultEncoding = utf8,
    Map<String, String>? httpHeaders,
  }) async {
    return Uri.parse(this).getHttpContent(
      defaultEncoding: defaultEncoding,
      httpHeaders: httpHeaders,
    );
  }
}

part of '../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/08
///

class NetworkStringLoader extends StringLoader<Uint8List> {
  /// See class doc.
  const NetworkStringLoader(
    this.url, {
    this.headers,
    super.theme,
    http.Client? httpClient,
  }) : _httpClient = httpClient;

  /// The [Uri] encoded resource address.
  final String url;

  /// Optional HTTP headers to send as part of the request.
  final Map<String, String>? headers;

  final http.Client? _httpClient;

  @override
  Future<Uint8List?> prepareMessage(BuildContext? context) async {
    final http.Client client = _httpClient ?? http.Client();
    return (await client.get(Uri.parse(url), headers: headers)).bodyBytes;
    //return url.dioGetBytes(context: context);
  }

  @override
  String provideString(Uint8List? message) =>
      utf8.decode(message!, allowMalformed: true);

  @override
  int get hashCode => Object.hash(url, headers, theme);

  @override
  bool operator ==(Object other) {
    return other is NetworkStringLoader &&
        other.url == url &&
        other.headers == headers &&
        other.theme == theme;
  }

  @override
  String toString() => 'NetworkStringLoader($url)';
}

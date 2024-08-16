library flutter3_shelf;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_shelf/shelf_html.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:udp/udp.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_multipart/shelf_multipart.dart';
export 'package:shelf_router/shelf_router.dart';
export 'package:udp/udp.dart';

part 'flutter3_shelf_http.dart';
part 'flutter3_shelf_web_socket.dart';
part 'udp_ex.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024-7-15
///

/// 获取上次获取到的wifi ip地址
/// 需要先调用[networkWifiIp]
String? $lastWifiIpCache;

/// 获取网络wifi ip地址
Future<String?> get networkWifiIp async {
  $lastWifiIpCache = await NetworkInfo().getWifiIP();
  return $lastWifiIpCache;
}

final _defaultMimeTypeResolver = MimeTypeResolver();

extension ShelfRequestEx on shelf.Request {
  /// 是否是html请求, 这样返回值也是html
  bool get isAcceptHtml =>
      mimeType == "text/html" ||
      headers["accept"]?.contains("text/html") == true;
}

/// 响应成功, 数据类型
shelf.Response responseOk(
  Object? body, {
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) =>
    shelf.Response.ok(
      body,
      headers: headers,
      encoding: encoding,
      context: context,
    );

/// 响应成功, 文本类型
shelf.Response responseOkHtml(
  Object? body, {
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'text/html'
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) =>
    responseOk(
      body,
      headers: headers,
      encoding: encoding,
      context: context,
    );

/// 响应成功, 文件类型
shelf.Response responseOkFile({
  String? filePath,
  Stream<List<int>>? fileStream,
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) {
  final file = File(filePath!);
  return responseOk(
    fileStream ?? file.openRead(),
    headers: headers ??
        {
          HttpHeaders.contentDisposition:
              'attachment; filename="${file.fileName()}"',
          HttpHeaders.contentLengthHeader: file.lengthSync().toString(),
          HttpHeaders.contentTypeHeader:
              _defaultMimeTypeResolver.lookup(file.path) ??
                  'application/octet-stream'
        },
    encoding: encoding,
    context: context,
  );
}

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
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_multipart/form_data.dart';
export 'package:shelf_multipart/multipart.dart';
export 'package:shelf_router/shelf_router.dart';

part 'flutter3_shelf_http.dart';
part 'flutter3_shelf_web_socket.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024-7-15
///
/// 获取网络wifi ip地址
Future<String?>? get networkWifiIp => NetworkInfo().getWifiIP();

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
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'application/octet-stream'
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) {
  return responseOk(
    fileStream ?? File(filePath!).openRead(),
    headers: headers,
    encoding: encoding,
    context: context,
  );
}

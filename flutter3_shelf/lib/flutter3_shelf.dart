library flutter3_shelf;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter3_app/flutter3_app.dart';
import 'package:flutter3_shelf/src/local/api/udp_apis.dart';
import 'package:flutter3_shelf/src/shelf_html.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:udp/udp.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'src/mode/service_info_bean.dart';
import 'src/mode/udp_client_info_bean.dart';
import 'src/mode/udp_message_bean.dart';
import 'src/mode/udp_packet_bean.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_multipart/shelf_multipart.dart';
export 'package:shelf_router/shelf_router.dart';
export 'package:udp/udp.dart';

export 'src/local/api/udp_api_bean.dart';
export 'src/local/api/udp_apis.dart';
export 'src/mode/service_info_bean.dart';
export 'src/mode/udp_client_info_bean.dart';
export 'src/mode/udp_message_bean.dart';
export 'src/mode/udp_packet_bean.dart';
export 'src/shelf_html.dart';

part 'src/flutter3_shelf_http.dart';
part 'src/flutter3_shelf_web_socket.dart';
part 'src/local/local_udp_base.dart';
part 'src/local/local_udp_client.dart';
part 'src/local/local_udp_server.dart';
part 'src/network/network_mix.dart';
part 'src/udp_ex.dart';
part 'src/udp_service.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024-7-15
///
/// 包含 `shelf` 实现的http客户端
///
/// - [Flutter3ShelfHttp] http服务
/// - [Flutter3ShelfWebSocketServer] 支持[WebSocket]的服务
/// - [DebugLogWebSocketServer] 调试日志服务
///
/// - [LocalUdpClient] udp客户端
/// - [LocalUdpServer] udp服务端

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
  int? statusCode,
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) => shelf.Response(
  statusCode ?? (body == null ? 404 : 200),
  body: body,
  headers: headers,
  encoding: encoding,
  context: context,
);

/// 响应成功, json数据类型
/// - [statusCode]指定状态码, 默认200
shelf.Response responseJson(
  Object? body, {
  int? statusCode,
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.accessControlAllowOriginHeader: '*',
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) => shelf.Response(
  statusCode ?? (body == null ? 404 : 200),
  body: body == null ? null : jsonEncode(body),
  headers: headers,
  encoding: encoding,
  context: context,
);

/// 响应成功, 文本类型
shelf.Response responseOkHtml(
  Object? body, {
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'text/html',
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) => responseOk(body, headers: headers, encoding: encoding, context: context);

/// 响应成功, 文件类型
///
/// ```
/// Invalid HTTP header field value: "attachment;
/// filename=\"LOG_中国人_1.0.1_3_2025-11-18_15-03-38_745.zip\"" (at character 27)
/// attachment; filename="LOG_中国人_1.0.1_3_2025-11-18_15-03-38_745.zip"
/// ```
///
shelf.Response responseFile(
  Object? body, {
  int? statusCode,
  String? mimeType,
  bool? mediaType = false,
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) {
  assert(
    body == null || body is String || body is File || body is Stream<List<int>>,
  );
  Stream<List<int>>? fileStream;
  File? file;
  if (body is File) {
    file = body;
    fileStream = body.openRead();
  } else if (body is String) {
    file = body.file();
    fileStream = file.openRead();
  } else if (body is Stream<List<int>>) {
    fileStream = body;
  }
  final defContentType = 'application/octet-stream';
  mimeType ??= mediaType == true ? file?.path.mimeType() : null;
  return responseOk(
    fileStream,
    statusCode: statusCode,
    headers:
        headers ??
        (file == null
            ? {HttpHeaders.accessControlAllowOriginHeader: '*'}
            : {
                HttpHeaders.contentDisposition:
                    'attachment; filename="${file.fileName().encodeUri()}"',
                HttpHeaders.contentLengthHeader: file.lengthSync().toString(),
                HttpHeaders.contentTypeHeader:
                    mediaType == true && mimeType?.isImageMimeType == true
                    ? mimeType ?? defContentType
                    : defContentType,
                HttpHeaders.accessControlAllowOriginHeader: '*',
              }),
    encoding: encoding,
    context: context,
  );
}

/// 启动一个WebSocket服务
@api
Future<HttpServer> startWebSocketServer(
  int port,
  void Function(WebSocketChannel webSocket, String? subprotocol)?
  onConnection, {
  Object? host,
  String? debugLabel,
}) async {
  final handler = webSocketHandler((webSocket, subProtocol) {
    if (onConnection == null) {
      webSocket.stream.listen((message) {
        webSocket.sink.add("[debug] echo->$message");
      });
      debugger(when: !isIos && debugLabel != null);
    }
    onConnection?.call(webSocket, subProtocol);
  });
  debugger(when: !isIos && debugLabel != null);
  //启动一个服务/支持WebSocket服务
  return await shelf_io.serve(handler, host ?? 'localhost', port).then((
    server,
  ) {
    debugger(when: !isIos && debugLabel != null);
    assert(() {
      l.d(
        '${debugLabel?.wsb}Serving at ws://${server.address.host}:${server.port}',
      );
      return true;
    }());
    return server;
  });
}

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
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) => shelf.Response.ok(
  body,
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
shelf.Response responseOkFile({
  String? filePath,
  Stream<List<int>>? fileStream,
  Map<String, /* String | List<String> */ Object>? headers,
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) {
  final file = filePath?.file();
  return responseOk(
    fileStream ?? file?.openRead(),
    headers:
        headers ??
        (file == null
            ? null
            : {
                HttpHeaders.contentDisposition:
                    'attachment; filename="${file.fileName().encodeUri()}"',
                HttpHeaders.contentLengthHeader: file.lengthSync().toString(),
                HttpHeaders.contentTypeHeader:
                    _defaultMimeTypeResolver.lookup(file.path) ??
                    'application/octet-stream',
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
      debugger(when: debugLabel != null);
    }
    onConnection?.call(webSocket, subProtocol);
  });
  debugger(when: debugLabel != null);
  //启动一个服务/支持WebSocket服务
  return await shelf_io.serve(handler, host ?? 'localhost', port).then((
    server,
  ) {
    debugger(when: debugLabel != null);
    assert(() {
      l.d(
        '${debugLabel?.wsb}Serving at ws://${server.address.host}:${server.port}',
      );
      return true;
    }());
    return server;
  });
}

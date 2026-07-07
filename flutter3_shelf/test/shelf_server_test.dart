import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/07
///

void main() async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_echoRequest);

  final server = await shelf_io.serve(handler, 'localhost', 9090);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');

  // 等待
  await Future.delayed(Duration(days: 1));
}

Response _echoRequest(Request request) =>
    Response.ok('Request for "${request.url}"');

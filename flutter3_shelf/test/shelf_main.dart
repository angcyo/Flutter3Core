///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/15
///
/// https://github.com/dart-lang/shelf/blob/master/pkgs/shelf/example/example.dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  final server = await shelf_io.serve(
      handler, 'localhost', 8080); //Serving at http://localhost:8080
  //final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080); //Serving at http://0.0.0.0:8080
  //final server = await shelf_io.serve(handler, InternetAddress.anyIPv6, 8080); //Serving at http://:::8080

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');

  //等待进程结束
  await Future.delayed(const Duration(days: 1));
}

Response _echoRequest(Request request) =>
    Response.ok('Request for "${request.url}"\n$request');

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/16
///

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final handler = webSocketHandler((webSocket, subProtocol) {
    webSocket.stream.listen((message) {
      webSocket.sink.add("echo $message");
    });
  });

  //启动一个服务/支持WebSocket服务
  await shelf_io.serve(handler, 'localhost', 8080).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');
  });

  //等待进程结束
  await Future.delayed(const Duration(days: 1));
}

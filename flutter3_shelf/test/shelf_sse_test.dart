import 'dart:developer';

import 'package:flutter3_app/flutter3_app.dart';
import 'package:shelf/shelf_io.dart' as io;
//import 'package:sse/client/sse_client.dart';
import 'package:sse/server/sse_handler.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/20
///
/// sse 测试
/// https://pub.dev/packages/shelf
/// https://pub.dev/packages/sse
///
/// ```
/// ?sseClientId=xxx
/// accept: text/event-stream
/// ```
///
void main() async {
  print("启动服务!");
  startDioSSEClient();
  //await startSSEClient();
  await startSSEServer();
  print("hello shelf sse");
}

/// 启动服务端
Future<void> startSSEServer() async {
  var handler = SseHandler(Uri.parse('/sseHandler'));
  await io.serve(handler.handler, 'localhost', 8082);
  var connections = handler.connections;
  while (await connections.hasNext) {
    var connection = await connections.next;
    connection.stream.listen(print);

    int count = 0;
    while (count < 10) {
      //connection.sink.add('id:$count\n\nevent:message\n\ndata:$count\n\n');
      connection.sink.add('id: $count\n\n');
      connection.sink.add('event: message\n\n');
      connection.sink.add('data: $count\n\n');
      await Future.delayed(Duration(milliseconds: 1000));
      count++;
    }
  }
}

/// 启动客户端
Future<void> startSSEClient() async {
  /*final channel = SseClient('/sseHandler');
  channel.stream.listen((s) {
    // Listen for messages and send them back.
    //channel.sink.add(s);
    print("客户端收到消息->$s");
  });*/
}

/// dio sse
Future<void> startDioSSEClient() async {
  "http://localhost:8082/sseHandler"
      .sseEvent((event) {
        l.i(event);
      })
      .get((value, error) {
        //debugger();
      });
}

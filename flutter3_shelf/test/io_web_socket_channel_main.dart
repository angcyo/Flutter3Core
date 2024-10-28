///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/10/28
///
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  //final wsUrl = Uri.parse('ws://localhost:8080');
  final wsUrl = Uri.parse('ws://echo.websocket.events');
  final channel = IOWebSocketChannel.connect(wsUrl);

  await channel.ready;

  await channel.stream.listen((message) {
    print('received: $message');
    channel.sink.add('received!');
    channel.sink.close(3000);
  }).asFuture();

  //等待进程结束
  await Future.delayed(const Duration(days: 1));
}

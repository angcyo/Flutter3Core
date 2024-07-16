///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/16
///
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final wsUrl = Uri.parse('ws://localhost:8080');
  final channel = WebSocketChannel.connect(wsUrl);

  await channel.ready;

  await channel.stream.listen((message) {
    channel.sink.add('received!');
    channel.sink.close(status.goingAway);
  }).asFuture();

  //等待进程结束
  await Future.delayed(const Duration(days: 1));
}

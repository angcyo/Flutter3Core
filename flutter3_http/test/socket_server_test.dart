import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/03
///
/// - [ServerSocket] 服务端示例
void main() async {
  // 1. 绑定本地地址与端口
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4040);
  print('服务端已启动: ${server.address.address}:${server.port}');

  // 2. 监听连接请求
  await server.listen((Socket client) {
    handleClient(client);
  }).asFuture();
  print("...end!");
}

void handleClient(Socket client) {
  print('新客户端连接: ${client.remoteAddress.address}:${client.remotePort}');
  // 接收数据
  client.listen(
    (data) {
      try {
        final message = utf8.decode(data);
        //print('收到消息: $message');
        print('收到客户端数据[${data.runtimeType}]: ${data.length} bytes : $message');
      } catch (e) {
        print('收到客户端数据[${data.runtimeType}]: ${data.length}');
      }
      // 回复客户端
      try {
        //client.add(data);
      } catch (e) {
        //SocketException: Write failed (OS Error: Broken pipe, errno = 32), address = 0.0.0.0, port = 4040
        print("写入客户端数据失败:$e");
      }
    },
    onError: (error) {
      print('错误: $error');
      client.close();
    },
    onDone: () {
      print('客户端断开连接:Done');
      client.destroy();
    },
    cancelOnError: false,
  );
}

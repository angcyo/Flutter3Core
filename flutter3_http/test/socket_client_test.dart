import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/03
///
void main() async {
  try {
    //final ip = '127.0.0.1';
    //final ip = 0.0.0.0';
    final ip = '0.0.100.1';
    final port = 4040;

    // 1. 连接服务器 (请替换为实际的服务端 IP)
    final socket = await Socket.connect(
      ip,
      port,
      /*timeout: Duration(seconds: 5),*/
    );
    print('已连接至服务器: $ip:$port');

    // 2. 监听服务端消息
    socket.listen(
      (data) {
        //debugger();
        final serverResponse = utf8.decode(data);
        print(
          '收到服务端数据[${data.runtimeType}]: ${data.length} bytes : $serverResponse',
        );
      },
      onError: (error) => disconnect(socket, error),
      onDone: () => disconnect(socket, "done"),
    );

    socket.add(utf8.encode("莫西莫西!"));
    //await socket.close();
    await Future.delayed(Duration(seconds: 3));
    socket.destroy();
    //disconnect(socket, "...end!");
  } catch (e) {
    //SocketException: Connection failed (OS Error: No route to host, errno = 65), address = 0.0.0.1, port = 4040
    print(e);
  }
}

void disconnect(Socket? socket, dynamic reason) {
  socket?.destroy();
  print('连接已关闭: $reason');
}

import 'dart:convert';
import 'dart:io';

void main() async {
  //await testHttp();
  await testWebSocket();
  print('test...end');
}

/// 使用dart进行简单的http请求测试
/// https://juejin.cn/post/7173887462219989005
Future<void> testHttp() async {
  //InternetAddress.loopbackIPv4;

  const url = "http://www.baidu.com";
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  //request.headers.add(name, value);
  final response = await request.close();
  final body = await response.transform(const Utf8Decoder()).join();
  print(body);
  client.close();

  /*client.getUrl(Uri.parse(url)).then((request) {
    return request.close();
  }).then((response) {
    response.transform(const Utf8Decoder()).listen((data) {
      print(data);
    });
  });*/
}

/// 使用dart进行简单的websocket测试
Future<void> testWebSocket() async {
  const url = "ws://echo.websocket.org";
  WebSocket socket = await WebSocket.connect(url);
  socket.add('Hello, World!');
  await for (var data in socket) {
    print("from Server: $data");
    // 关闭连接
    socket.close();
  }
}

/*void test(String | List<int>  data){
}*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_http/flutter3_http.dart';

void main() async {
  //await testHttp();
  //await testWebSocket();
  //await testDio();
  await testSocket();
  print('test...end');
  assert(true);
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

Future testSocket() async {
  Socket.connect('192.168.2.209', 1111).get((value, error) {
    consoleLog('1:$value $error');
  });
  Socket.connect('192.168.2.209', 1111).get((value, error) {
    consoleLog('2:$value $error');
  });
  await Future.delayed(10.seconds);
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

Future testDio() async {
  /*final bytes =
      await "https://gitee.com/angcyo/file/raw/master/LaserPeckerPro/version.json"
          .getBytes();
  print(utf8.decode(bytes ?? []));*/

  final imageBytes =
      await "https://gitcode.net/angcyo/file/-/raw/master/res/code/all_in1.jpg"
          .dioGetBytes();

  print(imageBytes?.toBase64Image());

  //final response = await dio.get('/info');
  //print(response.data);
}

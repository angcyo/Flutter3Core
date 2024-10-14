import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/14
///
void main() async {
  //监听http 8090端口
  final serverPort = 8890;
  final server = await HttpServer.bind('localhost', serverPort);
  print("http server started");

  final interfaces = await NetworkInterface.list(
    includeLoopback: false,
    type: InternetAddressType.IPv4,
  );

  for (final interface in interfaces) {
    for (final address in interface.addresses) {
      if (address.type == InternetAddressType.IPv4) {
        print("http://${address.address}:$serverPort/");
      }
    }
  }

  await for (final request in server) {
    print('request: ${request.uri}');
    try {
      //读取请求体中的所有字节数据
      /*await request.listen((data) {
        //debugger();
        print('data: ${data.length}');
      });*/

      //收集所有请求的字节数据
      final data = await request.fold<List<int>>([], (previous, element) {
        return previous..addAll(element);
      });
      print('data: ${data.length}');

      request.response
        ..statusCode = HttpStatus.ok
        ..write(
            "请求体字节长度: ${data.length}\n是否有\\r:${data.lastIndexOf('\r'.codeUnitAt(0)) != -1}\n是否有\\n:${data.lastIndexOf('\n'.codeUnitAt(0)) != -1}\n是否有\\r\\n:${data.lastIndexOf('\r\n'.codeUnitAt(0)) != -1} ")
        ..close();

      /*final boundary = request.headers.contentType?.parameters['boundary'];
      if (boundary == null) {
        String body = utf8.decode(data);
        request.response
          ..statusCode = HttpStatus.ok
          ..write("$body\n${hasBoundary}")
          ..close();
      } else {
        // 读取请求体
        //GZipDecoder gzip = GZipDecoder();
        //final bytes = gzip.decodeBytes(data); //await consolidatedStreamToBytes(request);
        final bytes = data; //await consolidatedStreamToBytes(request);
        String body = utf8.decode(bytes);

        // Split parts by boundary
        final boundaryBytes = '--$boundary';
        final parts = body.split(boundaryBytes);

        for (final part in parts) {
          // Skip the last part if it's empty (i.e. trailing boundary)
          if (part.trim().isEmpty || part == '--') continue;

          // Remove headers and get the content
          final contentIndex = part.indexOf('\r\n\r\n');
          if (contentIndex == -1) continue;

          final headers = part.substring(0, contentIndex).trim();
          final content =
              part.substring(contentIndex + 4); // 4 is for '\r\n\r\n'

          // 打印出每个部分的头和内容
          print('Part Headers: $headers');
          print('Part Content: $content\n');
        }

        //data 转成字符串
        //final body = utf8.decode(data);
        //读取请求体
        //String requestBody = await utf8.decoder.bind(request).join();
        //print('body: $requestBody');
        //返回响应

        // 设置响应
        request.response
          ..statusCode = HttpStatus.ok
          ..write(body)
          ..close();
      }*/
    } catch (e) {
      print('error: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('error: $e')
        ..close();
    }
  }
  //防止进程退出
  print('...end');
}

Future<List<int>> consolidatedStreamToBytes(HttpRequest request) async {
  final bytes = <int>[];
  await for (final chunk in request) {
    bytes.addAll(chunk);
  }
  return bytes;
}

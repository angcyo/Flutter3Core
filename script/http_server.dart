import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/14
///
///
///
void main() async {
  // await startHttpServer();
  await startSocketHttp();
}

/// 启动一个socket服务端
Future startSocketHttp() async {
  const serverPort = 8891;
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, serverPort);
  print("socket server started->${Directory.current.path}");

  logNetworkInterface(serverPort);

  await for (final socket in server) {
    print(
        '[${DateTime.now()}] socket: ${socket.remoteAddress} ${socket.remotePort}');

    //读取请求体中的所有字节数据
    socket.listen((data) async {
      //debugger();
      final text = utf8.decode(data);
      print('data[${data.length}]->$text');
      //socket.write("HTTP/1.1 200 OK\nconnection: close\ncontent-type: text/plain; charset=utf-8\n\n$text");
      //socket.write("HTTP/1.1 200\nback: 原封不动返回请求内容\n\n$text");
      socket.write("HTTP/1.1 200\n"); //写入协议
      //socket.write(Uri.encodeComponent("connection: close")); //写入头部信息
      socket.write("connection: close"); //写入头部信息
      socket.write("\n\n$text");
      await socket.flush();
      await socket.close();
    });
  }
}

//--

/// 启动一个http协议的服务端
Future startHttpServer() async {
  //监听http 8090端口
  const serverPort = 8890;
  //'localhost'
  final server = await HttpServer.bind(InternetAddress.anyIPv4, serverPort);
  print("http server started->${Directory.current.path}");

  logNetworkInterface(serverPort);

  await for (final request in server) {
    print('[${DateTime.now()}] request[${request.method}]: ${request.uri}');
    try {
      //handleFormDataRequest(request);
      handleRawRequest(request);

      //读取请求体中的所有字节数据
      /*await request.listen((data) {
        //debugger();
        print('data: ${data.length}');
      });*/

      //收集所有请求的字节数据
      /*final data = await request.fold<List<int>>([], (previous, element) {
        return previous..addAll(element);
      });
      print('data: ${data.length}');

      final resBody =
          "请求体字节长度: ${data.length}\n是否有\\r:${data.lastIndexOf('\r'.codeUnitAt(0)) != -1}\n是否有\\n:${data.lastIndexOf('\n'.codeUnitAt(0)) != -1}\n是否有\\r\\n:${data.lastIndexOf('\r\n'.codeUnitAt(0)) != -1}";
      print(resBody);

      request.response
        ..statusCode = HttpStatus.ok
        ..write(resBody)
        ..close();*/

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

/// 原封不动的返回请求信息
Future<void> handleRawRequest(HttpRequest request) async {
  final List<int> bytes = await consolidateHttpClientResponseBytes(request);
  final text = utf8.decode(bytes);
  request.response
    ..statusCode = HttpStatus.ok
    ..write(text)
    ..close();
}

/// 处理form-data请求
Future<void> handleFormDataRequest(HttpRequest request) async {
  //debugger();
  // 解析 multipart/form-data 数据
  /*final boundary =
      _getBoundary(request.headers.contentType?.parameters['boundary']);*/
  final boundary = request.headers.contentType?.parameters['boundary'];

  if (boundary != null) {
    final data = await _parseMultipartFormData(request, boundary);

    // 处理解析后的数据
    print('Parsed Data: $data');

    request.response
      ..statusCode = HttpStatus.ok
      ..write('Data received successfully.')
      ..close();
  } else {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write('Invalid Content Type: ${request.headers.contentType}')
      ..close();
  }
}

String? _getBoundary(String? contentType) {
  if (contentType != null) {
    RegExp regExp = RegExp(r'boundary=(.+)$');
    var match = regExp.firstMatch(contentType);
    return match?.group(1)?.trim();
  }
  return null;
}

Future<Map<String, dynamic>> _parseMultipartFormData(
  HttpRequest request,
  String boundary,
) async {
  Map<String, dynamic> formData = {};
  final List<int> bytes = await consolidateHttpClientResponseBytes(request);
  final boundaryBytes = '--$boundary'.codeUnits;

  int startIndex = 0;
  while (true) {
    startIndex = _findBoundaryIndex(bytes, startIndex, boundaryBytes);
    if (startIndex == -1) break;

    startIndex += boundaryBytes.length;
    int endIndex = startIndex;

    // 寻找下一个boundary
    endIndex = _findBoundaryIndex(bytes, endIndex, boundaryBytes);
    if (endIndex == -1) {
      // 处理最后一个部分
      endIndex = bytes.length;
    }

    // 解析表单内容
    String part = String.fromCharCodes(bytes.sublist(startIndex, endIndex));
    final lines = part.split('\r\n');

    // 获取内容类型，字段名称和数据内容
    String? fieldName;
    String? fieldValue;

    //debugger();
    for (final line in lines) {
      if (line.startsWith('Content-Disposition:')) {
        // 找到字段名称
        final match = RegExp(r'name="(.*?)"').firstMatch(line);
        if (match != null) {
          fieldName = match.group(1);
        }
      } else if (line.isNotEmpty && fieldName != null) {
        // 获取字段值
        fieldValue = line;
      }
    }

    if (fieldName != null && fieldValue != null) {
      formData[fieldName] = fieldValue;
    }

    startIndex = endIndex;
  }

  return formData;
}

int _findBoundaryIndex(List<int> bytes, int start, List<int> boundary) {
  for (int i = start; i < bytes.length - boundary.length; i++) {
    if (bytes.sublist(i, i + boundary.length).equals(boundary)) {
      return i;
    }
  }
  return -1;
}

extension ListEquals on List<int> {
  bool equals(List<int> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}

Future<List<int>> consolidateHttpClientResponseBytes(
  HttpRequest request,
) async {
  final bytes = <int>[];
  await for (final chunk in request) {
    bytes.addAll(chunk);
  }
  return bytes;
}

//--

/// 打印网络接口
Future logNetworkInterface(int serverPort) async {
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
}

import 'dart:io';

import 'package:path/path.dart' as path;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/09/30
/// 本地文件浏览服务
///
/// ## mac 查看端口占用情况
///
/// Activity Monitor
///
/// ```
/// lsof -i :8080
/// lsof -n -P | grep :<port>
/// ```
///
void main(List<String> arguments) async {
  //file:///Users/angcyo/project/Flutter/Flutter3Abc/Flutter3Core/script/local_file_server.dart
  /*print(Platform.script);*/
  //file:///Users/angcyo/project/Flutter/Flutter3Abc/Flutter3Core/script/lib/xxx.exe
  //print(Platform.script.resolve('lib/xxx.exe'));

  // /Users/angcyo/project/Flutter/Flutter3Abc/Flutter3Core/script
  final scriptFilePath = File(Platform.script.toFilePath()).parent.path;
  /*print(scriptFilePath);*/

  // 设置文件服务器的根目录
  // /Users/angcyo/project/Flutter/Flutter3Abc
  /*final rootDirectory = Directory.current.path;
  print(rootDirectory);*/

  final argPath = arguments.getOrNull(0);
  final localServerPath =
      (argPath == null || argPath.isEmpty) ? scriptFilePath : argPath;
  final serverPort = int.parse(arguments.getOrNull(1) ?? "80");

  //print(localServerPath);
  //print(serverPort);

  // 创建 HttpServer 实例
  // 'localhost'
  final server = await HttpServer.bind(InternetAddress.anyIPv4, serverPort);
  print('文件服务->$localServerPath');
  print("http://localhost:$serverPort/");

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

  // 处理请求
  await for (final request in server) {
    // path.join(localServerPath, request.uri.path);
    final requestPath = request.uri.path;
    final filePath =
        localServerPath == "/" ? requestPath : localServerPath + requestPath;
    final file = File(filePath);
    //print("请求->${request.uri.path}");
    print("请求路径->$filePath");

    if (await file.exists()) {
      // 如果请求的是文件,则返回文件内容
      request.response
        ..headers.contentType = ContentType.parse(
            /*lookupMimeType(filePath) ??*/
            'application/octet-stream')
        ..add(await file.readAsBytes())
        ..close();
    } else if (await FileSystemEntity.isDirectory(filePath)) {
      // 如果请求的是目录,则列出目录内容
      final fileList = await Directory(filePath).list().toList();
      final html = _generateDirectoryListingHtml(fileList);
      request.response
        ..headers.contentType = ContentType.html
        ..write(html)
        ..close();
    } else {
      request.response
        ..headers.contentType = ContentType.html
        ..write("404 Not Found")
        ..close();
    }
  }
}

String _generateDirectoryListingHtml(List<FileSystemEntity> fileList) {
  final sb = StringBuffer();
  sb.writeln('<!DOCTYPE html>');
  sb.writeln(
      '<html lang="zh"><head><meta charset="UTF-8"><title>本地文件浏览服务</title></head><body>');
  sb.writeln('<h1>Directory Listing</h1>');
  sb.writeln('<ul>');

  for (final entity in fileList) {
    final name = path.basename(entity.path);
    if (entity is Directory) {
      sb.writeln('<li><a href="$name/">$name/</a></li>');
    } else {
      sb.writeln('<li><a href="$name">$name</a></li>');
    }
  }

  sb.writeln('</ul>');
  sb.writeln('</body></html>');
  return sb.toString();
}

extension ListEx<T> on List<T> {
  /// [List]
  T? getOrNull(int index, [T? nul]) {
    if (index < 0 || index >= length) {
      return nul;
    }
    return this[index];
  }
}

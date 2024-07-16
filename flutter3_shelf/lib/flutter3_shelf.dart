library flutter3_shelf;

import 'dart:convert';
import 'dart:io';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_router/shelf_router.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_multipart/form_data.dart';
export 'package:shelf_multipart/multipart.dart';
export 'package:shelf_router/shelf_router.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2024-7-15
///
class Flutter3Shelf {
  /// 响应html
  static String getResponseHtml(String tile, String body) => '''
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>$tile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<div class="centered-content">
  <p>$body</p>
</div>
</body>
</html>
        ''';

  static String getResponseSucceedHtml(String tile, String body) => '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        .centered-content {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            height: 100%;
        }
    </style>
</head>
<body>
<div class="centered-content">
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
     width="100" height="100">
    <path d="M512 512m-512 0a512 512 0 1 0 1024 0 512 512 0 1 0-1024 0Z" fill="#67EBB2"
          opacity=".15"
    ></path>
    <path d="M512 814.545455a302.545455 302.545455 0 0 1-213.934545-516.48 302.545455 302.545455 0 1 1 427.86909 427.86909A300.555636 300.555636 0 0 1 512 814.545455z m-124.148364-328.052364a36.072727 36.072727 0 0 0-25.6 61.486545l92.997819 93.730909a29.917091 29.917091 0 0 0 42.46109 0l165.853091-166.74909a29.928727 29.928727 0 0 0-40.226909-44.218182l-127.418182 104.808727a29.905455 29.905455 0 0 1-38.597818-0.488727l-45.905454-39.761455a36.002909 36.002909 0 0 0-23.563637-8.808727z"
          fill="#20D76D"></path>
</svg>
<p>$body</p>
</div>
</body>
</html>
  ''';

  static String getReceiveSucceedHtml(String tile, String body, String again) =>
      '''
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>$tile</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        .centered-content {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
            height: 100%;
        }
        .btn {
            color: #20D76D;
            font-size: 20px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="centered-content">
<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
     width="100" height="100">
    <path d="M512 512m-512 0a512 512 0 1 0 1024 0 512 512 0 1 0-1024 0Z" fill="#67EBB2"
          opacity=".15"
    ></path>
    <path d="M512 814.545455a302.545455 302.545455 0 0 1-213.934545-516.48 302.545455 302.545455 0 1 1 427.86909 427.86909A300.555636 300.555636 0 0 1 512 814.545455z m-124.148364-328.052364a36.072727 36.072727 0 0 0-25.6 61.486545l92.997819 93.730909a29.917091 29.917091 0 0 0 42.46109 0l165.853091-166.74909a29.928727 29.928727 0 0 0-40.226909-44.218182l-127.418182 104.808727a29.905455 29.905455 0 0 1-38.597818-0.488727l-45.905454-39.761455a36.002909 36.002909 0 0 0-23.563637-8.808727z"
          fill="#20D76D"></path>
</svg>
<p>$body</p>
<p class="btn">$again</p>
</div>
<script>
    document.querySelector('.btn').addEventListener('click', function () {
        window.location.href = '/';
    });
</script>
</body>
</html>
  ''';

  /// 端口, 如果端口被占用, 会自动++
  int port;

  /// 主机 or ip
  /// 如果获取到了ip, 则会自动赋值ip
  @autoInjectMark
  String host = "localhost";

  /// 全部可以访问的url地址
  @autoInjectMark
  String? address;

  /// 路由
  final _router = Router();

  /// http核心服务服务
  HttpServer? _httpServer;

  Flutter3Shelf({
    this.port = 9200,
  });

  /// [handler]需要时[shelf.Handler]类型
  /// [shelf.Request]
  void get(String route, Function handler) => _router.get(route, handler);

  /// ```
  /// post("/upload", (shelf.Request request) async {
  ///   //debugger();
  ///   //final bytes = await request.read().toBytes(); //这里读出来的是整个body字节内容
  ///   //return shelf.Response.ok(bytes.utf8Str);
  ///
  ///   /*await request
  ///       .read()
  ///       .writeToFile(filePath: await cacheFilePath(nowTimeFileName()));*/
  /// })
  /// ```
  void post(String route, Function handler) => _router.post(route, handler);

  void put(String route, Function handler) => _router.put(route, handler);

  void delete(String route, Function handler) => _router.delete(route, handler);

  void options(String route, Function handler) =>
      _router.options(route, handler);

  /// 上传文件
  /// [savePath] 文件保存的路径, 默认是缓存路径
  /// [onSaveFile] 当有文件上传后, 保存到本地时回调.返回值直接返回给客户端
  void upload({
    String route = "/upload",
    String? savePath,
    dynamic Function(String filePath)? onSaveFile,
  }) {
    _router.post(route, (shelf.Request request) async {
      if (request.isMultipartForm) {
        // Read all form-data parameters into a single map:
        int count = 0;
        int bytesCount = 0;
        dynamic result;
        await for (final formData in request.multipartFormData) {
          final bytes = await formData.part.readBytes();
          count++;
          bytesCount += bytes.length;
          //formData.name
          final fileName = formData.filename ?? "unknown.file";
          //debugger();
          final saveFilePath = savePath == null
              ? await cacheFilePath(fileName, "upload")
              : "$savePath/$fileName";
          await bytes.writeToFile(filePath: saveFilePath);
          result = onSaveFile?.call(saveFilePath);
        }
        //debugger();
        final msg = count <= 1
            ? "文件上传成功:${bytesCount.toSizeStr()}"
            : "文件上传成功($count个文件, 总字节数:${bytesCount.toSizeStr()})";
        if (request.mimeType == "text/html" ||
            request.headers["accept"]?.contains("text/html") == true) {
          return result != null
              ? shelf.Response.ok("$result")
              : responseOk(Flutter3Shelf.getReceiveSucceedHtml(
                  "接收文件", isDebug ? msg : "上传成功", "重新传输"));
        } else {
          return shelf.Response.ok("${result ?? msg}");
        }
      }
      return shelf.Response(500,
          body:
              "不支持的数据类型, 请使用[multipart/form-data]格式上传文件!\n${(await request.read().toBytes()).utf8Str}");
    });
  }

  /// 启动服务
  /// [retryCount] 端口被占用时, 重试次数
  /// [checkNetwork] 是否检查网络, 默认检查, 无ip时, 报错
  Future<HttpServer> start({
    bool checkNetwork = true,
    int retryCount = 5,
  }) async {
    //debugger();
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_router.call);
    int count = 0;
    while (count <= retryCount) {
      try {
        //debugger();
        final ip = await NetworkInfo().getWifiIP();
        if (checkNetwork && ip == null) {
          throw "无网络, 请检查网络连接!";
        }
        host = ip ?? host;
        //debugger();
        _httpServer =
            await shelf_io.serve(handler, host, port).get((value, error) {
          //debugger();
          if (error != null) {
            throw error;
          }
          return value;
        }, null, true);
        /*_httpServer?.handleError((e) {
          l.w('服务关闭:$e');
        });
        _httpServer?.listen((data) {
          debugger();
        }, onError: (e) {
          debugger();
        });*/
        //debugger();
        if (port == 80) {
          address = "http://$host";
        } else if (port == 443) {
          address = "https://$host";
        } else {
          address = "http://$host:$port";
        }
        l.d(address);
        break;
      } catch (e) {
        //debugger();
        //if (e is SocketException) debugger();
        if (e is! String) {
          port++;
          count++;
        } else {
          rethrow;
        }
      }
    }
    //debugger();
    if (_httpServer == null) {
      throw "启动失败, 请稍后重试!";
    }
    return _httpServer!;
  }

  /// 停止服务
  void stop() {
    try {
      _httpServer?.close();
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

/*Router router() {
    final app = Router();

    app.get('/api', (Request request) {
      request.m
      final response = {
        'message': 'Dart API is alive',
        'api_routes': ['/posts', '/posts/{id}']
      };
      return Response.ok(toJson(response));
    });

    app.get('/posts', (Request request) {
      return PostController().find();
    });

    app.get('/posts/<id>', (Request request, String id) {
      return PostController().findOne(id);
    });

    app.get('/files/<name>', (Request request, String name) {
      return FileController().findOne(name);
    });

    return app;
  }*/
}

/// 响应成功, 文本类型
shelf.Response responseOk(
  Object? body, {
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'text/html'
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) =>
    shelf.Response.ok(
      body,
      headers: headers,
      encoding: encoding,
      context: context,
    );

/// 响应成功, 文件类型
shelf.Response responseOkFile({
  String? filePath,
  Stream<List<int>>? fileStream,
  Map<String, /* String | List<String> */ Object>? headers = const {
    HttpHeaders.contentTypeHeader: 'application/octet-stream'
  },
  Encoding? encoding = utf8,
  Map<String, Object>? context,
}) {
  return shelf.Response.ok(
    fileStream ?? File(filePath!).openRead(),
    headers: headers,
    encoding: encoding,
    context: context,
  );
}

library flutter3_shelf;

import 'dart:developer';
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
  /// [onSaveFile] 当有文件上传后, 保存到本地时回调
  void upload({
    String route = "/upload",
    String? savePath,
    void Function(String filePath)? onSaveFile,
  }) {
    _router.post(route, (shelf.Request request) async {
      if (request.isMultipartForm) {
        // Read all form-data parameters into a single map:
        int count = 0;
        await for (final formData in request.multipartFormData) {
          count++;
          final bytes = await formData.part.readBytes();
          //formData.name
          final fileName = formData.filename ?? "unknown.file";
          //debugger();
          final saveFilePath = savePath == null
              ? await cacheFilePath(fileName, "upload")
              : "$savePath/$fileName";
          await bytes.writeToFile(filePath: saveFilePath);
          onSaveFile?.call(saveFilePath);
        }
        return shelf.Response.ok("$count");
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

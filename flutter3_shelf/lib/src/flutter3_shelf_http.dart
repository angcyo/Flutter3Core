part of '../flutter3_shelf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/17
///
/// http 服务端
class Flutter3ShelfHttp {
  /// 端口, 如果端口被占用, 会自动++
  int port;

  /// 协议 http ws
  /// 如果是安全协议, 会自动加上s, 变成 https wss
  String scheme;

  //--

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
  @autoInjectMark
  HttpServer? _httpServer;

  /// 开始时间, 13位时间戳
  int startTime = -1;

  /// 停止时间, 13位时间戳
  int stopTime = -1;

  //--

  Flutter3ShelfHttp({
    this.port = 9200,
    this.scheme = "http",
  }) {
    /*get("/favicon.ico", (shelf.Request request) async {
      final logo = await loadAssetBytes(Assets.png.flutter.keyName);
      return responseOkFile(fileStream: logo.stream);
    });*/
  }

  /// [handler]需要时[shelf.Handler]类型
  /// [shelf.Request]
  void get(String route, Function handler) => _router.get(route, handler);

  /// ```
  /// post("/upload", (shelf.Request request) async {
  ///   //debugger();
  ///   //final bytes = await request.read().toBytes(); //这里读出来的是整个body字节内容
  ///   //return responseOk(bytes.utf8Str);
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

  /// 上传文件的接口
  /// [savePath] 文件保存的路径, 默认是缓存路径
  /// [onSaveFile] 当有文件上传后, 保存到本地时回调.返回值直接返回给客户端
  void upload({
    String route = "/upload",
    String? savePath,
    String title = "接收文件",
    dynamic Function(String filePath)? onSaveFile,
  }) {
    _router.post(route, (shelf.Request request) async {
      if (request.formData() case var form?) {
        // Read all form-data parameters into a single map:
        int count = 0;
        int bytesCount = 0;
        dynamic result;
        await for (final formData in form.formData) {
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
        if (request.isAcceptHtml) {
          return result != null
              ? responseOkHtml(ShelfHtml.getResponseHtml(title, "$result"))
              : responseOkHtml(ShelfHtml.getReceiveSucceedHtml(
                  title, isDebug ? msg : "上传成功", "重新传输"));
        } else {
          return responseOk("${result ?? msg}");
        }
      }
      final text =
          "不支持的数据类型, 请使用[multipart/form-data]格式上传文件!\n${(await request.read().toBytes()).utf8Str}";
      if (request.isAcceptHtml) {
        return shelf.Response(500,
            body: ShelfHtml.getResponseHtml(title, text));
      }
      return shelf.Response(500, body: text);
    });
  }

  /// 获取服务器地址
  String getServerAddress({String? scheme, String? host, int? port}) {
    scheme ??= this.scheme;
    host ??= this.host;
    port ??= this.port;
    if (port == 80) {
      return "$scheme://$host";
    } else if (port == 443) {
      return "${scheme}s://$host";
    } else {
      return "$scheme://$host:$port";
    }
  }

  //---

  /// 创建处理程序
  @overridePoint
  shelf.Handler createHandler() => const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_router.call);

  /// 启动服务
  /// [retryCount] 端口被占用时, 重试次数
  /// [checkNetwork] 是否检查网络, 默认检查, 无ip时, 报错
  @api
  Future<HttpServer> start({
    bool checkNetwork = true,
    int retryCount = 5,
  }) async {
    //debugger();
    final handler = createHandler();
    int count = 0;
    while (count <= retryCount) {
      try {
        //debugger();
        final ip = await $getWifiIp();
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
        startTime = nowTimestamp();
        /*_httpServer?.handleError((e) {
          l.w('服务关闭:$e');
        });
        _httpServer?.listen((data) {
          debugger();
        }, onError: (e) {
          debugger();
        });*/
        //debugger();
        address = getServerAddress();
        l.d("[${classHash()}]服务启动->$address");
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
  @api
  void stop() {
    try {
      _httpServer?.close();
      startTime = 0;
      stopTime = nowTimestamp();
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

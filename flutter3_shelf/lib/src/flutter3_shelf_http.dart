part of '../flutter3_shelf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/17
///
/// 使用[shelf_io.serve]实现的一个[HttpServer] http 服务端.
///
/// - [Router] 接口路由
///
class Flutter3ShelfHttp {
  /// [favicon.ico] 对应的base64数据
  static String faviconBase64 =
      "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";

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

  /// 接口路由处理路由
  final _router = Router();

  /// http核心服务服务
  @autoInjectMark
  HttpServer? _httpServer;

  /// 开始时间, 13位时间戳
  int startTime = -1;

  /// 停止时间, 13位时间戳
  int stopTime = -1;

  //--

  /// https://raw.githubusercontent.com/dart-lang/shelf/refs/heads/master/pkgs/shelf_static/example/files/favicon.ico
  Flutter3ShelfHttp({this.port = 9200, this.scheme = "http"}) {
    get("/favicon.ico", (shelf.Request request) async {
      //final logo = await loadAssetBytes(Assets.png.flutter.keyName);
      final bytes = faviconBase64.toBase64Bytes;
      return responseOkFile(fileStream: bytes.stream);
    });
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
              : responseOkHtml(
                  ShelfHtml.getReceiveSucceedHtml(
                    title,
                    isDebug ? msg : "上传成功",
                    "重新传输",
                  ),
                );
        } else {
          return responseOk("${result ?? msg}");
        }
      }
      final text =
          "不支持的数据类型, 请使用[multipart/form-data]格式上传文件!\n${(await request.read().toBytes()).utf8Str}";
      if (request.isAcceptHtml) {
        return shelf.Response(
          500,
          body: ShelfHtml.getResponseHtml(title, text),
        );
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
      .addMiddleware((innerHandler) {
        return (request) {
          assert(() {
            final headers = request.headers;
            //debugger();
            l.d("收到请求[${request.method}]->${request.url}");
            return true;
          }());
          return innerHandler(request);
        };
      })
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
        _httpServer = await shelf_io
            .serve(handler, host, port)
            .get(
              (value, error) {
                //debugger();
                if (error != null) {
                  throw error;
                }
                return value;
              },
              null,
              true,
            );
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

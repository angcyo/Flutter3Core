part of '../flutter3_shelf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/17
///
/// 将[Flutter3ShelfHttp]的 HTTP 请求升级到 [WebSocket] 连接
/// - 即能处理WebSocket请求
/// - 也能处理HTTP请求
///
/// WebSocket 服务端, 客户端请参考[Flutter3ShelfWebSocketClient]
/// [webSocket] 是一个 [IOWebSocketChannel]
/// [WebSocket]
class Flutter3ShelfWebSocketServer extends Flutter3ShelfHttp {
  /// WebSocket 客户端连接/状态通知
  final LiveStreamController<WebSocketClient?> clientStreamOnce =
      LiveStreamController(null, autoClearValue: true);

  /// 客户端消息通知
  final LiveStreamController<WebSocketClientMessage?> clientMessageStreamOnce =
      LiveStreamController(null, autoClearValue: true);

  /// WebSocket 客户端列表
  final clientList = <WebSocketClient>[];

  Flutter3ShelfWebSocketServer({super.port = 9200, super.scheme = 'ws'});

  HttpConnectionInfo? _connectionInfo;

  @override
  shelf.Handler createHandler() {
    //http请求处理
    final httpHandler = super.createHandler();
    //WebSocket请求处理
    final webHandler = webSocketHandler((
      WebSocketChannel webSocket,
      String? subProtocol,
    ) {
      //debugger();
      //webSocket.sink.close();
      if (_connectionInfo != null) {
        final client = WebSocketClient(
          clientId: _connectionInfo!.remoteAddress.address,
          state: WebSocketState.connected,
          channel: webSocket,
          connectionInfo: _connectionInfo!,
        );
        clientList.add(client);
        clientStreamOnce.add(client);
        //
        webSocket.stream.listen(
          (message) {
            //webSocket.sink.add("echo:${message.runtimeType} $message");
            clientMessageStreamOnce.add(
              WebSocketClientMessage(client: client, message: message),
            );
          },
          onDone: () {
            closeClient(client);
          },
          onError: (e, s) {
            debugger();
            closeClient(client);
            assert(() {
              printError(e, s);
              return true;
            }());
          },
          cancelOnError: true,
        );
      }
    });

    //同时处理http请求和web请求
    return (shelf.Request request) async {
      try {
        //request.requestedUri; //http://192.168.1.139:9201/ws
        final connectionInfo =
            request.context['shelf.io.connection_info'] as HttpConnectionInfo?;
        _connectionInfo = connectionInfo;
        final response = await httpHandler(request);
        if (response.statusCode == 404) {
          return webHandler(request);
        }
        return response;
      } catch (e) {
        return webHandler(request);
      }
    };
  }

  /// 关闭客户端
  @api
  Future closeClient(WebSocketClient client) async {
    if (clientList.contains(client)) {
      try {
        client.state = WebSocketState.disconnected;
        await client.close();
      } finally {
        clientList.remove(client);
        clientStreamOnce.add(client);
      }
    }
  }

  /// 发送数据
  @api
  void send(String message) {
    for (final client in clientList) {
      try {
        client.send(message);
      } catch (e, s) {
        assert(() {
          printError(e, s);
          return true;
        }());
      }
    }
  }
}

/// WebSocket 客户端
class Flutter3ShelfWebSocketClient {
  Future connect() async {
    /*final wsUrl = Uri.parse('ws://localhost:8080');
    final channel = WebSocketChannel.connect(wsUrl);

    await channel.ready;

    await channel.stream.listen((message) {
      channel.sink.add('received!');
      channel.sink.close(status.goingAway);
    }).asFuture();*/
  }
}

/// 状态
enum WebSocketState {
  /// 无状态
  none,

  /// 已连接
  connected,

  /// 已断开
  disconnected,
}

/// WebSocket 客户端
class WebSocketClient {
  /// 客户端id
  final String clientId;

  /// 双向通道
  /// [AdapterWebSocketChannel.sink] 用来发送数据
  /// [AdapterWebSocketChannel.stream] 用来监听数据
  final WebSocketChannel channel;

  /// 客户端连接信息
  final HttpConnectionInfo connectionInfo;

  WebSocketState state = WebSocketState.none;

  WebSocketClient({
    required this.clientId,
    required this.state,
    required this.channel,
    required this.connectionInfo,
  });

  /// 监听数据
  Stream get stream => channel.stream;

  /// 发送数据
  /// [StreamSink]
  WebSocketSink get sink => channel.sink;

  /// 关闭连接
  Future close() => channel.sink.close();

  /// 发送数据
  void send(dynamic message) {
    channel.sink.add(message);
  }
}

/// 收到客户端发来的消息
class WebSocketClientMessage {
  final WebSocketClient client;
  dynamic message;

  WebSocketClientMessage({required this.client, required this.message});
}

class DebugLogWebSocketServer extends Flutter3ShelfWebSocketServer {
  /// udp需要广播的额外数据
  @configProperty
  static List<FutureOr<Map<String, dynamic>> Function()>
  udpBroadcastDataMapActionList = [];

  /// 默认的调试日志服务器地址, 启动后才会自动赋值
  @output
  static LiveStreamController<String?> debugLogServerAddressStream = $live();

  /// udp广播收到的客户端uuid映射列表
  @output
  static Map<String, dynamic> udpBroadcastClientMap = {};

  /// 处理收到的udp广播数据,
  /// [udpBroadcastClientMap]
  static void handleUdpBroadcastClient(String body) {
    try {
      final map = body.jsonDecode();
      if (map["_type"] == "debugLogBroadcast") {
        final uuid = map["uuid"];
        if (map["_command"] == "start") {
          udpBroadcastClientMap[uuid] = map;
        } else if (map["_command"] == "stop") {
          udpBroadcastClientMap.remove(uuid);
        }
      }
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  //--

  /// udp广播端口
  /// 用来广播[logHtml]
  int udpBroadcastPort = 9299;

  /// udp广播间隔时长
  Duration udpBroadcastDuration = const Duration(seconds: 1);

  /// 唯一标识符
  String uuid = $uuid;

  DebugLogWebSocketServer({super.port = 9200, super.scheme = 'http'}) {
    //注册接口apis
    //--进入首页页面
    get('/', (shelf.Request request) {
      final text = ShelfHtml.getDebugLogIndexHtml().replaceKeyTemplate(
        "bottomInfo",
        nowTimeString().connect(
          DebugPage.buildLastDebugCopyString(
            GlobalConfig.def.globalContext,
          ).connect(null, "<br>").replaceAll("\n", "<br>"),
        ),
      );
      if (request.isAcceptHtml) {
        return responseOkHtml(text);
      }
      return responseOk(text);
    });
    //--进入ws页面
    get('/ws', (shelf.Request request) {
      final text = ShelfHtml.getWebSocketHtml(
        'WebSocket',
        "${getServerAddress(scheme: "ws")}/_ws_server_",
      );
      if (request.isAcceptHtml) {
        return responseOkHtml(text);
      }
      return responseOk(text);
    });
    //--进入文件浏览页面
    get('/files', (shelf.Request request) async {
      final path = request.requestedUri.queryParameters["path"];
      final buffer = StringBuffer();
      //根目录
      final filePathDir = await fileFolder();
      final rootPath = filePathDir.parent.path;
      //debugger();
      //需要请求的路径
      String? targetPath;
      if (isNil(path) || path == ".") {
        // 请求根目录
        targetPath = rootPath;
      } else if (path == "..") {
        // 请求上级
        targetPath = filePathDir.parent.path;
      } else if (path?.isFileExistsSync() == true) {
        // 请求文件
        targetPath = path!;
      } else {
        // 请求子目录
        targetPath = rootPath.connectUrl(path);
      }
      if (await targetPath.isFile()) {
        //返回文件数据流
        return responseOkFile(filePath: targetPath);
      } else {
        //返回文件目录
        buffer.write(ShelfHtml.getFilesHeaderHtml("文件浏览", targetPath)); //头
        buffer.write(
          await ShelfHtml.getFilesListHtml(rootPath, targetPath),
        ); //内容
        buffer.write(ShelfHtml.getFilesFooterHtml()); //尾
        return responseOkHtml(buffer.toString());
      }
    });
    //--进入udp client 客户端列表页面
    get('/list', (shelf.Request request) {
      //debugger();
      final buffer = StringBuffer();
      final values = udpBroadcastClientMap.values;
      buffer.write(
        ShelfHtml.getUdpClientListHeaderHtml(
          "UDP客户端列表",
          "UDP客户端列表[${values.length}]",
        ),
      );
      for (final value in values) {
        buffer.write(
          ShelfHtml.getUdpClientListItemHtml(
            value,
            value["address"] == address,
          ),
        );
      }
      buffer.write(ShelfHtml.getUdpClientListFooterHtml());
      return responseOkHtml(buffer.toString());
    });
    //--转发控制台日志输出
    l.printList.add((log) {
      send(log);
    });
  }

  Timer? _broadcastTimer;

  /// 开始udp广播
  void _startUdpBroadcast() async {
    if (_broadcastTimer != null) {
      return;
    }
    //循环发送udp广播
    _broadcastTimer = Timer.periodic(udpBroadcastDuration, (timer) async {
      if (_httpServer == null) {
        timer.cancel();
        _broadcastTimer = null;
      } else {
        final map = {};
        for (final action in udpBroadcastDataMapActionList) {
          map.addAll(await action());
        }
        //广播自身的服务信息
        sendUdpBroadcast(
          udpBroadcastPort,
          text: {
            "uuid": uuid,
            "_type": "debugLogBroadcast",
            "_command": "start",
            "startTime": startTime.toTimeString(),
            "deviceUuid": $deviceUuid,
            "platformName": $platformName,
            "address": address,
            "logHtml": address,
            ...map,
          }.toJsonString(),
        );
      }
    });
  }

  @override
  Future<HttpServer> start({
    bool checkNetwork = true,
    int retryCount = 5,
  }) async {
    _startUdpBroadcast();
    final server = await super.start(
      checkNetwork: checkNetwork,
      retryCount: retryCount,
    );
    debugLogServerAddressStream << address;
    return server;
  }

  @override
  void stop() {
    //发送一个停止udp广播
    sendUdpBroadcast(
      udpBroadcastPort,
      text: {
        "uuid": uuid,
        "_type": "debugLogBroadcast",
        "_command": "stop",
      }.toJsonString(),
    );
    debugLogServerAddressStream << null;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    super.stop();
  }
}

/// 调试日志数据输出服务
/// - Websocket日志浏览服务
/// - 以及文件浏览接口服务
final DebugLogWebSocketServer $debugLogWebSocketServer =
    DebugLogWebSocketServer()..start(checkNetwork: false, retryCount: 100);

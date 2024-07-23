part of 'flutter3_shelf.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/17
///
/// WebSocket 服务端
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

  Flutter3ShelfWebSocketServer({
    super.port = 9200,
    super.scheme = 'ws',
  });

  HttpConnectionInfo? _connectionInfo;

  @override
  shelf.Handler createHandler() {
    //http请求处理
    final httpHandler = super.createHandler();
    //WebSocket请求处理
    final webHandler = webSocketHandler((IOWebSocketChannel webSocket) {
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
        webSocket.stream.listen((message) {
          //webSocket.sink.add("echo:${message.runtimeType} $message");
          clientMessageStreamOnce.add(WebSocketClientMessage(
            client: client,
            message: message,
          ));
        }, onDone: () {
          closeClient(client);
        }, onError: (e, s) {
          debugger();
          closeClient(client);
          assert(() {
            printError(e, s);
            return true;
          }());
        }, cancelOnError: true);
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
  final IOWebSocketChannel channel;

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

  WebSocketClientMessage({
    required this.client,
    required this.message,
  });
}

class DebugLogWebSocketServer extends Flutter3ShelfWebSocketServer {
  /// 获取日志的网页地址
  String get logHtml => "http://$host:$port/ws";

  DebugLogWebSocketServer({
    super.port = 9200,
    super.scheme = 'ws',
  }) {
    //进入ws页面
    get(
      '/ws',
      (shelf.Request request) {
        final text = ShelfHtml.getWebSocketHtml('WebSocket', address ?? "");
        if (request.isAcceptHtml) {
          return responseOkHtml(text);
        }
        return responseOk(text);
      },
    );
    //进入文件浏览页面
    get(
      '/files',
      (shelf.Request request) async {
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
        } else {
          // 请求子目录
          targetPath = rootPath.connectUrl(path);
        }
        if (await targetPath.isFile()) {
          return responseOkFile(filePath: targetPath);
        } else {
          buffer.write(ShelfHtml.getFilesHeaderHtml("文件浏览", targetPath));
          buffer.write(await ShelfHtml.getFilesListHtml(rootPath, targetPath));
          buffer.write(ShelfHtml.getFilesFooterHtml());
          return responseOkHtml(buffer.toString());
        }
      },
    );
    l.printList.add((log) {
      send(log);
    });
  }
}

/// 调试日志数据输出服务
/// 以及文件浏览接口
final DebugLogWebSocketServer $debugLogWebSocketServer =
    DebugLogWebSocketServer()..start(checkNetwork: false, retryCount: 100);

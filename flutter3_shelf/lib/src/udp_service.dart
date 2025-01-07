part of '../flutter3_shelf.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/07
///
/// 使用UDP进行数据广播以及接收
class UdpService {}

/// 默认实现
class DefaultUdpService extends UdpService {
  /// 单例
  static final DefaultUdpService instance = DefaultUdpService();

  DefaultUdpService();

  /// 释放
  @api
  void dispose() {
    stopServer();
    stopClient();
  }

  //region 服务端

  /// 服务端监听的端口, 客户端向此端口发送数据/发送广播
  /// 监听端口
  @configProperty
  int serverPort = 9992;

  /// 服务端udp
  @output
  UDP? _serverUdp;

  /// 启动服务端
  @api
  Future<UDP> startServer() async {
    if (_serverUdp == null) {
      final udp = await UDP.bind(Endpoint.any(port: Port(serverPort)));
      debugger();
      udp.asStream().listen(
        (packet) {
          debugger();
          if (packet != null) {
            //InternetAddress('192.168.2.105', IPv4)
            packet.address; //数据包来自客户端的ip
            //50198
            packet.port; //数据包来自客户端的端口
            final body = packet.data.utf8Str;
          }
        },
        onError: (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
        },
        onDone: () {
          debugger();
        },
        cancelOnError: true,
      );
      _serverUdp = udp;
    }
    return _serverUdp!;
  }

  /// 停止服务端
  @api
  Future<void> stopServer() async {
    _serverUdp?.close();
    _serverUdp = null;
  }

  //endregion 服务端

  //region 客户端

  /// 客户端udp
  @output
  UDP? _clientUdp;

  /// 获取一个随机未被占用端口的[UDP]
  @api
  Future<UDP?> bindRandomClientUdp() async {
    //被占用的端口
    List<int> occupiedPorts = [];
    int nextPort() {
      final min = 1111;
      final max = 8888;
      int port = nextInt(max, min);
      while (occupiedPorts.contains(port)) {
        port = nextInt(max, min);
      }
      return port;
    }

    while (true) {
      final port = nextPort();
      try {
        final udp = await UDP.bind(Endpoint.any(port: Port(port)));
        return udp;
      } on SocketException catch (e) {
        debugger();
        if (e.osError?.errorCode == 48) {
          //Address already in use
          occupiedPorts.add(port);
        } else {
          break;
        }
      }
    }
    return null;
  }

  /// 启动服务端
  @api
  Future<UDP> startClient() async {
    if (_clientUdp == null) {
      debugger();
      final udp = await UDP.bind(Endpoint.any());
      //final udp = await bindRandomClientUdp();
      udp.asStream().listen(
        (packet) {
          debugger();
          if (packet != null) {
            final body = packet.data.utf8Str;
          }
        },
        onError: (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
        },
        onDone: () {
          debugger();
        },
        cancelOnError: true,
      );
      _clientUdp = udp;
    }
    return _clientUdp!;
  }

  /// 停止客户端
  @api
  Future<void> stopClient() async {
    _clientUdp?.close();
    _clientUdp = null;
  }

  /// 使用客户端udp向服务端口发送广播
  /// @return 发送的字节数
  @api
  Future<int?> sendBroadcast(String data) async {
    // send a simple string to a broadcast endpoint on port 65001.
    if (_clientUdp == null) {
      assert(() {
        l.w("请先调用[startClient]");
        return true;
      }());
    }
    final dataLength = await _clientUdp?.send(
      data.bytes,
      Endpoint.broadcast(port: Port(serverPort)),
    );
    return dataLength;
  }

//endregion 客户端
}

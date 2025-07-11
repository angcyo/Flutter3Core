part of '../flutter3_shelf.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2025/01/07
///
/// 使用UDP进行数据广播以及接收
class UdpService {
  /// 判断指定主机和端口是否被占用
  static Future<bool> isPortOccupied(
    int port, {
    String? hostname,
  }) async {
    // 创建一个尝试连接到指定主机和端口的 Socket。
    Socket? socket;
    try {
      // 设置一个短超时，防止永远等待连接
      socket = await Socket.connect(
        hostname ?? "127.0.0.1",
        port,
        timeout: Duration(milliseconds: 0),
      );
      // 端口被占用
      return true;
    } catch (e) {
      //端口未被占用
      /*assert(() {
        l.v("[$port]端口被占用!");
        return true;
      }());*/
      return false;
    } finally {
      socket?.destroy(); //关闭 socket
    }
  }

  /// 获取一个随机未被占用本机端口的[UDP]
  @api
  static Future<UDP?> bindRandomClientUdp() async {
    //被占用的端口
    List<int> occupiedPorts = [];
    int nextPort() {
      final min = 1111;
      final max = 9999;
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

  /// 获取一个随机可用的端口
  @api
  static Future<int> generatePort() async {
    //被占用的端口
    List<int> occupiedPorts = [];
    int nextPort() {
      final min = 1111;
      final max = 65535;
      int port = nextInt(max, min);
      while (occupiedPorts.contains(port)) {
        port = nextInt(max, min);
      }
      return port;
    }

    while (true) {
      final port = nextPort();
      final used = await isPortOccupied(port);
      if (used) {
        occupiedPorts.add(port);
        continue;
      }
      return port;
    }
  }

  //region server

  /// 服务端的信息
  final serverInfoSignal = $signal<ServiceInfoBean>();

  /// 启动服务端
  @api
  FutureOr startServer() {}

  /// 停止服务端
  @api
  FutureOr stopServer() {}

  /// 服务端服务信息改变通知
  @callPoint
  void onSelfServerInfoChanged(ServiceInfoBean? info) {
    //debugger();
    serverInfoSignal.updateValue(info, false);
  }

  /// 当服务端收到一包数据时回调
  @overridePoint
  void onSelfServerPacket(Datagram packet) {
    //InternetAddress('192.168.2.105', IPv4)
    packet.address; //数据包来自客户端的ip
    //50198
    packet.port; //数据包来自客户端的端口
    //final body = packet.data.utf8Str;
  }

  //endregion server

  //region client

  /// 客户端的信息
  final clientInfoSignal = $signal<ServiceInfoBean>();

  /// 启动服务端
  @api
  FutureOr startClient() {}

  /// 停止客户端
  @api
  FutureOr stopClient() {}

  /// 客户端服务信息改变通知
  @callPoint
  void onSelfClientInfoChanged(ServiceInfoBean? info) {
    clientInfoSignal.updateValue(info, false);
  }

  /// 当客户端收到一包数据时回调
  @overridePoint
  void onSelfClientPacket(Datagram packet) {
    //InternetAddress('192.168.2.105', IPv4)
    packet.address; //数据包来自客户端的ip
    //50198
    packet.port; //数据包来自客户端的端口
    //final body = packet.data.utf8Str;
    assert(() {
      l.v("客户端收到数据包[${packet.address}:${packet.port}]->${packet.data.size().toSizeStr()}");
      return true;
    }());
  }

  //endregion client

  //region api

  /// 使用客户端udp向服务端口发送广播
  ///
  /// - 在`macOs`使用`udp`发送数据时, 需要开启 `Network` 才行. Outgoing Connections (Client)
  /// - 在`iOS`中使用`udp`发送数据时, 需要申请 `com.apple.developer.networking.multicast` 权限才行.
  ///
  /// @return 发送的字节数
  @api
  @overridePoint
  Future<int?> sendBroadcast(List<int> data) async {
    return -1;
  }

  //--

  /// 释放
  @api
  void dispose() {
    stopServer();
    stopClient();
  }

//endregion api
}

/// 默认实现
class DefaultUdpService extends UdpService {
  /// 单例
  static final DefaultUdpService instance = DefaultUdpService();

  DefaultUdpService() {
    $platformDeviceInfoCache;
    //转发控制台日志输出
    l.printList.add((log) {
      if (_clientUdp != null) {
        sendBroadcastMessage(UdpMessageBean.text(log));
      }
    });
  }

  //region 服务端

  /// 服务端监听的端口, 客户端向此端口发送数据/发送广播
  /// 监听端口
  @configProperty
  int serverPort = 9992;

  /// 5秒内, 没有心跳视为离线
  @configProperty
  Duration offlinePeriod = const Duration(seconds: 5);

  /// 新客户端上线通知
  @output
  final newClientStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 客户端上线通知
  @output
  final onlineClientStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 客户端离线通知
  @output
  final offlineClientStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 客户端更新通知, 当前的客户端信息更新时通知
  @output
  final clientUpdateStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 客户端信息列表
  @output
  final clientListStream = $live<List<UdpClientInfoBean>>([]);

  /// 指定客户端收到新的消息时通知
  @output
  final newClientMessageStreamOnce = $liveOnce<UdpMessageBean?>();

  /// 所有客户端收到的消息
  @output
  final clientMessageMapStream = $live<Map<String, List<UdpMessageBean>>>({});

  /// 服务端udp
  @output
  UDP? _serverUdp;

  /// 客户端离线检查定时器
  /// 如果客户端在指定时间内没有发送心跳数据, 则认为客户端已经离线.
  @output
  Timer? _offlineTimer;

  /// 启动服务端
  @api
  @override
  FutureOr startServer() async {
    if (_serverUdp == null) {
      final udp = await UDP.bind(Endpoint.any(port: Port(serverPort)));
      //debugger();
      udp.asStream().listen(
        (packet) {
          //debugger();
          if (packet != null) {
            /*assert(() {
              l.v("服务端收到数据包[${packet.address}:${packet.port}]->${packet.data.size().toSizeStr()}");
              return true;
            }());*/
            onSelfServerPacket(packet);
          }
        },
        onError: (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
          stopServer();
        },
        onDone: () {
          //debugger();
          stopServer();
        },
        cancelOnError: true,
      );
      _serverUdp = udp;
      //--
      onSelfServerInfoChanged(ServiceInfoBean()..servicePort = serverPort);
      //--启动离线检查
      _offlineTimer = Timer.periodic(offlinePeriod, (timer) {
        checkClientOffline();
      });
    }
    return _serverUdp!;
  }

  /// 停止服务端
  @override
  @api
  FutureOr stopServer() async {
    if (_serverUdp == null) {
      //no op
      return;
    }
    try {
      _serverUdp?.close();
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    _serverUdp = null;
    //--
    try {
      onSelfServerInfoChanged(null);
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    _offlineTimer?.cancel();
    _offlineTimer = null;
  }

  /// 检查客户端是否离线
  void checkClientOffline() {
    try {
      final now = nowTime();
      final list = clientListStream.value;
      if (isNil(list)) {
        return;
      }
      for (final client in list!) {
        if (client.isOffline == true) {
          continue;
        }
        if (client.deviceId == serverInfoSignal.value?.deviceId) {
          //本身
          continue;
        }
        final time = client.updateTime ?? client.time;
        if (time == null) {
          continue;
        }
        if (now - time > offlinePeriod.inMilliseconds) {
          //客户端离线
          //debugger();
          client.offlineTime = now;
          offlineClientStreamOnce.updateValue(client);
        }
      }
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  @override
  void onSelfServerPacket(Datagram packet) async {
    try {
      final text = packet.data.utf8Str;
      final packetBean = UdpPacketBean.fromJson(text.fromJson());
      //final packetBean = await UdpPacketBean.fromBytes(packet.data);
      if (packetBean.type == UdpPacketTypeEnum.heart.name) {
        //客户端的心跳
        final client = packetBean.client ?? UdpClientInfoBean();
        client
          ..deviceId = packetBean.deviceId
          ..clientAddress = packet.address.address.toString()
          ..clientPort = packet.port;
        onSelfServerHandleClientPacket(packetBean, client);
      } else {
        final message = packetBean.message;
        if (message != null) {
          //debugger();
          //客户端发来的消息
          message
            ..deviceId = packetBean.deviceId
            ..receiveTime = nowTime()
            ..clientAddress = packet.address.address.toString()
            ..clientPort = packet.port;
          onSelfServerHandleMessagePacket(packetBean, message);
        }
      }
    } catch (e, s) {
      //非法格式的数据
      assert(() {
        l.v("无法解析的数据包[${packet.address}:${packet.port}]->${packet.data.size().toSizeStr()}");
        printError(e, s);
        return true;
      }());
    }
  }

  /// 专心处理客户端心跳消息
  @overridePoint
  void onSelfServerHandleClientPacket(
      UdpPacketBean packet, UdpClientInfoBean bean) {
    //debugger();
    final deviceId = bean.deviceId ??= packet.deviceId;
    final client = getServerClientInfo(deviceId);
    if (client != null) {
      //已有旧设备
      bean.time = client.time ??= nowTime();
    }
    addServerClientInfo(bean);
    if (client == null) {
      //新设备
      bean.time = nowTime(); //设备在线时间
      newClientStreamOnce.updateValue(bean);
    }
  }

  /// 获取服务端指定的客户端
  @api
  UdpClientInfoBean? getServerClientInfo(String? deviceId) {
    final clientList = clientListStream.value ?? [];
    return clientList.findFirst((e) => e.deviceId == deviceId);
  }

  /// 服务端是否有指定的客户端
  @api
  bool haveServerClient(String? deviceId) {
    return getServerClientInfo(deviceId) != null;
  }

  /// 添加客户端
  @api
  void addServerClientInfo(UdpClientInfoBean bean) {
    bean.offlineTime = null;
    bean.updateTime = nowTime();
    final deviceId = bean.deviceId;
    final clientList = clientListStream.value ?? [];
    final findIndex = clientList.indexWhere((e) => e.deviceId == deviceId);
    if (findIndex == -1) {
      //未找到旧的
      clientList.add(bean);
      clientListStream.updateValue(clientList);
    } else {
      //找到旧的
      final find = clientList[findIndex];
      clientList[findIndex] = bean;
      if (find.isOffline) {
        onlineClientStreamOnce.updateValue(find);
      }
    }
  }

  /// 获取服务端的客户端列表
  @api
  List<UdpClientInfoBean> getServerClientList() => clientListStream.value ?? [];

  //--

  /// 专心处理客户端的消息
  @overridePoint
  void onSelfServerHandleMessagePacket(
      UdpPacketBean packet, UdpMessageBean bean) {
    final deviceId = bean.deviceId ??= packet.deviceId;
    final have = haveServerClient(deviceId);
    if (!have) {
      //客户端未在线...
      return;
    }
    addServerMessageInfo(bean);
    newClientMessageStreamOnce.updateValue(bean);
  }

  /// 获取服务端指定客户端的消息
  @api
  List<UdpMessageBean> getServerClientMessageList(String? deviceId) {
    final messageMap = clientMessageMapStream.value ?? {};
    final messageList = messageMap[deviceId] ?? [];
    return messageList;
  }

  /// 添加服务端收到客户端的消息
  @api
  void addServerMessageInfo(UdpMessageBean bean) {
    final deviceId = bean.deviceId;
    if (deviceId == null) {
      return;
    }
    final messageMap = clientMessageMapStream.value ?? {};
    final messageList = messageMap[deviceId] ?? [];
    messageList.add(bean);
    messageMap[deviceId] = messageList;
    clientMessageMapStream.updateValue(messageMap);
  }

  //endregion 服务端

  //region 客户端

  /// 客户端的信息, 将通过心跳发送给服务端
  /// [sendBroadcastHeart]
  @configProperty
  UdpClientInfoBean? clientInfo = UdpClientInfoBean();

  /// 客户端发送心跳的周期
  @configProperty
  Duration heartPeriod = const Duration(seconds: 1);

  /// 客户端udp
  @output
  UDP? _clientUdp;

  /// 客户端心跳定时器
  @output
  Timer? _heartTimer;

  /// 启动客户端
  @api
  @override
  FutureOr startClient() async {
    if (_clientUdp == null) {
      //debugger();
      final udp = await UDP.bind(Endpoint.any());
      //final udp = await bindRandomClientUdp();
      udp.asStream().listen(
        (packet) {
          if (packet != null) {
            onSelfClientPacket(packet);
          }
        },
        onError: (e, s) {
          assert(() {
            printError(e, s);
            return true;
          }());
          stopClient();
        },
        onDone: () {
          //debugger();
          stopClient();
        },
        cancelOnError: true,
      );
      _clientUdp = udp;
      //--
      onSelfClientInfoChanged(
          ServiceInfoBean()..servicePort = udp.local.port?.value ?? -1);
      //--启动心跳
      _heartTimer = Timer.periodic(heartPeriod, (timer) {
        sendBroadcastHeart();
      });
    }
    return _clientUdp!;
  }

  /// 停止客户端
  @api
  @override
  Future<void> stopClient() async {
    if (_clientUdp == null) {
      //no op
      return;
    }
    try {
      _clientUdp?.close();
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    _clientUdp = null;
    try {
      onSelfClientInfoChanged(null);
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
    _heartTimer?.cancel();
    _heartTimer = null;
  }

  /// 使用客户端udp向服务端口发送广播
  /// @return 发送的字节数
  @api
  @override
  Future<int?> sendBroadcast(List<int> data) async {
    // send a simple string to a broadcast endpoint on port 65001.
    if (_clientUdp == null) {
      assert(() {
        l.w("请先调用[startClient]");
        return true;
      }());
      return null;
    }
    try {
      final dataLength = await _clientUdp?.send(
        data,
        Endpoint.broadcast(port: Port(serverPort)),
      );
      return dataLength;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
      return -1;
    }
  }

  ///测试使用tcp发送数据, 看udp能不能收到
  ///
  /// ```
  /// Connection refused (OS Error: Connection refused, errno = 111), address = 192.168.31.250, port = 38196
  /// ```
  @implementation
  FutureOr testTcpSendToClient(
    String? host,
    int? port,
    List<int> data, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (host == null || port == null) {
      return false;
    }
    try {
      //debugger();
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.add(data);
      socket.close();
      socket.destroy();
      return true;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  ///测试使用udp发送数据, 看udp能不能收到
  ///udp 发送数据给 udp, 就是单播广播
  @implementation
  FutureOr testUdpSendToClient(
    String? host,
    int? port,
    List<int> data, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (host == null || port == null) {
      return false;
    }
    try {
      final udp = await UDP.bind(Endpoint.any());
      final result = await udp.send(
          data, Endpoint.unicast(InternetAddress(host), port: Port(port)));
      udp.close();
      return true;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  //--

  /// 发送一包数据
  @api
  Future<bool> sendBroadcastPacket(UdpPacketBean packet) async {
    packet.packetId ??= $uuid;
    packet.deviceId ??= $deviceUuid;
    packet.time ??= nowTime();
    final length =
        await sendBroadcast(packet.toJson().toJsonString(null).bytes);
    return (length ?? 0) > 0;
  }

  /// 发送客户端在线心跳
  @api
  Future<bool> sendBroadcastHeart() async {
    final packet = UdpPacketBean();
    packet.deviceId ??= $deviceUuid;
    //--
    clientInfo?.deviceName ??= $platformDeviceInfoCache?.platformDeviceName;
    clientInfo?.deviceId ??= packet.deviceId;
    //--
    packet
      ..type = UdpPacketTypeEnum.heart.name
      ..data = clientInfo?.toJson().toJsonString(null).bytes;
    return sendBroadcastPacket(packet);
  }

  /// 发送广播消息
  @api
  Future<bool> sendBroadcastMessage(UdpMessageBean message) async {
    final packet = UdpPacketBean();
    packet.deviceId ??= $deviceUuid;
    message
      ..deviceId ??= packet.deviceId
      ..time ??= nowTime();
    packet
      ..type = UdpPacketTypeEnum.message.name
      ..data = message.toJson().toJsonString(null).bytes;
    return sendBroadcastPacket(packet);
  }

//endregion 客户端
}

/// 默认的udp服务
DefaultUdpService get $defaultUdp => DefaultUdpService.instance;

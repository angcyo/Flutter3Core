part of flutter3_shelf;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/02
///
/// - [start] 启动服务
///   - [startHeartTimer] 启动心跳
///     - [onSelfHandleHeart] 自定义心跳逻辑
///       - [checkClientOffline] 检查客户端是否离线
///   - [startReceiveUdpBroadcast] 启动服务端接收客户端数据的广播
///   - [startReceiveUdpBroadcast] 客户端接收服务端信息
/// - [stop] 停止服务
///   - [stopHeartTimer] 停止心跳
///   - [stopReceiveUdpBroadcast] 停止接收广播数据
///
/// - [sendClientPacket] 向服务端发送一包数据[UdpPacketBean]
///   - [sendClientMessage] 向服务端上报消息[UdpMessageBean]
///
abstract class LocalUdpBase {
  //--

  /// 服务端广播的端口,
  /// 客户端监听的端口
  @configProperty
  int serverBroadcastPort = 9999;

  /// 心跳的周期, 用于检查服务端/客户端是否离线
  @configProperty
  Duration heartPeriod = const Duration(seconds: 1);

  /// 5秒内, 没有心跳视为离线
  @configProperty
  Duration offlinePeriod = const Duration(seconds: 5);

  //--

  /// 本地客户端设备信息
  /// 如果为null, 表示服务端未启动
  ///
  /// - 服务端/客户端 每隔一段时间[heartPeriod], 广播自身的信息
  ///
  @output
  final localInfoStream = $live<UdpClientInfoBean?>();

  /// 服务端/客户端设备列表
  @output
  final clientListStream = $live<List<UdpClientInfoBean>?>();

  List<UdpClientInfoBean> get clientList => clientListStream.value ?? [];

  /// 服务端/客户端上线通知
  @output
  final clientOnlineStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 服务端/客户端更新通知
  @output
  final clientUpdateStreamOnce = $liveOnce<UdpClientInfoBean?>();

  /// 服务端/客户端下线通知
  @output
  final clientOfflineStreamOnce = $liveOnce<UdpClientInfoBean?>();

  //--

  /// 所有客户端收到的消息
  @output
  final clientMessageMapStream = $live<Map<String, List<UdpMessageBean>>>({});

  /// 指定客户端收到新的消息时通知
  @output
  final clientNewMessageStreamOnce = $liveOnce<UdpMessageBean?>();

  //region api

  /// 启动
  @api
  Future<bool> start() async {
    startHeartTimer();
    return true;
  }

  /// 停止
  @api
  Future<bool> stop() async {
    stopHeartTimer();
    stopReceiveUdpBroadcast();
    localInfoStream.updateValue(null);
    return true;
  }

  /// 向所有服务端上报一包数据
  @api
  Future sendClientPacket(UdpPacketBean packet) async {
    packet.packetId ??= $uuid;
    packet.deviceId ??= $deviceUuid;
    packet.time ??= nowTime();

    for (final server in clientList) {
      if (server.isOffline) {
        //服务端离线
      } else {
        sendUdpData(server.clientAddress, server.clientPort, bean: packet);
      }
    }
  }

  /// 向所有服务端上报消息
  @api
  Future sendClientMessage(UdpMessageBean message) async {
    final packet = UdpPacketBean();
    packet.deviceId ??= $deviceUuid;
    message
      ..deviceId ??= packet.deviceId
      ..time ??= nowTime();
    packet
      ..type = UdpPacketTypeEnum.message.name
      ..data = jsonString(message.toJson())?.bytes;
    sendClientPacket(packet);
  }

  /// 获取指定的客户端设备信息
  @api
  UdpClientInfoBean? getClientInfo(String? deviceId) {
    return clientList.findFirst((e) => e.deviceId == deviceId);
  }

  /// 获取服务端指定客户端的消息
  @api
  List<UdpMessageBean> getClientMessageList(String? deviceId) {
    final messageMap = clientMessageMapStream.value ?? {};
    final messageList = messageMap[deviceId] ?? [];
    return messageList;
  }

  //region api

  //region core

  /// 心跳定时器
  @output
  Timer? heartTimer;

  /// 开始心跳定时器
  void startHeartTimer() {
    heartTimer?.cancel();
    heartTimer = Timer.periodic(heartPeriod, (timer) {
      onSelfHandleHeart(timer);
    });
  }

  /// 停止心跳定时器
  void stopHeartTimer() {
    heartTimer?.cancel();
    heartTimer = null;
  }

  /// 重写此方法, 处理定时心跳回调
  @overridePoint
  void onSelfHandleHeart(Timer timer) {
    checkClientOffline();
  }

  //--

  @output
  UDP? receiveBroadcastUdp;

  /// 启动一个用于接收广播的UDP
  ///
  /// - 如果是服务端, 则监听客户端发过来的数据
  /// - 如果是客户端, 则监听服务端发过来的数据, 用于保存服务端信息
  ///
  Future<UDP> startReceiveUdpBroadcast(int port) async {
    receiveBroadcastUdp?.close();
    receiveBroadcastUdp = null;
    final udp = await receiveUdpBroadcast(
      port,
      onDatagramAction: (datagram) {
        //收到的广播数据,开始解析数据
        final message = datagram?.data.utf8Str;
        if (message != null) {
          onSelfHandleUdpBroadcast(datagram!, message);
        }
      },
    );
    receiveBroadcastUdp = udp;
    return udp;
  }

  /// 停止接收广播的UDP
  Future<bool> stopReceiveUdpBroadcast() async {
    receiveBroadcastUdp?.close();
    receiveBroadcastUdp = null;
    return true;
  }

  /// 重写此方法, 处理收到的udp广播回调
  @overridePoint
  void onSelfHandleUdpBroadcast(Datagram datagram, String message) {}

  /// 处理客户端[client]结构数据
  /// [checkClientOffline]
  @callPoint
  void handleClientInfoMessage(UdpClientInfoBean client) {
    final deviceId = client.deviceId;
    final list = clientList;
    final old = list.findFirst((e) => e.deviceId == deviceId);
    if (old == null) {
      //新增

      list.add(client);
      clientListStream.updateValue(list);

      clientOnlineStreamOnce.updateValue(client);
    } else {
      //更新
      //debugger();
      final isOffline = old.isOffline;
      old.offlineTime = null; //清空离线时间
      old.updateFrom(client);
      //l.w("客户端在线时间->${old.updateTime}");

      clientUpdateStreamOnce.updateValue(client);
      if (isOffline) {
        clientOnlineStreamOnce.updateValue(client);
      }
    }
  }

  /// 处理客户端[UdpMessageBean]发过来的消息结构数据
  @callPoint
  void handleClientMessageBean(UdpMessageBean bean) {
    final deviceId = bean.deviceId;
    if (deviceId == null) {
      return;
    }
    final messageMap = clientMessageMapStream.value ?? {};
    final messageList = messageMap[deviceId] ?? [];
    messageList.add(bean);
    messageMap[deviceId] = messageList;
    //--
    clientMessageMapStream.updateValue(messageMap);
    //--
    clientNewMessageStreamOnce.updateValue(bean);
  }

  //--

  /// 检查客户端是否离线
  /// [onSelfHandleHeart]
  ///
  /// [clientListStream]
  void checkClientOffline() {
    try {
      final now = nowTime();
      final list = clientList;
      if (isNil(list)) {
        return;
      }
      for (final client in list) {
        if (client.isOffline == true) {
          continue;
        }
        if (client.deviceId == localInfoStream.value?.deviceId) {
          //本身
          continue;
        }
        //debugger();
        final time = client.updateTime ?? client.time;
        if (time == null) {
          continue;
        }
        if (now - time > offlinePeriod.inMilliseconds) {
          //客户端离线
          //debugger();
          //l.w("客户端离线->$now ${client.updateTime}");
          client.offlineTime = now;
          clientOfflineStreamOnce.updateValue(client);
        }
      }
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
    }
  }

  //endregion core
}

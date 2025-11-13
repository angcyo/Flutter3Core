part of flutter3_shelf;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/02
///
/// 本地udp通信服务客户端, 用于上报数据给服务端
///
/// 客户端对接实现功能:
/// - 监听指定端口的UDP广播, 用来获取服务端接收数据的端口
/// - 向服务端的数据端口发送本地数据
///
/// - 客户端监听公共端口[serverBroadcastPort]的广播, 获取服务端信息, 比如通信端口. 保存之后用于通信
/// - [sendRemotePacket]
/// - [sendRemoteMessage]
class LocalUdpClient extends LocalUdpBase {
  //region api

  /// 发送数据给所有服务端
  @api
  void sendUpdData() {
    for (final server in remoteList) {
      //sendUdpData(server.clientAddress, server.clientPort, bean: heart);
    }
  }

  //endregion api

  @override
  Future<bool> start() {
    UdpClientInfoBean clientInfo = localInfoStream.value ?? UdpClientInfoBean();
    clientInfo
      ..deviceId = $deviceUuid
      ..name = Platform.operatingSystem
      ..deviceName = $platformDeviceInfoCache?.platformDeviceName
      ..time = nowTime();

    //--
    localInfoStream.add(clientInfo);

    startReceiveUdpBroadcast(serverBroadcastPort);
    return super.start();
  }

  /// 在心跳回调中, 向服务端发送客户端的信息
  @override
  void onSelfHandleHeart(Timer timer) {
    super.onSelfHandleHeart(timer);

    final info = localInfoStream.value;
    if (info != null) {
      info.updateTime = nowTime();
      localInfoStream.updateValue(info);

      final heart = UdpPacketBean.heart(info);
      sendRemotePacket(heart);
    }
  }

  /// 收到服务端发来的广播
  @override
  void onSelfHandleUdpBroadcast(Datagram datagram, String message) {
    try {
      //debugger();
      final json = jsonDecode(message);
      final packetBean = UdpPacketBean.fromJson(json);
      final server = packetBean.client;
      if (server != null) {
        server.remotePort ??= datagram.port;
        server.remoteAddress ??= datagram.address.address;
        //服务端发来的心跳数据, 此时应该保存服务端信息, 用于上报数据
        handleRemoteInfoMessage(server);
      }
    } catch (e) {
      assert(() {
        print(e);
        return true;
      }());
    }
    super.onSelfHandleUdpBroadcast(datagram, message);
  }
}

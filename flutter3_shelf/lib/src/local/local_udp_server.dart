part of flutter3_shelf;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/02
///
/// 本地udp通信服务服务端, 用于局域网内收集显示客户端的日志信息等
///
/// 服务端主要实现功能:
/// - 每隔1s向指定端口发送UDP广播, 广播服务端的信息. (主要包含服务端用于接收客户端数据的端口)
/// - 服务端监听指定数据端口, 用于接收客户端的数据.
class LocalUdpServer extends LocalUdpBase {
  /// 服务端用来接收客户端数据的端口
  @output
  int? dataPort;

  @override
  Future<bool> start() async {
    if (dataPort == null) {
      final port = await UdpService.generatePort();
      dataPort = port;

      //开始监听客户端的数据
      startReceiveUdpBroadcast(port);
    }
    return super.start();
  }

  /// 服务端每隔一段时间, 广播自身的服务数据
  @override
  void onSelfHandleHeart(Timer timer) {
    super.onSelfHandleHeart(timer);

    //将服务端的数据端口以及自身信息发送出去
    UdpClientInfoBean? serverInfo = localInfoStream.value;
    serverInfo ??= UdpClientInfoBean()
      ..time = nowTime()
      ..clientPort = dataPort;
    serverInfo.updateTime = nowTime();

    //--
    localInfoStream.add(serverInfo);

    //--
    sendUdpBroadcast(
      serverBroadcastPort,
      bean: UdpPacketBean.heart(serverInfo),
    );
  }

  /// 收到客户端的数据
  @override
  void onSelfHandleUdpBroadcast(Datagram datagram, String message) {
    try {
      //debugger();
      final json = jsonDecode(message);
      final packetBean = UdpPacketBean.fromJson(json);
      final client = packetBean.client;
      if (client != null) {
        client.clientPort ??= datagram.port;
        client.clientAddress ??= datagram.address.address;
        //客户端发来的心跳数据, 此时应该保存客户端信息, 用户接受归纳客户端数据
        //debugger();
        handleClientInfoMessage(client);
      } else {
        final message = packetBean.message;
        if (message != null) {
          message.receiveTime ??= nowTime();
          message.clientPort ??= datagram.port;
          message.clientAddress ??= datagram.address.address;
          handleClientMessageBean(message);
        }
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

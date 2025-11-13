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
///
/// - 服务端启动时, 启动一个数据监听广播端口[dataPort]用于客户端通信
/// - 服务端在心跳中向公共端口[serverBroadcastPort]发送服务端信息的广播
///
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
      ..remotePort = dataPort;
    serverInfo.updateTime = nowTime();

    //--
    localInfoStream.add(serverInfo);

    //--
    sendUdpBroadcast(
      serverBroadcastPort,
      bean: UdpPacketBean.heart(serverInfo),
    );

    l.v("服务端UDP发送心跳[$serverBroadcastPort]->$serverInfo");
  }

  /// 服务端收到客户端的数据
  @override
  void onSelfHandleReceiveUdpBroadcast(Datagram datagram, String message) {
    super.onSelfHandleReceiveUdpBroadcast(datagram, message);
  }
}

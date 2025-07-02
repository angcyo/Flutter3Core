part of '../flutter3_shelf.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/23
///

/// 向指定地址和端口, 发送指定的UDP数据
/// @return 返回发送的数据长度
Future<int> sendUdpData(
  String? host,
  int? port, {
  String? text,
  List<int>? data,
  dynamic bean,
  Duration timeout = const Duration(seconds: 1),
}) async {
  if (host == null || port == null) {
    return -1;
  }
  try {
    final udp = await UDP.bind(Endpoint.any());
    final result = await udp
        .send(
          data ?? text?.bytes ?? jsonString(bean?.toJson())?.bytes ?? [],
          Endpoint.unicast(InternetAddress(host), port: Port(port)),
        )
        .wait(timeout);
    udp.close();
    return result;
  } catch (e, s) {
    assert(() {
      printError(e, s);
      return true;
    }());
    return -1;
  }
}

/// 接收UDP广播的数据
/// [receiveUdpBroadcast]
Future<Uint8List?> receiveUdpData(
  int port, {
  Duration? timeout,
  void Function(Datagram? datagram)? onDatagramAction,
}) async {
  final completer = Completer<Uint8List?>();
  final udp = await receiveUdpBroadcast(
    port,
    timeout: timeout,
    onDatagramAction: (datagram) {
      onDatagramAction?.call(datagram);
      if (!completer.isCompleted) {
        final data = datagram?.data;
        completer.complete(data);
      }
    },
  );
  return completer.future;
}

/// 在指定端口, 发送指定的UDP数据广播
/// [data] 发送的数据.[text]发送文本
/// [port] 发送的端口
///
/// ```
/// iOS 发送udp广播需要申请权限.
/// ```
///
/// @return 返回发送的数据长度
Future<int> sendUdpBroadcast(
  int port, {
  String? text,
  List<int>? data,
  dynamic bean,
}) async {
  /*UdpSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
    socket.send(data.codeUnits, InternetAddress.anyIPv4, port);
  });*/
  // creates a UDP instance and binds it to the first available network
  // interface on port 65000.
  final sender = await UDP.bind(Endpoint.any());

  // send a simple string to a broadcast endpoint on port 65001.
  //debugger();
  final dataLength = await sender.send(
    data ?? text?.bytes ?? jsonString(bean?.toJson())?.bytes ?? [],
    Endpoint.broadcast(port: Port(port)),
  );
  sender.close();
  return dataLength;
}

/// 在指定端口, 接收UDP数据广播
/// [port] 监听的端口, 如果端口已被占用会报错.
/// ```
///  SocketException: Failed to create datagram socket (OS Error: Address already in use, errno = 48), address = 0.0.0.0, port = 9999
/// ```
/// [timeout] 接收超时自动关闭时长, 不指定不自动关闭
/// [onDatagramAction] 数据接收回调.
///
/// [Datagram.data] 获取字节数据
///
Future<UDP> receiveUdpBroadcast(
  int port, {
  Duration? timeout,
  void Function(Datagram? datagram)? onDatagramAction,
}) async {
  // creates a new UDP instance and binds it to the local address and the port
  // 65002.
  final receiver = await UDP.bind(Endpoint.any(port: Port(port)));
  //debugger();
  // receiving\listening
  receiver.asStream(timeout: timeout).listen(
    (datagram) {
      //var str = String.fromCharCodes(datagram.data);
      //stdout.write(str);
      //debugger();
      onDatagramAction?.call(datagram);
    },
    onDone: () {
      //完成, 超时之后流会被close, 会走此方法.
      debugger();
      onDatagramAction?.call(null);
    },
    onError: (e) {
      //错误
      debugger();
      onDatagramAction?.call(null);
    },
    cancelOnError: true,
  );
  return receiver;

  /*final receiver = await UDP.bind(Endpoint.any(port: Port(port)));

  // listen to the stream and print the incoming data.
  return await receiver.asStream().first.then((datagram) {
    return String.fromCharCodes(datagram!.data);
  });*/
}

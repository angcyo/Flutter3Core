part of '../flutter3_shelf.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/23
///

/// 在指定端口, 发送指定的UDP数据广播
/// [data] 发送的数据.[text]发送文本
/// [port] 发送的端口
/// @return 返回发送的数据长度
Future<int> sendUdpBroadcast(
  int port, {
  String? text,
  List<int>? data,
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
    data ?? text?.bytes ?? [],
    Endpoint.broadcast(port: Port(port)),
  );
  sender.close();
  return dataLength;
}

/// 在指定端口, 接收UDP数据广播
/// [timeout] 接收超时自动关闭时长, 不指定不自动关闭
/// [onDatagramAction] 数据接收回调
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
  receiver.asStream(timeout: timeout).listen((datagram) {
    //var str = String.fromCharCodes(datagram.data);
    //stdout.write(str);
    //debugger();
    onDatagramAction?.call(datagram);
  });
  return receiver;

  /*final receiver = await UDP.bind(Endpoint.any(port: Port(port)));

  // listen to the stream and print the incoming data.
  return await receiver.asStream().first.then((datagram) {
    return String.fromCharCodes(datagram!.data);
  });*/
}

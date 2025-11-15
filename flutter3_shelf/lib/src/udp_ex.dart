part of '../flutter3_shelf.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/23
///

/// 向指定地址和端口, 发送指定的UDP数据
/// - 支持分包
/// @return 返回发送的数据字节长度
Future<int> sendUdpData(
  String? host,
  int? port, {
  String? text,
  List<int>? data,
  dynamic bean,
  int bufferSize = 4096,
  int partDelay = 6,
  Duration timeout = const Duration(seconds: 1),
}) async {
  if (host == null || port == null) {
    return -1;
  }
  try {
    final udp = await UDP.bind(Endpoint.any());
    final bytes =
        data ?? text?.bytes ?? jsonString(bean?.toJson())?.bytes ?? [];
    final length = bytes.length;
    //debugger(when: length > bufferSize);

    //udp 一包最多发送65535字节, 所以这里需要分包发送
    int sendSize = 0;
    if (length <= 65535) {
      //不分包直接发送
      final result = await udp
          .send(
            bytes,
            Endpoint.unicast(InternetAddress(host), port: Port(port)),
          )
          .wait(timeout);
      sendSize = result;
    } else {
      for (var i = 0; i < length; i += bufferSize) {
        final part = [
          92, //分包标识 "\" 字符
          ...bufferSize.toBytes(4), //每包的数据长度
          ...bytes.sublist(i, minOf(length, i + bufferSize)),
        ];
        final result = await udp
            .send(
              part,
              Endpoint.unicast(InternetAddress(host), port: Port(port)),
            )
            .wait(timeout);
        await sleep(partDelay);
        if (result >= 5) {
          sendSize += result - 5;
        }
      }
      udp.close();
    }

    if (length != sendSize) {
      l.w("UDP发送数据失败, 应发: ${length.toSizeStr()}, 实发: ${sendSize.toSizeStr()}");
      debugger();
    }
    return sendSize;
  } catch (e, s) {
    assert(() {
      printError(e, s);
      return true;
    }());
    return -1;
  }
}

/// 接收UDP广播的数据
/// - 支持分包
/// [receiveUdpBroadcast]
Future<UDP> receiveUdpData(
  int port, {
  Duration? timeout,
  void Function(Datagram? datagram, Object? error)? onDatagramAction,
}) async {
  //收集数据, 用于粘包
  final buffer = <int>[];
  final udp = await receiveUdpBroadcast(
    port,
    timeout: timeout,
    onDatagramAction: (datagram, error) {
      if (datagram == null && error == null) {
        //close
        buffer.clear();
        onDatagramAction?.call(null, null);
      } else if (error != null) {
        buffer.clear();
        onDatagramAction?.call(null, error);
      } else if (datagram != null) {
        final data = datagram.data;
        final first = data.getOrNull(0);
        if (first == 92) {
          //分包标识
          final bufferSize = data.subListCount(1, 4).toInt();
          if (bufferSize > 0) {
            final partBytes = data.subList(5); //每包的真实数据
            buffer.addAll(partBytes);
            if (partBytes.length < bufferSize) {
              //接收完成
              onDatagramAction?.call(
                Datagram(buffer.clone().bytes, datagram.address, datagram.port),
                null,
              );
              buffer.clear();
            } else {
              //继续等待接收数据
            }
          } else {
            //无效的分包头
            onDatagramAction?.call(datagram, null);
          }
        } else {
          //不需要分包
          onDatagramAction?.call(datagram, null);
        }
      }
    },
  );
  return udp;
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
  final bytes = data ?? text?.bytes ?? jsonString(bean?.toJson())?.bytes ?? [];
  final dataLength = await sender.send(
    bytes,
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
  void Function(Datagram? datagram, Object? error)? onDatagramAction,
}) async {
  // creates a new UDP instance and binds it to the local address and the port
  // 65002.
  final receiver = await UDP.bind(Endpoint.any(port: Port(port)));
  //debugger();
  // receiving\listening
  receiver
      .asStream(timeout: timeout)
      .listen(
        (datagram) {
          //var str = String.fromCharCodes(datagram.data);
          //stdout.write(str);
          //debugger();
          onDatagramAction?.call(datagram, null);
        },
        onDone: () {
          //完成, 超时之后流会被close, 会走此方法.
          debugger();
          onDatagramAction?.call(null, null);
        },
        onError: (e) {
          //错误
          debugger();
          onDatagramAction?.call(null, e);
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

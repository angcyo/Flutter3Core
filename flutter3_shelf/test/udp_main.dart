///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/23
///
import 'dart:convert';
import 'dart:io';

import 'package:udp/udp.dart';

void main() async {
  //_testUdp();
  //_testUdpSocket();
  await _testUdpBroadcast();

  await Future.delayed(Duration(seconds: 5));
  print("...end");
}

/// 测试udp发送广播
Future _testUdpBroadcast() async {
  int port = 9999;

  // listen forever & send response
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
    socket.listen(
      (event) {
        if (event != RawSocketEvent.read) {
          print("event->$event");
        }
        if (event == RawSocketEvent.read) {
          Datagram? dg = socket.receive();
          if (dg != null) {
            final recvd = utf8.decode(dg.data); //String.fromCharCodes(dg.data);

            // send ack to anyone who sends ping
            /*if (recvd == "ping"){
              socket.send(Utf8Codec().encode("ping ack"), dg.address, port);
            }*/
            print("收到[${dg.address.address}:${dg.port}]->$recvd");
          }
        }
        if (event == RawSocketEvent.write) {
          //socket.close();
        }
      },
      onError: (error) {
        print("onError->$error");
      },
      onDone: () {
        print("onDone");
      },
      cancelOnError: true,
    );
    socket.broadcastEnabled = true;
    final bytes = utf8.encode("发送广播");
    final send =
        socket.send(bytes, InternetAddress("255.255.255.255"), port - 1);
    print(
        "发送广播[${socket.address}]->[${send}/${bytes.length}]${utf8.decode(bytes)}");
  });
}

///
void _testUdpSocket() {
  int port = 8082;

  // listen forever & send response
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((socket) {
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();
        if (dg == null) return;
        final recvd = utf8.decode(dg.data); //String.fromCharCodes(dg.data);

        /// send ack to anyone who sends ping
        if (recvd == "ping")
          socket.send(utf8.encode("ping ack"), dg.address, port);
        print("$recvd from ${dg.address.address}:${dg.port}");
      }
    });
  });
  print("udp listening on $port");

  // send single packet then close the socket
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port + 1).then((socket) {
    socket.send(utf8.encode("single send"), InternetAddress("127.0.0.1"), port);
    socket.listen((event) {
      if (event == RawSocketEvent.write) {
        socket.close();
        print("single closed");
      }
    });
  });

  // 发送广播
  RawDatagramSocket.bind(InternetAddress.anyIPv4, port + 2).then((socket) {
    socket.broadcastEnabled = true;
    socket.send(utf8.encode("发送广播"), InternetAddress("255.255.255.255"), port);
    socket.listen((event) {
      if (event == RawSocketEvent.write) {
        socket.close();
        print("single closed2");
      }
    });
  });
}

///
void _testUdp() async {
  // creates a UDP instance and binds it to the first available network
  // interface on port 65000.
  var sender = await UDP.bind(Endpoint.any(port: Port(65000)));

  // send a simple string to a broadcast endpoint on port 65001.
  var dataLength = await sender.send(
      "Hello World!".codeUnits, Endpoint.broadcast(port: Port(65001)));

  print("$dataLength bytes sent.");

  // creates a new UDP instance and binds it to the local address and the port
  // 65002.
  var receiver = await UDP.bind(Endpoint.any(port: Port(65001)));

  // receiving\listening
  receiver.asStream(timeout: Duration(seconds: 20)).listen((datagram) {
    var str = String.fromCharCodes(datagram?.data ?? []);
    print(str);
  });

  // close the UDP instances and their sockets.
  sender.close();
  receiver.close();

  // MULTICAST
  var multicastEndpoint =
      Endpoint.multicast(InternetAddress("239.1.2.3"), port: Port(54321));

  /*var receiver = await UDP.bind(multicastEndpoint);

  var sender = await UDP.bind(Endpoint.any());

  receiver.asStream().listen((datagram) {
    if (datagram != null) {
      var str = String.fromCharCodes(datagram?.data);

      stdout.write(str);
    }
  });

  await sender.send("Foo".codeUnits, multicastEndpoint);*/

  await Future.delayed(Duration(seconds: 5));

  sender.close();
  receiver.close();
}

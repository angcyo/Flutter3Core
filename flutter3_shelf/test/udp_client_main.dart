import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/07/01
///
/// UDP 客户端
void main() async {
  print("...start");
  await _testUdpClient();
  await Future.delayed(Duration(seconds: 50));
  print("...end");
}

Future _testUdpClient() async {
  int port = 9998;

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
  });
}

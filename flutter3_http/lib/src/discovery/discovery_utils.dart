import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
///
/// https://github.com/mattsouza26/network_discovery/blob/main/lib/src/utils/utils.dart
class DiscoveryUtils {
  static const _classASubnets = 16777216;
  static const _classBSubnets = 65536;
  static const _classCSubnets = 256;

  //using dart_ping for ping and dicover pingable devices
  /*static Future<HostActive> getHostFromPing(
    String host,
    Duration timeout,
  ) async {
    await for (final PingData pingData in Ping(
      host,
      count: 1,
      timeout: timeout.inSeconds,
    ).stream) {
      final PingResponse? response = pingData.response;
      if (response != null) {
        final Duration? time = response.time;
        if (time != null) {
          return HostActive(host, true);
        }
      }
    }
    return HostActive(host, false);
  }*/

  //using socket for ping and discover ports
  static Future<Socket> getPortFromPing(
    String host,
    int port,
    Duration timeout,
  ) {
    /*assert(() {
      l.v("准备connect:$host:$port $timeout");
      return true;
    }());*/
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return socket;
    });
  }

  //validate ip
  static bool isValidAddress(String ip) {
    final RegExp regExp = RegExp(
      r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    if (regExp.hasMatch(ip)) {
      return true;
    }
    return false;
  }

  //validate ports
  static bool isValidPort(List<int> ports) {
    for (var port in ports) {
      if (port < 0 || port > 65535) {
        return false;
      } else {
        continue;
      }
    }
    return true;
  }

  //define subnet type
  static int getMaxHost(String subnet) {
    final List<String> lastHostIdStr = subnet.split('.');
    if (lastHostIdStr.isEmpty) {
      throw 'Invalid subnet Address';
    }

    final int lastHostId = int.parse(lastHostIdStr[0]);
    if (lastHostId < 128) {
      return _classASubnets;
    } else if (lastHostId >= 128 && lastHostId < 192) {
      return _classBSubnets;
    } else if (lastHostId >= 192 && lastHostId < 224) {
      return _classCSubnets;
    }
    return _classCSubnets;
  }
}

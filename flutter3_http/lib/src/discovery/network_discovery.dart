part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// - ping_discover_network: ^0.2.0+1
///   - https://pub.dev/packages/ping_discover_network
///
/// 网络探测
/// 通过子网[xxx.xxx.xxx]ip地址, 识别有效的后面所有ip地址. [0~255]

/// Pings a given subnet (xxx.xxx.xxx) on a given port using [discover] method.
class NetworkDiscovery {
  /// Pings a given [subnet] (xxx.xxx.xxx) on a given [port].
  ///
  /// Pings IP:PORT one by one
  static Stream<NetworkAddress> discover(
    String subnet,
    int port, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) async* {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }
    // TODO : validate subnet

    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';

      try {
        final Socket s = await Socket.connect(host, port, timeout: timeout);
        s.destroy();
        final address = NetworkAddress(host, openPorts: [port], exists: true);
        onFindAddress?.call(address);
        yield address;
      } catch (e) {
        if (e is! SocketException) {
          rethrow;
        }

        // Check if connection timed out or we got one of predefined errors
        if (e.osError == null || _errorCodes.contains(e.osError?.errorCode)) {
          yield NetworkAddress(host, openPorts: [port], exists: false);
        } else {
          // Error 23,24: Too many open files in system
          rethrow;
        }
      }
    }
  }

  /// Pings a given [subnet] (xxx.xxx.xxx) on a given [port].
  ///
  /// Pings IP:PORT all at once
  static Stream<NetworkAddress> discover2(
    String subnet,
    int port, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }
    // TODO : validate subnet

    final out = StreamController<NetworkAddress>();
    final futures = <Future<Socket>>[];
    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';
      final Future<Socket> f = _ping(host, port, timeout);
      futures.add(f);
      f
          .then((socket) {
            socket.destroy();
            final address = NetworkAddress(
              host,
              openPorts: [port],
              exists: true,
            );
            out.sink.add(address);
            onFindAddress?.call(address);
          })
          .catchError((dynamic e) {
            if (e is! SocketException) {
              throw e;
            }

            // Check if connection timed out or we got one of predefined errors
            if (e.osError == null ||
                _errorCodes.contains(e.osError?.errorCode)) {
              out.sink.add(
                NetworkAddress(host, openPorts: [port], exists: false),
              );
            } else {
              // Error 23,24: Too many open files in system
              throw e;
            }
          });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) => out.close())
        .catchError((dynamic e) => out.close());

    return out.stream;
  }

  static Future<Socket> _ping(String host, int port, Duration timeout) {
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return socket;
    });
  }

  // 13: Connection failed (OS Error: Permission denied)
  // 49: Bind failed (OS Error: Can't assign requested address)
  // 61: OS Error: Connection refused
  // 64: Connection failed (OS Error: Host is down)
  // 65: No route to host
  // 101: Network is unreachable
  // 111: Connection refused
  // 113: No route to host
  // <empty>: SocketException: Connection timed out
  static final _errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];
}

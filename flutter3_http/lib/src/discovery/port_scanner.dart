part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// 端口扫描
///
/// - network_discovery: ^1.0.0
///   - https://github.com/mattsouza26/network_discovery
class PortScanner {
  /// 扫描子网下指定的端口有效的ip
  static Stream<NetworkAddress> discover(
    String subnet,
    int port, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) {
    if (port < 1 || port > 65535) {
      throw 'Provide a valid port range between 0 to 65535';
    }
    final out = StreamController<NetworkAddress>();
    final futures = <Future<Socket>>[];

    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';
      final Future<Socket> socket = DiscoveryUtils.getPortFromPing(
        host,
        port,
        timeout,
      );
      futures.add(socket);

      socket
          .then((Socket s) {
            s.destroy();
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
          });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) => out.close())
        .catchError((dynamic e) => out.close());
    return out.stream;
  }

  /// 扫描多个端口
  static Stream<NetworkAddress> discoverMultiplePorts(
    String subnet,
    List<int> ports, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) {
    if (!DiscoveryUtils.isValidPort(ports)) {
      throw 'Provide a valid port range between 0 to 65535';
    }
    final out = StreamController<NetworkAddress>();
    final futures = <Future<Socket>>[];

    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';
      final networkAddress = NetworkAddress(host, openPorts: List.from([]));
      for (final port in ports) {
        final Future<Socket> socket = DiscoveryUtils.getPortFromPing(
          host,
          port,
          timeout,
        );
        futures.add(socket);

        socket
            .then((Socket s) async {
              s.destroy();
              networkAddress.openPorts.add(port);
              onFindAddress?.call(networkAddress);
            })
            .catchError((dynamic e) async {
              if (e is! SocketException) {
                throw e;
              }
            });
      }

      Future.wait<Socket>(futures)
          .then<void>((sockets) {
            out.sink.add(networkAddress);
          })
          .catchError((dynamic e) {
            if (networkAddress.openPorts.isNotEmpty) {
              out.sink.add(networkAddress);
            }
          });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) => out.close())
        .catchError((dynamic e) => out.close());

    return out.stream;
  }

  /// 使用域名扫描
  static Future<NetworkAddress> discoverFromAddress(
    String address,
    int port, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) async {
    if (!DiscoveryUtils.isValidAddress(address)) {
      throw "Provide a valid ip address";
    }
    if (port < 1 || port > 65535) {
      throw 'Provide a valid port range between 0 to 65535';
    }

    final Future<Socket> socket = DiscoveryUtils.getPortFromPing(
      address,
      port,
      const Duration(seconds: 2),
    );
    final networkAddress = NetworkAddress(address, openPorts: List.from([]));

    await socket
        .then((Socket s) {
          s.destroy();
          networkAddress.openPorts.add(port);
          onFindAddress?.call(networkAddress);
        })
        .catchError((dynamic e) {
          if (e is! SocketException) {
            throw e;
          }
        });
    return networkAddress;
  }

  static Future<NetworkAddress> discoverFromAddressMultiplePorts(
    String address,
    List<int> ports, {
    Duration timeout = const Duration(milliseconds: 400),
    void Function(NetworkAddress address)? onFindAddress,
  }) async {
    if (!DiscoveryUtils.isValidAddress(address)) {
      throw "Provide a valid ip address";
    }
    if (!DiscoveryUtils.isValidPort(ports)) {
      throw 'Provide a valid port range between 0 to 65535';
    }

    final out = StreamController<NetworkAddress>();
    final futures = <Future<Socket>>[];
    final host = address;
    final networkAddress = NetworkAddress(host, openPorts: List.from([]));

    for (var port in ports) {
      final Future<Socket> socket = DiscoveryUtils.getPortFromPing(
        host,
        port,
        timeout,
      );
      futures.add(socket);
      socket
          .then((Socket s) async {
            s.destroy();
            networkAddress.openPorts.add(port);
            onFindAddress?.call(networkAddress);
          })
          .catchError((dynamic e) {
            if (e is! SocketException) {
              throw e;
            }
          });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) {
          out.sink.add(networkAddress);
          out.close();
        })
        .catchError((dynamic e) {
          out.sink.add(networkAddress);
          out.close();
        });

    return out.stream.first;
  }
}

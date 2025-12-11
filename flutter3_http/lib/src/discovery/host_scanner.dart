part of '../../flutter3_http.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/11
///
/// - network_discovery: ^1.0.0
///   - https://github.com/mattsouza26/network_discovery
class HostScanner {
  /*static Stream<HostActive> discoverAllPingableDevices(
    String subnet, {
    required int firstHostId,
    required int lastHostId,
    required Duration timeout,
    required bool resultsInAddressAscendingOrder,
  }) async* {
    final int maxEnd = Utils.getMaxHost(subnet);
    if (firstHostId > lastHostId ||
        firstHostId < 1 ||
        lastHostId < 1 ||
        firstHostId > maxEnd ||
        lastHostId > maxEnd) {
      throw 'Invalid subnet range or firstHostId < lastHostId is not true';
    }
    final int lastValidSubnet = min(lastHostId, maxEnd);
    final out = StreamController<HostActive>();
    final futures = <Future<HostActive>>[];

    for (int i = firstHostId; i <= lastValidSubnet; i++) {
      final host = '$subnet.$i';
      final Future<HostActive> f = Utils.getHostFromPing(host, timeout);
      futures.add(f);
      f
          .then((host) {
            out.sink.add(host);
          })
          .catchError((e) {
            throw e;
          });
    }

    Future.wait<HostActive>(
      futures,
    ).then<void>((host) => out.close()).catchError((dynamic e) => out.close());

    if (!resultsInAddressAscendingOrder) {
      yield* out.stream;
    }

    for (final Future<HostActive> host in futures) {
      final HostActive tempHost = await host;
      yield tempHost;
    }
  }*/
}

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:grpc/src/server/call.dart';

import '../protobuf/test_protobuf.pbgrpc.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/12
///
/// rpc 服务
class TestRpcService extends TestRpcServiceBase {
  @override
  Future<TestProtobuf2> testSayHello(
    ServiceCall call,
    TestProtobuf request,
  ) async {
    return TestProtobuf2(
      test: [request],
      data: [
        MapEntry("收到请求->", "$request"),
        MapEntry("headers ↓", nowTimeString()),
        ...?call.headers?.entries,
        MapEntry("↑", ""),
        MapEntry("clientMetadata ↓↓", nowTimeString()),
        ...?call.clientMetadata?.entries,
        MapEntry("↑↑", ""),
        MapEntry("trailers ↓↓↓", nowTimeString()),
        ...?call.trailers?.entries,
        MapEntry("↑↑↑", ""),
      ],
    );
  }
}

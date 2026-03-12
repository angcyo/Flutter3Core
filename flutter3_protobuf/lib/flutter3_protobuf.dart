import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:grpc/grpc.dart';

import 'src/grpc/test_rpc_service.dart';
import 'src/protobuf/test_protobuf.pbgrpc.dart';

// @formatter:off

export 'package:grpc/grpc.dart';

export 'src/protobuf/test_protobuf.pb.dart';

// @formatter:on

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/11
///
@testPoint
Future<(TestProtobuf2?, Object?)> testRpcClient() async {
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  final stub = TestRpcClient(channel);
  try {
    final response = await stub.testSayHello(TestProtobuf()
      ..query = "查询条件"
      ..corpus = .CORPUS_NEWS);
    return (response, null);
  } catch (e) {
    l.w('Caught error: $e');
    return (null, e);
  } finally {
    await channel.shutdown();
  }
}

/// 启动测试服务端
@testPoint
Future<Server?> startTestRpcServer() async {
  try {
    final server = Server.create(
      services: [TestRpcService()],
      codecRegistry: CodecRegistry(
        codecs: const [GzipCodec(), IdentityCodec()],
      ),
    );
    await server.serve(port: 50051);
    l.i('Server listening on port ${server.port}...');
    return server;
  } catch (e) {
    l.e(e);
    return null;
  }
}

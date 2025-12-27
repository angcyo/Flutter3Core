part of '../../flutter3_mcp.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/27
///
/// Debug MCP Server.
///
final class DebugMCPServer extends MCPServer {
  /// 启动debug mcp服务
  static Future<DebugMCPServer> start() async {
    final clientController = StreamController<String>();
    final serverController = StreamController<String>();

    late final serverChannel = StreamChannel<String>.withCloseGuarantee(
      clientController.stream,
      serverController.sink,
    );

    return DebugMCPServer(
      serverChannel,
      protocolLogSink: await createProtocolLogFileSink(),
    );
  }

  @configProperty
  final String? debugLabel;

  DebugMCPServer(super.channel, {super.protocolLogSink, this.debugLabel})
    : super.fromStreamChannel(
        implementation: Implementation(
          name: 'debug log tooling',
          version: '0.0.1',
        ),
        instructions: 'This server helps to debug log',
      );

  //MARK: - initialized

  @override
  FutureOr<InitializeResult> initialize(InitializeRequest request) async {
    debugger();
    final result = await super.initialize(request);
    return result;
  }

  ///
  @override
  Future<InitializedNotification?> get initialized => super.initialized;

  ///
  @override
  void handleInitialized([InitializedNotification? notification]) {
    super.handleInitialized(notification);
  }

  //MARK: -
}

part of '../../flutter3_mcp.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/27
///
/// Debug MCP Server.
///
/// # mcp_dart 服务器指南
///
/// https://github.com/leehack/mcp_dart/blob/main/doc/server-guide.md
///
/// # mcp 服务检查器
///
/// https://inspector.mcp-use.com/inspector
/// https://mcp.ziziyi.com/inspector
///
final class DebugMcpServer extends McpServer {
  /// - [start] 启动mcp服务
  /// - [close] 关闭mcp服务
  ///
  /// - [StreamableMcpServer]
  /// - [StreamableHTTPServerTransport]
  static Future<StreamableMcpServer?> start() async {
    try {
      final server = StreamableMcpServer(
        serverFactory: (String sessionId) {
          //debugger();
          assert(() {
            l.i("sessionId->$sessionId");
            return true;
          }());
          return DebugMcpServer();
        },
        //host = 'localhost',
        //port = 3000,
        //path = '/mcp',
      );
      await server.start();
      l.d(
        "[DebugMcpServer]Mcp服务启动->http://${server.host}:${server.port}${server.path}",
      );
      return server;
    } catch (e) {
      //server.getCapabilities().logger.severe('Failed to start server: $e');
      assert(() {
        l.w('Failed to start server: $e');
        return true;
      }());
      return null;
    }
  }

  DebugMcpServer()
    : super(
        Implementation(
          name: 'debug log tooling server',
          version: '.0.1',
          description: "debug server by angcyo",
        ),
        options: McpServerOptions(
          capabilities: ServerCapabilities(
            tools: ServerCapabilitiesTools(),
            resources: ServerCapabilitiesResources(),
            prompts: ServerCapabilitiesPrompts(),
            //--
            //logging: ServerCapabilitiesLogging(),
            //experimental: ServerCapabilitiesExperimental(),
          ),
          instructions: "!instructions!",
        ),
      ) {
    //MARK: - prompt
    registerPrompt(
      'Prompt name',
      title: '!Prompt title!',
      description: '!Prompt description!',
      /*argsSchema: {
        'language': const PromptArgumentDefinition(
          type: String,
          description: 'Programming language',
          required: true,
        ),
      },*/
      callback: (args, extra) async {
        return const GetPromptResult(
          description: '!GetPromptResult description!',
          messages: [
            PromptMessage(
              role: PromptMessageRole.user,
              content: TextContent(text: '!GetPromptResult text!'),
            ),
          ],
        );
      },
    );
  }

  //MARK: - api

  /// 连接mcp服务
  @override
  Future<void> connect(Transport transport) {
    return super.connect(transport);
  }

  /// 关闭mcp服务
  @override
  Future<void> close() {
    return super.close();
  }

  /// 发送日志消息
  @api
  Future<void> sendLogMessage(
    String? logger, {
    LoggingLevel? level,
    dynamic data,
    String? sessionId,
  }) async {
    return sendLoggingMessage(
      LoggingMessageNotification(
        level: level ?? .debug,
        logger: logger,
        data: data,
      ),
      sessionId: sessionId,
    );
  }

  //MARK: -
}

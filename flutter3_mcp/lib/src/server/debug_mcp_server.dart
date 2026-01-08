part of '../../flutter3_mcp.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/27
///
/// Debug MCP Server.
///
/// # MCP 协议
///
/// https://modelcontextprotocol.io/specification/2025-11-25
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
  /// - [HttpStreamableMcpServer]
  /// - [StreamableHTTPServerTransport]
  static Future<HttpStreamableMcpServer?> start() async {
    try {
      final server = HttpStreamableMcpServer(
        serverFactory: (HttpStreamableMcpServer server, String sessionId) {
          //debugger();
          assert(() {
            l.i("[${server.classHash()}]收到会话sessionId->$sessionId");
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

  /// # initialize
  /// ```
  /// {"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{"elicitation":{},"sampling":{}},"clientInfo":{"name":"Postman Client","version":"1.0.0"}},"jsonrpc":"2.0","id":0}
  /// ```
  ///
  /// ```
  /// {"method":"notifications/initialized","jsonrpc":"2.0"}
  /// ```
  ///
  /// # tools/list
  ///
  /// ```
  /// {"method":"tools/list","jsonrpc":"2.0","id":1}
  /// ```
  ///
  /// # prompts/list
  ///
  /// ```
  /// {"method":"prompts/list","jsonrpc":"2.0","id":2}
  /// ```
  ///
  /// # resources/list
  ///
  /// ```
  /// {"method":"resources/list","jsonrpc":"2.0","id":3}
  /// ```
  ///
  DebugMcpServer()
    : super(
        Implementation(
          name: 'debug log tooling server',
          version: '.0.1',
          description: "debug server by angcyo",
        ),
        options: McpServerOptions(
          capabilities: ServerCapabilities(
            prompts: ServerCapabilitiesPrompts(),
            tools: ServerCapabilitiesTools(),
            resources: ServerCapabilitiesResources(),
            //--
            //logging: ServerCapabilitiesLogging(),
            //experimental: ServerCapabilitiesExperimental(),
            //completions:
            //tasks:
            //elicitation:
          ),
          instructions: "!instructions!",
        ),
      ) {
    //MARK: - tools
    registerTool(
      'Tool name',
      title: '!Tool title!',
      description: '!Tool description!',
      callback: (args, extra) async {
        //debugger();
        return const CallToolResult(
          content: [TextContent(text: '!ToolResult text!')],
        );
      },
    );
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
        //debugger();
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
    //MARK: - resource
    registerResource('Resource name', "https://www.baidu.com", null, (
      uri,
      extra,
    ) async {
      //debugger();
      return const ReadResourceResult(
        contents: [
          TextResourceContents(
            text: '!ReadResourceResult text!',
            uri: 'https://www.baidu.com',
            mimeType: null,
          ),
        ],
        meta: null,
      );
    });
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

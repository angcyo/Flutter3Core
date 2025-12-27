part of '../../flutter3_mcp.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/27
///
/// MCP 协议log日志

/// 创建一个日志文件sink
Future<Sink<String>> createProtocolLogFileSink({
  String? logFileName,
  File? logFile,
}) async {
  logFile ??= (await (logFileName ??= kMcpFileName).logFilePath()).file();
  logFile.createSync(recursive: true);
  final fileByteSink = logFile.openWrite(mode: FileMode.write, encoding: utf8);
  return fileByteSink.transform(
    StreamSinkTransformer.fromHandlers(
      handleData: (data, innerSink) {
        innerSink.add(utf8.encode(data));
      },
      handleDone: (innerSink) async {
        innerSink.close();
      },
      handleError: (Object e, StackTrace s, _) {
        stderr.writeln('Error in writing to log file ${logFile?.path}: $e\n$s');
      },
    ),
  );
}

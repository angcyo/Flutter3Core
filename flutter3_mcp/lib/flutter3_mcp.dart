library flutter3_mcp;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:stream_channel/stream_channel.dart';

part 'src/core/protocol_log_sink.dart';
part 'src/server/debug_mcp_server.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/12/27
///
///
void _test() async {
  /*l.log;
  "".writeToLog()*/
  await kMcpFileName.logFilePath();
}

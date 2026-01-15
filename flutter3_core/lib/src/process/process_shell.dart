import 'dart:async';
import 'dart:developer';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:process_run/process_run.dart';
import 'package:process_run/stdio.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/01/10
///
/// 进程执行器
///
/// - [ShellLinesController]
class ProcessShell {
  /// 核心执行器
  @output
  late Shell shell;

  @output
  late ShellLinesController shellLinesController;

  @output
  final StreamController<List<int>> stdin = StreamController.broadcast();

  /// 输出流, 指令也会输出
  /// ```
  /// $ pwd
  /// /Users/angcyo/Library/Containers/com.angcyo.flutter3.desktop.abc.flutter3DesktopAbc/Data
  /// ```
  @output
  final StreamController<List<int>> stdout = StreamController.broadcast();

  @output
  final StreamController<List<int>> stderr = StreamController.broadcast();

  ProcessShell() {
    shellLinesController = ShellLinesController();
    shell = Shell(
      /// 不抛出异常, 异常在[stderr]中返回
      throwOnError: false,
      /*stdin: shellLinesController.binaryStream,*/
      stdin: stdin.stream,
      stdout: stdout,
      stderr: stderr,
    );
  }

  /// 执行shell命令
  /// - [script] 支持多条指令
  /// - [onProcess]返回系统的[Process]对象
  @api
  Future<List<ProcessResult>> run(
    String script, {
    ShellOnProcessCallback? onProcess,
  }) async {
    final result = await shell.run(script, onProcess: onProcess);
    //result.firstOrNull?.outText;
    assert(() {
      final errText = result.firstOrNull?.errText;
      debugger(when: !isNil(errText));
      return true;
    }());
    return result;
  }
}

extension ExceptionEx on Object {
  bool get isShellException => this is ShellException;

  String get message =>
      isShellException ? (this as ShellException).message : toString();
}

/// - copy from [ProcessRunProcessResultsExt]
extension ProcessRunProcessResultsEx on List<ProcessResult> {
  String get outText2 => outText;

  String get errText2 => errText;

  Iterable<String> get outLines2 => outLines;

  Iterable<String> get errLines2 => errLines;
}

/// - copy from [ProcessRunProcessResultExt]
extension ProcessRunProcessResultEx on ProcessResult {
  String get outText2 => outText;

  String get errText2 => errText;

  Iterable<String> get outLines2 => outLines;

  Iterable<String> get errLines2 => errLines;
}

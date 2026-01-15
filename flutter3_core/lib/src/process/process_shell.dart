import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:process_run/cmd_run.dart';
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
  Shell? _shell;

  Shell get shell {
    return _shell ??= Shell(
      /// 不抛出异常, 异常在[stderr]中返回
      throwOnError: false,
      verbose: verbose,
      commandVerbose: null,
      runInShell: runInShell,
      /*stdin: shellLinesController.binaryStream,*/
      stdin: stdin.stream,
      stdout: stdout,
      stderr: stderr,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }

  //MARK: config

  @configProperty
  bool verbose = true;
  @configProperty
  bool? runInShell;

  /// - [systemEncoding]
  /// - [systemEncoding]
  @configProperty
  Encoding stdoutEncoding = utf8;
  @configProperty
  Encoding stderrEncoding = utf8;

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

  ProcessShell({this.verbose = true}) {
    shellLinesController = ShellLinesController();
  }

  /// 执行shell脚本批量命令
  /// - [script] 支持多条指令, 会在[shellSplit]方法中进行指令分割.
  ///   - 所以包含空格字符的指令, 需要使用双引号包裹起来.
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

  /// 运行单条命令
  @api
  Future<ProcessResult> cmd(
    String executable, {
    List<String>? arguments,
    String? workingDirectory,
    bool? runInShell,
  }) async {
    final result = await runCmd(
      ProcessCmd(
        executable,
        arguments ?? [],
        workingDirectory: workingDirectory,
        runInShell: runInShell ?? this.runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding,
      ),
      verbose: verbose,
      commandVerbose: null,
      stdin: stdin.stream,
      stdout: stdout,
      stderr: stderr,
    );
    //final result = await shell.run(script, onProcess: onProcess);
    //result.firstOrNull?.outText;
    assert(() {
      final errText = result.errText;
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

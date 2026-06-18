part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/05
/// 进程相关操作
/// https://pub.dev/packages/git

/// 运行本机命令
/// - [runInShell] 为true时, 在Windows上参数中有空格时, 会被shell解析为多个参数, 导致失败
/// - [ProcessStartMode.detached] 脱离模式, 分离进程, 父进程退出, 子进程继续运行.
///   - 此模式下不可以获取进程的任何信息, 子进程自生自灭
///
/// - [Process.runSync]
Future<ProcessResult> runCommand(
  String executable,
  List<String> arguments, {
  bool throwOnError = true,
  bool echoOutput = false,
  bool runInShell = false,
  String? processWorkingDir,
  ProcessStartMode? mode,
}) async {
  mode ??= (echoOutput
      ? ProcessStartMode.inheritStdio
      : ProcessStartMode.normal);
  final isDetach = mode == ProcessStartMode.detached;
  final pr = await Process.start(
    executable,
    arguments,
    workingDirectory: processWorkingDir,
    runInShell: runInShell,
    mode: mode,
  );
  if (isDetach) {
    return ProcessResult(pr.pid, 0, null, null);
  }

  final results = await Future.wait([
    pr.exitCode,
    if (!echoOutput) pr.stdout.transform(const SystemEncoding().decoder).join(),
    if (!echoOutput) pr.stderr.transform(const SystemEncoding().decoder).join(),
  ]);

  final result = ProcessResult(
    pr.pid,
    results[0] as int,
    echoOutput ? null : results[1] as String,
    echoOutput ? null : results[2] as String,
  );

  if (throwOnError) {
    _throwIfProcessFailed(result, executable, arguments);
  }
  return result;
}

void _throwIfProcessFailed(
  ProcessResult pr,
  String process,
  List<String> args,
) {
  if (pr.exitCode != 0) {
    final values = {
      if (pr.stdout != null) 'Standard out': pr.stdout.toString().trim(),
      if (pr.stderr != null) 'Standard error': pr.stderr.toString().trim(),
    }..removeWhere((k, v) => v.isEmpty);

    String message;
    if (values.isEmpty) {
      message = 'Unknown error';
    } else if (values.length == 1) {
      message = values.values.single;
    } else {
      message = values.entries.map((e) => '${e.key}\n${e.value}').join('\n');
    }

    throw ProcessException(process, args, message, pr.exitCode);
  }
}

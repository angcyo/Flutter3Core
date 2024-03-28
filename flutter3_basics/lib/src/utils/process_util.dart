part of '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/03/05
/// 进程相关操作
/// https://pub.dev/packages/git

/// 运行本机命令
Future<ProcessResult> runCommand(
  String executable,
  List<String> arguments, {
  bool throwOnError = true,
  bool echoOutput = false,
  runInShell = true,
  String? processWorkingDir,
}) async {
  final pr = await Process.start(
    executable,
    arguments,
    workingDirectory: processWorkingDir,
    runInShell: runInShell,
    mode: echoOutput ? ProcessStartMode.inheritStdio : ProcessStartMode.normal,
  );

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

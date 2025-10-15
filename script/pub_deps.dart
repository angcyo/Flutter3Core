import 'dart:convert';
import 'dart:io';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/08/21
///
/// https://dart.dev/tools/pub/cmd/pub-deps
@pragma("vm:entry-point")
void main() async {
  colorLog("当前路径->${Directory.current.path}");
  final result = await runCommand(Directory.current.path);
  //写入文件
  final outputPath = "${Directory.current.path}/build/pub_dependencies.txt";
  File(outputPath).writeAsStringSync(result);
  colorLog("已输出到->$outputPath");
  Process.runSync("code", [outputPath], runInShell: true);
}

/// 执行命令
Future<String> runCommand(String dir) async {
  final result = Process.runSync(
    "flutter",
    ["pub", "deps"],
    runInShell: true,
    workingDirectory: dir,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  return result.stdout;
  //colorLog(result.stdout, 250); //输出标准输出
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg\x1B[0m');
}

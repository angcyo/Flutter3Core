import 'dart:io';

import 'package:flutter3_app/flutter3_app.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/12
///
@pragma("vm:entry-point")
void main() async {
  await runAllProjectFlutterPubGetCommand();
}

/// 递归获取指定目录下的所有Flutter工程目录
/// [result] 返回的数据放在此处
@api
Future getFlutterProjectList(
  String path,
  int depth,
  List<FileSystemEntity> result,
  int maxDepth,
) async {
  final folder = path.file();
  final list = await folder.listFiles();
  for (var file in list ?? <FileSystemEntity>[]) {
    if (file.path.isDirectorySync()) {
      final pubspec = file.path.file(fileName: 'pubspec.yaml');
      if (pubspec.existsSync()) {
        result.add(file);
      }
      if (depth < maxDepth) {
        await getFlutterProjectList(file.path, depth + 1, result, maxDepth);
      }
    }
  }
}

/// 执行所有工程的`flutter pub get`命令
@testPoint
Future runAllProjectFlutterPubGetCommand() async {
  final result = <FileSystemEntity>[];
  await getFlutterProjectList(currentDirPath, 1, result, 3);
  consoleLog('找到Flutter工程数量:${result.length}');
  int index = 0;
  for (var file in result) {
    consoleLog('准备执行命令->${++index}/${result.length}');
    await runFlutterPubGetCommand(file.path);
  }
}

/// 在指定路径下, 执行`flutter pub get`命令
@testPoint
Future runFlutterPubGetCommand(String dir) async {
  consoleLog('执行命令->$dir');
  final pr = await runCommand(
    "flutter",
    ['pub', 'get'],
    throwOnError: true,
    echoOutput: true,
    processWorkingDir: dir,
  );
  return pr.exitCode == 0;
}

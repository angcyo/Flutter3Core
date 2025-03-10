import 'dart:io';

import 'package:path/path.dart' as p;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/21
///
/// 在所有 Flutter 项目中，执行 flutter pub get
@pragma("vm:entry-point")
void main() async {
  colorLog("当前路径->${Directory.current.path}");

  final flutterProjectList = <FileSystemEntity>[];
  await findFlutterProjectList(
    Directory.current.path,
    0,
    flutterProjectList,
    3,
    true,
  );
  flutterProjectList.sort((o1, o2) => o1.path.compareTo(o2.path));
  colorLog('找到Flutter工程[${flutterProjectList.length}]个.');
  int index = 0;
  for (final item in flutterProjectList) {
    colorLog('准备执行命令[${++index}/${flutterProjectList.length}]->${item.path}');
    await runFlutterPubGetCommand(item.path);
  }
  colorLog('执行结束[${flutterProjectList.length}]!');
}

/// 查找指定路径[path]下的所有`Flutter`项目所在的目录
/// 通过`pubspec.yaml`文件识别是否是`Flutter`工程
Future findFlutterProjectList(
  String path,
  int depth,
  List<FileSystemEntity> result,
  int maxDepth,
  bool includeRoot,
) async {
  if (depth > maxDepth) {
    return;
  }
  final folder = Directory(path);
  if (includeRoot || depth > 0) {
    if (!p.basename(folder.path).startsWith(".")) {
      final pubspec = File("${folder.path}/pubspec.yaml");
      if (pubspec.existsSync()) {
        result.add(folder);
      }
    }
  }
  await for (final file in folder.list()) {
    if (file is Directory && !p.basename(file.path).startsWith(".")) {
      if (depth < maxDepth) {
        await findFlutterProjectList(
          file.path,
          depth + 1,
          result,
          maxDepth,
          false,
        );
      }
    }
  }
}

/// 执行命令
Future runFlutterPubGetCommand(String dir) async {
  final result = Process.runSync(
    "flutter",
    ["pub", "get"],
    runInShell: true,
    workingDirectory: dir,
  );
  colorLog(result.stdout, 250); //输出标准输出
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

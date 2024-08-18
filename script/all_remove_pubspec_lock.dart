import 'dart:io';

import 'package:path/path.dart' as p;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/08/18
///
/// 在所有 Flutter 项目中，删除`pubspec.lock`文件
@pragma("vm:entry-point")
void main() async {
  colorLog("当前路径->${Directory.current.path}");

  final flutterProjectList = <FileSystemEntity>[];
  await findFlutterProjectList(
    Directory.current.path,
    0,
    flutterProjectList,
    3,
  );
  flutterProjectList.sort((o1, o2) => o1.path.compareTo(o2.path));
  colorLog('找到Flutter工程[${flutterProjectList.length}]个.');
  int index = 0;
  for (final item in flutterProjectList) {
    colorLog('准备执行命令[${++index}/${flutterProjectList.length}]->${item.path}');
    await deletePubspecLock(item.path);
  }
  colorLog('执行结束[${flutterProjectList.length}]!');
}

/// 查找所有Flutter项目所在的目录
Future findFlutterProjectList(
  String path,
  int depth,
  List<FileSystemEntity> result,
  int maxDepth,
) async {
  if (depth > maxDepth) {
    return;
  }
  final folder = Directory(path);
  await for (final file in folder.list()) {
    if (file is Directory && !p.basename(file.path).startsWith(".")) {
      final pubspec = File("${file.path}/pubspec.yaml");
      if (pubspec.existsSync()) {
        result.add(file);
      }
      if (depth < maxDepth) {
        await findFlutterProjectList(file.path, depth + 1, result, maxDepth);
      }
    }
  }
}

/// 执行命令
Future deletePubspecLock(String dir) async {
  final file = File(p.join(dir, "pubspec.lock"));
  file.deleteSync();
  colorLog("删除->${file.path}", 250);
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

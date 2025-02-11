import 'dart:io';

import 'package:path/path.dart' as p;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/10
///
/// ```
/// dart pub workspace list
/// ```
///
/// 输出当前1级路径下包含的`package`相对路径信息到`workspaces.txt`文件中
/// https://dart.cn/tools/pub/workspaces/
///
@pragma("vm:entry-point")
void main() async {
  final rootPath = Directory.current.path;
  colorLog("当前路径->$rootPath");

  //--
  final flutterProjectList = <FileSystemEntity>[];
  await findFlutterProjectList(
    rootPath,
    0,
    flutterProjectList,
    2,
    false,
  );
  colorLog('找到Flutter工程[${flutterProjectList.length}]个.');

  final flutterProjectMap = {};
  //int index = 0;
  for (final item in flutterProjectList) {
    //将路径item.path处理成相对于rootPath的相对路径
    //colorLog(item.path.replaceFirst("$rootPath/", ""));

    //colorLog('准备处理[${++index}/${flutterProjectList.length}]->${item.path}');
    //await runFlutterPubGetCommand(item.path);
    final list = flutterProjectMap.putIfAbsent(
        item.parent.path, () => <FileSystemEntity>[]);
    list.add(item);
  }
  flutterProjectMap.forEach((key, value) {
    //colorLog('${key}->${value.length}');
    final configFile = File("$key/workspaces.txt");
    configFile.writeAsStringSync(
        "# ${DateTime.now()}\n# Create by angcyo (${Platform.script.path.replaceFirst("$rootPath/", "")})\n${value.map((e) => e.path.replaceFirst("$rootPath/", "- ")).join("\n")}");
  });
  colorLog(flutterProjectMap.keys);
  //colorLog(flutterProjectMap.length);
  colorLog(
      '执行结束[${flutterProjectList.length}], 处理工作区[${flutterProjectMap.keys.length}]个!');
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

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

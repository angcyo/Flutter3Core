import 'dart:io';

import 'package:path/path.dart' as p;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/10
///
/// ```
/// # 运行本脚本
/// dart run Flutter3Core/script/pub_workspace.dart
///
/// # 列出所有工作区包
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
  await findFlutterProjectList(rootPath, 0, flutterProjectList, 2, false);
  colorLog('找到Flutter工程[${flutterProjectList.length}]个.');

  final flutterProjectMap = {};
  //int index = 0;
  for (final item in flutterProjectList) {
    //将路径item.path处理成相对于rootPath的相对路径
    //colorLog(item.path.replaceFirst("$rootPath/", ""));

    //colorLog('准备处理[${++index}/${flutterProjectList.length}]->${item.path}');
    //await runFlutterPubGetCommand(item.path);
    final list = flutterProjectMap.putIfAbsent(
      item.parent.path,
      () => <FileSystemEntity>[],
    );
    list.add(item);
  }
  //归纳工作区的状态
  // - 新建
  // - 更新
  // - 未更新
  final stateMap = {};
  final txtName = "workspaces.txt";
  flutterProjectMap.forEach((key, value) {
    //colorLog('$key->${value.length}');
    final configFile = File("$key/$txtName");
    final isNewWorkspace = !configFile.existsSync();
    //读取文件, 用来比对内容是否有改变
    final oldLines = isNewWorkspace ? ["empty"] : configFile.readAsLinesSync();
    final newLines = value.map((e) => e.path.replaceFirst("$rootPath/", "- "));
    bool updateFile = false;
    if (isNewWorkspace) {
      stateMap[key] = "新建";
      updateFile = true;
    } else if (oldLines.join("\n") != newLines.join("\n")) {
      stateMap[key] = "未更新";
    } else {
      stateMap[key] = "更新";
      updateFile = true;
    }
    if (updateFile) {
      configFile.writeAsStringSync(
        "# ${DateTime.now()}\n# Create by angcyo (dart run ${Platform.script.path.replaceFirst("$rootPath/", "")})\n${newLines.join("\n")}",
      );
    }
  });
  colorLog(
    "\n找到工作区[${flutterProjectMap.keys.length}]个,输出到[$txtName]↓:\n${flutterProjectMap.keys.map((e) => e + " -> ${stateMap[e]}").join("\n")}\n",
  );
  //colorLog(flutterProjectMap.length);
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

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg\x1B[0m');
}

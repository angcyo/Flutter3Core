import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/28
///
/// 构建Android Apk
void main() async {
  final currentPath = Directory.current.path;
  print('打包脚本工作路径->$currentPath');

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(localYamlFile.readAsStringSync());
  final yaml = loadYaml(yamlFile.readAsStringSync());

  String? appPackageName =
      yaml["appPackageName"] ?? localYaml["appPackageName"];

  // 需要构建的风味
  String? flavor = yaml["appFlavor"] ?? localYaml["appFlavor"];
  //json文件中的风味标识
  String flavorFlag = yaml["appFlavorFlag"] ??
      localYaml["appFlavorFlag"] ??
      flavor ??
      "release";

  bool? appBuildBundle = yaml["appBuildBundle"] ?? localYaml["appBuildBundle"];

  //--

  await amendAppBuildInfo(packageName: appPackageName, flavorFlag: flavorFlag);

  //开始计时
  final watch = Stopwatch()..start();
  if (appBuildBundle == true) {
    colorLog('开始打包aab...');
    await buildBundle(flavor: flavor);
    colorLog(
        '打包aab完成,耗时:${watch.elapsedMilliseconds ~/ 1000}s${watch.elapsedMilliseconds % 1000}ms');
  } else {
    colorLog('开始打包apk...');
    await buildApk(flavor: flavor);
    colorLog(
        '打包apk完成,耗时:${watch.elapsedMilliseconds ~/ 1000}s${watch.elapsedMilliseconds % 1000}ms');
  }
}

/// 构建apk
/// https://docs.flutter.dev/deployment/android#build-an-app-bundle
Future buildApk({String? flavor}) async {
  await runCommand("flutter", [
    "build",
    "apk",
    "--release",
    if (flavor != null) ...["--flavor", flavor],
  ]);
}

/// 构建aab
/// https://docs.flutter.dev/deployment/android#build-an-app-bundle
Future buildBundle({String? flavor}) async {
  await runCommand("flutter", [
    "build",
    "appbundle",
    "--release",
    if (flavor != null) ...["--flavor", flavor],
  ]);
}

/// 修改app构建信息
Future amendAppBuildInfo({
  String? packageName,
  String? flavorFlag,
}) async {
  await runCommand("dart", [
    "run",
    "Flutter3Core/script/build.dart",
    if (packageName != null) ...["-p", packageName],
    if (flavorFlag != null) ...["-f", flavorFlag],
  ]);
}

//--

/// 执行命令
Future runCommand(
  String executable,
  List<String> arguments, {
  String? dir,
}) async {
  final result = Process.runSync(
    executable,
    arguments,
    runInShell: true,
    workingDirectory: dir ?? Directory.current.path,
  );
  colorLog(result.stdout, 250); //输出标准输出
}

void colorLog(dynamic msg, [int col = 92]) {
  print('\x1B[38;5;${col}m$msg');
}

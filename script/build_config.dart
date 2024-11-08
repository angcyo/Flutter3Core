import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/08
///
/// 用来构建[BuildConfig]
void main(List<String> arguments) {
  final currentPath = Directory.current.path;
  colorLog('[buildConfig]工作路径->$currentPath');

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  //1:
  final buildConfig = yaml?["build_config"] ?? localYaml?["build_config"];
  if (buildConfig == null) {
    colorLog("未找到自定义的[build_config]]配置");
  }
  final json = {
    "buildTime": DateTime.now().toString(),
    "buildOperatingSystem": Platform.operatingSystem,
    "buildOperatingSystemVersion": Platform.operatingSystemVersion,
    "buildOperatingSystemLocaleName": Platform.localeName,
    "buildOperatingSystemUserName":
        Platform.environment['USERNAME'] ?? Platform.environment['USER'],
    if (buildConfig is Map) ...buildConfig,
  };

  //目标文件
  const outputPath = "assets/config";
  final outputFile = File("$currentPath/$outputPath/build_config.json");
  outputFile.parent.createSync();

  outputFile.writeAsStringSync(jsonEncode(json));
  colorLog('构建信息修改->${outputFile.path}↓\n$json');
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

void colorErrorLog(dynamic msg, [int col = 9]) {
  print('\x1B[38;5;${col}m$msg');
}

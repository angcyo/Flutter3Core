import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/08
///
/// 用来构建[BuildConfig]
void main(List<String> arguments) {
  colorLog(
      '[${Platform.script.path.split("/").last.split(".")[0]}]工作路径->${Directory.current.path}');
  final currentPath = Directory.current.path;

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  //1:
  final buildConfig = yaml?["build_config"] ?? localYaml?["build_config"];
  if (buildConfig == null) {
    colorLog(
        "未找到自定义的[build_config]]配置:请在项目根目录中的[script.yaml]文件中加入[build_config]配置信息.");
  } else if (buildConfig is! Map) {
    colorErrorLog("不支持的[build_config]数据类:请使用[Map]类型");
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
  //2:
  Map? androidJson;
  final buildConfigAndroid =
      yaml?["build_config_android"] ?? localYaml?["build_config_android"];
  if (buildConfigAndroid is Map) {
    androidJson = {
      ...json,
      ...buildConfigAndroid,
    };
  } else if (buildConfigAndroid != null && buildConfigAndroid is! Map) {
    colorErrorLog("不支持的[build_config_android]数据类:请使用[Map]类型");
  }
  //3:
  Map? iosJson;
  final buildConfigIos =
      yaml?["build_config_ios"] ?? localYaml?["build_config_ios"];
  if (buildConfigIos is Map) {
    iosJson = {
      ...json,
      ...buildConfigIos,
    };
  } else if (buildConfigIos != null && buildConfigIos is! Map) {
    colorErrorLog("不支持的[build_config_ios]数据类:请使用[Map]类型");
  }

  if (androidJson != null || iosJson != null) {
    json["platformMap"] = {
      if (androidJson != null) "android": androidJson,
      if (iosJson != null) "ios": iosJson,
    };
  }

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

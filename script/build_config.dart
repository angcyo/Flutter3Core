import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '_script_common.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/11/08
///
/// 用来构建[BuildConfig]
void main(List<String> arguments) {
  colorLog(
    '[${Platform.script.path.split("/").last.split(".")[0]}]工作路径->${Directory.current.path}',
  );
  final currentPath = Directory.current.path;

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
    localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "",
  );
  final yaml = loadYaml(
    yamlFile.existsSync() ? yamlFile.readAsStringSync() : "",
  );

  final pubspecFile = File("$currentPath/pubspec.yaml");
  final pubspecYaml = loadYaml(
    pubspecFile.existsSync() ? pubspecFile.readAsStringSync() : "",
  );
  final version = pubspecYaml["version"];
  final buildVersionName = version.split("+")[0];
  final buildVersionCode = version.split("+")[1];

  //1:
  final buildConfig = readBuildConfigMap("build_config");
  if (buildConfig == null) {
    colorLog(
      "未找到自定义的[build_config]]配置:请在项目根目录中的[script.yaml]文件中加入[build_config]配置信息.",
    );
  }
  final json = {
    "buildTime": DateTime.now().toString(),
    "buildOperatingSystem": Platform.operatingSystem,
    "buildOperatingSystemVersion": Platform.operatingSystemVersion,
    "buildOperatingSystemLocaleName": Platform.localeName,
    "buildOperatingSystemUserName":
        Platform.environment['USERNAME'] ?? Platform.environment['USER'],
    "buildVersionName": buildVersionName,
    "buildVersionCode": int.tryParse(buildVersionCode?.toString() ?? ""),
    if (buildConfig is Map) ...buildConfig,
  };
  //debugger();

  //目标文件
  const outputPath = "assets/config";
  final outputFile = File("$currentPath/$outputPath/build_config.json");
  outputFile.parent.createSync(recursive: true);

  outputFile.writeAsStringSync(jsonEncode(json));
  colorLog('构建信息修改->${outputFile.path}↓\n$json');
}

/// 读取指定key对应的map数据
Map? readBuildConfigMap(String key) {
  initScriptCommon();

  final value = $localYaml?[key] ?? $yaml?[key] ?? $pubspec?[key];
  if (value is Map) {
    return value;
  }
  if (value is String) {
    //当做json路径读取
    final jsonFile = File(value);
    if (jsonFile.existsSync()) {
      return jsonDecode(jsonFile.readAsStringSync());
    } else {
      colorErrorLog("配置[$key]对应的json文件不存在: $value");
    }
  } else if (value != null) {
    colorErrorLog("不支持的[$key]数据类[${value.runtimeType}]");
  }
  return null;
}

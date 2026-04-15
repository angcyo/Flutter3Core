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
    '[${Platform.script.toFilePath(windows: isWindows).split("/").last.split(".")[0]}]工作路径->${Directory.current.path}',
  );
  final currentPath = Directory.current.path;

  //从`pubspec.yaml`中获取版本信息
  final pubspecFile = File("$currentPath/pubspec.yaml");
  final pubspecYaml = loadYaml(
    pubspecFile.existsSync() ? pubspecFile.readAsStringSync() : "",
  );
  final version = pubspecYaml["version"] ?? "0.0.1+1";
  final buildVersionName = version.split("+")[0];
  final buildVersionCode = version.split("+")[1];

  //MARK: 1.读取自定义的配置
  final buildConfig = readBuildConfigMap("build_config");
  if (buildConfig == null) {
    colorLog(
      "未找到自定义的[build_config]]配置,请在项目根目录中的[script.yaml]文件中加入[build_config]配置信息.",
    );
  }
  final buildInfoJson = {
    "buildTime": DateTime.now().toString(),
    "buildOperatingSystem": Platform.operatingSystem,
    "buildOperatingSystemVersion": Platform.operatingSystemVersion,
    "buildOperatingSystemLocaleName": Platform.localeName,
    "buildOperatingSystemUserName":
        Platform.environment['USERNAME'] ?? Platform.environment['USER'],
    "buildVersionName": buildVersionName,
    "buildVersionCode": int.tryParse(buildVersionCode?.toString() ?? ""),
  };

  //MARK: 2.组装配置数据
  dynamic json;
  if (buildConfig is Map) {
    final oldJson = buildConfig["json"];
    json = {
      ...buildConfig,
      "json": {...buildInfoJson, ...?oldJson},
    };
  } else {
    colorErrorLog("不支持的[build_config]数据类[${buildConfig.runtimeType}]");
    json = {"json": buildInfoJson};
  }
  //debugger();

  //MARK: 3.输出目标文件
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
    //Map
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

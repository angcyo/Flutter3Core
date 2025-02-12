import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/12
///
/// 收集ios ipa产物
/// 请使用`flutter build ipa --release --export-method ad-hoc`构建ipa
/// 默认输出路径在`build/ios/ipa/xxx.ipa`
/// 默认文件名是`ios/Runner/Info.plist`中`CFBundleName`对应的值
///
/// 配置项(在根的`script.yaml`文件中配置):
/// 产物文件名格式: {app_name}-{version}_{build_config.buildType}.ipa
/// - app_name : 指定收集产物的文件名
/// - build_config.buildType : 构建类型
///
void main() async {
  final fileName = Platform.script.path.split("/").last.split(".")[0];

  final currentPath = Directory.current.path;
  colorLog('[$fileName]工作路径->$currentPath');

  //输出路径
  final outputPath = ".output/.ipa";

  //--
  final bundleName = readBundleName();
  if (bundleName == null || bundleName.isEmpty) {
    colorErrorLog("读取`ios/Runner/Info.plist`中`CFBundleName`对应的值失败");
    return;
  }

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  //--读取配置的app_name
  final appName = yaml?["app_name"] ?? localYaml?["app_name"] ?? bundleName;
  final buildConfig = yaml?["build_config"] ?? localYaml?["build_config"];
  String? buildType;
  if (buildConfig is YamlMap) {
    buildType = buildConfig["buildType"];
  }
  //--读取version
  final pubspecYamlFile = File("$currentPath/pubspec.yaml");
  final pubspecYaml = loadYaml(
      pubspecYamlFile.existsSync() ? pubspecYamlFile.readAsStringSync() : "");
  String? version = pubspecYaml?["version"]?.toString().split("+")[0];

  //源文件文件路径
  final scrPath = "$currentPath/build/ios/ipa/$bundleName.ipa";
  //输出路径
  StringBuffer outputPathBuffer = StringBuffer();
  outputPathBuffer.write("$currentPath/$outputPath");
  if (!outputPath.endsWith("/")) {
    outputPathBuffer.write("/");
  }
  outputPathBuffer.write(appName);
  if (version != null) {
    outputPathBuffer.write("-$version");
  }
  if (buildType != null) {
    outputPathBuffer.write("_$buildType");
  }
  outputPathBuffer.write(".ipa");

  final outputPathString = outputPathBuffer.toString();
  copyFile(scrPath, outputPathString);

  //输出结果
  colorLog('[$fileName]收集完成->$outputPathString');
}

/// 读取`ios/Runner/Info.plist`中`CFBundleName`对应的值
String? readBundleName() {
  final file = File("ios/Runner/Info.plist");
  if (!file.existsSync()) {
    return null;
  }
  final content = file.readAsStringSync();
  final lines = content.split("\n");

  String? bundleName;

  bool find = false;
  for (final line in lines) {
    if (find) {
      //<string>flutter3_abc</string>
      final match = RegExp(r'<string>(.*)</string>').firstMatch(line);
      if (match != null) {
        bundleName = match.group(1);
      }
      break;
    }
    if (line.contains("<key>CFBundleName</key>")) {
      find = true;
    }
  }

  return bundleName;
}

/// 复制文件到指定路径
void copyFile(String srcPath, String dstPath) {
  final srcFile = File(srcPath);
  final dstFile = File(dstPath);

  if (!srcFile.existsSync()) {
    colorErrorLog("源文件不存在:$srcPath");
    return;
  }

  dstFile.createSync(recursive: true);
  dstFile.writeAsBytesSync(srcFile.readAsBytesSync());
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

void colorErrorLog(dynamic msg, [int col = 9]) {
  print('\x1B[38;5;${col}m$msg');
}

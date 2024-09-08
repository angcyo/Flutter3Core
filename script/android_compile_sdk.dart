import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/08/11
///
/// 新版本的flutter 3.24.0使用Android 34编译,
/// 所有子库不使用sdk 34编译的话, 就会在打包的时候报错.
/// ```
/// AAPT: error: resource android:attr/lStar not found.
/// ```
/// ```
/// android {
///     // Conditional for compatibility with AGP <4.2.
///     if (project.android.hasProperty("namespace")) {
///         namespace 'com.rmawatson.flutterisolate'
///     }
///
///     compileSdkVersion 34
///
///     defaultConfig {
///         minSdkVersion 16
///     }
/// }
/// ```
///
/// 此脚本用于在打包前, 修改子库的compileSdkVersion编译版本.
///
void main() async {
  final currentPath = Directory.current.path;
  print('脚本工作路径->$currentPath');

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml = loadYaml(yamlFile.readAsStringSync());

  //Android sdk compile sdk version
  int? compileSdk = yaml["androidCompileSdk"] ?? localYaml["androidCompileSdk"];
  if (compileSdk == null) {
    colorLog("请在[${yamlFile.path}]文件中指定[androidCompileSdk]属性.");
    return;
  }

  // 需要修改库的名字集合, 不指定全部
  // [YamlList]
  final names =
      yaml["androidCompileSdkNames"] ?? localYaml["androidCompileSdkNames"];

  //获取所有依赖的子库
  final dependenciesFile = File("$currentPath/.flutter-plugins-dependencies");
  final androidDependencies =
      jsonDecode(dependenciesFile.readAsStringSync())?["plugins"]?["android"];
  if (androidDependencies is List) {
    //{
    //    "name": "device_info_plus",
    //    "path": "/Users/angcyo/.pub-cache/hosted/pub.dev/device_info_plus-10.1.1/",
    //    "native_build": true,
    //    "dependencies": []
    // },
    int index = 0;
    for (final dependency in androidDependencies) {
      final name = dependency["name"];
      final path = dependency["path"];
      if (path != null) {
        if (names == null || names.contains(name)) {
          colorLog(
              "正在修改[${index + 1}/${androidDependencies.length}]->$path -> compileSdk:$compileSdk");
          amendAndroidCompileSdkVersion(path, compileSdk);
        }
      }
      index++;
    }
  } else {
    colorLog("未找到子模块的依赖信息, 请检查[${dependenciesFile.path}]文件.");
  }
}

/// 核心修改方法
/// 修改子库flutter工程中android工程中`build.gradle`文件中的`compileSdkVersion`和`compileSdk`
/// [flutterPath] flutter工程路径
/// [compileSdk] 修改后的编译版本
void amendAndroidCompileSdkVersion(String flutterPath, int compileSdk) {
  final androidPath = "$flutterPath/android";
  final androidPathFile = File("$androidPath/build.gradle");
  if (androidPathFile.existsSync()) {
    final androidPathFileContent = androidPathFile.readAsStringSync();
    if (androidPathFileContent.contains("compileSdkVersion")) {
      //修改compileSdkVersion
      final newContent = androidPathFileContent
          .replaceAllMapped(RegExp(r"compileSdkVersion\s+(\d+)"), (match) {
        return "compileSdkVersion $compileSdk";
      });
      //修改compileSdk
      final newContent2 =
          newContent.replaceAllMapped(RegExp(r"compileSdk\s+(\d+)"), (match) {
        return "compileSdk $compileSdk";
      });
      //写入文件
      androidPathFile.writeAsStringSync(newContent2);
      colorLog("修改成功->$androidPathFile", 250);
    }
  }
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

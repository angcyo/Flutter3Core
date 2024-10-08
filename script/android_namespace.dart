import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/10/08
///
/// 更新Gradle到7.5.0之后, 需要指定namespace属性, 不指定会报错.
/// ```
/// Namespace not specified.
/// ```
///
/// ```
/// android {
///     if (project.android.hasProperty("namespace")) {
///         namespace 'com.angcyo.xxx'
///     }
/// }
/// ```
///
/// 此脚本用于在`build.gradle`文件的`android{ ... }`中加入`namespace`属性.
///
void main() async {
  final currentPath = Directory.current.path;
  print('脚本工作路径->$currentPath');

  //读取yaml配置信息
  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");
  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml = loadYaml(yamlFile.readAsStringSync());

  //---

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
          final namespace = getPackageFromAndroidManifest(path);
          if (namespace != null) {
            colorLog(
                "正在添加[${index + 1}/${androidDependencies.length}]->$path -> namespace:$namespace");
            appendNamespace(path, namespace);
          } else {
            colorLog("未找到[package]信息, 请检查[${getAndroidManifestPath(path)}]文件.");
          }
        }
      }
      index++;
    }
  } else {
    colorLog("未找到子模块的依赖信息, 请检查[${dependenciesFile.path}]文件.");
  }
}

/// 核心修改方法
/// 添加flutter子库android工程中`build.gradle`文件加入`namespace`
/// [flutterPath] flutter工程子库根路径
void appendNamespace(String flutterPath, String namespace) {
  final androidPath = "$flutterPath/android";
  final androidPathFile = File("$androidPath/build.gradle");
  if (androidPathFile.existsSync()) {
    final androidPathFileContent = androidPathFile.readAsStringSync();
    if (!androidPathFileContent.contains("namespace")) {
      //修改 android {
      final newContent = androidPathFileContent
          .replaceAllMapped(RegExp(r"android *{ *"), (match) {
        return 'android { \n    if (project.android.hasProperty("namespace")) namespace "$namespace" //by angcyo ${DateTime.now()}\n';
      });
      //写入文件
      androidPathFile.writeAsStringSync(newContent);
      colorLog("修改成功->$androidPathFile", 250);
    } else {
      colorLog("跳过已存在[namespace]信息 -> ${androidPathFile.path}");
    }
  }
}

/// 获取AndroidManifest.xml文件路径
String getAndroidManifestPath(String flutterPath) {
  return "$flutterPath/android/src/main/AndroidManifest.xml";
}

/// 从`AndroidManifest.xml`文件中获取`package`
String? getPackageFromAndroidManifest(String flutterPath) {
  final androidManifestFile = File(getAndroidManifestPath(flutterPath));
  if (androidManifestFile.existsSync()) {
    final content = androidManifestFile.readAsStringSync();
    final package = RegExp(r'package=\"(.*?)\"').firstMatch(content)?.group(1);
    return package;
  }
  return null;
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

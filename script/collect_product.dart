import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
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
/// 收集macos app产物(--macos)
/// 默认输出路径在`build/macos/Build/Products/Release/xxx.app`
///默认文件名是`macos/Runner/Configs/AppInfo.xcconfig`中`PRODUCT_NAME`对应的值
///
/// 配置项(在根的`script.yaml`文件中配置):
/// 产物文件名格式: {app_name}-{version}_{build_config.buildType}.ipa
/// - app_name : 指定收集产物的文件名
/// - build_config.buildType : 构建类型
///
void main(List<String> arguments) async {
  final isCollectMacos = arguments.contains("macos");

  //--
  final fileName = Platform.script.path.split("/").last.split(".")[0];

  final currentPath = Directory.current.path;
  colorLog('[$fileName]工作路径->$currentPath');

  //输出路径
  final outputPath = isCollectMacos ? ".output/.app" : ".output/.ipa";

  //--
  final targetFileName = isCollectMacos ? readProductName() : readBundleName();
  if (targetFileName == null || targetFileName.isEmpty) {
    if (isCollectMacos) {
      colorErrorLog(
          "读取`macos/Runner/Configs/AppInfo.xcconfig`中`PRODUCT_NAME`对应的值失败");
    } else {
      colorErrorLog("读取`ios/Runner/Info.plist`中`CFBundleName`对应的值失败");
    }
    return;
  }

  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");

  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  //--读取配置的app_name
  final appName = yaml?["app_name"] ?? localYaml?["app_name"] ?? targetFileName;
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
  final scrPath = isCollectMacos
      ? "$currentPath/build//macos/Build/Products/Release/$targetFileName.app"
      : "$currentPath/build/ios/ipa/$targetFileName.ipa";

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
  if (isCollectMacos) {
    outputPathBuffer.write(".zip");
  } else {
    outputPathBuffer.write(".ipa");
  }

  final outputPathString = outputPathBuffer.toString();
  if (isCollectMacos) {
    await zipFolder(scrPath, outputPathString);
  } else {
    copyFile(scrPath, outputPathString);
  }

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

/// 读取`macos/Runner/Configs/AppInfo.xcconfig`中`PRODUCT_NAME`对应的值
String? readProductName() {
  final file = File("macos/Runner/Configs/AppInfo.xcconfig");
  if (!file.existsSync()) {
    return null;
  }
  final content = file.readAsStringSync();
  final lines = content.split("\n");

  String? productName;

  for (final line in lines) {
    if (line.contains("PRODUCT_NAME")) {
      final match = RegExp(r'PRODUCT_NAME = (.*)').firstMatch(line);
      if (match != null) {
        productName = match.group(1);
        break;
      }
    }
  }

  return productName;
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

/// 压缩源文件夹到指定路径
Future zipFolder(String srcPath, String dstPath) async {
  final srcFolder = Directory(srcPath);
  if (!srcFolder.existsSync()) {
    colorErrorLog("源文件夹不存在:$srcPath");
    return;
  }
  final encoder = ZipFileEncoder();
  try {
    encoder.create(dstPath);
    await [srcPath].zipEncoder(encoder);
  } catch (e) {
    colorErrorLog(e);
  } finally {
    encoder.close();
  }
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

void colorErrorLog(dynamic msg, [int col = 9]) {
  print('\x1B[38;5;${col}m$msg');
}

//--

extension ZipListEx on List<String> {
  /// 压缩所有文件/文件夹到指定文件
  /// [ZipFileEncoder.zipDirectoryAsync]
  /// [ZipFileEncoderEx.writeStringSync]
  Future<void> zip(
    String outputPath, {
    DateTime? modified,
    FutureOr Function(ZipFileEncoder zipEncoder)? action,
    String? Function(String)? onGetFileName,
  }) async {
    final encoder = ZipFileEncoder();
    try {
      encoder.create(outputPath, modified: modified ?? DateTime.now());
      await zipEncoder(encoder, onGetFileName: onGetFileName);
      if (action != null) {
        await action(encoder);
      }
    } catch (e) {
      colorErrorLog(e);
    } finally {
      encoder.close();
    }
  }

  /// 入参不一样的压缩扩展方法
  /// [zip]
  /// [onGetFileName] 获取文件名, 用于在压缩包中显示. 默认就是文件名
  Future<void> zipEncoder(
    ZipFileEncoder encoder, {
    String? Function(String)? onGetFileName,
  }) async {
    for (final path in this) {
      if (FileSystemEntity.isDirectorySync(path)) {
        await encoder.addDirectory(Directory(path));
      } else if (File(path).existsSync()) {
        await encoder.addFile(File(path), onGetFileName?.call(path));
      }
    }
  }
}

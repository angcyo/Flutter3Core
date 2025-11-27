import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';

import '_script_common.dart';
import 'build_config.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/02/12
///
/// 将目标产物, 复制重命名到指定路径
///
/// 配置项(在根的`script.yaml`文件中配置):
/// # 可用参数:
/// - #an: app名字, 默认是`pubspec.yaml`中的`name`对应的值
/// - #vn: 版本名, 默认是`pubspec.yaml`中的`version`对应的值
/// - #bn: 编译类型名, `build_config`中的`buildType`对应的值
/// - #fn: 风味名, `build_config`中的`buildFlavor`对应的值
///
/// # 收集Android apk/aab 产物
/// `flutter build apk --release`
/// 默认输出路径在: `build/app/outputs/flutter-apk/app-release.apk` (41.9MB)
/// `flutter build appbundle --release`
/// 默认输出路径在: `build/app/outputs/bundle/release/app-release.aab` (38.2MB)
///
/// # 收集ios ipa产物
/// 请使用`flutter build ipa --release --export-method ad-hoc`构建ipa
/// 默认输出路径在: `build/ios/ipa/xxx.ipa`
/// 默认文件名是: `ios/Runner/Info.plist`中`CFBundleName`对应的值
///
/// # 收集macos app产物(macos)
/// `flutter build macos --release`
/// 默认输出路径在: `build/macos/Build/Products/Release/xxx.app` (36.9MB)
/// 默认文件名是: `macos/Runner/Configs/AppInfo.xcconfig`中`PRODUCT_NAME`对应的值
///
/// # 收集windows exe产物(windows)
/// `flutter build windows --release`
/// 默认输出路径在: `build/windows/x64/runner/Release/xxx.exe`
/// 默认文件名是: `windows/CMakeLists.txt`中`BINARY_NAME`对应的值
///
void main(List<String> arguments) async {
  colorLog('[$currentFileName]工作路径->$currentPath');
  final config = $value(currentFileName);
  if (config is! Map) {
    throw "请在根目录的[script.yaml]或[script.local.yaml]文件中配置[$currentFileName]脚本";
  }

  final appName = _getAppName();
  final versionName = _getVersionName();
  final buildTypeName = _getBuildTypeName();
  final buildFlavorName = _getBuildFlavorName();
  print("appName: $appName"
      "\nversionName: $versionName"
      "\nbuildTypeName: $buildTypeName"
      "\nbuildFlavorName: $buildFlavorName");

  //输出路径
  final outputPath = config["output_path"] ?? ".output";
  /*? ".output/.exe"
      : isCollectMacos
          ? ".output/.app"
          : ".output/.ipa";*/

  final androidApkName = config["android_apk_name"];
  if (androidApkName is String) {
    //收集 apk
    final outputName = formatName(androidApkName);
    final from = "$currentPath/build/app/outputs/flutter-apk/app-release.apk";
    final to = "$currentPath/$outputPath/.apk/$outputName";
    copyFile(from, to);
  }

  final androidAppbundleName = config["android_appbundle_name"];
  if (androidAppbundleName is String) {
    //收集 aab
    final outputName = formatName(androidAppbundleName);
    final from =
        "$currentPath/build/app/outputs/bundle/release/app-release.aab";
    final to = "$currentPath/$outputPath/.apk/$outputName";
    copyFile(from, to);
  }

  final iosIpaName = config["ios_ipa_name"];
  if (iosIpaName is String) {
    //收集 ipa
    final targetFileName = readIosBundleName();
    final outputName = formatName(iosIpaName);
    final from = "$currentPath/build/ios/ipa/$targetFileName.ipa";
    final to = "$currentPath/$outputPath/.ipa/$outputName";
    copyFile(from, to);
  }

  final macosAppName = config["macos_app_name"];
  if (macosAppName is String) {
    //收集 app
    final targetFileName = readMacosProductName();
    final outputName = formatName(macosAppName);
    final from =
        "$currentPath/build/macos/Build/Products/Release/$targetFileName.app";
    final to = "$currentPath/$outputPath/.app/$outputName";
    if (outputName.endsWith(".app")) {
      copyFile(from, to);
    } else {
      await zipFolderByPlatform(from, to);
    }
  }

  final windowsExeName = config["windows_exe_name"];
  if (windowsExeName is String) {
    //收集 exe
    final targetFileName = readWindowsExeName();
    final outputName = formatName(windowsExeName);
    final from = "$currentPath/build/windows/x64/runner/Release";
    final to = "$currentPath/$outputPath/.exe/$outputName";
    if (outputName.endsWith(".exe")) {
      copyFile(from, to);
    } else {
      await zipFolder(from, to, excludeRoot: true);
    }
  }

  //--
  /*final targetFileName = isCollectWindows
      ? readWindowsExeName()
      : isCollectMacos
          ? readMacosProductName()
          : readIosBundleName();
  if (targetFileName == null || targetFileName.isEmpty) {
    if (isCollectMacos) {
      colorErrorLog(
          "读取`macos/Runner/Configs/AppInfo.xcconfig`中`PRODUCT_NAME`对应的值失败");
    } else {
      colorErrorLog("读取`ios/Runner/Info.plist`中`CFBundleName`对应的值失败");
    }
    return;
  }*/

  /*final localYamlFile = File("$currentPath/script.local.yaml");
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
  final scrPath = isCollectWindows
      ? "$currentPath/build/windows/x64/runner/Release"
      : isCollectMacos
          ? "$currentPath/build/macos/Build/Products/Release/$targetFileName.app"
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
  if (isCollectMacos || isCollectWindows) {
    outputPathBuffer.write(".zip");
  } else {
    outputPathBuffer.write(".ipa");
  }

  final outputPathString = outputPathBuffer.toString();
  if (isCollectWindows) {
    await zipFolder(scrPath, outputPathString, excludeRoot: true);
  } else if (isCollectMacos) {
    await zipFolderByPlatform(scrPath, outputPathString);
  } else {
    copyFile(scrPath, outputPathString);
  }
*/
  //输出结果
  colorLog('收集完成!');
}

String? _getAppName() {
  return $pubspec["name"];
}

String? _getVersionName() {
  return $pubspec?["version"]?.toString().split("+")[0];
}

String? _getBuildTypeName() {
  final buildConfig = readBuildConfigMap("build_config");
  return buildConfig?["buildType"];
}

String? _getBuildFlavorName() {
  final buildConfig = readBuildConfigMap("build_config");
  return buildConfig?["buildFlavor"];
}

/// 格式化名称
String formatName(String pattern) {
  String output = pattern;
  output = output.replaceAll("#an", _getAppName() ?? "");
  output = output.replaceAll("#vn", _getVersionName() ?? "");
  output = output.replaceAll("#bn", _getBuildTypeName() ?? "");
  output = output.replaceAll("#fn", _getBuildFlavorName() ?? "");
  output = output.replaceAll("--", "-");
  output = output.replaceAll("__", "_");
  return output;
}

//--

/// 读取`ios/Runner/Info.plist`中`CFBundleName`对应的值
String? readIosBundleName() {
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
String? readMacosProductName() {
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

/// 默认文件名是`windows/CMakeLists.txt`中`BINARY_NAME`对应的值
String? readWindowsExeName() {
  final file = File("windows/CMakeLists.txt");
  if (!file.existsSync()) {
    return null;
  }
  final content = file.readAsStringSync();
  final lines = content.split("\n");

  String? productName;

  for (final line in lines) {
    if (line.contains("BINARY_NAME")) {
      final match = RegExp(r'BINARY_NAME "(.*)"').firstMatch(line);
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

  //--
  dstFile.createSync(recursive: true);
  dstFile.writeAsBytesSync(srcFile.readAsBytesSync());

  //--
  colorLog('复制文件: $srcPath -> $dstPath');
}

/// 压缩源文件夹到指定路径
/// [excludeRoot] 是否排除根目录
Future zipFolder(
  String srcPath,
  String dstPath, {
  bool excludeRoot = false,
}) async {
  final srcFolder = Directory(srcPath);
  if (!srcFolder.existsSync()) {
    colorErrorLog("源文件夹不存在:$srcPath");
    return;
  }
  final encoder = ZipFileEncoder();
  try {
    encoder.create(dstPath);
    if (excludeRoot) {
      await srcFolder
          .listSync()
          .map((e) => e.path)
          .toList()
          .zipEncoder(encoder);
    } else {
      await [srcPath].zipEncoder(encoder);
    }
  } catch (e) {
    colorErrorLog(e);
  } finally {
    encoder.close();
  }
}

/// 使用平台压缩命令进行文件夹压缩
Future<void> zipFolderByPlatform(
  String srcPath,
  String dstPath, {
  bool excludeRoot = false,
}) async {
  final srcFolder = Directory(srcPath);
  if (!srcFolder.existsSync()) {
    colorErrorLog("源文件夹不存在:$srcPath");
    return;
  }
  final pathList = excludeRoot
      ? srcFolder.listSync().map((e) => e.path).toList()
      : [srcPath];

  final workPath = srcFolder.parent.path;
  await Process.run(
    Platform.isWindows ? "7z" : "zip",
    [
      Platform.isWindows ? "-a -c -f" : "-r",
      dstPath,
      ...pathList.map((e) => e.replaceFirst("$workPath/", "")),
    ],
    workingDirectory: workPath,
    /*runInShell: true,*/
  );
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
        await encoder.addDirectory(
          Directory(path),
          followLinks: false,
          /*filter: (entity, progress) {
            //debugger(when: entity.path.contains("Frameworks") && entity.path.contains("Resources"));
            if (FileSystemEntity.isLinkSync(entity.parent.path) ||
                (FileSystemEntity.isDirectorySync(entity.path) &&
                    FileSystemEntity.isLinkSync(entity.path))) {
              return ZipFileOperation.skip;
            }
            return ZipFileOperation.include;
          },*/
        );
      } else if (File(path).existsSync()) {
        await encoder.addFile(File(path), onGetFileName?.call(path));
      }
    }
  }
}

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
/// - #an: app名字, 默认是`pubspec.yaml`中的`app_name` ?? `name`对应的值
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

  final time = DateTime.now();

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
  //记录复制过的文件
  final copiedFile = ensureFile("$currentPath/$outputPath/.copy");
  final copiedLines = copiedFile?.readAsLinesSync() ?? [];
  int collectProductCount = 0;

  final androidApkName = config["android_apk_name"];
  if (androidApkName is String) {
    //收集 apk
    final outputName = formatName(androidApkName);
    final from = "$currentPath/build/app/outputs/flutter-apk/app-release.apk";
    if (File(from).existsSync()) {
      final key = "app-release.apk/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("已复制过: $from");
      } else {
        final to = "$currentPath/$outputPath/.apk/$outputName";
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  final androidAppbundleName = config["android_appbundle_name"];
  if (androidAppbundleName is String) {
    //收集 aab
    final outputName = formatName(androidAppbundleName);
    final from =
        "$currentPath/build/app/outputs/bundle/release/app-release.aab";
    if (File(from).existsSync()) {
      final key = "app-release.aab/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("已复制过: $from");
      } else {
        final to = "$currentPath/$outputPath/.apk/$outputName";
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  final iosIpaName = config["ios_ipa_name"];
  if (iosIpaName is String) {
    //收集 ipa
    final targetFileName = readIosBundleName();
    final outputName = formatName(iosIpaName);
    final from = "$currentPath/build/ios/ipa/$targetFileName.ipa";
    if (File(from).existsSync()) {
      final key = "$targetFileName.ipa/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("已复制过: $from");
      } else {
        final to = "$currentPath/$outputPath/.ipa/$outputName";
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  final macosAppName = config["macos_app_name"];
  if (macosAppName is String) {
    //收集 app
    final targetFileName = readMacosProductName();
    final outputName = formatName(macosAppName);
    final from =
        "$currentPath/build/macos/Build/Products/Release/$targetFileName.app";
    if (Directory(from).existsSync()) {
      final key =
          "$targetFileName.app/${File("$from/Contents/Info.plist").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("已复制过: $from");
      } else {
        final to = "$currentPath/$outputPath/.app/$outputName";
        if (outputName.endsWith(".app")) {
          if (await copyFolderByPlatform(from, to)) {
            collectProductCount++;
            copiedLines.add(key);
            copiedFile?.writeAsStringSync(copiedLines.join("\n"));
          }
        } else {
          if (await zipFolderByPlatform(from, to)) {
            collectProductCount++;
            copiedLines.add(key);
            copiedFile?.writeAsStringSync(copiedLines.join("\n"));
          }
        }
      }
    }
  }

  final windowsExeName = config["windows_exe_name"];
  if (windowsExeName is String) {
    //收集 exe
    final targetFileName = readWindowsExeName();
    final outputName = formatName(windowsExeName);
    final from = "$currentPath/build/windows/x64/runner/Release";
    if (Directory(from).existsSync()) {
      final key =
          "$targetFileName.exe/${File("$from/$targetFileName.exe").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("已复制过: $from");
      } else {
        final to = "$currentPath/$outputPath/.exe/$outputName";
        if (outputName.endsWith(".exe")) {
          if (copyFile(from, to)) {
            collectProductCount++;
            copiedLines.add(key);
            copiedFile?.writeAsStringSync(copiedLines.join("\n"));
          }
        } else {
          if (await zipFolder(from, to, excludeRoot: true)) {
            collectProductCount++;
            copiedLines.add(key);
            copiedFile?.writeAsStringSync(copiedLines.join("\n"));
          }
        }
      }
    }
  }

  //输出结果
  if(collectProductCount==0){
    colorErrorLog('请检查是否执行过`flutter build xxx --release`');
  }
  colorLog('收集完成[$collectProductCount], 耗时: ${DateTime.now().difference(time)}');
}

String? _getAppName() {
  return $pubspec["app_name"] ?? $pubspec["name"];
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
bool copyFile(
  String srcPath,
  String dstPath, {
  bool inner = false,
}) {
  //如果是文件夹, 则复制文件夹
  if (FileSystemEntity.isDirectorySync(srcPath)) {
    //--
    Directory(dstPath).createSync(recursive: true);
    Directory(srcPath).listSync().forEach((element) {
      copyFile(element.path, "$dstPath/${element.path.split("/").last}",
          inner: true);
    });
    if (!inner) {
      colorLog('复制文件夹: $srcPath -> $dstPath');
    }
    return true;
  }

  final srcFile = File(srcPath);
  final dstFile = File(dstPath);

  if (!srcFile.existsSync()) {
    colorErrorLog("源文件不存在:$srcPath");
    return false;
  }

  //--
  dstFile.createSync(recursive: true);
  dstFile.writeAsBytesSync(srcFile.readAsBytesSync());

  //--
  if (!inner) {
    colorLog('复制文件: $srcPath -> $dstPath');
  }

  return true;
}

/// 压缩源文件夹到指定路径
/// [excludeRoot] 是否排除根目录
Future<bool> zipFolder(
  String srcPath,
  String dstPath, {
  bool excludeRoot = false,
}) async {
  final srcFolder = Directory(srcPath);
  if (!srcFolder.existsSync()) {
    colorErrorLog("源文件夹不存在:$srcPath");
    return false;
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
    return true;
  } catch (e) {
    colorErrorLog(e);
  } finally {
    encoder.close();
  }
  return false;
}

/// 使用平台压缩命令进行文件夹压缩
Future<bool> zipFolderByPlatform(
  String srcPath,
  String dstPath, {
  bool excludeRoot = false,
}) async {
  final srcFolder = Directory(srcPath);
  if (!srcFolder.existsSync()) {
    colorErrorLog("源文件夹不存在:$srcPath");
    return false;
  }
  final pathList = excludeRoot
      ? srcFolder.listSync().map((e) => e.path).toList()
      : [srcPath];

  final workPath = srcFolder.parent.path;
  final result = await Process.run(
    Platform.isWindows ? "7z" : "zip",
    [
      Platform.isWindows ? "-a -c -f" : "-r",
      dstPath,
      ...pathList.map((e) => e.replaceFirst("$workPath/", "")),
    ],
    workingDirectory: workPath,
    /*runInShell: true,*/
  );
  colorLog('压缩文件夹: $srcPath -> $dstPath');
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode == 0;
}

/// 使用平台cp命令, 复制文件夹
Future<bool> copyFolderByPlatform(String srcPath, String dstPath) async {
  final result = await Process.run(
    Platform.isWindows ? "cp" : "cp",
    [
      Platform.isWindows ? "" : "-R",
      srcPath,
      dstPath,
    ],
    runInShell: true,
  );
  colorLog('复制文件夹: $srcPath -> $dstPath');
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode == 0;
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

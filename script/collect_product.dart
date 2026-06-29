import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

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
/// - #vc: 版本号, 默认是`pubspec.yaml`中的`version`对应的值
/// - #bn: 编译类型名, `build_config`中的`buildType`对应的值
/// - #fn: 风味名, `build_config`中的`buildFlavor`对应的值
/// - [formatName]
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
  colorLog('🚀 [$currentFileName]工作路径->$currentPath');
  final config = $value(currentFileName);
  if (config is! Map) {
    throw "❌ 请在[$currentPath]目录的[script.yaml]或[script.local.yaml]文件中配置[$currentFileName]脚本的收集产品名称";
  }

  final time = DateTime.now();

  final appName = _getAppName();
  final versionName = _getVersionName();
  final versionCode = _getVersionCode();
  print(
    "💡 appName:$appName"
    " versionName:$versionName"
    " versionCode:$versionCode",
  );

  //输出路径
  final outputPath = config["output_path"] ?? ".output";
  //记录复制过的文件
  final copiedFile = ensureFile("$currentPath/$outputPath/.copy");
  final copiedLines = copiedFile?.readAsLinesSync() ?? [];

  //已经复制过的产物数量
  int exitProductCount = 0;
  //收集的产物数量
  int collectProductCount = 0;

  //MARK: - Android apk

  final androidApkName = config["android_apk_name"];
  if (androidApkName is String) {
    //收集 apk
    final outputName = formatName(androidApkName, "android");
    final from = "$currentPath/build/app/outputs/flutter-apk/app-release.apk";
    if (File(from).existsSync()) {
      final key = "app-release.apk/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("⚠️ 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath/$outputPath/.apk/$outputName";
        ensureFolder(to, parent: true);
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  //MARK: - Android aab

  final androidAppbundleName = config["android_appbundle_name"];
  if (androidAppbundleName is String) {
    //收集 aab
    final outputName = formatName(androidAppbundleName, "android");
    final from =
        "$currentPath/build/app/outputs/bundle/release/app-release.aab";
    if (File(from).existsSync()) {
      final key = "app-release.aab/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("⚠️ 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath/$outputPath/.apk/$outputName";
        ensureFolder(to, parent: true);
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  //MARK: - iOS

  final iosIpaName = config["ios_ipa_name"];
  if (iosIpaName is String) {
    //收集 ipa
    final targetFileName = readIosBundleName();
    final outputName = formatName(iosIpaName, "ios");
    final from = "$currentPath/build/ios/ipa/$targetFileName.ipa";
    if (File(from).existsSync()) {
      final key = "$targetFileName.ipa/${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("⚠️ 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath/$outputPath/.ipa/$outputName";
        ensureFolder(to, parent: true);
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  //MARK: - macOS

  final macosAppName = config["macos_app_name"];
  if (macosAppName is String) {
    //收集 app
    final productFileName = readMacosProductName();
    final outputName = formatName(macosAppName, "macos");
    final from =
        "$currentPath/build/macos/Build/Products/Release/$productFileName.app";
    if (Directory(from).existsSync()) {
      final key =
          "$productFileName.app/${File("$from/Contents/MacOS/$productFileName").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("⚠️ 已复制过: $from");
        exitProductCount++;
      } else {
        final toDir = "$currentPath/$outputPath/.app";
        final to = "$toDir/$outputName";
        ensureFolder(to, parent: true);
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
        //使用appdmg打包安装程序
        final macosAppdmgConfig = config["macos_appdmg_config"];
        if (macosAppdmgConfig is String) {
          final appdmgConfigFile = File("$currentPath/$macosAppdmgConfig");
          if (appdmgConfigFile.existsSync()) {
            final result = await runCommand(
              "appdmg",
              printLog: false,
              printErrorLog: false,
            );
            if (result != null) {
              final dmgName = outputName.substring(
                0,
                outputName.lastIndexOf("."),
              );
              final outputDmgPath = "$toDir/$dmgName.dmg";
              outputDmgPath.safeDelete();

              //修改appdmg配置文件
              final appVersion = _getVersionName() ?? "0.0.1";
              final dmgTitle = "$appName v$appVersion";
              final json = jsonDecode(appdmgConfigFile.readAsStringSync());
              json["title"] = dmgTitle;
              final tempConfigFile = File(
                "$currentPath/.appdmg.config.temp.json",
              );
              tempConfigFile.writeAsStringSync(jsonEncode(json));

              colorLog('💡准备打包安装程序: $from -> $dmgTitle');
              final result = await runCommand(
                "appdmg",
                args: [tempConfigFile.path, outputDmgPath],
                printLog: false,
              );
              tempConfigFile.path.safeDelete();
              if (result?.exitCode == 0) {
                collectProductCount++;
                colorLog('🎉-> $outputDmgPath ${outputDmgPath.fileSizeStr}');
              }
            } else {
              colorErrorLog("请先安装`appdmg` -> npm install -g appdmg");
            }
          } else {
            colorErrorLog("未找到`appdmg`配置文件->${appdmgConfigFile.path}");
          }
        }
      }
    }
  }

  //MARK: - windows

  final windowsExeName = config["windows_exe_name"];
  if (windowsExeName is String) {
    //收集 exe
    final exeFileName = "${readWindowsExeName()}.exe";
    final outputName = formatName(windowsExeName, "windows");
    final from = "$currentPath/build/windows/x64/runner/Release";
    if (Directory(from).existsSync()) {
      final key =
          "$exeFileName/${File("$from/data/app.so").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("⚠️ 已复制过: $from/$exeFileName");
        exitProductCount++;
      } else {
        final toDir = "$currentPath/$outputPath/.exe";
        final to = "$toDir/$outputName";
        ensureFolder(to, parent: true);
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
        //使用Inno Setup打包安装程序
        final windowsInnoSetup = config["windows_inno_setup"];
        if (windowsInnoSetup is String) {
          final issFile = File("$currentPath/$windowsInnoSetup");
          if (issFile.existsSync()) {
            final isccPath = await _findISCCPath();
            if (isccPath != null) {
              final setupExeName = outputName.substring(
                0,
                outputName.lastIndexOf("."),
              );
              final appVersion = _getVersionName() ?? "0.0.1";
              //print("$toDir/$setupExeName:$appVersion");
              colorLog('💡准备打包安装程序: $from/$exeFileName');
              final result = await runCommand(
                isccPath,
                args: [
                  "/Qp",
                  "/F$setupExeName",
                  "/O$toDir",
                  '/DMyAppVersion=v$appVersion',
                  '/DMySource=$from',
                  '/DMyAppExeName=$exeFileName',
                  issFile.path,
                ],
                printLog: false,
              );
              if (result?.exitCode == 0) {
                collectProductCount++;
                final outputExePath = "$toDir/$setupExeName.exe";
                colorLog('🎉-> $outputExePath ${outputExePath.fileSizeStr}');
              }
            } else {
              colorErrorLog(
                "请先安装`Inno Setup` -> https://jrsoftware.org/isdl.php",
              );
            }
          } else {
            colorErrorLog("未找到`iss`文件->${issFile.path}");
          }
        }
      }
    }
  }

  //MARK: - result

  //输出结果
  if (exitProductCount == 0 && collectProductCount == 0) {
    colorErrorLog('请检查是否执行过`flutter build xxx --release`');
  }
  colorLog(
    '✅ 收集完成[$collectProductCount], 耗时: ${DateTime.now().difference(time)}',
  );
}

String? _getAppName() {
  return $value(currentFileName)["app_name"] ??
      $pubspec["app_name"] ??
      $pubspec["name"];
}

String? _getVersionName() {
  return $pubspec?["version"]?.toString().split("+")[0];
}

String? _getVersionCode() {
  return $pubspec?["version"]?.toString().split("+")[1];
}

String? _getBuildTypeName(String? platformName) {
  final buildConfig = readBuildConfigMap("build_config");
  final def = buildConfig?["json"]?["buildType"];
  if (platformName == null || platformName.isEmpty) {
    return def;
  }
  return buildConfig?["platformMap"]?[platformName]?["json"]?["buildType"] ??
      def;
}

String? _getBuildFlavorName(String? platformName) {
  final buildConfig = readBuildConfigMap("build_config");
  final def = buildConfig?["json"]?["buildFlavor"];
  if (platformName == null || platformName.isEmpty) {
    return def;
  }
  return buildConfig?["platformMap"]?[platformName]?["json"]?["buildFlavor"] ??
      def;
}

/// 格式化名称
String formatName(String pattern, String? platformName) {
  String output = pattern;
  output = output.replaceAll("#an", _getAppName() ?? "APP");
  output = output.replaceAll("#vn", _getVersionName() ?? "0.0.1");
  output = output.replaceAll("#vc", _getVersionCode() ?? "1");
  output = output.replaceAll("#bn", _getBuildTypeName(platformName) ?? "");
  output = output.replaceAll("#fn", _getBuildFlavorName(platformName) ?? "");
  output = output.replaceAll("--", "-");
  output = output.replaceAll("__", "_");
  output = output.replaceAll("-.", ".");
  output = output.replaceAll("_.", ".");
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
bool copyFile(String srcPath, String dstPath, {bool inner = false}) {
  //如果是文件夹, 则复制文件夹
  if (FileSystemEntity.isDirectorySync(srcPath)) {
    //--
    if (!inner) {
      colorLog('💡准备复制文件夹: $srcPath');
    }
    Directory(dstPath).createSync(recursive: true);
    Directory(srcPath).listSync().forEach((element) {
      copyFile(
        element.path,
        "$dstPath/${element.path.split("/").last}",
        inner: true,
      );
    });
    if (!inner) {
      colorLog('🎉-> $dstPath');
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
  if (!inner) {
    colorLog('💡准备复制文件: $srcPath');
  }
  dstFile.createSync(recursive: true);
  dstFile.writeAsBytesSync(srcFile.readAsBytesSync());
  if (!inner) {
    colorLog('🎉-> $dstPath');
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
    colorLog('💡准备压缩文件夹: $srcPath');
    if (excludeRoot) {
      await srcFolder
          .listSync()
          .map((e) => e.path)
          .toList()
          .zipEncoder(encoder);
    } else {
      await [srcPath].zipEncoder(encoder);
    }
    colorLog('🎉-> $dstPath ${dstPath.fileSizeStr}');
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
  colorLog('💡准备压缩文件夹: $srcPath');
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
  colorLog('🎉-> $dstPath ${dstPath.fileSizeStr}');
  if (result.exitCode < 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode >= 0;
}

/// 使用平台cp命令, 复制文件夹
Future<bool> copyFolderByPlatform(String srcPath, String dstPath) async {
  colorLog('💡准备复制文件夹: $srcPath');
  final result = await Process.run(Platform.isWindows ? "cp" : "cp", [
    Platform.isWindows ? "" : "-R",
    srcPath,
    dstPath,
  ], runInShell: true);
  colorLog('🎉-> $dstPath');
  if (result.exitCode < 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode >= 0;
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

//MARK: - iscc

/// 通过注册表查找本地安装的`ISCC.exe`的路径
Future<String?> _findISCCPath() async {
  for (final key in [
    r"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
    r"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
  ]) {
    final result = await runCommand(
      "reg",
      args: ["query", key],
      printLog: false,
    );
    if (result?.exitCode != 0) {
      continue;
    }
    final output = result!.stdout;
    if (output is String) {
      for (final line
          in output
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)) {
        //print("行->" + line);
        final subKey = line;
        final subOutput = await runCommand(
          "reg",
          args: ["query", subKey],
          printLog: false,
        );
        if (subOutput?.exitCode != 0) {
          continue;
        }
        //print("subKey:" + subKey + " -> " + subOutput.stdout);
        final path = _findInnoSetupPath(subOutput!.stdout);
        if (path != null) {
          final isccPath = p.join(path, 'ISCC.exe');
          if (File(isccPath).existsSync()) {
            return isccPath;
          }
        }
      }
    }
  }
  return null;
}

/// 查找`Inno Setup`的安装路径内
String? _findInnoSetupPath(String output) {
  // reg query 的输出格式通常为：
  //     (Default)    REG_SZ    C:\Program Files (x86)\Inno Setup 6\ISCC.exe
  // Inno Setup: App Path    REG_SZ    D:\Inno Setup 7
  final lines = output.split('\n');
  for (final line in lines) {
    if (line.contains("Inno Setup: App Path") && line.contains('REG_SZ')) {
      // 以 REG_SZ 作为切分点，取后面的部分并修剪空格
      final parts = line.split('REG_SZ');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
  }
  return null;
}

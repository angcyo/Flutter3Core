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
/// ```
/// # [collect_product.dart] 收集时的名称
/// collect_product:
///   output_path: ".output"
///   android_apk_name: "#an-#vn_#fn_#bn.apk"
///   android_appbundle_name: "#an-#vn_#fn_#bn.aab"
///   ios_archive_name: "#an-#vn_#fn_#bn.xcarchive"
///   ios_ipa_name: "#an-#vn_#fn_#bn.ipa"
///   #macos_app_name: "#an-#vn_#fn_#bn.app"
///   macos_app_name: "#an-macos-arm64-v#vn-#bn.zip"
///   # `macos_sign_identity` 签名身份信息, 指定了就会进行签名
///   macos_sign_identity: null
///   # 指定`macOS_appdmg_config`使用appdmg打包安装程序
///   macos_appdmg_config: "script_appdmg_config.json"
///   # `macos_keychain_profile` 公证安全凭证信息, 指定了就会进行产物dmg的公证
///   macos_keychain_profile: null
///   windows_exe_name: "#an-windows-x64-v#vn-#bn.zip"
///   # 指定`windows_inno_setup`使用Inno Setup打包安装程序
///   windows_inno_setup: "script_inno_setup.iss"
/// ```
///
/// # 收集Android apk/aab 产物
///
/// ## `flutter build apk --release`
/// 默认输出路径在: `build/app/outputs/flutter-apk/app-release.apk` (41.9MB)
/// ## `call flutter build apk --release --flavor overseas`
/// 默认输出路径在: `build/app/outputs/flutter-apk/app-overseas-release.apk` (91.4MB)
///
/// ## `flutter build appbundle --release`
/// 默认输出路径在: `build/app/outputs/bundle/release/app-release.aab` (38.2MB)
/// ## `call flutter build appbundle --release --flavor overseas`
/// 默认输出路径在: `build/app/outputs/bundle/overseasRelease/app-overseas-release.aab` (83.6MB)
///
/// # 收集ios ipa产物
/// 请使用`flutter build ipa --release --export-method ad-hoc`构建ipa
/// 默认输出路径在: `build/ios/ipa/xxx.ipa`
/// 默认文件名是: `ios/Runner/Info.plist`中`CFBundleName`对应的值
///
/// # 收集ios archive产物
/// 请使用`flutter build ipa --release`构建archive
/// 默认输出路径在: `build/ios/archive/Runner.xcarchive`
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

  //MARK: input args
  String? argBuildType;
  String? argBuildFlavor;
  for (final arg in arguments) {
    if (arg.startsWith("--buildType=")) {
      argBuildType = arg.split("=")[1];
    } else if (arg.startsWith("--buildFlavor=")) {
      argBuildFlavor = arg.split("=")[1];
    }
  }
  String buildTypeTag = argBuildType == null || argBuildType.isEmpty == true
      ? "-release"
      : "-$argBuildType";
  String buildFlavorTag =
      argBuildFlavor == null || argBuildFlavor.isEmpty == true
      ? ""
      : "-$argBuildFlavor";

  //MARK: yaml config

  final time = DateTime.now();
  final kPS = Platform.pathSeparator;

  final appName = _getAppName();
  final versionName = _getVersionName();
  final versionCode = _getVersionCode();
  print(
    "💡 appName:$appName"
    " versionName:$versionName"
    " versionCode:$versionCode"
    " buildType:${argBuildType ?? "N/A"}"
    " buildFlavor:${argBuildFlavor ?? "N/A"}",
  );

  //输出路径
  final outputPath = config["output_path"] ?? ".output";
  //记录复制过的文件
  final copiedFile = ensureFile("$currentPath$kPS$outputPath$kPS.copy");
  final copiedLines = copiedFile?.readAsLinesSync() ?? [];

  //已经复制过的产物数量
  int exitProductCount = 0;
  //收集的产物数量
  int collectProductCount = 0;

  //MARK: - Android apk

  final apkNameConfig = config["android_apk_name"];
  if (apkNameConfig is String) {
    //收集 apk
    final outputName = formatName(
      apkNameConfig,
      "android",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final apkName = "app$buildFlavorTag$buildTypeTag.apk";
    final from =
        "$currentPath${kPS}build${kPS}app${kPS}outputs${kPS}flutter-apk$kPS$apkName";
    if (File(from).existsSync()) {
      final key = "$apkName$kPS${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath$kPS$outputPath$kPS.apk$kPS$outputName";
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

  final appBundleNameConfig = config["android_appbundle_name"];
  if (appBundleNameConfig is String) {
    //收集 aab
    final outputName = formatName(
      appBundleNameConfig,
      "android",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final aabName = "app$buildFlavorTag$buildTypeTag.aab";
    final from = argBuildFlavor == null
        ? "$currentPath${kPS}build${kPS}app${kPS}outputs${kPS}bundle${kPS}release$kPS$aabName"
        : "$currentPath${kPS}build${kPS}app${kPS}outputs${kPS}bundle$kPS${argBuildFlavor}Release$kPS$aabName";
    if (File(from).existsSync()) {
      final key = "$aabName$kPS${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath$kPS$outputPath$kPS.apk$kPS$outputName";
        ensureFolder(to, parent: true);
        if (copyFile(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  //MARK: - iOS archive

  final iosArchiveNameConfig = config["ios_archive_name"];
  if (iosArchiveNameConfig is String) {
    //收集 Runner.xcarchive
    final targetFileName = "Runner";
    final outputName = formatName(
      iosArchiveNameConfig,
      "ios",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final from =
        "$currentPath${kPS}build${kPS}ios${kPS}archive$kPS$targetFileName.xcarchive";
    if (Directory(from).existsSync()) {
      final key =
          "$targetFileName.xcarchive$kPS${File("$from${kPS}Info.plist").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath$kPS$outputPath$kPS.ipa$kPS$outputName";
        ensureFolder(to, parent: true);
        if (await macOSCopyFolderByDitto(from, to)) {
          collectProductCount++;
          copiedLines.add(key);
          copiedFile?.writeAsStringSync(copiedLines.join("\n"));
        }
      }
    }
  }

  //MARK: - iOS ipa

  final ipaNameConfig = config["ios_ipa_name"];
  if (ipaNameConfig is String) {
    //收集 ipa
    final targetFileName = readIosBundleName();
    final outputName = formatName(
      ipaNameConfig,
      "ios",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final from =
        "$currentPath${kPS}build${kPS}ios${kPS}ipa$kPS$targetFileName.ipa";
    if (File(from).existsSync()) {
      final key = "$targetFileName.ipa$kPS${File(from).lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from");
        exitProductCount++;
      } else {
        final to = "$currentPath$kPS$outputPath$kPS.ipa$kPS$outputName";
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

  final macosAppNameConfig = config["macos_app_name"];
  if (macosAppNameConfig is String) {
    //收集 app
    final productFileName = readMacosProductName();
    final outputName = formatName(
      macosAppNameConfig,
      "macos",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final from =
        "$currentPath${kPS}build${kPS}macos${kPS}Build${kPS}Products${kPS}Release$kPS$productFileName.app";
    if (Directory(from).existsSync()) {
      final key =
          "$productFileName.app$kPS${File("$from${kPS}Contents${kPS}MacOS$kPS$productFileName").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from");
        exitProductCount++;
      } else {
        final toDir = "$currentPath$kPS$outputPath$kPS.app";
        final to = "$toDir$kPS$outputName";
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
          final appdmgConfigFile = File("$currentPath$kPS$macosAppdmgConfig");
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
              final outputDmgPath = "$toDir$kPS$dmgName.dmg";
              outputDmgPath.safeDelete();

              //修改appdmg配置文件中的值
              final appVersion = _getVersionName() ?? "0.0.1";
              final dmgTitle = "$appName v$appVersion";
              final json = jsonDecode(appdmgConfigFile.readAsStringSync());
              json["title"] = dmgTitle;
              (json["contents"] as List?)
                      ?.where((e) => e["type"] == "file")
                      .firstOrNull?["path"] =
                  from;
              final tempConfigFile = File(
                "$currentPath$kPS.appdmg.config.temp.json",
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
                colorLog(
                  '🎉$_rSpace-> $outputDmgPath ${outputDmgPath.fileSizeStr}',
                );
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

  final windowsExeNameConfig = config["windows_exe_name"];
  if (windowsExeNameConfig is String) {
    //收集 exe
    final exeFileName = "${readWindowsExeName()}.exe";
    final outputName = formatName(
      windowsExeNameConfig,
      "windows",
      defBuildType: argBuildType,
      defBuildFlavor: argBuildFlavor,
    );
    final from =
        "$currentPath${kPS}build${kPS}windows${kPS}x64${kPS}runner${kPS}Release";
    if (Directory(from).existsSync()) {
      final key =
          "$exeFileName$kPS${File("$from${kPS}data${kPS}app.so").lastModifiedSync()}";
      if (copiedLines.contains(key)) {
        colorLog("🚨 已复制过: $from$kPS$exeFileName");
        exitProductCount++;
      } else {
        final toDir = "$currentPath$kPS$outputPath$kPS.exe";
        final to = "$toDir$kPS$outputName";
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
        final windowsInnoSetupConfig = config["windows_inno_setup"];
        if (windowsInnoSetupConfig is String) {
          final issFile = File("$currentPath$kPS$windowsInnoSetupConfig");
          if (issFile.existsSync()) {
            final isccPath = await _findISCCPath();
            if (isccPath != null) {
              final setupExeName = outputName.substring(
                0,
                outputName.lastIndexOf("."),
              );
              final appVersion = _getVersionName() ?? "0.0.1";
              //print("$toDir${kPS}$setupExeName:$appVersion");
              colorLog('💡准备打包安装程序: $from$kPS$exeFileName');
              final result = await runCommand(
                isccPath,
                args: [
                  "/Qp",
                  "/F$setupExeName",
                  "/O$toDir",
                  '/DMyAppVersion=$appVersion',
                  '/DMySource=$from',
                  '/DMyAppExeName=$exeFileName',
                  issFile.path,
                ],
                dir: currentPath,
                printLog: false,
              );
              if (result?.exitCode == 0) {
                collectProductCount++;
                final outputExePath = "$toDir$kPS$setupExeName.exe";
                colorLog(
                  '🎉$_rSpace-> $outputExePath ${outputExePath.fileSizeStr}',
                );
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
    '✅ 收集完成[$collectProductCount], 耗时: ${DateTime.now().difference(time)}s',
  );
}

const _rSpace = "         ";

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

String? _getBuildTypeName(String? platformName, {String? def}) {
  final buildConfig = readBuildConfigMap("build_config");
  def ??= buildConfig?["json"]?["buildType"];
  if (platformName == null || platformName.isEmpty) {
    return def;
  }
  return buildConfig?["platformMap"]?[platformName]?["json"]?["buildType"] ??
      def;
}

String? _getBuildFlavorName(String? platformName, {String? def}) {
  final buildConfig = readBuildConfigMap("build_config");
  def ??= buildConfig?["json"]?["buildFlavor"];
  if (platformName == null || platformName.isEmpty) {
    return def;
  }
  return buildConfig?["platformMap"]?[platformName]?["json"]?["buildFlavor"] ??
      def;
}

/// 格式化名称
String formatName(
  String pattern,
  String? platformName, {
  String? defBuildType,
  String? defBuildFlavor,
}) {
  String output = pattern;
  output = output.replaceAll("#an", _getAppName() ?? "APP");
  output = output.replaceAll("#vn", _getVersionName() ?? "0.0.1");
  output = output.replaceAll("#vc", _getVersionCode() ?? "1");
  output = output.replaceAll(
    "#bn",
    _getBuildTypeName(platformName, def: defBuildType) ?? "",
  );
  output = output.replaceAll(
    "#fn",
    _getBuildFlavorName(platformName, def: defBuildFlavor) ?? "",
  );
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
      colorLog('🎉$_rSpace-> $dstPath');
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
    colorLog('💡 准备复制文件: $srcPath');
  }
  dstFile.createSync(recursive: true);
  dstFile.writeAsBytesSync(srcFile.readAsBytesSync());
  if (!inner) {
    colorLog('🎉$_rSpace-> $dstPath');
  }

  return true;
}

/// 压缩源文件夹到指定路径
/// [excludeRoot] 是否排除根目录
///
/// - [zipFolder]
/// - [zipFolderByPlatform]
/// - [macOSCopyFolderByDitto]
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
    colorLog('🎉$_rSpace-> $dstPath ${dstPath.fileSizeStr}');
    return true;
  } catch (e) {
    colorErrorLog(e);
  } finally {
    encoder.close();
  }
  return false;
}

/// 使用平台压缩命令进行文件夹压缩
///
/// - [zipFolder]
/// - [zipFolderByPlatform]
/// - [macOSCopyFolderByDitto]
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
  colorLog('🎉$_rSpace-> $dstPath ${dstPath.fileSizeStr}');
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode == 0;
}

/// 使用平台cp命令, 复制文件夹
/// - windows 使用 `cp`
/// - macos 使用 `cp -R`
/// - [srcPath] 源文件夹路径
/// - [dstPath] 目标文件夹路径
Future<bool> copyFolderByPlatform(String srcPath, String dstPath) async {
  colorLog('💡准备复制文件夹: $srcPath');
  final result = await Process.run(Platform.isWindows ? "cp" : "cp", [
    Platform.isWindows ? "" : "-R",
    srcPath,
    dstPath,
  ], runInShell: true);
  colorLog('🎉$_rSpace-> $dstPath');
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode == 0;
}

/// 使用 `ditto` 命令, 复制文件夹/压缩文件夹
/// 只适用于 macOS 平台
/// - [srcPath] 源文件夹路径
/// - [dstPath] 目标文件夹路径
/// - [isCompress] 是否压缩
///
/// - [zipFolder]
/// - [zipFolderByPlatform]
/// - [macOSCopyFolderByDitto]
Future<bool> macOSCopyFolderByDitto(
  String srcPath,
  String dstPath, {
  bool isCompress = false,
}) async {
  if (isCompress) {
    colorLog('💡准备压缩文件夹: $srcPath');
    final result = await Process.run("ditto", [
      "-c",
      "-k",
      "--sequesterRsrc",
      '--keepParent',
      srcPath,
      dstPath,
    ], runInShell: true);
    colorLog('🎉$_rSpace-> $dstPath ${dstPath.fileSizeStr}');
    if (result.exitCode != 0) {
      colorErrorLog(result.stderr);
    }
    return result.exitCode == 0;
  }
  colorLog('💡准备复制文件夹: $srcPath');
  final result = await Process.run("ditto", [
    srcPath,
    dstPath,
  ], runInShell: true);
  colorLog('🎉$_rSpace-> $dstPath');
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  }
  return result.exitCode == 0;
}

/// macOS 使用 `codesign` 命令进行签名 `xxx.app` 文件夹
/// - [identity] 签名证书
///
/// - [macOSCodeSign] 签名
/// - [macOSNotarytoolSubmit] 公证
Future<bool> macOSCodeSign(String appPath, String? identity) async {
  if (identity == null || identity.isEmpty) {
    colorErrorLog("🔴无法进行签名,签名证书为空!");
    return false;
  }
  colorLog('💡准备进行签名: $appPath');
  final result = await Process.run("codesign", [
    '--force', // 强制覆盖旧签名
    "--options runtime", // 公证需要
    '--deep', // 深度递归签名内部所有框架与二进制
    /*'-v', // 输出详细日志*/
    "--sign",
    identity,
    appPath,
  ], runInShell: true);
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  } else {
    colorLog('🎉 签名成功 -> $appPath');
  }
  return result.exitCode == 0;
}

/// macOS 使用 `codesign` 命令进行签名验证
Future<bool> macOSCodeSignVerify(String appPath) async {
  colorLog('💡准备进行签名验证: $appPath');
  final result = await Process.run("codesign", [
    '--verify',
    '--deep',
    '--strict',
    '-vvvv',
    appPath,
  ], runInShell: true);
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  } else {
    colorLog('🎉 签名验证成功 -> $appPath');
  }
  return result.exitCode == 0;
}

/// macOS 使用 `notarytool` 提交公证
/// - [keychainProfile] 公证安全凭证名称
///
/// - [macOSCodeSign] 签名
/// - [macOSNotarytoolSubmit] 公证
Future<bool> macOSNotarytoolSubmit(
  String dmgPath,
  String? keychainProfile,
) async {
  if (keychainProfile == null || keychainProfile.isEmpty) {
    colorErrorLog("🔴无法进行签名,公证凭证为空!");
    return false;
  }
  colorLog('💡准备进行公证提交: $dmgPath');
  final result = await Process.run("xcrun", [
    'notarytool',
    'submit',
    dmgPath,
    '--keychain-profile',
    keychainProfile,
    '--wait',
  ], runInShell: true);
  if (result.exitCode != 0) {
    colorErrorLog(result.stderr);
  } else {
    // 检查 stdout / stderr 输出
    final output = '${result.stdout}\n${result.stderr}';
    colorLog('💡Notarytool 输出: $output');
    if (!output.contains('status: Accepted')) {
      colorErrorLog('❌ 公证失败！');
      return false;
    }
    colorLog('🎉 公证成功 -> $dmgPath');
    //钉入公证票据
    final stapleResult = await Process.run("xcrun", [
      'stapler',
      'staple',
      dmgPath,
    ], runInShell: true);
    final stapleOutput = '${stapleResult.stdout}\n${stapleResult.stderr}';
    colorLog('💡Staple 输出: $stapleOutput');
    if (stapleResult.exitCode == 0 && stapleOutput.contains('validate')) {
      colorLog('🎉 Staple 公证票据钉入成功 -> $dmgPath');
    }
    return stapleResult.exitCode == 0;
  }
  return result.exitCode == 0;
}

//MARK: - extension

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

//MARK: - iscc / Inno Setup

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

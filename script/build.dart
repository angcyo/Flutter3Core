import 'dart:io';

import 'package:args/args.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/20
///
/// 模板
/// - `Flutter3Core/flutter3_app/assets/template/app_setting.tl.json`
///
/// 构建信息写入
/// - `Flutter3Core/flutter3_app/assets/config/app_setting.json`
/// - `assets/config/app_setting.json`
void main(List<String> arguments) {
  //throw "test";

  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }

    //信息
    final packageName = results['packageName'] ?? "";
    final appFlavor = results['appFlavor'] ?? "";
    final appState = results['appState'] ?? "";
    final buildTime = results['buildTime'] ?? DateTime.now().toString();
    final operatingSystem = results['operatingSystem'] ??
        Platform.operatingSystem.replaceAll("\"", "\\\"");
    final operatingSystemVersion = results['operatingSystemVersion'] ??
        Platform.operatingSystemVersion.replaceAll("\"", "\\\"");
    final operatingSystemLocaleName = results['operatingSystemLocaleName'] ??
        Platform.localeName.replaceAll("\"", "\\\"");
    final operatingSystemUserName = results['operatingSystemUserName'] ??
        Platform.environment['USERNAME'] ??
        Platform.environment['USER'];

    //handle

    const templatePath = "Flutter3Core/flutter3_app/assets/template";
    const targetPath = "assets/config";

    final currentPath = Directory.current.path;
    print('构建脚本工作路径->$currentPath');

    //模板文件
    final templateFile = File("$currentPath/$templatePath/app_setting.tl.json");
    //目标文件
    final targetFile = File("$currentPath/$targetPath/app_setting.json");
    targetFile.parent.createSync();

    //修改
    String text = templateFile.readAsStringSync();
    /*final json = jsonDecode(text);
    text = jsonEncode(json);*/

    if (packageName != null) {
      text = text.replaceAll(r"${packageName}", packageName);
    }
    if (appFlavor != null) {
      text = text.replaceAll(r"${appFlavor}", appFlavor);
    }
    if (appState != null) {
      text = text.replaceAll(r"${appState}", appState);
    }
    //--build
    if (buildTime != null) {
      text = text.replaceAll(r"${buildTime}", buildTime);
    }
    if (operatingSystem != null) {
      text = text.replaceAll(r"${operatingSystem}", operatingSystem);
    }
    if (operatingSystemVersion != null) {
      text =
          text.replaceAll(r"${operatingSystemVersion}", operatingSystemVersion);
    }
    if (operatingSystemLocaleName != null) {
      text = text.replaceAll(
          r"${operatingSystemLocaleName}", operatingSystemLocaleName);
    }
    if (operatingSystemUserName != null) {
      text = text.replaceAll(
          r"${operatingSystemUserName}", operatingSystemUserName);
    }

    //end
    //print(text);
    targetFile.writeAsStringSync(text);
    print('构建信息修改->${targetFile.path}');

    //成功退出
    //exit(0);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

/// 命令参数说明解析
ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addOption(
      'packageName',
      abbr: 'p',
      valueHelp: "包名字符串",
      help: '替换[packageName]',
    )
    ..addOption(
      'appFlavor',
      abbr: 'f',
      valueHelp: "风味字符串",
      help: '替换[appFlavor]',
    )
    ..addOption(
      'appState',
      abbr: 's',
      valueHelp: "状态字符串",
      help: '替换[appState]',
    )
    ..addOption(
      'buildTime',
      abbr: 'b',
      valueHelp: "编译时间",
      help: '替换[buildTime]',
    )
    ..addOption(
      'operatingSystem',
      valueHelp: "打包操作系统",
      help: '替换[operatingSystem]',
    )
    ..addOption(
      'operatingSystemVersion',
      valueHelp: "打包操作系统版本",
      help: '替换[operatingSystemVersion]',
    )
    ..addOption(
      'operatingSystemLocaleName',
      valueHelp: "打包操作系统语言",
      help: '替换[operatingSystemLocaleName]',
    )
    ..addOption(
      'operatingSystemUserName',
      valueHelp: "打包操作系统用户",
      help: '替换[operatingSystemUserName]',
    );
}

/// 打印命令参数说明
void printUsage(ArgParser argParser) {
  print('Usage: dart build.dart <flags> [arguments]');
  print(argParser.usage);
}

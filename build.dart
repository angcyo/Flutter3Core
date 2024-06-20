import 'dart:io';

import 'package:args/args.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/20
///

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
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart build.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }

    final packageName = results['packageName'];
    final appFlavor = results['appFlavor'];

    //模板文件
    final templateFile = File(
        "${Directory.current.path}/Flutter3Core/flutter3_app/assets/config/app_setting.tl.json");
    //目标文件
    final targetFile = File(
        "${Directory.current.path}/Flutter3Core/flutter3_app/assets/config/app_setting.json");

    String text = templateFile.readAsStringSync();
    if (packageName != null) {
      text = text.replaceAll(r"${packageName}", packageName);
    }
    if (appFlavor != null) {
      text = text.replaceAll(r"${appFlavor}", appFlavor);
    }
    //print(text);
    targetFile.writeAsStringSync(text);
    print('修改文本->${targetFile.path}');

    //成功退出
    //exit(0);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

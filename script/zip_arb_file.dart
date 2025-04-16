import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:yaml/yaml.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/10/21
///
/// 将指定的arb文件, 压缩输出到一个zip文件中
void main() async {
  //读取yaml配置信息
  final currentPath = Directory.current.path;
  final localYamlFile = File("$currentPath/script.local.yaml");
  final yamlFile = File("$currentPath/script.yaml");
  final localYaml = loadYaml(
      localYamlFile.existsSync() ? localYamlFile.readAsStringSync() : "");
  final yaml =
      loadYaml(yamlFile.existsSync() ? yamlFile.readAsStringSync() : "");

  //文件输出的路径
  final outputDirName =
      yaml?["zipArbOutput"] ?? localYaml?["zipArbOutput"] ?? ".output";
  final outputDirPath = "${Directory.current.path}/$outputDirName";
  ensureOutputDir(outputDirPath);

  //需要压缩的文件列表
  final List<(dynamic, dynamic)> arbFilePathList = [
    ("Flutter3Core/flutter3_res/lib/l10n/intl_zh.arb", "lib_intl_zh.arb"),
  ];

  final configPathList =
      yaml?["zipArbFiles"] ?? localYaml?["zipArbFiles"] ?? [];
  if (!configPathList.isEmpty) {
    arbFilePathList.clear();
    for (final configPath in configPathList) {
      if (configPath is Map) {
        arbFilePathList
            .add((configPath.keys.first, configPath.values.firstOrNull));
      } else if (configPath is String) {
        arbFilePathList.add((configPath, null));
      }
    }
  }

  //--output--
  // yyyy-MM-dd
  final nowDateTime = DateTime.now();
  final timeStr = "${nowDateTime.year}-${nowDateTime.month}-${nowDateTime.day}";
  final outputPath = "$outputDirPath/Flutter_intl_$timeStr.zip";

  //压缩文件列表到zip文件
  var count = 0;
  await writeZipFile(outputPath, (encoder) async {
    for (final filePathPair in arbFilePathList) {
      final file = File(filePathPair.$1);
      if (file.existsSync()) {
        await encoder.addFile(file, filePathPair.$2);
        print("压缩: ${file.path} -> ${filePathPair.$2}");
        count++;
      } else {
        print("文件不存在:${file.path}");
      }
    }
  });
  colorLog("压缩完成[$count/${arbFilePathList.length}]↓\n$outputPath");
}

/// 确保输出目录存在
void ensureOutputDir(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    dir.createSync();
  }
}

/// 将文件写入到zip文件中
Future writeZipFile(
  String zipPath,
  FutureOr Function(ZipFileEncoder zipEncoder) action,
) async {
  final encoder = ZipFileEncoder();
  try {
    encoder.create(zipPath, modified: DateTime.now());
    await action(encoder);
  } finally {
    encoder.close();
  }
}

void colorLog(dynamic msg, [int col = 93]) {
  print('\x1B[38;5;${col}m$msg');
}

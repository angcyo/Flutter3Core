part of '../flutter3_app.dart';

extension AppLogPathListEx on List<String> {
  /// 压缩文件/文件夹
  /// [output] zip文件输出全路径
  Future zipPathList(String output) async {
    await zip(output,
        action: (encoder) {
          final hiveJson = hiveAll()?.toJsonString();
          if (hiveJson != null && hiveJson.isNotEmpty) {
            encoder.writeStringSync(hiveJson, 'hive.json');
          }
          final lastInfo = DebugPage.lastDebugCopyStringBuilder(
              GlobalConfig.def.globalContext);
          if (lastInfo != null && lastInfo.isNotEmpty) {
            encoder.writeStringSync(lastInfo, 'last_debug_info.log');
          }
        },
        onGetFileName: (path) => zipEntryKeyMap[path]);
    assert(() {
      final log =
          "压缩完成[${size()}]:$output :${(output.file().fileSizeSync()).toSizeStr()}";
      l.i(log);
      return true;
    }());
  }
}

extension AppLogDirectoryEx on Directory {
  /// 分享文件夹对应的日志
  /// [shareAppLog]
  Future shareAppLog([String? logName]) async {
    final info = await $platformPackageInfo;
    final output = await cacheFilePath(logName?.ensureSuffix(".zip") ??
        "LOG_${info.appName}_${info.version}_${info.buildNumber}_${nowTimeString("yyyy-MM-dd_HH-mm-ss_SSS")}.zip");
    final list = <String>[path];
    await list.zipPathList(output);
    output.shareFile().ignore();
  }
}

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/03
///
/// 快速分享app日志压缩文件, 分享日志
/// [logName] 指定日志的名称, 不指定使用默认
/// [includeFilePath] 是否要包含文件路径数据的分享
Future shareAppLog({
  String? logName,
  bool? includeFilePath = true,
}) async {
  final info = await $platformPackageInfo;
  final output = await cacheFilePath(logName?.ensureSuffix(".zip") ??
      "LOG_${info.appName}_${info.version}_${info.buildNumber}_${nowTimeString("yyyy-MM-dd_HH-mm-ss_SSS")}.zip");
  final list = <String>[];
  //--
  final logFolderPath = (await fileFolder(kLogPathName)).path;
  final configFolderPath = (await fileFolder(kConfigPathName)).path;
  list.add(logFolderPath);
  list.add(configFolderPath);
  //--
  list.addAll(tempShareLogPathList);
  if (includeFilePath == true) {
    list.addAll(tempShareFilePathList);
  }
  list.addAll(globalShareLogPathList);
  //--
  await list.zipPathList(output);
  output.shareFile().ignore();
  clearTempShareLogPath(clearFilePath: includeFilePath == true);
}

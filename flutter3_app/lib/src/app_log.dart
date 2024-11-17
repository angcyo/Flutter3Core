part of '../flutter3_app.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/03
///
/// 快速分享app日志压缩文件, 分享日志
/// [logName] 指定日志的名称, 不指定使用默认
Future shareAppLog([String? logName]) async {
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
  list.addAll(globalShareLogPathList);
  //--
  list.zip(output, action: (encoder) {
    final hiveJson = hiveAll()?.toJsonString();
    if (hiveJson != null && hiveJson.isNotEmpty) {
      encoder.writeStringSync(hiveJson, 'hive.json');
    }
    final lastInfo =
        DebugPage.lastDebugCopyStringBuilder(GlobalConfig.def.globalContext);
    if (lastInfo != null && lastInfo.isNotEmpty) {
      encoder.writeStringSync(lastInfo, 'last_debug_info.log');
    }
  }).ignore();
  assert(() {
    final log = "压缩完成:$output :${(output.file().fileSizeSync()).toSizeStr()}";
    l.i(log);
    return true;
  }());
  output.shareFile().ignore();
  clearTempShareLogPath();
}

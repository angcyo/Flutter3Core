part of '../flutter3_app.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/03
///
/// 快速分享app日志压缩文件, 分享日志
Future shareAppLog([String? name]) async {
  final info = await $platformPackageInfo;
  final output = await cacheFilePath(name?.ensureSuffix(".zip") ??
      "LOG_${info.buildNumber}_${info.version}_${nowTimeString("yyyy-MM-dd_HH-mm-ss_SSS")}.zip");
  final list = <String>[];
  final logFolderPath = (await fileFolder(kLogPathName)).path;
  list.add(logFolderPath);
  list.addAll(tempShareLogPathList);
  list.addAll(globalShareLogPathList);
  list.zip(output, action: (encoder) {
    encoder.writeStringSync(hiveAll()?.toJsonString(), 'hive.json');
  }).ignore();
  assert(() {
    final log =
        "压缩完成:$output :${(output.file().fileSizeSync()).toSizeStr()}";
    l.i(log);
    return true;
  }());
  output.shareFile().ignore();
  clearTempShareLogPath();
}

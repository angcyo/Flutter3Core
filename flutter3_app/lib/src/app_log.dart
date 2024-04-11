part of '../flutter3_app.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/03
///

/// 临时需要分享的日志路径, 触发分享后清空
const List<String> _tempShareLogPathList = [];

/// 需要分享的日志路径, 全局共享
const List<String> _globalShareLogPathList = [];

/// 添加一个临时的日志分享路径
/// [temp] 是否是临时的
@callPoint
void addShareLogPath(String path, {bool temp = true}) {
  if (temp) {
    _tempShareLogPathList.add(path);
  } else {
    _globalShareLogPathList.add(path);
  }
}

/// 清空临时的日志分享路径
@callPoint
void clearTempShareLogPath() {
  _tempShareLogPathList.clear();
}

/// 快速分享app日志压缩文件, 分享日志
Future shareAppLog([String? name]) async {
  final info = await packageInfo;
  final output = await cacheFilePath(name?.ensureSuffix(".zip") ??
      "Log_${info.buildNumber}_${info.version}_${nowTimeString("yyyy-MM-dd_HH-mm-ss_SSS")}.zip");
  final list = <String>[];
  final logFolderPath = (await fileFolder(kLogPathName)).path;
  list.add(logFolderPath);
  list.addAll(_tempShareLogPathList);
  list.addAll(_globalShareLogPathList);
  list.zip(output, action: (encoder) {
    encoder.writeString(hiveAll().toJsonString(), 'hive.json');
  }).ignore();
  assert(() {
    final log =
        "压缩完成:$output :${(output.file().fileSizeSync()).toFileSizeStr()}";
    l.i(log);
    return true;
  }());
  output.shareFile().ignore();
  clearTempShareLogPath();
}

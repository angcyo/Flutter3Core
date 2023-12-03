part of flutter3_app;

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2023/12/03
///

/// 临时需要分享的日志路径, 触发分享后清空
const List<String> tempShareLogPathList = [];

void addTempShareLogPath(String path) {
  tempShareLogPathList.add(path);
}

void clearTempShareLogPath() {
  tempShareLogPathList.clear();
}

/// 快速分享app日志压缩文件
Future shareAppLog([String? name]) async {
  var info = await packageInfo;
  var output = await cacheFilePath(name?.ensureSuffix(".zip") ??
      "LOG-${info.buildNumber}-${info.version}-${nowTimeString("yyyy-MM-dd_HH-mm-ss_SSS")}.zip");
  var list = <String>[];
  var logFolderPath = await fileFolderPath(kLogPathName);
  list.add(logFolderPath);
  list.zip(output).ignore();
  var log = "压缩完成:$output :${(await output.fileSize()).toFileSizeStr()}";
  l.i(log);
  output.shareFile().ignore();
}

part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/18
///

/// 日志文件的最大大小字节
const kMaxLogLength = 2 * 1024 * 1024; //2M
/// 日志文件的扩展名
const kLogExtension = ".log";
const kLFileName = "l.log";
const kLogFileName = "log.log";
const kErrorFileName = "error.log";
const kHttpFileName = "http.log";
const kLogPathName = "log";

extension LogEx on Object {
  /// 包裹一下日志信息
  String wrapLog([String? prefix]) => "\n${prefix ?? nowTimeString()}\n$this\n";

  /// 写入内容到文件, 支持限制文件的长度
  /// [fileName] 日志文件名
  /// [folder] 上层文件夹
  /// [limitLength] 是否限制日志文件的最大长度
  /// @return 返回文件路径
  Future<String> appendToFile(
    String fileName, {
    String? folder,
    bool limitLength = true,
  }) async {
    var filePath = await fileName.filePathOf(folder);
    var mode = FileMode.append;
    if (limitLength && filePath.length > kMaxLogLength) {
      mode = FileMode.write;
    }
    if (this is UiImage) {
      filePath.writeImage(this as UiImage?);
    } else {
      filePath.writeString(
        fileName.endsWith(kLogExtension) ? wrapLog() : "$this",
        mode: mode,
      );
    }
    return filePath;
  }

  /// 写入内容到日志文件
  /// @return 返回文件路径
  Future<String> appendToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) async {
    return appendToFile(fileName, folder: folder, limitLength: limitLength);
  }

  /// 写入内容到日志文件, 同步方法
  void toLogSync({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void toErrorLogSync({
    String fileName = kErrorFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void toHttpLogSync({
    String fileName = kHttpFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }
}

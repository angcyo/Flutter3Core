part of '../../flutter3_core.dart';

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
  String wrapLogString([String? prefix]) =>
      "\n${prefix ?? nowTimeString()}\n$this\n";

  /// 写入到文件, 返回对应的文件
  Future<File> writeToFile({
    String? fileName,
    String? folder,
    bool append = false,
    bool limitLength = false,
    bool? wrapLog = false,
  }) async {
    fileName ??= nowTimeFileName();
    return appendToFile(
      fileName,
      folder: folder,
      append: append,
      limitLength: limitLength,
      wrapLog: wrapLog,
    );
  }

  /// 写入内容到文件, 支持限制文件的长度
  /// [fileName] 日志文件名
  /// [folder] 上层文件夹
  /// [limitLength] 是否限制日志文件的最大长度
  /// [wrapLog] 是否包裹一下日志信息, null:自动根据后缀[kLogExtension]判断
  /// @return 返回文件路径
  Future<File> appendToFile(
    String fileName, {
    String? folder,
    bool append = true,
    bool limitLength = true,
    bool? wrapLog,
  }) async {
    final filePath = await fileName.filePathOf(folder);
    FileMode mode = append ? FileMode.append : FileMode.write;
    if (append && limitLength && (filePath.length > kMaxLogLength)) {
      mode = FileMode.write;
    }
    final file = filePath.file();
    if (this is UiImage) {
      file.writeImage(this as UiImage?);
    } else if (this is Uint8List) {
      file.writeAsBytes(this as Uint8List, mode: mode);
    } else {
      file.writeString(
        (wrapLog == true ||
                (wrapLog == null && fileName.endsWith(kLogExtension)))
            ? wrapLogString()
            : "$this",
        mode: mode,
      );
    }
    return file;
  }

  /// 写入内容到日志文件
  /// @return 返回文件路径
  Future<File> appendToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) async {
    return appendToFile(fileName, folder: folder, limitLength: limitLength);
  }

  /// 写入内容到日志文件, 同步方法
  void writeToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void writeToErrorLog({
    String fileName = kErrorFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void writeToHttpLog({
    String fileName = kHttpFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(fileName, folder: folder, limitLength: limitLength));
  }
}

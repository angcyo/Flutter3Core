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

/// 当前支持写入文件的数据类型
/// [UiImage]
/// [ByteData]/[TypedData]|[ByteData.buffer]->[ByteBuffer]|[ByteData.view]
/// [ByteBuffer]|[ByteBuffer.asUint8List]->[Uint8List]|[ByteBuffer.asByteData]->[ByteData]
/// [Uint8List]/[TypedData]|[Uint8List.buffer]->[ByteBuffer]
/// [String]
/// [LogEx.appendToFile]
typedef FileDataType = Object;

extension LogEx on Object {
  /// 包裹一下日志信息
  String wrapLogString([String? prefix]) =>
      "\n${prefix ?? nowTimeString()}\n$this\n";

  /// 写入到文件, 返回对应的文件
  /// [file] 直接指定文件, 否则会根据[fileName].[folder]生成文件对象
  Future<File> writeToFile({
    File? file,
    String? fileName,
    String? folder,
    bool append = false,
    bool limitLength = false,
    bool? wrapLog = false,
    bool useCacheFolder = false,
  }) async {
    fileName ??= nowTimeFileName();
    return appendToFile(
      file: file,
      fileName: fileName,
      folder: folder,
      append: append,
      limitLength: limitLength,
      useCacheFolder: useCacheFolder,
      wrapLog: wrapLog,
    );
  }

  /// 写入内容到文件, 支持限制文件的长度
  /// [fileName] 日志文件名
  /// [folder] 上层文件夹
  /// [limitLength] 是否限制日志文件的最大长度
  /// [wrapLog] 是否包裹一下日志信息, null:自动根据后缀[kLogExtension]判断
  /// @return 返回文件路径
  Future<File> appendToFile({
    File? file,
    String? fileName,
    String? folder,
    bool append = true,
    bool limitLength = true,
    bool useCacheFolder = false,
    bool? wrapLog,
  }) async {
    fileName ??= "Unknown";
    final filePath =
        file?.path ?? await fileName.filePathOf(folder, useCacheFolder);
    FileMode mode = append ? FileMode.append : FileMode.write;
    if (append && limitLength && (filePath.length > kMaxLogLength)) {
      mode = FileMode.write;
    }
    final fileObj = filePath.file();

    Future writeBytes(Uint8List? bytes) async {
      if (bytes != null) {
        await fileObj.writeAsBytes(bytes, mode: mode);
      }
    }

    Future writeByteBuffer(ByteBuffer? byteBuffer) async {
      if (byteBuffer != null) {
        final list = byteBuffer.asUint8List();
        await writeBytes(list);
      }
    }

    Future writeByteData(ByteData? byteData) async {
      if (byteData != null) {
        final buffer = byteData.buffer;
        await writeByteBuffer(buffer);
      }
    }

    Future writeImage(UiImage? image) async {
      final byteData = await image?.toByteData(format: UiImageByteFormat.png);
      await writeByteData(byteData);
    }

    Future writeString(String? string) async {
      if (string != null) {
        await fileObj.writeString(
          (wrapLog == true ||
                  (wrapLog == null &&
                      fileName?.endsWith(kLogExtension) == true))
              ? wrapLogString()
              : string,
          mode: mode,
        );
      }
    }

    if (this is UiImage) {
      //图片不支持[FileMode.append]模式
      fileObj.writeImage(this as UiImage?);
    } else if (this is Uint8List) {
      writeBytes(this as Uint8List);
    } else if (this is ByteData) {
      writeByteData(this as ByteData);
    } else if (this is ByteBuffer) {
      writeByteBuffer(this as ByteBuffer);
    } else {
      writeString("$this");
    }
    return fileObj;
  }

  /// 写入内容到日志文件
  /// @return 返回文件路径
  Future<File> appendToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) async {
    return appendToFile(
        fileName: fileName, folder: folder, limitLength: limitLength);
  }

  /// 写入内容到日志文件, 同步方法
  void writeToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(
        fileName: fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void writeToErrorLog({
    String fileName = kErrorFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(
        fileName: fileName, folder: folder, limitLength: limitLength));
  }

  /// 写入内容到日志文件, 同步方法
  void writeToHttpLog({
    String fileName = kHttpFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
  }) {
    unawaited(appendToFile(
        fileName: fileName, folder: folder, limitLength: limitLength));
  }
}

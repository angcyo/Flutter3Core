part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/18
///

/// 日志文件的最大大小字节
const kMaxLogLength = 2 * 1024 * 1024; //2M
/// 日志文件的扩展名
const kLogExtension = ".log"; //日志文件后缀
const kLFileName = "l.log"; //常规操作日志
const kOperateFileName = "operate.log"; //特殊操作日志
const kLogFileName = "log.log"; //特殊日志文件
const kBleFileName = "ble.log"; //蓝牙机器操作日志
const kErrorFileName = "error.log"; //错误日志
const kHttpFileName = "http.log"; //网络请求日志
const kPerfFileName = "perf.log"; //性能相关日志
const kLogPathName = "log"; //日志文件夹

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
      "${prefix ?? nowTimeString()} $this\n";

  /// 写入到文件, 返回对应的文件
  /// [file] 直接指定文件, 否则会根据[fileName].[folder]生成文件对象
  /// [FileDataType] 支持的数据类型
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
  /// [FileDataType] 支持的数据类型
  /// @return 返回文件对象
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
    final fileObj = filePath.file();
    if (append && limitLength && (fileObj.lengthSync() > kMaxLogLength)) {
      mode = FileMode.write;
    }

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

    //Flutter3Core/flutter3_basics/lib/src/basics/basics_file.dart:206
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
  /// [level] 日志等级, 用于输出日志
  /// @return 返回文件路径
  Future<File> appendToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.none,
    int forward = 4,
    bool append = true,
  }) async {
    //debugger();
    l.log(this, level: level, forward: forward);
    return appendToFile(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      append: append,
    );
  }

  /// 写入内容到日志文件
  void writeToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.debug,
    int forward = 5,
    bool append = true,
  }) {
    unawaited(appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
      append: append,
    ));
  }

  /// 写入内容到日志文件
  void writeToErrorLog({
    String fileName = kErrorFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.error,
    int forward = 5,
  }) {
    unawaited(appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
    ));
  }

  /// 写入内容到日志文件
  void writeToHttpLog({
    String fileName = kHttpFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.none,
    int forward = 5,
  }) {
    unawaited(appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
    ));
  }
}

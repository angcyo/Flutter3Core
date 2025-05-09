part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/18
///

/// 日志文件的最大大小字节
const kMaxLogLength = 2 * 1024 * 1024; //2M
/// 日志文件的扩展名
const kLogExtension = ".log"; //日志文件后缀
/// 常用日志文件名
const kLFileName = "l.log"; //常规操作日志, l.x输出的日志, 会被写入到这个文件
const kOperateFileName = "operate.log"; //特殊操作日志
const kLogFileName = "log.log"; //特殊日志文件
const kBleFileName = "ble.log"; //蓝牙机器操作日志
const kChannelFileName = "channel.log"; //通信数据日志
const kWebSocketFileName = "websocket.log"; //websocket接收的日志
const kErrorFileName = "error.log"; //错误日志
const kHttpFileName = "http.log"; //网络请求日志
const kPerfFileName = "perf.log"; //性能相关日志
/// 路径
const kLogPathName = "log"; //日志存放的文件夹
const kConfigPathName = "config"; //配置存放的文件夹
const kExportPathName = "export"; //导出的数据存放文件夹
const kPrintPathName = "print"; //打印雕刻的数据存放文件夹

/// 当前支持写入文件的数据类型
/// [UiImage]
/// [ByteData]/[TypedData]|[ByteData.buffer]->[ByteBuffer]|[ByteData.view]
/// [ByteBuffer]|[ByteBuffer.asUint8List]->[Uint8List]|[ByteBuffer.asByteData]->[ByteData]
/// [Stream<List<int>>]/[List<int>]/[Uint8List]/[TypedData]|[Uint8List.buffer]->[ByteBuffer]
/// [String]
/// [ObjectLogEx.appendToFile]
/// [FileSystemEntity].[File].[Directory].
///
typedef FileDataType = Object;

extension ObjectLogEx on Object {
  /// 包裹一下日志信息
  String wrapLogString([String? prefix]) =>
      "${prefix ?? nowTimeString()} $this\n";

  /// 日志文件对应的文件全路径
  /// [kLFileName]
  /// [kLogPathName]
  /// [kConfigPathName]
  Future<String> logFilePath({
    String? subFolder = kLogPathName,
    bool useCacheFolder = true,
  }) async =>
      "$this".filePathOf(subFolder, useCacheFolder);

  /// [writeToFile]
  Future<File> saveToFile(File? file) => writeToFile(file: file);

  /// 写入到文件, 返回对应的文件
  /// [file] 直接指定文件, 否则会根据[fileName].[folder]生成文件对象
  /// [FileDataType] 支持的数据类型
  Future<File> writeToFile({
    File? file,
    //--
    String? filePath,
    String? fileName,
    String? folder,
    //--
    bool append = false,
    bool overwrite = true,
    bool limitLength = false,
    bool? wrapLog = false,
    bool useCacheFolder = false,
  }) async {
    fileName ??= nowTimeFileName();
    return appendToFile(
      file: file,
      filePath: filePath,
      fileName: fileName,
      folder: folder,
      append: append,
      overwrite: overwrite,
      limitLength: limitLength,
      useCacheFolder: useCacheFolder,
      wrapLog: wrapLog,
    );
  }

  /// 写入内容到文件, 支持限制文件的长度
  /// [filePath] 直接指定文件路径, 优先级1
  /// [file] 直接指定文件, 否则会根据[fileName].[folder]生成文件对象, 优先级2
  /// [fileName] 日志文件名 , 优先级3
  /// [folder] 上层文件夹, 文件夹复制时, 请使用此变量
  /// [append] 是否追加写入文件数据
  /// [overwrite] 文件已存在是否覆写文件
  /// [limitLength] 是否限制日志文件的最大长度
  /// [wrapLog] 是否包裹一下日志信息, null:自动根据后缀[kLogExtension]判断
  /// [FileDataType] 支持的数据类型
  /// @return 返回文件对象
  Future<File> appendToFile({
    File? file,
    //--
    String? filePath,
    String? fileName,
    String? folder,
    //--
    bool append = true,
    bool overwrite = true,
    bool limitLength = true,
    bool useCacheFolder = false,
    bool? wrapLog,
  }) async {
    fileName ??= "Unknown";
    filePath ??=
        file?.path ?? await fileName.filePathOf(folder, useCacheFolder);

    //确保父文件夹存在
    filePath.ensureParentDirectory();

    FileMode mode = append ? FileMode.append : FileMode.write;
    final fileObj = filePath.file();
    if (await fileObj.exists()) {
      if (!overwrite && !append) {
        //文件已存在, 并且不覆盖/不追加
        return fileObj;
      }
    }
    if (append && limitLength && (fileObj.fileSizeSync() > kMaxLogLength)) {
      mode = FileMode.write;
    }

    // List<int>
    Future writeBytes(List<int>? bytes) async {
      if (bytes != null) {
        await fileObj.writeAsBytes(bytes, mode: mode);
      }
    }

    // Stream<List<int>>
    Future writeStream(Stream<List<int>>? stream) async {
      if (stream != null) {
        await stream.listen((event) async {
          await fileObj.writeAsBytes(event, mode: mode);
        }, cancelOnError: true).asFuture();
      }
    }

    // ByteBuffer
    Future writeByteBuffer(ByteBuffer? byteBuffer) async {
      if (byteBuffer != null) {
        final list = byteBuffer.asUint8List();
        await writeBytes(list);
      }
    }

    // ByteData
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

    // String
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
      await fileObj.writeImage(this as UiImage?);
    } else if (this is List<int>) {
      await writeBytes(this as List<int>);
    } else if (this is ByteData) {
      await writeByteData(this as ByteData);
    } else if (this is ByteBuffer) {
      await writeByteBuffer(this as ByteBuffer);
    } else if (this is Stream<List<int>>) {
      //debugger();
      await writeStream(this as Stream<List<int>>);
    } else if (this is File) {
      //debugger();
      //文件复制
      await (this as File).copy(filePath);
    } else if (this is Directory) {
      //debugger();
      //文件夹复制
      await (this as Directory)
          .copyDirectory(Directory(folder ?? fileObj.parent.path));
    } else {
      await writeString("$this");
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
  }) {
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
  /// [limitLength] 是否限制日志文件的最大长度
  Future<File> writeToLog({
    String fileName = kLogFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.debug,
    int forward = 5,
    bool append = true,
  }) {
    return appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
      append: append,
    );
  }

  /// 写入内容到日志文件
  Future<File> writeToErrorLog({
    String fileName = kErrorFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.error,
    int forward = 5,
  }) {
    return appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
    );
  }

  /// 写入内容到日志文件
  Future<File> writeToHttpLog({
    String fileName = kHttpFileName,
    String? folder = kLogPathName,
    bool limitLength = true,
    int level = L.none,
    int forward = 5,
  }) {
    return appendToLog(
      fileName: fileName,
      folder: folder,
      limitLength: limitLength,
      level: level,
      forward: forward,
    );
  }
}

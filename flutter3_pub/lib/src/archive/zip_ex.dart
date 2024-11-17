part of '../../flutter3_pub.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

/// https://pub.dev/packages/archive
/// https://github.com/brendan-duncan/archive/blob/main/example/example.dart

extension ZipEx on String {
  /// 遍历压缩包中的文件
  Future<bool> eachArchiveFile(
      FutureOr Function(ArchiveFile archive) action) async {
    final input = InputFileStream(this);
    try {
      final archive = ZipDecoder().decodeBuffer(input);
      for (final file in archive.files) {
        await action(file);
      }
    } finally {
      input.close();
    }
    return true;
  }

  /// 修改指定压缩包中的文件
  /// [action] 修改文件的回调, 返回null 则删除了文件
  Future<bool> modifyArchiveFile(
      Future<ArchiveFile?> Function(ArchiveFile archive) action) async {
    final tempCacheFilePath = await cacheFilePath(uuidFileName());
    final targetZipFilePath = this;
    final result = await tempCacheFilePath.writeZipFile((zipEncoder) async {
      await eachArchiveFile((file) async {
        final newFile = await action(file);
        if (newFile != null) {
          //修改了文件
          zipEncoder.addArchiveFile(newFile);
        }
      });
    });
    //修改之后, 删除目标文件
    await targetZipFilePath.delete();
    //重命名临时文件到目标文件
    await tempCacheFilePath.rename(targetZipFilePath);
    return result;
  }

  /// 读取zip文件
  /// [extractFileToDisk]
  /// [Archive.findFile]->[ArchiveFile]
  /// [ArchiveFile.content] 内容
  Future<bool> readZipFile(FutureOr Function(Archive archive) action) async {
    final input = InputFileStream(this);
    final archive = ZipDecoder().decodeBuffer(input);
    //archive.findFile(name); //查找指定文件

    /*for (final file in archive.files) {
      if (file.isFile) {
        //是文件
        //file.writeContent(output);
        //final bytes = file.content as List<int>; //字节数据
      } else if (!file.isFile && !file.isSymbolicLink) {
        //是文件夹
      }
    }*/

    try {
      await action(archive);
    } finally {
      input.close();
    }
    return true;
  }

  /// 写入数据到zip文件
  /// [ZipFileEncoder.addDirectory]
  /// [ZipFileEncoder.addFile]
  /// [ZipFileEncoder.addArchiveFile]
  /// [ArchiveFile]
  Future<bool> writeZipFile(
    FutureOr Function(ZipFileEncoder zipEncoder) action, {
    DateTime? modified,
  }) async {
    final encoder = ZipFileEncoder();
    try {
      encoder.create(this, modified: modified ?? DateTime.now());
      await action(encoder);
    } finally {
      encoder.close();
    }
    return true;
  }

  /// 解压文件到指定目录下
  /// [extractFileToDisk]
  /// [extractArchiveToDisk]
  Future<String> unzip([String? outputPath]) async {
    outputPath ??= folderPath().join(fileName(true));
    l.d("解压:$this->$outputPath");
    await extractFileToDisk(this, outputPath);
    return outputPath;
  }
}

extension ZipListEx on List<String> {
  /// 压缩所有文件/文件夹到指定文件
  /// [ZipFileEncoder.zipDirectoryAsync]
  /// [ZipFileEncoderEx.writeStringSync]
  Future<void> zip(
    String outputPath, {
    DateTime? modified,
    FutureOr Function(ZipFileEncoder zipEncoder)? action,
  }) async {
    final encoder = ZipFileEncoder();
    try {
      encoder.create(outputPath, modified: modified ?? DateTime.now());
      await zipEncoder(encoder);
      if (action != null) {
        await action(encoder);
      }
    } catch (e) {
      l.e(e);
    } finally {
      encoder.close();
    }
  }

  /// 入参不一样的压缩扩展方法
  /// [zip]
  Future<void> zipEncoder(ZipFileEncoder encoder) async {
    for (final path in this) {
      if (path.isDirectorySync()) {
        encoder.addDirectory(Directory(path));
      } else if (path.isExistsSync()) {
        encoder.addFile(File(path));
      }
    }
  }
}

extension ZipFileEncoderEx on ZipFileEncoder {
  /// 写入[Uint8List]
  /// [InputStream]
  /// [name] 名称
  /// [compress] 是否压缩
  void writeBytesSync(
    Uint8List? bytes,
    String? name, {
    bool compress = true,
  }) {
    if (bytes == null || name == null) {
      return;
    }
    if (isNil(bytes)) {
      return;
    }
    addArchiveFile(compress
        ? ArchiveFile(name, 0, bytes) /*用0, 内部会自动使用length*/
        : ArchiveFile.noCompress(name, bytes.length, bytes));
  }

  /// [writeBytesSync]
  Future writeBytes(
    Uint8List? bytes,
    String? name, {
    bool compress = true,
  }) async =>
      () async {
        return writeBytesSync(bytes, name, compress: compress);
      }();

  /// 写入[UiImage]
  /// [Uint8List]
  /// [InputStream]
  /// [name] 名称
  Future<void> writeImage(
    UiImage? uiImage,
    String? name, {
    bool compress = true,
  }) async {
    if (uiImage == null || name == null) {
      return;
    }
    final bytes = await uiImage.toBytes();
    writeBytesSync(bytes, name, compress: compress);
  }

  /// 写入字符串
  /// [content] 字符内容
  /// [name] 名称
  /// [compress] 是否要将[content]使用[utf8.encode]变成[Uint8List]
  void writeStringSync(
    String? content,
    String? name, {
    bool compress = false,
  }) {
    //debugger();
    if (content == null || name == null) {
      return;
    }
    if (compress) {
      addArchiveFile(ArchiveFile.string(name, content));
    } else {
      final bytes = content.bytes; //[utf8.encode]
      addArchiveFile(ArchiveFile.noCompress(name, bytes.size(), bytes));
    }
  }

  /// [writeStringSync]
  Future writeString(
    String? content,
    String? name, {
    bool compress = false,
  }) async =>
      () async {
        return writeStringSync(content, name, compress: compress);
      }();
}

extension ArchiveEx on Archive {
  /// [readContent]
  Uint8List? readBytes(String? name) => readContent(name);

  /// 读取文件内容
  /// [ArchiveFile.content]
  Uint8List? readContent(String? name) {
    if (name == null) {
      return null;
    }
    final file = findFile(name);
    if (file != null) {
      return file.readContent();
    }
    return null;
  }

  /// 读取字符串
  /// [ArchiveFile.content]
  String? readString(String? name) {
    if (name == null) {
      return null;
    }
    final file = findFile(name);
    if (file != null) {
      return file.readString();
    }
    return null;
  }

  /// 读取图片
  /// [ArchiveFile.content]
  Future<UiImage?> readImage(String? name) async {
    if (name == null) {
      return null;
    }
    final file = findFile(name);
    if (file != null) {
      return file.readImage();
    }
    return null;
  }
}

extension ArchiveFileEx on ArchiveFile {
  /// [readContent]
  Uint8List? readBytes() => readContent();

  /// 读取文件内容
  /// [ArchiveFile.content]
  Uint8List? readContent() {
    if (content is Uint8List) {
      return content as Uint8List;
    } else if (content is InputStream) {
      return (content as InputStream).toUint8List();
    }
    return null;
  }

  /// 读取字符串
  /// [ArchiveFile.content]
  String? readString() {
    if (content is String) {
      return content as String;
    }
    final bytes = readContent();
    if (bytes != null) {
      return bytes.utf8Str;
      //return String.fromCharCodes(bytes);
    }
    return null;
  }

  /// 读取图片
  /// [ArchiveFile.content]
  Future<UiImage?> readImage() async {
    final bytes = readContent();
    if (bytes != null) {
      return bytes.toImage();
    }
    return null;
  }
}

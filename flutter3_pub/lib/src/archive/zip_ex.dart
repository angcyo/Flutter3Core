part of flutter3_pub;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/12/02
///

/// https://pub.dev/packages/archive
/// https://github.com/brendan-duncan/archive/blob/main/example/example.dart

extension ZipEx on String {
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
  Future<void> zip(
    String outputPath, {
    int? level = ZipFileEncoder.GZIP,
    DateTime? modified,
  }) async {
    var encoder = ZipFileEncoder();
    encoder.create(outputPath, modified: modified ?? DateTime.now());
    await zipEncoder(encoder);
    encoder.close();
  }

  /// 入参不一样的压缩扩展方法
  /// [zip]
  Future<void> zipEncoder(ZipFileEncoder encoder) async {
    for (var path in this) {
      if (path.isDirectorySync()) {
        encoder.addDirectory(Directory(path));
      } else {
        encoder.addFile(File(path));
      }
    }
  }
}

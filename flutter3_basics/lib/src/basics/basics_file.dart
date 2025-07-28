part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/31
///

extension FileUriEx on Uri {
  bool get isFileScheme => scheme == 'file';

  bool get isHttpScheme => scheme == 'http' || scheme == 'https';

  /// 获取文件全路径, 支持中文, 不需要进行解码
  /// [StringEx.decodeUri]
  ///
  /// 如果不是一个文件路径, 则会报错
  /// ```
  /// Unsupported operation: Cannot extract a file path from a https URI
  /// ```
  ///
  String get filePath => toFilePath();

  /// 如果是文件scheme, 则返回文件路径
  /// 否则返回...
  /// [filePath]
  /// [toString]
  String get filePathOrUrl => scheme == 'file' ? filePath : toString();

  /// 转换成[File]类型
  File toFile() => File.fromUri(this);
}

/// https://api.dart.dev/stable/3.2.0/dart-io/dart-io-library.html
/// https://api.dart.dev/stable/3.2.0/dart-io/Process-class.html
/// https://pub.dev/packages/uri_to_file
extension FileStringEx on String {
  /// [File]
  /// [Directory]
  File toFile() => File(this);

  String? get fileMd5Sync => toFile().md5Sync();

  Future<String?> get fileMd5 => toFile().md5();

  //region ---Path---

  /// 转换成文件夹对象
  /// [File]
  /// [Directory]
  Directory get folder => Directory(this);

  /// [folder]
  Directory toFolder() => Directory(this);

  /// 确保文件夹存在, 如果不存在, 则创建
  Directory ensureDirectory() => Directory(this).ensureDirectory();

  /// 确保文件的文件夹目录存在, 如果不存在, 则创建
  Directory ensureParentDirectory() {
    return parentPath.ensureDirectory();
  }

  /// 父路径
  String get parentPath => FileSystemEntity.parentOf(this);

  /// 当前文件/文件夹是否存在
  Future<bool> isExists() async =>
      await File(this).exists() || await Directory(this).exists();

  ///[isExists]
  bool isExistsSync() =>
      File(this).existsSync() || Directory(this).existsSync();

  /// 文件是否存在
  bool isFileExistsSync() => File(this).existsSync();

  /// 是否是文件夹
  Future<bool> isDirectory() async => FileSystemEntity.isDirectory(this);

  bool isDirectorySync() => FileSystemEntity.isDirectorySync(this);

  /// 是否是文件
  Future<bool> isFile() async => FileSystemEntity.isFile(this);

  bool isFileSync() => FileSystemEntity.isFileSync(this);

  /// 异步创建目录
  Future<Directory> createAsync({bool recursive = true}) =>
      Directory(this).create(recursive: recursive);

  /// 同步创建目录
  void createDirectory({bool recursive = true}) {
    Directory(this).createSync(recursive: recursive);
  }

  /// [listFiles]
  /// [listFilesStream]
  Stream<FileSystemEntity> listFilesStream({
    bool recursive = false,
    bool followLinks = true,
  }) =>
      Directory(this).list(
        recursive: recursive,
        followLinks: followLinks,
      );

  /// 获取文件夹中的文件列表
  /// [recursive] 是否递归
  Future<List<FileSystemEntity>?> listFiles({
    bool recursive = false,
    bool followLinks = true,
  }) async {
    try {
      return await Directory(this)
          .list(
            recursive: recursive,
            followLinks: followLinks,
          )
          .toList();
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 同步方法
  /// [listFiles]
  List<FileSystemEntity>? listFilesSync({
    bool recursive = false,
    bool followLinks = true,
  }) {
    try {
      return Directory(this)
          .listSync(
            recursive: recursive,
            followLinks: followLinks,
          )
          .toList();
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

//endregion ---Path---
}

//region File 扩展

extension FileSystemEntityEx on FileSystemEntity {
  Future<DateTime?> get lastModified {
    if (this is File) {
      return (this as File).lastModified();
    }
    return Future.value(null);
  }

  DateTime? get lastModifiedSync {
    if (this is File) {
      return (this as File).lastModifiedSync();
    }
    return null;
  }

  /// 是否是文件夹
  Future<bool> isDirectory() async => FileSystemEntity.isDirectory(path);

  bool isDirectorySync() => FileSystemEntity.isDirectorySync(path);

  /// 是否是文件
  Future<bool> isFile() async => FileSystemEntity.isFile(path);

  bool isFileSync() => FileSystemEntity.isFileSync(path);

  /// 链接对象
  bool isLinkSync() => FileSystemEntity.isLinkSync(path);

  /// 文件对象
  File? get file {
    if (this is File) {
      return this as File;
    }
    return null;
  }

  /// 文件夹对象
  Directory? get directory {
    if (this is Directory) {
      return this as Directory;
    }
    return null;
  }
}

extension FileEx on File {
  /// 文件流
  Stream<List<int>> get stream {
    return openRead();
  }

  /// 有个path库的方法叫做[basename]
  /// 获取路径对应的文件名, 包含扩展名
  String get filename {
    String text = path;
    if (text.contains('?')) {
      text = text.split('?').first;
    }
    //路径分隔符, Android:/
    return text.split(Platform.pathSeparator).last;
  }

  /// [UiImageProvider]
  /// [ImageProviderEx.toImage]
  FileImage toImageProvider([double scale = 1]) =>
      FileImage(this, scale: scale);

  /// 文件大小
  /// [fileSize]
  int fileSizeSync() {
    if (existsSync()) {
      return lengthSync();
    }
    return 0;
  }

  /// 文件大小
  /// [fileSizeSync]
  Future<int> fileSize() async {
    if (await exists()) {
      return length();
    }
    return 0;
  }

  /// 读取文件内容
  Future<Uint8List?> readBytes() async {
    try {
      return await readAsBytes();
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 读取文件内容
  Uint8List? readBytesSync() {
    try {
      return readAsBytesSync();
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 读取文件内容, 系统的[readAsString]当文件不存在时, 会抛出异常
  /// ```
  /// PathNotFoundException: Cannot open file, path = '/storage/emulated/0/Android/data/com.xxx.xxx/cache/resource.json'
  /// (OS Error: No such file or directory, errno = 2)
  /// ```
  /// [loadAssetString]
  Future<String?> readString({
    Encoding encoding = utf8,
    bool ignoreError = true,
    bool ignoreErrorLog = false,
  }) async {
    try {
      return await readAsString(encoding: encoding);
    } catch (e, s) {
      if (!ignoreErrorLog) {
        assert(() {
          l.e(e);
          printError(e, s);
          return true;
        }());
      }
      if (!ignoreError) {
        rethrow;
      }
    }
    return null;
  }

  /// 读取文件内容
  String? readStringSync({Encoding encoding = utf8}) {
    try {
      return readAsStringSync(encoding: encoding);
    } on FileSystemException catch (e) {
      //有些时候, 直接读取字符串会失败
      //但是读取字节流, 然后转换成字符串, 就可以成功
      return readBytesSync()?.decode(utf8);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 读取文件内容
  Future<List<String>?> readLines({Encoding encoding = utf8}) async {
    try {
      return await readAsLines(encoding: encoding);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 读取文件内容
  List<String>? readLinesSync({Encoding encoding = utf8}) {
    try {
      return readAsLinesSync(encoding: encoding);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 写入图片到文件
  Future<File?> writeImage(
    UiImage? image, {
    UiImageByteFormat format = UiImageByteFormat.png,
  }) async {
    if (image == null) {
      return null;
    }
    return image.saveToFile(this, format: format);
  }

  /// 从文件路径中读取图片
  /// [FileImage._loadAsync]
  /// [ImageStringEx.toImageFromFile]
  Future<UiImage> toImage() async {
    final Uint8List bytes = await readAsBytes();

    /*final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromFilePath(this);
    final ui.Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(buffer);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;*/

    return decodeImageFromList(bytes);
  }

  /// 写入文件内容
  Future<File?> writeString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = true,
  }) async {
    try {
      parent.path.ensureDirectory();
      return await writeAsString(
        contents,
        mode: mode,
        encoding: encoding,
        flush: flush,
      );
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 写入文件内容
  File? writeStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    try {
      parent.path.ensureDirectory();
      return this
        ..writeAsStringSync(
          contents,
          mode: mode,
          encoding: encoding,
          flush: flush,
        );
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 写入文件内容
  Future<File?> writeBytes(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) async {
    try {
      return await writeAsBytes(
        bytes,
        mode: mode,
        flush: flush,
      );
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 写入文件内容
  File? writeBytesSync(
    List<int> bytes, {
    FileMode mode = FileMode.write,
    bool flush = false,
  }) {
    try {
      return this
        ..writeAsBytesSync(
          bytes,
          mode: mode,
          flush: flush,
        );
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 文件的md5值, 共hex 32位
  String? md5Sync() => readBytesSync()?.md5();

  Future<String?> md5() async => (await readBytes())?.md5();

  /// 文件的sha1值, 共hex 40位
  String? sha1Sync() => readBytesSync()?.sha1();

  Future<String?> sha1() async => (await readBytes())?.sha1();

  /// 如果是文件夹, 获取文件列表
  Stream<FileSystemEntity> listFilesStream({
    bool recursive = false,
    bool followLinks = true,
  }) {
    if (path.isDirectorySync()) {
      return path.listFilesStream(
        recursive: recursive,
        followLinks: followLinks,
      );
    }
    return const Stream.empty();
  }

  /// 如果是文件夹, 获取文件列表
  Future<List<FileSystemEntity>?> listFiles({
    bool recursive = false,
    bool followLinks = true,
  }) async {
    try {
      if (await path.isDirectory()) {
        return path.listFiles(
          recursive: recursive,
          followLinks: followLinks,
        );
      }
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// 如果是文件夹, 获取文件列表
  List<FileSystemEntity>? listFilesSync({
    bool recursive = false,
    bool followLinks = true,
  }) {
    try {
      if (path.isDirectorySync()) {
        return path.listFilesSync(
          recursive: recursive,
          followLinks: followLinks,
        );
      }
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return null;
  }

  /// PathNotFoundException: Cannot delete file, path = '/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/files/2024-03-30_22-08-34-053.lp2' (OS Error: No such file or directory, errno = 2)
  Future<FileSystemEntity?> deleteSafe({bool recursive = false}) async {
    try {
      return await delete(recursive: recursive);
    } catch (e) {
      assert(() {
        l.w(e);
        return true;
      }());
    }
    return null;
  }

  /// [deleteSafe]
  bool deleteSafeSync({bool recursive = false}) {
    try {
      deleteSync(recursive: recursive);
      return true;
    } catch (e) {
      assert(() {
        l.w(e);
        return true;
      }());
    }
    return false;
  }

  /// 读取文件最后的几个字节
  Future<Uint8List> readLastBytes(int count) async {
    final file = this;
    final length = await file.length();
    if (length <= count) {
      return file.readAsBytes();
    }
    final buffer = await file.open();
    await buffer.setPosition(length - count);
    final bytes = buffer.read(count);
    await buffer.close();
    return bytes;
  }

  Uint8List readLastBytesSync(int count) {
    final file = this;
    final length = file.lengthSync();
    if (length <= count) {
      return file.readAsBytesSync();
    }
    final buffer = file.openSync();
    buffer.setPositionSync(length - count);
    final bytes = buffer.readSync(count);
    buffer.closeSync();
    return bytes;
  }

  /// [readLastBytes]
  Future<String> readLastString(int count, {Encoding encoding = utf8}) async {
    final file = this;
    final length = await file.length();
    if (length <= count) {
      return file.readAsString(encoding: encoding);
    }
    final buffer = await file.open();
    await buffer.setPosition(length - count);
    final bytes = await buffer.read(count);
    await buffer.close();
    return bytes.toStr(encoding);
  }

  String readLastStringSync(int count, {Encoding encoding = utf8}) {
    final file = this;
    final length = file.lengthSync();
    if (length <= count) {
      return file.readAsStringSync(encoding: encoding);
    }
    final buffer = file.openSync();
    buffer.setPositionSync(length - count);
    final bytes = buffer.readSync(count);
    buffer.closeSync();
    return bytes.toStr(encoding);
  }

  /// 判断当前文件是否是文件夹
  Future<bool> isDirectory() async => FileSystemEntity.isDirectory(path);

  /// 重命名文件
  /// 有些平台上, 直接重命名会失败, 建议复制然后删除源文件
  /// ```
  /// FileSystemException: Cannot rename file to '/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/files/projects/012734b6cb4a4022a64126480f51c3cb.lp2', path = '/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/cache/92a68da582db4001806eabcaceb9ee59' (OS Error: Cross-device link, errno = 18)
  /// ```
  Future<bool> renameTo(String newPath) async {
    try {
      await rename(newPath);
      return true;
    } catch (e) {
      //debugger();
      await copy(newPath);
      await delete();
      return true;
    }
  }

  /// [renameTo]
  bool renameToSync(String newPath) {
    try {
      renameSync(newPath);
      return true;
    } catch (e) {
      //debugger();
      copySync(newPath);
      deleteSync();
      return true;
    }
  }

  /// 复制文件到指定的文件夹
  Future<bool> copyTo(String folder) async {
    try {
      await copy(File("$folder/$filename").path);
      return true;
    } catch (e, s) {
      assert(() {
        printError(e, s);
        return true;
      }());
      return false;
    }
  }
}

//endregion File 扩展

//region Directory 扩展

extension DirectoryEx on Directory {
  /// 确保文件夹存在, 如果不存在, 则创建
  Directory ensureDirectory() {
    final dir = this;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// PathNotFoundException: Cannot delete file, path = '/storage/emulated/0/Android/data/com.angcyo.flutter3.abc/files/2024-03-30_22-08-34-053.lp2' (OS Error: No such file or directory, errno = 2)
  Future<FileSystemEntity?> deleteSafe({bool recursive = false}) async {
    try {
      return await delete(recursive: recursive);
    } catch (e) {
      assert(() {
        l.w("无法删除文件夹->$e");
        return true;
      }());
    }
    return null;
  }

  /// [deleteSafe]
  bool deleteSafeSync({bool recursive = false}) {
    try {
      deleteSync(recursive: recursive);
      return true;
    } catch (e) {
      assert(() {
        l.w(e);
        return true;
      }());
    }
    return false;
  }

  /// 复制文件夹的方法
  /// [destination] 目标文件夹
  /// [File.copy]
  Future<bool> copyDirectory(Directory destination) async {
    // 如果目标文件夹不存在，则创建它
    if (!(await destination.exists())) {
      await destination.create(recursive: true);
    }

    // 遍历源文件夹中的文件和子文件夹
    await for (final entity in list()) {
      if (entity is File) {
        // 复制文件
        await entity
            .copy('${destination.path}/${entity.uri.pathSegments.last}');
      } else if (entity is Directory) {
        // 递归复制子文件夹
        await entity.copyDirectory(
            Directory('${destination.path}/${entity.uri.pathSegments.last}'));
      }
    }
    return true;
  }
}

//endregion Directory 扩展

extension FileListEx on List<FileSystemEntity> {
  /// 是否包含指定文件
  /// [file] 支持[String].[FileSystemEntity]
  bool containsFile(dynamic file) {
    return firstWhereOrNull((element) {
          final filePath =
              file is FileSystemEntity ? file.path : file?.toString();
          return element.path == filePath;
        }) !=
        null;
  }

  /// 移除指定文件
  /// [file] 支持[String].[FileSystemEntity]
  void removeFile(dynamic file) {
    removeWhere((element) {
      final filePath = file is FileSystemEntity ? file.path : file?.toString();
      return element.path == filePath;
    });
  }

  /// 排序文件列表 asc:升序 desc:降序
  /// [folderFront] 文件夹放在前面
  /// [modifiedTimeDesc] 按照修改时间降序, 二选一
  /// [filenameDesc] 按照文件名降序, 二选一
  List<FileSystemEntity> sortFileList({
    bool? folderFront = true,
    bool? filenameDesc,
    bool? modifiedTimeDesc,
  }) {
    //-1 0 1 , 从小到大
    sort((a, b) {
      //debugger();
      if (folderFront != null) {
        //文件夹需要前后排序
        if (a.isDirectorySync() && b.isFileSync()) {
          return folderFront == true ? -1 : 1;
        } else if (a.isFileSync() && b.isDirectorySync()) {
          return folderFront == true ? 1 : -1;
        }
      }
      if (filenameDesc != null) {
        final r = a.path.compareTo(b.path);
        if (filenameDesc == true) {
          //文件名降序
          return -r;
        }
        return r;
      } else if (modifiedTimeDesc != null) {
        final r = a.lastModifiedSync
                ?.compareTo(b.lastModifiedSync ?? DateTime.now()) ??
            0;
        if (modifiedTimeDesc == true) {
          //修改时间降序
          return -r;
        }
      }
      return 0;
    });
    return this;
  }
}

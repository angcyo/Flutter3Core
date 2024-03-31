part of '../../flutter3_basics.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/03/31
///

/// https://api.dart.dev/stable/3.2.0/dart-io/dart-io-library.html
/// https://api.dart.dev/stable/3.2.0/dart-io/Process-class.html
/// https://pub.dev/packages/uri_to_file
extension FileStringEx on String {
  //region ---Path---

  /// 转换成文件夹对象
  Directory get folder => Directory(this);

  /// 确保文件夹存在, 如果不存在, 则创建
  Directory ensureDirectory() => Directory(this).ensureDirectory();

  /// 确保文件的文件夹目录存在, 如果不存在, 则创建
  Directory ensureParentDirectory() {
    return parentPath.ensureDirectory();
  }

  /// 父路径
  String get parentPath => FileSystemEntity.parentOf(this);

  /// 当前文件是否存在
  Future<bool> isExists() async => File(this).exists();

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

extension FileEx on File {
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

  /// 读取文件内容
  /// [loadAssetString]
  Future<String?> readString({Encoding encoding = utf8}) async {
    try {
      return await readAsString(encoding: encoding);
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
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
    bool flush = false,
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

  /// 文件的md5值
  String? md5() => readBytesSync()?.md5();

  String? sha1() => readBytesSync()?.sha1();

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

}

//endregion Directory 扩展

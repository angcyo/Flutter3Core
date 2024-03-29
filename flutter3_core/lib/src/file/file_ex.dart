part of '../../flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 保存屏幕截图
/// [filePath] 需要保存到的文件路径
/// [context] 截图来源, 默认是全屏
Future<UiImage?> saveScreenCapture([
  String? filePath,
  BuildContext? context,
  double pixelRatio = 1.0,
]) async {
  final path =
      (filePath ?? await cacheFilePath("ScreenCapture${nowTime()}.png"));
  var image = await (context ?? GlobalConfig.def.globalContext)
      ?.captureImage(pixelRatio: pixelRatio);
  image?.saveToFile(path.file());
  assert(() {
    l.d('屏幕截图保存至[${image?.width}*${image?.height}:$pixelRatio]->$path');
    return true;
  }());
  return image;
}

/// 获取一个files类型的文件夹
/// ```
/// WidgetsFlutterBinding.ensureInitialized(); //Binding has not yet been initialized.
/// ```
///[getApplicationDocumentsDirectory]
///[getApplicationCacheDirectory]
///
Future<Directory> fileDirectory() async {
  Directory? directory;
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // /storage/emulated/0/Android/data/com.angcyo.flutter3_abc/files
      try {
        directory = await getExternalStorageDirectory();
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        //l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/files
        directory = await getApplicationSupportDirectory();
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        //l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    assert(() {
      l.e(e);
      return true;
    }());
    //l.e(e);
  }
  return directory ?? Directory.systemTemp;
}

/// 获取一个cache类型的文件夹
/// ```
/// WidgetsFlutterBinding.ensureInitialized(); //Binding has not yet been initialized.
/// ```
///
Future<Directory> cacheDirectory() async {
  Directory? directory;
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // /storage/emulated/0/Android/data/com.angcyo.flutter3_abc/cache
      try {
        directory = (await getExternalCacheDirectories())?.firstOrNull;
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        //l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/cache
        directory = await getTemporaryDirectory();
      } catch (e) {
        assert(() {
          l.e(e);
          return true;
        }());
        //l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    assert(() {
      l.e(e);
      return true;
    }());
    //l.e(e);
  }
  return directory ?? Directory.systemTemp;
}

extension FileEx on File {
  /// 文件大小
  int fileSizeSync() {
    if (existsSync()) {
      return lengthSync();
    }
    return 0;
  }

  /// 文件大小
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
    ImageByteFormat format = ImageByteFormat.png,
  }) async {
    if (image == null) {
      return null;
    }
    return image.saveToFile(this, format: format);
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
      if (path.isDirectorySync()) {
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
}

extension DirectoryEx on Directory {
  /// 枚举所有文件, 并按照文件夹, 文件的顺序返回
  /// [sort] 是否排序
  /// [throwError] 是否抛出异常
  /// [PathAccessException]
  List<FileSystemEntity>? listFilesSync({
    bool recursive = false,
    bool followLinks = false,
    bool sort = true,
    bool throwError = false,
  }) {
    try {
      //2024-3-26`listSync`偶尔会返回数据空
      final list = listSync(
        recursive: recursive,
        followLinks: followLinks,
      );
      assert(() {
        l.d('listFilesSync->$path:${list.length}');
        return true;
      }());
      if (!sort) {
        return list;
      }
      //文件夹在前, 文件在后
      list.sort((a, b) {
        if (a.path.isDirectorySync() && b.path.isFileSync()) {
          return -1;
        } else if (a.path.isFileSync() && b.path.isDirectorySync()) {
          return 1;
        }
        return a.path.fileName().compareTo(b.path.fileName());
      });
      return list;
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
      if (throwError) {
        rethrow;
      }
    }
    return null;
  }
}

/// https://api.dart.dev/stable/3.2.0/dart-io/dart-io-library.html
/// https://api.dart.dev/stable/3.2.0/dart-io/Process-class.html
/// https://pub.dev/packages/uri_to_file
extension PathStringEx on String {
  /// 获取目录名称, 去掉了文件名的路径
  String dirname() => p.dirname(this);

  /// 获取文件名, 包含扩展名, 去掉路径
  /// [withoutExtension] 是否去掉扩展名
  /// [extension] 获取文件扩展名
  String basename([bool withoutExtension = false]) =>
      withoutExtension ? p.basenameWithoutExtension(this) : p.basename(this);

  /// 获取扩展名
  /// [includeDot] 是否包含.本身
  /// [extension] 获取文件扩展名
  String exName([bool includeDot = false]) {
    var ex = extension();
    if (includeDot || !ex.startsWith(".")) {
      return ex;
    }
    return ex.substring(1);
  }

  /// 获取文件扩展名, 包含.本身
  /// 统一输出小写
  /// [level] 扩展名的级别, 要获取多少个点后面的内容
  String extension([int level = 1]) => p.extension(this, level).toLowerCase();

  /// [dirname]
  String folderPath() => dirname();

  /// 包含扩展名的文件名
  /// [basename]
  String fileName([bool withoutExtension = false]) =>
      basename(withoutExtension);

  /// 父路径
  String get parentPath => FileSystemEntity.parentOf(this);

  /// 分割路径
  List<String> splitPath() => p.split(this);

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

  /// 获取一个对应平台的文件路径
  /// [this] 文件名
  /// [subFolder] 子文件夹, 不包含根目录
  Future<String> filePathOf([String? subFolder]) async {
    var folderPath = await fileFolderPath();
    if (subFolder == null) {
      subFolder = folderPath;
    } else {
      subFolder = p.join(folderPath, subFolder);
    }
    subFolder.ensureDirectory();
    var filePath = p.join(subFolder, this);
    return filePath;
  }

  /// 通过[part1]...[part15]拼接路径
  /// ```
  /// var context = p.Context(style: Style.windows);
  /// context.join('directory', 'file.txt');
  /// ```
  /// https://pub.dev/packages/path
  String join(String part1,
      [String? part2,
      String? part3,
      String? part4,
      String? part5,
      String? part6,
      String? part7,
      String? part8,
      String? part9,
      String? part10,
      String? part11,
      String? part12,
      String? part13,
      String? part14,
      String? part15]) {
    return p.join(
      this,
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
    );
  }
}

/// https://api.dart.dev/stable/3.2.0/dart-io/dart-io-library.html
/// 文件扩展操作
extension FilePathEx on String {
  /// 确保文件夹存在, 如果不存在, 则创建
  void ensureDirectory() {
    final dir = Directory(this);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// 确保文件的文件夹目录存在, 如果不存在, 则创建
  void ensureParentDirectory() {
    parentPath.ensureDirectory();
  }

  /// 转换成文件夹对象
  Directory get folder => Directory(this);

  /// 转换成文件对象
  /// 在web环境下, 会抛出异常
  /// `The argument type 'File/*1*/' can't be assigned to the parameter type 'File/*2*/'.`
  /// [name] 文件名, 如果指定了文件名, 则返回当前目录下的文件
  File file([String? name]) {
    String path = this;
    if (name != null) {
      path = p.join(this, name);
    }
    return isLocalUrl ? File.fromUri(path.toUri()!) : File(path);
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

  /// 删除文件或文件夹
  /// [recursive] 如果是文件夹,是否递归删除
  Future<bool> delete({bool recursive = false}) async {
    try {
      if (isFileSync()) {
        await file().delete();
        return true;
      }
      await folder.delete(recursive: recursive);
      return true;
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return false;
  }

  /// 同步删除
  /// [delete]
  bool deleteSync({bool recursive = false}) {
    try {
      if (isFileSync()) {
        file().deleteSync();
        return true;
      }
      folder.deleteSync(recursive: recursive);
      return true;
    } catch (e) {
      assert(() {
        l.e(e);
        return true;
      }());
    }
    return false;
  }
}

/// 快速获取一个文件类型的文件夹路径
/// [filePath]
Future<String> fileFolderPath([
  String? part1,
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
  String? part9,
  String? part10,
  String? part11,
  String? part12,
  String? part13,
  String? part14,
  String? part15,
]) async {
  var folder = (await fileDirectory()).path;
  if (part1 != null) {
    folder = p.join(
      folder,
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
    );
  }
  return folder..ensureDirectory();
}

/// 快速获取一个文件路径
/// [fileFolderPath]
Future<String> filePath(
  String fileName, [
  String? part1,
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
  String? part9,
  String? part10,
  String? part11,
  String? part12,
  String? part13,
  String? part14,
  String? part15,
]) async {
  var folder = await fileFolderPath(part1, part2, part3, part4, part5, part6,
      part7, part8, part9, part10, part11, part12, part13, part14, part15);
  return p.join(folder, fileName);
}

/// 快速获取一个缓存文件路径
/// [cacheFilePath]
Future<String> cacheFolderPath([
  String? part1,
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
  String? part9,
  String? part10,
  String? part11,
  String? part12,
  String? part13,
  String? part14,
  String? part15,
]) async {
  var folder = (await cacheDirectory()).path;
  if (part1 != null) {
    folder = p.join(
      folder,
      part1,
      part2,
      part3,
      part4,
      part5,
      part6,
      part7,
      part8,
      part9,
      part10,
      part11,
      part12,
      part13,
      part14,
      part15,
    );
  }
  return folder..ensureDirectory();
}

/// 快速获取一个缓存文件路径
/// [cacheFolderPath]
Future<String> cacheFilePath(
  String fileName, [
  String? part1,
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
  String? part9,
  String? part10,
  String? part11,
  String? part12,
  String? part13,
  String? part14,
  String? part15,
]) async {
  var folder = await cacheFolderPath(part1, part2, part3, part4, part5, part6,
      part7, part8, part9, part10, part11, part12, part13, part14, part15);
  return p.join(folder, fileName);
}

part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 保存屏幕截图
/// [filePath] 文件路径
/// [context] 截图来源, 默认是全屏
Future<UiImage?> saveScreenCapture([
  String? filePath,
  BuildContext? context,
]) async {
  var path = (filePath ?? await cacheFilePath("ScreenCapture${nowTime()}.png"));
  var image = await (context ?? GlobalConfig.def.globalContext)?.captureImage();
  image?.saveToFile(path.file());
  return image;
}

/// 获取一个files类型的文件夹
/// ```
/// WidgetsFlutterBinding.ensureInitialized(); //Binding has not yet been initialized.
/// ```
///
Future<Directory> fileDirectory() async {
  Directory? directory;
  try {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // /storage/emulated/0/Android/data/com.angcyo.flutter3_abc/files
      try {
        directory = await getExternalStorageDirectory();
      } catch (e) {
        print(e);
        //l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/files
        directory = await getApplicationSupportDirectory();
      } catch (e) {
        print(e);
        //l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    print(e);
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
        print(e);
        //l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/cache
        directory = await getTemporaryDirectory();
      } catch (e) {
        print(e);
        //l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    print(e);
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
      l.e(e);
    }
    return null;
  }

  /// 读取文件内容
  Uint8List? readBytesSync() {
    try {
      return readAsBytesSync();
    } catch (e) {
      l.e(e);
    }
    return null;
  }

  /// 读取文件内容
  /// [loadAssetString]
  Future<String?> readString({Encoding encoding = utf8}) async {
    try {
      return await readAsString(encoding: encoding);
    } catch (e) {
      l.e(e);
    }
    return null;
  }

  /// 读取文件内容
  String? readStringSync({Encoding encoding = utf8}) {
    try {
      return readAsStringSync(encoding: encoding);
    } catch (e) {
      l.e(e);
    }
    return null;
  }

  /// 读取文件内容
  Future<List<String>?> readLines({Encoding encoding = utf8}) async {
    try {
      return await readAsLines(encoding: encoding);
    } catch (e) {
      l.e(e);
    }
    return null;
  }

  /// 读取文件内容
  List<String>? readLinesSync({Encoding encoding = utf8}) {
    try {
      return readAsLinesSync(encoding: encoding);
    } catch (e) {
      l.e(e);
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
      l.e(e);
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
      l.e(e);
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
      l.e(e);
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
      l.e(e);
    }
    return null;
  }

  /// 文件的md5值
  String? md5() => readBytesSync()?.md5();

  String? sha1() => readBytesSync()?.sha1();
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
  String extension([int level = 1]) => p.extension(this, level);

  /// [dirname]
  String folderPath() => dirname();

  /// [basename]
  String fileName([bool withoutExtension = false]) =>
      basename(withoutExtension);

  /// 父路径
  String parentPath() => FileSystemEntity.parentOf(this);

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
    var dir = Directory(this);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// 确保文件的文件夹目录存在, 如果不存在, 则创建
  void ensureFileDirectory() {
    parentPath().ensureDirectory();
  }

  /// 转换成文件对象
  File file() => isLocalUrl ? File.fromUri(toUri()!) : File(this);

  /// 获取文件夹中的文件列表
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
      l.e(e);
    }
    return null;
  }
}

/// 快速获取一个文件类型的文件夹路径
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

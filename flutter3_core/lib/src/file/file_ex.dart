part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

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
        l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/files
        directory = await getApplicationSupportDirectory();
      } catch (e) {
        l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    l.e(e);
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
        l.e(e);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        // /data/user/0/com.angcyo.flutter3_abc/cache
        directory = await getTemporaryDirectory();
      } catch (e) {
        l.e(e);
      }
    }
    directory ??= await getTemporaryDirectory();
  } catch (e) {
    l.e(e);
  }
  return directory ?? Directory.systemTemp;
}

/// https://api.dart.dev/stable/3.2.0/dart-io/dart-io-library.html
/// https://api.dart.dev/stable/3.2.0/dart-io/Process-class.html
extension PathStringEx on String {
  /// 获取目录名称, 去掉了文件名的路径
  String dirname() => p.dirname(this);

  /// 父路径
  String parentPath() => FileSystemEntity.parentOf(this);

  /// 分割路径
  List<String> splitPath() => p.split(this);

  /// 获取文件扩展名, 包含.本身
  String extension([int level = 1]) => p.extension(this, level);

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

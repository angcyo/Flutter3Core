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

extension DirectoryPubEx on Directory {
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
/// 文件扩展操作
extension FileStringPubEx on String {
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

  /// 分割路径
  List<String> splitPath() => p.split(this);

  /// 获取一个对应平台的文件路径
  /// [this] 文件名
  /// [subFolder] 子文件夹, 不包含根目录
  /// [useCacheFolder] 是否使用缓存文件夹
  Future<String> filePathOf(
      [String? subFolder, bool useCacheFolder = false]) async {
    var folderPath =
        useCacheFolder ? (await cacheFolder()).path : (await fileFolder()).path;
    if (subFolder == null) {
      subFolder = folderPath;
    } else {
      subFolder = p.join(folderPath, subFolder);
    }
    subFolder.ensureDirectory();
    final filePath = p.join(subFolder, this);
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

  /// 获取一个自身路径对应的文件对象
  /// 在web环境下, 会抛出异常
  /// `The argument type 'File/*1*/' can't be assigned to the parameter type 'File/*2*/'.`
  /// [fileName] 文件名, 如果指定了文件名, 则自身就是文件夹路径,并返回当前目录下的文件
  /// [parentPath] 父路径, 如果指定了父路径, 则自身就是文件名,并返回父路径下的文件
  File file({
    String? fileName,
    String? parentPath,
  }) {
    String path = this;
    if (fileName != null) {
      path = p.join(this, fileName);
    } else if (parentPath != null) {
      path = p.join(parentPath, this);
    }
    return isLocalUrl ? File.fromUri(path.toUri()!) : File(path);
  }

  /// 2024-03-31
  File file2({
    String? fileName,
    String? parentPath,
  }) =>
      file(fileName: fileName, parentPath: parentPath);

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

//---

/// 快速获取一个文件类型的文件夹路径, 会自动创建文件夹
/// [filePath]
/// [cacheFolder]
Future<Directory> fileFolder([
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
  return folder.ensureDirectory();
}

/// 快速获取一个文件路径, 会自动创建文件夹
/// [fileFolder]
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
  var folder = await fileFolder(part1, part2, part3, part4, part5, part6, part7,
      part8, part9, part10, part11, part12, part13, part14, part15);
  return p.join(folder.path, fileName);
}

/// 快速获取一个缓存文件路径, 会自动创建文件夹
/// [cacheFilePath]
Future<Directory> cacheFolder([
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
  return folder.ensureDirectory();
}

/// 快速获取一个缓存文件路径, 会自动创建文件夹
/// [cacheFolder]
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
  var folder = await cacheFolder(part1, part2, part3, part4, part5, part6,
      part7, part8, part9, part10, part11, part12, part13, part14, part15);
  return p.join(folder.path, fileName);
}

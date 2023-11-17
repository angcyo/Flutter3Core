part of flutter3_core;

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/17
///

/// 获取一个files类型的文件夹
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

extension PathStringEx on String {
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

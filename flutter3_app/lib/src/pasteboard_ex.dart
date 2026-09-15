import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:pasteboard/pasteboard.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/15
///
/// 允许从剪贴板读取图像和文件，以及向剪贴板写入文件。

/// 读取剪切板中的图像
/// available on iOS, Desktop, Web, Android
Future<UiImage?> get $pasteboardImage async {
  final imageBytes = await Pasteboard.image;
  //print(imageBytes?.length);
  return imageBytes?.toImage();
}

/// 写入剪切板中的图像
/// available on iOS, Android, Web
/// - Windows 测试有效
Future<bool> $setPasteboardImage(UiImage? image) async {
  try {
    if (image != null) {
      await Pasteboard.writeImage(await image.toBytes());
    } else {
      await Pasteboard.writeImage(null);
    }
    return true;
  } catch (e) {
    assert(() {
      l.e(e);
      return true;
    }());
    return false;
  }
}

/// 读取剪切板中的文件路径
/// available on Desktop, Android.
/// - Windows 测试有效
Future<List<String>> get $pasteboardFiles async {
  final files = await Pasteboard.files();
  //print(imageBytes?.length);
  return files;
}

/// 写入剪切板中的文件路径
/// Only available on desktop platforms.
Future<bool> $setPasteboardFiles(List<String>? files) async {
  try {
    if (files != null) {
      await Pasteboard.writeFiles(files);
      return true;
    }
    return false;
  } catch (e) {
    assert(() {
      l.e(e);
      return true;
    }());
    return false;
  }
}

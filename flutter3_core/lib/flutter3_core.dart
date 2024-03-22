library flutter3_core;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_core/assets_generated/assets.gen.dart';
import 'package:flutter3_core/src/isar/isar_test_collection.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:path/path.dart' as p;

import 'flutter3_core.dart';

export 'package:cross_file/cross_file.dart';
export 'package:flutter3_basics/flutter3_basics.dart';
export 'package:flutter3_http/flutter3_http.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:isar/isar.dart';
export 'package:isar_flutter_libs/isar_flutter_libs.dart';
export 'package:mime/mime.dart';
export 'package:path_provider/path_provider.dart';
export 'package:provider/provider.dart';

export 'src/view_model/jetpack/livedata.dart';
export 'src/view_model/jetpack/viewmodel.dart';

part 'src/core/svg_core.dart';
part 'src/dialog/number_keyboard_dialog.dart';
part 'src/file/app_lifecycle_log.dart';
part 'src/file/file_ex.dart';
part 'src/file/file_log.dart';
part 'src/file/file_type.dart';
part 'src/isar/hive/hive_ex.dart';
part 'src/isar/isar_ex.dart';
part 'src/view_model/mutable_live_data.dart';
part 'src/view_model/view_model_ex.dart';

/// 获取当前的工作目录
/// [Directory.current]
/// [Directory.systemTemp]
String get currentDirPath => p.current;

/// 初始化Flutter3核心库
Future<void> initFlutter3Core() async {
  // 写入文件fn
  GlobalConfig.def.writeFileFn = (fileName, folder, content) async {
    return "$content".appendToFile(
      fileName,
      folder: folder,
      limitLength: fileName.endsWith(kLogExtension),
    );
  };

  // 文件日志
  l.filePrint = (log) {
    GlobalConfig.def.writeFileFn
        ?.call(kLFileName, kLogPathName, log)
        .catchError((error) {
      debugPrint('写入文件调用失败: $error');
    });
  };

  //初始化isar数据库
  await openIsar();

  //初始化Hive数据库
  //Hive.registerAdapter(adapter)
  await Hive.initFlutterEx();
}

extension MimeEx on String {
  /// 是否是图片类型
  bool get isImageType => toLowerCase() == 'image';

  /// 获取文件的Mime类型
  /// ```
  /// print(lookupMimeType('test.html')); // text/html
  ///
  /// print(lookupMimeType('test', headerBytes: [0xFF, 0xD8])); // image/jpeg
  ///
  /// print(lookupMimeType('test.html', headerBytes: [0xFF, 0xD8])); // image/jpeg
  ///
  /// ```
  String? mimeType({List<int>? headerBytes}) {
    final path = toUri()?.path ?? this;
    final mimeType = lookupMimeType(
      path,
      headerBytes: headerBytes,
    );
    if (mimeType == null) {
      return null;
    }
    return mimeType.split('/').firstOrNull;
  }

  ///判断当前是否是http/https网络地址
  bool get isHttpUrl {
    return startsWith('http://') || startsWith('https://');
  }

  ///判断当前是否是本地文件地址
  bool get isLocalUrl {
    return startsWith('file://');
  }

  ///判断当前字符串是否是文件路径
  bool get isFilePath {
    return File(this).existsSync();
  }

  /// 判断是否是svg
  bool get isSvg {
    return toUri()?.path.toLowerCase().endsWith('.svg') == true;
  }
}

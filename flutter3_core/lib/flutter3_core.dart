library flutter3_core;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_core/src/isar/isar_test_collection.dart';
import 'package:path/path.dart' as p;

import 'flutter3_core.dart';

export 'package:cross_file/cross_file.dart';
export 'package:flutter3_http/flutter3_http.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:isar/isar.dart';
export 'package:isar_flutter_libs/isar_flutter_libs.dart';
export 'package:jetpack/jetpack.dart';
export 'package:mime/mime.dart';
export 'package:path_provider/path_provider.dart';
export 'package:provider/provider.dart';

part 'src/file/app_lifecycle_log.dart';

part 'src/file/file_ex.dart';

part 'src/file/file_log.dart';

part 'src/isar/hive/hive_ex.dart';

part 'src/isar/isar_ex.dart';

part 'src/view_model/mutable_live_data.dart';

part 'src/view_model/view_model_ex.dart';

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
    final mimeType = lookupMimeType(
      this,
      headerBytes: headerBytes,
    );
    if (mimeType == null) {
      return null;
    }
    return mimeType.split('/').firstOrNull;
  }
}

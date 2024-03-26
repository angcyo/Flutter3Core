library flutter3_core;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter3_core/assets_generated/assets.gen.dart';
import 'package:flutter3_core/src/debug/debug_file_tiles.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:path/path.dart' as p;

import 'flutter3_core.dart';
import 'src/isar/isar_test_collection.dart';

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

part 'src/core/core_keys.dart';
part 'src/core/svg_core.dart';
part 'src/debug/debug_file_page.dart';
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

/// [Image].[StatefulWidget]
SvgPicture? loadCoreAssetSvgPicture(
  String? key, {
  String? prefix = 'assets/svg/',
  String? package = 'flutter3_core',
  BoxFit? fit,
  double? width,
  double? height,
  Color? color,
  UiColorFilter? colorFilter,
}) =>
    key == null
        ? null
        : SvgPicture.asset(
            key.ensurePackagePrefix(package, prefix),
            fit: fit ?? BoxFit.contain,
            width: width,
            height: height,
            colorFilter: colorFilter ?? color?.toColorFilter(),
          );

/// [Image].[StatefulWidget]
Image? loadCoreAssetImageWidget(
  String? key, {
  String? prefix = 'assets/png/',
  String? package = 'flutter3_core',
  BoxFit? fit,
  double? width,
  double? height,
  Color? color,
  BlendMode? colorBlendMode,
}) =>
    key == null
        ? null
        : Image.asset(
            key.ensurePackagePrefix(package, prefix),
            fit: fit,
            width: width,
            height: height,
            color: color,
            colorBlendMode: colorBlendMode,
          );

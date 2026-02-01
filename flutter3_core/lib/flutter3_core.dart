library flutter3_core;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3_core/assets_generated/assets.gen.dart';
import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter3_core/src/debug/debug_file_tiles.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as p;

import 'src/isar/isar_test_collection.dart';

export 'package:cross_file/cross_file.dart';
export 'package:flutter3_basics/flutter3_basics.dart';
export 'package:flutter3_http/flutter3_http.dart';
export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:isar_community/isar.dart'; //export 'package:isar_flutter_libs/isar_flutter_libs.dart';
export 'package:isar_community_flutter_libs/isar_flutter_libs.dart';
export 'package:mime/mime.dart';
export 'package:path_provider/path_provider.dart';
export 'package:provider/provider.dart';

export 'src/core/build_config.dart';
export 'src/debug/debug_overlay.dart';
export 'src/log/log_message_mix.dart';
export 'src/log/log_scope_widget.dart';
export 'src/process/process_shell.dart';
export 'src/view_model/jetpack/livedata.dart';
export 'src/view_model/jetpack/viewmodel.dart';

// @formatter:off

part 'src/core/core_keys.dart';
part 'src/core/hive_data_mix.dart';
part 'src/core/svg_core.dart';
part 'src/debug/core_debug.dart';
part 'src/debug/debug_file_mix.dart';
part 'src/debug/debug_file_page.dart';
part 'src/debug/debug_mix.dart';
part 'src/debug/debug_page.dart';
part 'src/debug/navigator_route_overlay.dart';
part 'src/debug/screen_capture_overlay.dart';
part 'src/dialog/number_keyboard_dialog.dart';
part 'src/dialog/options_dialog.dart';
part 'src/dialog/shortcut_dialog.dart';
part 'src/dialog/single_bottom_input_dialog.dart';
part 'src/dialog/single_image_dialog.dart';
part 'src/dialog/single_text_dialog.dart';
part 'src/dialog/wheel_dialog.dart';
part 'src/file/app_lifecycle_log.dart';
part 'src/file/config_file.dart';
part 'src/file/file_log.dart';
part 'src/file/file_pub_ex.dart';
part 'src/file/file_type.dart';
part 'src/isar/hive/hive_ex.dart';
part 'src/isar/hive/hive_string_value.dart';
part 'src/isar/isar_ex.dart';
part 'src/popup/slider_popup_dialog.dart';
part 'src/tiles/core_dialog_title.dart';
part 'src/tiles/label_number_slider_tile.dart';
part 'src/tiles/label_number_tile.dart';
part 'src/tiles/wheel_tile.dart';
part 'src/view_model/mutable_live_data.dart';
part 'src/view_model/view_model_ex.dart';

// @formatter:on

/// 获取当前的工作目录
/// [Directory.current]
/// [Directory.systemTemp]
String get currentDirPath => p.current;

/// 初始化Flutter3核心库
@initialize
@entryPoint
@CallFrom("runGlobalApp")
Future<void> initFlutter3Core() async {
  // 写入文件fn
  GlobalConfig.def.writeFileFn = (fileName, folder, content) async {
    return (await "$content".appendToFile(
      fileName: fileName,
      folder: folder,
      limitLength: fileName.endsWith(kLogExtension),
    )).path;
  };

  // 文件日志
  l.filePrint = (log) {
    GlobalConfig.def.writeFileFn
        ?.call(kLFileName, kLogPathName, log)
        .catchError((error) {
          debugPrint('写入文件调用失败: $error');
        });
  };

  //--
  testBasicsLibrary();
  /*postDelayCallback(() {
    testBasicsLibrary();
  }, 2.seconds);*/
}

/// 初始化hive
/// [RCoreException]
/// [ROccupiedException]
///
/// - [initHive]
/// - [initIsar]
@initialize
@entryPoint
@CallFrom("runGlobalApp")
Future<void> initHive() async {
  //初始化Hive数据库
  //Hive.registerAdapter(adapter)
  try {
    await Hive.initHive();
  } catch (e, s) {
    debugger(when: isDebug);
    final log = "初始化Hive数据库失败->$e";
    l.e(log);
    if (e is FileSystemException) {
      throw ROccupiedException(message: log, cause: e, stackTrace: s);
    } else {
      throw RCoreException(message: log, cause: e, stackTrace: s);
    }
  }

  //device uuid
  $coreKeys.initDeviceUuid();
}

/// 初始化Isar数据库, 初始化之前请先注册表结构
/// [registerIsarCollection]
///
/// [RCoreException]
/// [ROccupiedException]
///
/// - [initHive]
/// - [initIsar]
@initialize
@entryPoint
@CallFrom("runGlobalApp")
Future<void> initIsar() async {
  //初始化isar数据库
  try {
    await openIsar();
  } catch (e, s) {
    debugger(when: isDebug);
    final log = "初始化Isar数据库失败->$e";
    l.e(log);
    if (e is FileSystemException) {
      throw ROccupiedException(message: log, cause: e, stackTrace: s);
    } else {
      throw RCoreException(message: log, cause: e, stackTrace: s);
    }
  }
}

//--

/// [Image].[StatefulWidget]
SvgPicture? loadCoreAssetSvgPicture(
  String? key, {
  String? prefix = kDefAssetsSvgPrefix,
  String? package = 'flutter3_core',
  BoxFit? fit,
  double? size,
  double? width,
  double? height,
  UiColor? tintColor,
  UiColorFilter? colorFilter,
}) => key == null
    ? null
    : SvgPicture.asset(
        key.ensurePackagePrefix(package, prefix).transformKey(),
        fit: fit ?? BoxFit.contain,
        width: size ?? width,
        height: size ?? height,
        colorFilter: colorFilter ?? tintColor?.toColorFilter(),
      );

/// [loadAssetSvgWidget]
Widget loadCoreSvgWidget(
  String key, {
  String? prefix = kDefAssetsSvgPrefix,
  String? package = 'flutter3_core',
  Color? tintColor,
  UiColorFilter? colorFilter,
  BoxFit fit = BoxFit.contain,
  double? size,
  double? width,
  double? height,
}) => loadAssetSvgWidget(
  key,
  prefix: prefix,
  package: package,
  tintColor: tintColor,
  colorFilter: colorFilter,
  size: size,
  width: width,
  height: height,
  fit: fit,
);

/// 下一步svg图标
SvgPicture coreNextSvgPicture({
  BoxFit? fit,
  double? size,
  double? width,
  double? height,
  UiColor? tintColor,
  UiColorFilter? colorFilter,
}) => loadCoreAssetSvgPicture(
  Assets.svg.coreNext,
  fit: fit,
  size: size,
  width: width,
  height: height,
  tintColor: tintColor,
  colorFilter: colorFilter,
)!;

/// [Image].[StatefulWidget]
Image? loadCoreAssetImageWidget(
  String? key, {
  String? prefix = kDefAssetsPngPrefix,
  String? package = 'flutter3_core',
  BoxFit? fit,
  double? size,
  double? width,
  double? height,
  UiColor? color,
  UiBlendMode? colorBlendMode,
}) => key == null
    ? null
    : Image.asset(
        key.ensurePackagePrefix(package, prefix).transformKey(),
        fit: fit,
        width: size ?? width,
        height: size ?? height,
        color: color,
        colorBlendMode: colorBlendMode,
      );

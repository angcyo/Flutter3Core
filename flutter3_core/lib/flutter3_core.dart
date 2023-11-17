library flutter3_core;

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'flutter3_core.dart';

import 'package:path/path.dart' as p;

export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:isar/isar.dart';
export 'package:isar_flutter_libs/isar_flutter_libs.dart';
export 'package:jetpack/jetpack.dart';
export 'package:path_provider/path_provider.dart';
export 'package:provider/provider.dart';

part 'src/file/file_ex.dart';

part 'src/hive/hive_ex.dart';

part 'src/view_model/mutable_once_live_data.dart';

part 'src/view_model/view_model_ex.dart';

/// 初始化Flutter3核心库
Future<void> initFlutter3Core() async {
  //初始化Hive数据库
  await Hive.initFlutterEx();
}

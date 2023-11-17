library flutter3_core;

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter3_core/src/isar/isar_test_collection.dart';
import 'package:path/path.dart' as p;

import 'flutter3_core.dart';

export 'package:flutter3_widgets/flutter3_widgets.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:isar/isar.dart';
export 'package:isar_flutter_libs/isar_flutter_libs.dart';
export 'package:jetpack/jetpack.dart';
export 'package:path_provider/path_provider.dart';
export 'package:provider/provider.dart';

part 'src/file/file_ex.dart';

part 'src/isar/hive/hive_ex.dart';

part 'src/isar/isar_ex.dart';

part 'src/view_model/mutable_once_live_data.dart';

part 'src/view_model/view_model_ex.dart';

/// 初始化Flutter3核心库
Future<void> initFlutter3Core() async {
  //初始化isar数据库
  await openIsar();

  //初始化Hive数据库
  //Hive.registerAdapter(adapter)
  await Hive.initFlutterEx();
}

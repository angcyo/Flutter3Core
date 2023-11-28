import 'dart:io';

import 'package:flutter3_core/flutter3_core.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @since 2023/11/28
///

class TestBean {
  String? name = "name";
  int? age = 99;
}

/// 初始化之前调用, 还未[ensureInitialized]
/// [runApp]
@callPoint
@testPoint
Future<void> testRunBefore() async {
  //await _testProcess();
}

/// 初始化之后调用
/// [runApp]
@callPoint
@testPoint
Future<void> testRunAfter() async {
  //await _testApp();
  //await testFile();
}

@testPoint
Future<void> _testApp() async {
  await "key-int".hivePut(1);
  await "key-bool".hivePut(true);
  await "key-string".hivePut("~false~");
  await "key-list".hivePut([1, 2, 3]);
  await "key-map".hivePut({"a": 1, "b": 2, "c": "c"});
  //await "key-bean".hivePut(TestBean());
}

@testPoint
Future<void> _testProcess() async {
  // List all files in the current directory in UNIX-like systems.
  var result = await Process.run('ls', ['-l']);
  l.i("Process[${result.pid}]:${result.exitCode}");
  l.i("Process Result->${result.stdout}");
}

@testPoint
Future<void> _testFile() async {
  (await cacheFilePath("cache.log", "f1", "f2"))
      .writeString("${nowTimeString()}\nangcyo~", mode: FileMode.append);
  (await filePath("file.log", "f1", "f2"))
      .writeString("${nowTimeString()}\nangcyo~", mode: FileMode.append);
  delayCallback(() async => await saveScreenCapture());
}

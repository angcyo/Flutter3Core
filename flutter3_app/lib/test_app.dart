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

  // Binding has not yet been initialized.
  // MissingPluginException(No implementation found for method test on channel com.angcyo)
  /*const MethodChannel("com.angcyo").invokeMethod("test").get((value, error) {
    debugger();
  });*/
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
      .file()
      .writeString("${nowTimeString()}\nangcyo~", mode: FileMode.append);
  (await filePath("file.log", "f1", "f2"))
      .file()
      .writeString("${nowTimeString()}\nangcyo~", mode: FileMode.append);
  delayCallback(() async => await saveScreenCapture());
}

///
/// ```
/// 循环200000000次:19999999900000000, 耗时:580ms
/// 循环300000000次:44999999850000000, 耗时:854ms
/// 循环400000000次:79999999800000000, 耗时:1s124ms
/// 循环500000000次:124999999750000000, 耗时:1s538ms
/// 循环600000000次:179999999700000000, 耗时:1s868ms
/// 循环700000000次:244999999650000000, 耗时:2s162ms
/// 循环800000000次:319999999600000000, 耗时:2s476ms
/// 循环900000000次:404999999550000000, 耗时:2s806ms
/// 循环1000000000次:499999999500000000, 耗时:3s131ms
/// 循环1100000000次:604999999450000000, 耗时:3s709ms
///
/// 循环200000000次:19999999900000000, 耗时:629ms
/// 循环300000000次:44999999850000000, 耗时:910ms
/// 循环400000000次:79999999800000000, 耗时:1s406ms
/// 循环500000000次:124999999750000000, 耗时:1s502ms
/// 循环600000000次:179999999700000000, 耗时:1s834ms
/// 循环700000000次:244999999650000000, 耗时:2s115ms
/// 循环800000000次:319999999600000000, 耗时:2s448ms
/// 循环900000000次:404999999550000000, 耗时:2s730ms
/// 循环1000000000次:499999999500000000, 耗时:3s94ms
/// 循环1100000000次:604999999450000000, 耗时:3s695ms
///
/// 循环200000000次:19999999900000000, 耗时:1s289ms
/// 循环300000000次:44999999850000000, 耗时:1s826ms
/// 循环400000000次:79999999800000000, 耗时:1s599ms
/// 循环500000000次:124999999750000000, 耗时:2s274ms
/// 循环600000000次:179999999700000000, 耗时:2s759ms
/// 循环700000000次:244999999650000000, 耗时:2s773ms
/// 循环800000000次:319999999600000000, 耗时:3s233ms
/// 循环900000000次:404999999550000000, 耗时:3s568ms
/// 循环1000000000次:499999999500000000, 耗时:4s77ms
/// 循环1100000000次:604999999450000000, 耗时:4s659ms
/// ```
///
@testPoint
void testTime() {
  assert(() {
    var c = 0;
    while (c++ < 10) {
      lTime.tick();
      int count = 10000000 * 10 * (c + 1);
      var sum = 0;
      for (int i = 0; i < count; i++) {
        sum += i;
      }
      l.i('循环$count次:$sum, 耗时:${lTime.time()}');
    }
    return true;
  }());
}

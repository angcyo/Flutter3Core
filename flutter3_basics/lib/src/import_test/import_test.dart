///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/16
///
/// # isolates.dart
/// ```
/// import '_isolates_io.dart' if (dart.library.js_util) '_isolates_web.dart' as isolates;
/// ```
import 'dart:developer';

import '_import_ios.dart' if (Platform.isAndroid) '_import_android.dart'
    deferred as import_test;

import '_import_deferred.dart' deferred as import_test_deferred;

/// 测试导入
void importTest() async {
  await import_test.loadLibrary();
  final testName = import_test.testImportName();
  print("testImportName->$testName");
  debugger();

  //Deferred library import_test_deferred was not loaded.
  await import_test_deferred.loadLibrary();
  final testName2 = import_test_deferred.testDeferredImportName();
  print("testDeferredImportName->$testName2");
  debugger();
}

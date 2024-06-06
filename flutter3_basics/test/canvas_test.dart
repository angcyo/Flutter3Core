import 'dart:io';
import 'dart:ui';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/06
///

void main() {
  test('test canvas', () async {
    final image = drawImageSync(const Size(100, 100), (canvas) {});
    await image.saveToFile(outputFile('canvas_test.png'));
    consoleLog('...end');
  });
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  consoleLog('path:$path');
  return File(path);
}

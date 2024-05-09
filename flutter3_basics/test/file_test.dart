import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/09
///

void main() {
  test('file test', () async {
    final file = File('test/file_test.dart');
    consoleLog(file.readLastStringSync(100));

    /*final accessFile = await file.open();

    accessFile.setPositionSync(accessFile.lengthSync() - 100);
    consoleLog(accessFile.readSync(100).toStr().lines().reversed.join('\n'));

    consoleLog(accessFile.positionSync());
    consoleLog(accessFile.lengthSync());*/

    /*final lines = await file.readAsLines();
    consoleLog(lines);*/
  });
}

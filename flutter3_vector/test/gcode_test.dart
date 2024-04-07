import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/07
///

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  test('test gcode', () {
    final size = 10.toDpFromMm();
    final rect = Rect.fromLTWH(size, size, size, size);
    final path = Path();
    path.addOval(rect);

    final path2 = Path();
    path2.addRect(rect);

    final pathList = <Path>[];
    //pathList.add(path);
    pathList.add(path2);

    GCodeWriteHandle handle = GCodeWriteHandle();
    handle.useCutData = true;

    consoleLog(pathList.toGCodeString(
      handle: handle,
      isAutoLaser: false,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ));
    consoleLog('...');
    return true;
  });
}

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

    final linePath = Path();
    linePath.moveTo(0, 0);
    linePath.lineTo(size, size);

    final pathList = <Path>[];
    pathList.add(path);
    pathList.add(path2);
    pathList.add(linePath);

    GCodeWriteHandle handle = GCodeWriteHandle();
    handle.useCutData = false;

    consoleLog(pathList.toGCodeString(
      handle: handle,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ));
    consoleLog('...');
    return true;
  });
}

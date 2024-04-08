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
  test('test gcode', () async {
    final size = 10.toDpFromMm();
    final rect = Rect.fromLTWH(size, size, size, size);
    final ovalPath = Path();
    ovalPath.addOval(rect);

    final rectPath = Path();
    rectPath.addRect(rect);

    final linePath = Path();
    linePath.moveTo(0, 0);
    linePath.lineTo(size, size);

    final pathList = <Path>[];
    pathList.add(ovalPath);
    //pathList.add(rectPath);
    //pathList.add(linePath);

    GCodeWriteHandle handle = GCodeWriteHandle();
    handle.useCutData = false;

    /* consoleLog(pathList.toGCodeString(
      handle: handle,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ));*/

    final gcode = pathList.toGCodeString(
      handle: handle,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ); //"G0X10Y10\n;start\nG1X20Y20\n";
    GCodeParser parser = GCodeParser();
    final gcodePath = parser.parse(gcode);

    handle.stringBuffer = StringBuffer();
    final resultGCode = gcodePath?.toGCodeString(
      handle: handle,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ); //"G0X10Y10\n;start\nG1X20Y20\n";
    /*final base64 = await gcodePath?.ofList<Path>().toUiImageBase64();
    consoleLog(base64);*/

    consoleLog(gcode);
    consoleLog('new↓');
    consoleLog(resultGCode);

    consoleLog('...');
    return true;
  });
}

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
  /*test('test gcode', () async {
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

    */ /* consoleLog(pathList.toGCodeString(
      handle: handle,
      header: kGCodeHeader,
      power: 255,
      speed: 12000,
    ));*/ /*

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
    */ /*final base64 = await gcodePath?.ofList<Path>().toUiImageBase64();
    consoleLog(base64);*/ /*

    consoleLog(gcode);
    consoleLog('new↓');
    consoleLog(resultGCode);

    consoleLog('...');
    return true;
  });*/

  test('test gcode parse', () {
    const gcode = '''
M05 S0
G90
G21
G1 F1500
G1  X-0.5292 Y2.1167
G4 P0 
M03 S255
G4 P0
G1 F300.000000
G3 X-2.0416 Y-0.8433 I0.6945 J-2.2212
G3 X0.8426 Y-2.3259 I2.2021 J0.7372
G3 X2.3995 Y0.5286 I-0.6836 J2.2247
G3 X-0.5292 Y2.1167 I-2.2357 J-0.6284
G1  X-0.5292 Y2.1167
''';

    GCodeParser parser = GCodeParser();
    final gcodePath = parser.parse(gcode);

    consoleLog(gcodePath?.toGCodeString());
    consoleLog('...');
    return true;
  });
}

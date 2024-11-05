import 'dart:io';

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
  //await File("./test.log").writeAsString("angcyo");
  //outputFile("test.log").writeAsString("angcyo", mode: FileMode.write);

  lTime.tick();
  //testOutputGCode();
  //testOutputCutGCode();
  //testOutputPoint();

  test('test gcode', () {
    outputGCode();
  });

  print("...end:${lTime.time()}");
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  return File(path);
}

/// 获取路径列表
List<Path> getPathList() {
  final size = 10.0 /*10.toDpFromMm()*/;
  final rect = Rect.fromLTWH(size, size, size, size);
  final ovalPath = Path();
  ovalPath.addOval(rect);

  final rectPath = Path();
  rectPath.addRect(rect);

  final linePath = Path();
  linePath.moveTo(0, 0);
  linePath.lineTo(size, size);

  final pathList = <Path>[];
  // pathList.add(ovalPath);
  pathList.add(rectPath);
  //pathList.add(linePath);

  return pathList;
}

String getGCodeString() {
  const gcode = '''
M5 S0
G90
G21
G1 F1500
G1  X-0.5292 Y2.1167
G4 P0 
M3 S255
G4 P0
G1 F300.000000
G3 X-2.0416 Y-0.8433 I0.6945 J-2.2212
G3 X0.8426 Y-2.3259 I2.2021 J0.7372
G3 X2.3995 Y0.5286 I-0.6836 J2.2247
G3 X-0.5292 Y2.1167 I-2.2357 J-0.6284
G1  X-0.5292 Y2.1167
''';
  return gcode;
}

@testPoint
void testOutputGCode() async {
  final pathList = getPathList();

  GCodeWriteHandle handle = GCodeWriteHandle();
  handle.useCutData = false;

  consoleLog(pathList.toGCodeString(
    handle: handle,
    header: kGCodeHeader,
    power: 255,
    speed: 12000,
  ));

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
  );

  //"G0X10Y10\n;start\nG1X20Y20\n";
  final base64 = await gcodePath?.ofList<Path>().toUiImageBase64();
  consoleLog(base64);

  consoleLog(gcode);
  consoleLog('new↓');
  consoleLog(resultGCode);

  consoleLog('...');
}

@testPoint
void testOutputCutGCode() {
  final pathList = getPathList();
  GCodeWriteHandle handle = GCodeWriteHandle();
  handle.unit = null;

  handle.useCutData = true;
  handle.cutDataLoopCount = 1;

  PointWriteHandle pointHandle = PointWriteHandle();
  pointHandle.unit = handle.unit;
  pointHandle.digits = 0;
  handle.parentWriteHandle = pointHandle;

  //--
  final gcode = pathList.toGCodeString(
    handle: handle,
    power: 255,
    speed: 12000,
  );
  outputFile("gcode_cut.nc").writeString(gcode!);

  //--
  final pointList = pointHandle.pointList;
  final file = outputFile("gcode_point_list.log");
  file.writeAsStringSync(""); //清空文件
  for (final point in pointList ?? []) {
    //N段折现
    for (final p in point) {
      //N个点
      file.writeAsStringSync("${p.x},${p.y} ", mode: FileMode.append);
    }
    file.writeAsStringSync("\n", mode: FileMode.append);
  }
}

@testPoint
void testParseGCode() {
  final gcode = getGCodeString();

  GCodeParser parser = GCodeParser();
  final gcodePath = parser.parse(gcode);

  consoleLog(gcodePath?.toGCodeString());
  consoleLog('...');
}

@testPoint
void testOutputPoint() {
  final pathList = getPathList();
  PointWriteHandle handle = PointWriteHandle();
  final pointList = pathList.toPointList(handle: handle, unit: null, precision: 0);
  final file = outputFile("point_list.log");
  file.writeAsStringSync(""); //清空文件
  for (final point in pointList ?? []) {
    //N段折现
    for (final p in point) {
      //N个点
      file.writeAsStringSync("${p.x},${p.y} ", mode: FileMode.append);
    }
    file.writeAsStringSync("\n", mode: FileMode.append);
  }
}

@testPoint
void outputGCode() {
  const xCount = 10;
  const yCount = 10;
  @mm
  const step = 0.8 * 10;

  @mm
  const cx = 80.0;
  @mm
  const cy = 80.0;

  const left = cx - xCount * step / 2;
  const top = cy - yCount * step / 2;
  const right = cx + xCount * step / 2;
  const bottom = cy + yCount * step / 2;

  final buffer = StringBuffer();
  buffer.write(kGCodeAutoHeader);

  //一行一行
  for (var y = 0; y <= yCount; y++) {
    final t = top + y * step;
    buffer.writeln("G0 X$left Y$t");
    buffer.writeln("G1 X$right Y$t S255 F12000");
  }

  //一列一列
  for (var x = 0; x <= xCount; x++) {
    final l = left + x * step;
    buffer.writeln("G0 X$l Y$top");
    buffer.writeln("G1 X$l Y$bottom S255 F12000");
  }

  buffer.write(kGCodeFooter);

  outputFile("gcode_auto.nc").writeString(buffer.toString());
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';

void main() async {
  /*test('adds one to input values', () {
    final calculator = Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });*/
  //print(1.toDpFromMm());
  //print(0.25.toDpFromMm());

  WidgetsFlutterBinding.ensureInitialized();
  //testPath();
  //testCircle();
  //testLine();

  await testSvg();

  assert(true);
}

void testPath() {
  final circlePath = Path()
    ..addOval(Rect.fromCircle(center: const Offset(100, 100), radius: 100));

  final arcPath = Path()
    ..addArc(const Rect.fromLTWH(0, 0, 100, 20), 0.toRadians, -360.toRadians);

  final rectPath = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 100));

  final testPath = rectPath;
  consoleLog(testPath.toSvgPathString());
  print(lineSeparator);
  consoleLog(testPath.toGCodeString());
  print(lineSeparator);
  consoleLog(testPath.toPathPointJsonString());

  print(lineSeparator);
  consoleLog(testPath.toPointList());
}

void testCircle() {
  final a = Offset(0, 0);
  final b = Offset(100, 0);
  final c = Offset(50, 50);
  final cc = centerOfCircle(a, b, c);
  print(cc);
}

void testLine() {
  Path path = Path()
    ..moveTo(10, 10)
    ..lineTo(100, 100);
  path = path.moveToZero(width: 50);
  print(path.toSvgPathString());
}

Future testSvg() async {
  //当前目录
  final svg1 = File('${Directory.current.path}/test/star_10_100.svg');
  final svg2 = File('${Directory.current.path}/test/star_45_10_100.svg');
  final svgImage = File('${Directory.current.path}/test/svg_image.svg');
  consoleLog(Directory.current.path);

  final svgString = svgImage.readAsStringSync();

  //consoleLog(svgString);
  final response = await decodeSvgString(svgString);
  consoleLog(response);
}

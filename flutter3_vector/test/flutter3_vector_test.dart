import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:xml/xpath.dart';

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
  //testStringScanner();

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
  final xcsImage = File('./test/xcs_image.svg');
  consoleLog(Directory.current.path);

  final svgString = xcsImage.readAsStringSync();

  //consoleLog(svgString);
  final response = await decodeSvgString(
    svgString,
    listener: SvgListener()
      ..onDrawElement = (element, data, paint, bounds, matrix) {
        consoleLog('${element.runtimeType} $bounds $data');
      },
  );
  //等待5秒
  //await Future.delayed(const Duration(seconds: 5));
  consoleLog(response);
}

void testStringScanner() {
  final svgImage = File('${Directory.current.path}/test/svg_image.svg');
  final svgString = svgImage.readAsStringSync();

  final document = XmlDocument.parse(svgString);
  consoleLog(document.findElements("svg").firstOrNull?.getAttribute("width"));
  consoleLog(document.xpath("svg").firstOrNull?.getAttribute("width"));
  consoleLog(document.xpath("svg").firstOrNull?.getAttribute("height2"));

  final scanner = StringScanner(svgString);

  // 扫描并提取字符串中的单词和数字
  /*while (!scanner.isDone) {
    if (scanner.scan(RegExp(r'\w+'))) {
      print('Word: ${scanner.lastMatch?[0]}');
    } else if (scanner.scan(RegExp(r'\d+'))) {
      print('Number: ${scanner.lastMatch?[0]}');
    } else {
      //scanner.expect(' '); // 跳过空格
      //scanner.expectDone();
      consoleLog(String.fromCharCode(scanner.readChar()));
    }
  }*/

  /*consoleLog(scanner.position);
  consoleLog('1'.codeUnitAt(0));
  consoleLog(scanner.scan('width='));
  consoleLog(scanner.scanChar('1'.codeUnitAt(0)));
  consoleLog(scanner.rest);*/
}

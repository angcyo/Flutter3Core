import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter3_vector/flutter3_vector.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/07/05
///
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    final svg = await svgBuilder((builder) async {
      builder.writeViewBox(Offset.zero & const Size(200.0, 200.0));
      builder.writeRect(width: 20, height: 10, transform: Matrix4.identity());
      builder.writeRect(
        width: 20,
        height: 10,
        rx: 2,
        ry: 2,
        strokeColor: Colors.purpleAccent,
        /*transform: Matrix4.identity()..rotateZ(45.hd),*/
        transform: Matrix4.identity()..scale(2.0, 1.0),
      );
      builder.writeRect(
        width: 20,
        height: 10,
        rx: 2,
        ry: 2,
        strokeColor: Colors.redAccent,
        /*transform: Matrix4.identity()..rotateZ(45.hd),*/
        transform: Matrix4.identity()..scale(1.0, 2.0),
      );
      builder.writeRect(
        width: 20,
        height: 10,
        rx: 2,
        ry: 2,
        strokeColor: Colors.blue,
        /*transform: Matrix4.identity()..rotateZ(45.hd),*/
        transform: Matrix4.identity()..rotateZ(45.hd),
      );

      /*final face = outputFile('face.jpg');
      final image = await face.toImage();
      builder.writeViewBox(
          Offset.zero & Size(image.width.toDouble(), image.height.toDouble()));
      await builder.writeImage(image);
      builder.writeText(
        "angcyo",
        y: 14,
        fontSize: 14,
        color: Colors.purple,
      );*/
    });
    await outputFile('output_face.svg').writeAsString(svg);
    consoleLog('...');
  });
}

File outputFile(String fileName) {
  final path = "${Directory.current.path}/test/output/$fileName";
  path.ensureParentDirectory();
  consoleLog('path:$path');
  return File(path);
}

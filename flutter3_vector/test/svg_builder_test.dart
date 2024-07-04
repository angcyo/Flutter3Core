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
      final face = outputFile('face.png');
      final image = await face.toImage();
      builder.writeViewBox(
          Offset.zero & Size(image.width.toDouble(), image.height.toDouble()));
      await builder.writeImage(image);
      builder.writeText(
        "angcyo",
        y: 14,
        fontSize: 14,
        color: Colors.purple,
      );
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

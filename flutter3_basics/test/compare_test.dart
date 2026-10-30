import 'dart:io';
import 'dart:math' as math;

import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/10/30
///
/// 文件对比测试
void main() {
  final leftPath = r"E:\易雕科技\KopLaser\QY_BR1.1_261030.bin";
  final rightPath = r"E:\易雕科技\KopLaser\QY_BR1.1.kpb";

  final leftBytes = File(leftPath).readAsBytesSync();
  final rightBytes = File(rightPath).readAsBytesSync();

  final maxLength = math.max(leftBytes.length, rightBytes.length);
  for (int i = 0; i < maxLength; i++) {
    final lb = leftBytes.getOrNull(i);
    final rb = rightBytes.getOrNull(i);
    if (lb == null || rb == null) {
      print(
        "第[$i] / [${leftBytes.length} : ${rightBytes.length}]个字节不同: ${lb?.toHex()} ${rb?.toHex()}",
      );
      break;
    }
  }

  print("...end");
}

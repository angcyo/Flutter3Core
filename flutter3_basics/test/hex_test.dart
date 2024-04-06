import 'dart:typed_data';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/06
///

void main() {
  test('test hex', () {
    final data = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    final hex = data.toHex();
    consoleLog(hex.fillHexSpace());
    consoleLog(10.toHex());
    consoleLog(10.toHex(2));
    consoleLog(1010.toHex(4));
    consoleLog("AABB".toHexBytes());
    consoleLog("AABB".toHexBytes().toHex());
  });

  test('test bytes', () {
    final bytes = bytesWriter((writer) {
      writer.writeHex("AABB");
      writer.writeString("AABB");
      writer.writeByte(1);
      writer.writeInt(2);
      writer.writeLong(3);
      writer.writeBytes([4, 5, 6, 7, 8, 9, 10]);
    });
    consoleLog(bytes.toHex().fillHexSpace());
    consoleLog(bytes.crc16().toHex(4));
  });
}

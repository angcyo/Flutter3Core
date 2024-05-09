import 'dart:typed_data';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/04/06
///

void main() {
  /*const str = "abc123ABC";
  consoleLog(str.codeUnits);
  consoleLog(String.fromCharCodes(str.codeUnits));
  consoleLog(String.fromCharCode(97));

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
  });*/

  /*test('test hex', () {
    consoleLog('7e2b7dfc'.toInt(radix: 16));
    consoleLog('00000001'.toInt(radix: 16));
    consoleLog('...');
  });*/

  test('test bytes', () {
    //定义一个字节数组
    final data = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    final hex = data.toHex();
    consoleLog(data);
    consoleLog(hex);

    /*consoleLog('${data.length}');
    consoleLog('${hex.length}');
    consoleLog('${200.toHex()}');
    consoleLog('${200.toHex(4)}');*/

    final data2 = 65535.toBytes(4);
    consoleLog(data2);
    consoleLog(data2.toInt(4));

    consoleLog('...end');
  });

  test('test string', () {
    const text = "AABB";
    consoleLog(text.substring(0)); //[)
    consoleLog(text.substring(2));
    consoleLog('${1 / 2}');
    consoleLog('${1 ~/ 2}');
    consoleLog('...end');
  });

  test('test ascii string', () {
    const int = 2116779516;
    const str = "7E2B7DFC";
    consoleLog(int.toAsciiString());
    consoleLog(str.toAsciiInt());
  });
}

import 'dart:io';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/05/09
///
/// 文件测试
void main() async {
  /*test('file test', () async {
    final file = File('test/file_test.dart');
    consoleLog(file.readLastStringSync(100));

    */ /*final accessFile = await file.open();

    accessFile.setPositionSync(accessFile.lengthSync() - 100);
    consoleLog(accessFile.readSync(100).toStr().lines().reversed.join('\n'));

    consoleLog(accessFile.positionSync());
    consoleLog(accessFile.lengthSync());*/ /*

    */ /*final lines = await file.readAsLines();
    consoleLog(lines);*/ /*
  });*/
  await convertFileByteToHex(
    r"E:\temp\image 3-image-stucki-1784098578771.100x100.rgb565a8",
    r"E:\temp\image 3-image-stucki-1784098578771.100x100.rgb565a8.hex",
  );
  await convertFileByteToHex(
    r"E:\temp\image 3-image-stucki-1784098257693.10x5.rgb565a8",
    r"E:\temp\image 3-image-stucki-1784098257693.10x5.rgb565a8.hex",
  );
  await convertFileByteToHex(
    r"E:\temp\image 3-image-stucki-1784100722195.100x100.rgb565a8",
    r"E:\temp\image 3-image-stucki-1784100722195.100x100.rgb565a8.hex",
  );
}

/// 将文件字节数据转成十六进制字符串数组,写入到文件
Future<void> convertFileByteToHex(String filePath, String toFilePath) async {
  final file = File(filePath);
  final toFile = File(toFilePath);
  await toFile.deleteSafe();
  await toFile.create();

  final bytes = await file.readAsBytes();
  for (var i = 0; i < bytes.length; i++) {
    final hex = bytes[i].toHex();
    toFile.writeAsStringSync('0x$hex,', mode: FileMode.append);
  }
}

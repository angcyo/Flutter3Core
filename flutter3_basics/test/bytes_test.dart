import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/04/17
///
void main() {
  /*print(bytesWriter((writer) {
    writer.writeFillHex(length: 100);
  }).utf8Str);*/

  print("Y".ascii);
  print("D".ascii);

  print("YDMG".bytes.toHex());
  print("YDMG".asciiBytes.toHex());
}

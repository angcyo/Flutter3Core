import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/26
///
void main() {
  test('test bit', () {
    for (var i = 0; i < 8; i++) {
      int byteLength = i;
      int value = (1 << 8 * byteLength) - 1;
      print("[$i]个字节能表示最大数值->$value");
    }
  });

  int n = 0xFFFFFFFF;
  print(n);
  print(n.bits(8, 2));
}

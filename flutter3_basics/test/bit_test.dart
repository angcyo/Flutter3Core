import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/26
///
void main() {
  /*test('test bit', () {
    for (var i = 0; i < 8; i++) {
      int byteLength = i;
      int value = (1 << 8 * byteLength) - 1;
      print("[$i]个字节能表示最大数值->$value");
    }
  });

  int n = 0xFFFFFFFF;
  print(n);
  print(n.bits(8, 2));*/

  /*test("test set bits", () {
    //print("${0.setBits(0, 1, 1)}");
    //print("${0.setBits(0, 2, 1)}");
    print(15.toRadixString(2));
    print(0.setBits(0, 4, 0xffffffff).toRadixString(2));
    print("...");
  });*/

  test("test set bit", () {
    //print("${0.setBits(0, 1, 1)}");
    //print("${0.setBits(0, 2, 1)}");
    //print(15.toRadixString(2));
    print(0.setBit(0, 1).toRadixString(2));// 1
    print(0.setBit(1, 1).toRadixString(2));// 1
    print(0.setBit(2, 1).toRadixString(2));// 10
    print(0.setBit(3, 1).toRadixString(2));// 100
    print(0xffffffff.setBit(1, 0).toRadixString(2));// 11111111111111111111111111111110
    print(0xffffffff.setBit(2, 0).toRadixString(2));// 11111111111111111111111111111101
    print(0xffffffff.setBit(3, 0).toRadixString(2));// 11111111111111111111111111111011
    print(0xffffffff.setBit(4, 0).toRadixString(2));// 11111111111111111111111111110111
    print(0xffffffff.setBits(3, 4, 0).toRadixString(2));// 11111111111111111111111111110000
    print(0.setBits(3, 4, 0xffffffff).toRadixString(2));// 1111
    print(0.setBits(4, 4, 0xffffffff).toRadixString(2));// 11110
    print(0.setBits(5, 4, 0xffffffff).toRadixString(2));// 111100
    print("...");
  });
}

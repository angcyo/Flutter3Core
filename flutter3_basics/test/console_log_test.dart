import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// Email:angcyo@126.com
/// @author angcyo
/// @date 2024/08/10
///
void main() {
  test('color', () {
    const index = 2;
    if (index == 0) {
      for (var i = 0; i < 120; i++) {
        consoleFgColorLog("$i " * 30, i);
      }
    } else if (index == 1) {
      for (var i = 120; i < 214; i++) {
        consoleFgColorLog("$i " * 30, i);
      }
    } else {
      for (var i = 214; i < 256; i++) {
        consoleFgColorLog("$i " * 30, i);
      }
    }
  });
}

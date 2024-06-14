import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/14
///
void main() {
  test('...colors', () {
    const size = 4;
    consoleLog('${[for (var i = 0; i < size; i++) i * (1 / (size - 1))]}');
  });
}

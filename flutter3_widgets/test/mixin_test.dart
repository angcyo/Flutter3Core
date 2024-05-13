import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/13
///

void main() {
  test('mixin test', () {
    MixinTest test = Test("123", "abc");

    print('${test.label}');
    print('${test.label2}');
    print('$test');
    print('...end');
  });
}

mixin MixinTest {
  late final String? label;
  late final String label2;
}

class Test with MixinTest {
  final String? label;
  final String label2;

  Test(this.label, this.label2);
}

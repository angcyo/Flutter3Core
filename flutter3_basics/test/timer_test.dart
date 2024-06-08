import 'dart:async';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/06/08
///
void main() {
  test('test timer', () async {
    consoleLog('...start');
    var duration = const Duration(seconds: 10);
    Timer.periodic(const Duration(seconds: 10), (timer) {
      consoleLog(duration);
    });
    await futureDelay(const Duration(seconds: 30));
    consoleLog('...end');
    return true;
  });
}

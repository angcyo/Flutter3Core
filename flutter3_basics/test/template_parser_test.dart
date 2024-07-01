import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/07/01
///
void main() {
  test("test", () {
    //final result = "{{year}}1{{month}}".parseDateTemplate();
    final result = "yyyy{{year}}MM{{month}}".parseDateTemplate();
    consoleLog(result);
    consoleLog("...end");
  });
}

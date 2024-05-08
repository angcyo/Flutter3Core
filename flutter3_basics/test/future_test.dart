import 'package:flutter3_basics/flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/08
///

void main() async {
  final f1 = future(() => consoleLog('..1'));
  final f2 = asyncFuture((completer) {
    delayCallback(() {
      consoleLog('..2');
      completer.complete();
    });
  });
  consoleLog('...end');

  await f1;
  await f2;
}

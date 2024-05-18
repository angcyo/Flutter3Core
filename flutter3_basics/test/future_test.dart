import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/05/08
///

void main() async {
  /*final f1 = future(() => consoleLog('..1'));
  final f2 = asyncFuture((completer) {
    delayCallback(() {
      consoleLog('..2');
      completer.complete();
    });
  });
  consoleLog('...end');

  await f1;
  await f2;*/

  final futureTest = FutureTest();

  for (var i = 0; i < 5; i++) {
    //future(() async =>  futureTest.test());
    futureTest.test();
  }

  await futureDelay(10.seconds);
}

class FutureTest {

  int index = 0;

  Future test() async {
    await future((){
      if(index == 0){
        consoleLog('..${index++}');
      }
    });
    //consoleLog('..${index++}');
    consoleLog('...end:$index');
  }
}

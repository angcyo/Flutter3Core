import 'dart:async';

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

  test('test future1', () async {
    final futureTest = FutureTest();

    for (var i = 0; i < 5; i++) {
      //future(() async =>  futureTest.test());
      futureTest.test();
    }

    await futureDelay(10.seconds);

    consoleLog('...end test:${futureTest.index}');
  });

  test('test future2', () async {
    final futureTest = FutureTest2();

    for (var i = 0; i < 5; i++) {
      //future(() async =>  futureTest.test());
      futureTest.test(Completer()).then((value) {
        consoleLog('...value:$value');
      });
    }
    consoleLog('...test:${futureTest.index}');

    await futureDelay(10.seconds);

    consoleLog('...end test:${futureTest.index}');
  });

  test('test future3', () async {
    final futureTest = FutureTest3();

    for (var i = 0; i < 5; i++) {
      //future(() async =>  futureTest.test());
      futureTest.test(false).then((value) {
        consoleLog('...value:$value');
      });
    }
    consoleLog('...test:${futureTest.index}');

    await futureDelay(10.seconds);

    consoleLog('...end test:${futureTest.index}');
  });

  test('test future', () async {
    futureDelay(1.seconds, () {
      consoleLog('..1');
    });

    await futureDelay(10.seconds);
  });

  await futureDelay(10.seconds);
}

class FutureTest {
  int index = 0;

  Future test() async {
    await future(() {
      if (index == 0) {
        consoleLog('..${index++}');
      }
    });
    //consoleLog('..${index++}');
    consoleLog('...end:$index');
  }
}

class FutureTest2 {
  int index = 0;

  Future test(Completer completer) async {
    futureDelay(1.seconds, () async {
      //if (index == 0) {
      consoleLog('..${index++}');
      //}

      if (index == 2) {
        await futureDelay(3.seconds, () {
          completer.complete(index);
        });
      } else {
        completer.complete(index);
      }
    });
    //consoleLog('..${index++}');
    consoleLog('...end:$index');
    return completer.future;
  }
}

class FutureTest3 {
  int index = 0;

  Future test(bool sync) async {
    if (sync) {
      final int = index++;
      consoleLog('开始请求:$int');
      await futureDelay(1.seconds, () {
        consoleLog('请求...:$int');
      });
      consoleLog('请求结束:$int');
      return int;
    } else {
      Completer completer = Completer();
      final int = index++;
      consoleLog('开始请求:$int');
      futureDelay(1.seconds, () {
        consoleLog('请求...:$int');
        consoleLog('请求结束:$int');
        completer.complete(int);
      });
      return completer.future;
    }
  }
}

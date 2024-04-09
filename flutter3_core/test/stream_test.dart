import 'dart:async';

import 'package:flutter3_core/flutter3_core.dart';
import 'package:flutter_test/flutter_test.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2024/04/09
///

void main() {
  test('test stream', () {
    /// 普通的控制器只能有1个监听者
    final control1 = StreamController();

    /// 广播控制器可以有多个监听者
    final control2 = StreamController.broadcast();

    control1.stream.listen(
      (event) {
        consoleLog('控制器1-1-收到: $event');
      },
      onError: (error) {
        consoleLog('控制器1-1-收到error: $error');
      },
    );
    //Bad state: Stream has already been listened to.
    /*control1.stream.listen((event) {
      consoleLog('control1_2: $event');
    });*/

    /// 只监听第一个事件
    control2.stream.first.get((value, error) {
      consoleLog('控制器first收到: $value');
    });

    /// 只监听最后一个事件, 在close之后, 会收到最后一个事件
    control2.stream.last.get((value, error) {
      consoleLog('控制器last收到: $value');
    });

    control2.stream.listen((event) {
      consoleLog('控制器2-1-收到: $event');
    });

    control2.stream.listen((event) {
      consoleLog('控制器2-2-收到: $event');
    });

    control1.add('事件1111_1');
    /// 发送一个错误之后, 如果没有处理错误, 则会抛出这个错误
    /// 如果处理了, 则正常流程
    /// 发送错误之后, 依旧可以正常发送数据
    control1.addError("test...error");
    control1.add('事件1111_2');
    control2.add('事件2222_1');
    control2.add('事件2222_2');

    control1.close();
    //control2.close();

    //Bad state: Cannot add event after closing
    //control1.add('1111...');

    //Bad state: Cannot add new events after calling close
    //control2.add('1111...');

    control2.stream.listen((event) {
      consoleLog('控制器2-3-收到: $event');
    });
    control2.add('1111...1');

    control2.close();
    consoleLog('...end');
    return true;
  });
}

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/05
///
void main() async {
  // 获取当前 Isolate
  print('Main Isolate Name: ${Isolate.current.debugName}');

  // 使用 compute 函数创建新的 Isolate
  //await compute(isolateFunction, 'Hello from main isolate!');
  await Isolate.spawn(isolateFunction, 'Hello from main isolate!');
  final map = await Isolate.run(isolateFunction2, debugName: 'isolate2');
  print(map);
  await Isolate.spawn(isolateFunction3, TestDataClass());
  await testIsolate();

  //等待
  await Future.delayed(Duration(seconds: 5));
  print("...end");
}

/// 支持收发
void isolateFunction(String message) {
  print('Isolate Name: ${Isolate.current.debugName}');
  print(message);
}

/// 支持收发
FutureOr<Map<String, dynamic>> isolateFunction2() async {
  print('Isolate Name: ${Isolate.current.debugName}');
  return {
    "name": "angcyo",
    "age": 18,
    "man": true,
    "list": ["1", 1, true],
    "map": {
      "a": "a",
      "1": 1,
      'bool': true,
    }
  };
}

/// 支持收发
TestDataClass isolateFunction3(TestDataClass message) {
  print('Isolate Name: ${Isolate.current.debugName}');
  print(message);
  return message;
}

/// 支持收发
Future testIsolate() async {
  final data = TestDataClass();
  final map =
      await Isolate.run(() => isolateFunction3(data), debugName: 'isolate2');
  print("testIsolate->$map");
  final map2 = await compute((data) async {
    return data;
  }, data);
  print("testIsolate2->$map2");
}

//--

/// `SendPort ` 支持的 Message types  消息类型
/// https://dart.dev/language/concurrency#message-types
///
/// `SendPort.send ` 可以发送的对象
/// https://api.dart.dev/dart-isolate/SendPort/send.html
class TestDataClass {
  final String name;
  final int age;
  final bool man;
  final List<dynamic> list;
  final Map<String, dynamic> map;

  TestDataClass({
    this.name = "name",
    this.age = 0,
    this.man = true,
    this.list = const ["1", 1, true],
    this.map = const {
      "a": "a",
      "1": 1,
      'bool': true,
    },
  });

  @override
  String toString() {
    return 'TestDataClass{name: $name, age: $age, man: $man, list: $list, map: $map}';
  }
}
